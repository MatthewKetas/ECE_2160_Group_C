import argparse
import contextlib
import csv
import io
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock

HERE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(HERE))
import analyze
import collect

BINARY = None
MATRIX = None


def row(slot, start=-1, acquired=-1, saved=-1, finish=-1, ok=1):
    return dict(slot=slot, release_ns=slot * 100_000_000,
                start_ns=start * 1_000_000 if start >= 0 else -1,
                acquired_ns=acquired * 1_000_000 if acquired >= 0 else -1,
                saved_ns=saved * 1_000_000 if saved >= 0 else -1,
                finish_ns=finish * 1_000_000 if finish >= 0 else -1,
                cpu_ns=1_000_000 if start >= 0 else -1,
                read_ok=ok if start >= 0 else 0, save_ok=ok if start >= 0 else 0,
                filter_ok=ok if start >= 0 else 0, source=2, outlier=0)


class MetricsTests(unittest.TestCase):
    def test_gnu_time_fields(self):
        values = analyze.time_metrics("\tUser time (seconds): 0.23\n\tSystem time (seconds): 0.04\n"
            "\tElapsed (wall clock) time (h:mm:ss or m:ss): 1:02.50\n\tInvoluntary context switches: 7\n")
        self.assertEqual(values["process_elapsed_s"], 62.5)
        self.assertEqual(values["process_involuntary_switches"], 7)
        self.assertEqual(values["process_user_s"], .23)
    def test_late_skipped_and_successful_cycles(self):
        info = dict(duration_ns=400_000_000, period_ns=100_000_000, deadline_ns=100_000_000)
        rows = [row(0, 5, 10, 15, 20), row(1, 110, 150, 160, 250), row(2), row(3, 305, 310, 320, 330)]
        result = analyze.metrics(info, rows)
        self.assertEqual(result["deadline_miss_pct"], 50)
        self.assertEqual(result["response_median_ms"], 30)
        self.assertEqual(result["response_p99_ms"], 150)
        self.assertEqual(result["max_observed_lateness_ms"], 50)
        self.assertEqual(result["max_acquisition_gap_ms"], 160)
        self.assertEqual(result["longest_miss_streak"], 2)
        self.assertEqual(result["skipped_cycles"], 1)

    def test_deadline_equality_and_outlier_are_success(self):
        info = dict(duration_ns=100_000_000, period_ns=100_000_000, deadline_ns=100_000_000)
        r = row(0, 0, 1, 2, 100)
        r["outlier"] = 1
        self.assertEqual(analyze.metrics(info, [r])["deadline_misses"], 0)

    def test_failed_reads_do_not_create_an_acquisition(self):
        info = dict(duration_ns=100_000_000, period_ns=100_000_000, deadline_ns=100_000_000)
        result = analyze.metrics(info, [row(0, 0, finish=10, ok=0)])
        self.assertEqual(result["max_acquisition_gap_ms"], 100)
        self.assertEqual(result["successful_reads"], 0)
        self.assertEqual(result["deadline_miss_pct"], 100)

    def test_missing_slots_and_bad_grid_are_rejected(self):
        info = dict(duration_ns=200_000_000, period_ns=100_000_000, deadline_ns=100_000_000)
        with self.assertRaises(ValueError):
            analyze.metrics(info, [row(0)])
        rows = [row(0), row(1)]
        rows[1]["release_ns"] = 1
        with self.assertRaises(ValueError):
            analyze.metrics(info, rows)

    def test_failed_run_is_retained(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            run = root / "failed"
            run.mkdir()
            (run / "metadata.json").write_text(json.dumps(dict(condition="baseline", status="failed", error="timeout")))
            results = analyze.analyze(root)
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0]["run_status"], "failed")
            with (root / "condition_summary.csv").open() as f:
                self.assertEqual(next(csv.DictReader(f))["runs_valid"], "0")

    def test_legacy_and_boot_core_methods_are_not_pooled(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name, extra in (("old", {}), ("new", {"core_method": "boot"})):
                folder = root / name
                folder.mkdir()
                (folder / "metadata.json").write_text(json.dumps(
                    dict(condition="baseline", status="failed", error="setup failed", **extra)))
            analyze.analyze(root)
            with (root / "condition_summary.csv").open() as file:
                groups = list(csv.DictReader(file))
            self.assertEqual({g["core_method"] for g in groups}, {"legacy", "boot"})
            self.assertEqual(len(groups), 2)


class PlanAndConfigurationTests(unittest.TestCase):
    def test_all_requested_conditions_and_repetition_blocks(self):
        native = collect.condition_plan()
        self.assertEqual(len(native), 30)
        reduced = [r for cores in (3, 2, 1)
                   for r in collect.condition_plan(family="cores", cores=cores)]
        plan = native + reduced
        self.assertEqual(len(plan), 39)
        self.assertEqual(len(reduced) + sum(len(collect.condition_plan(ram)) for ram in ("8", "4", "2", "1.5")), 48)
        self.assertEqual(native, collect.condition_plan())
        self.assertTrue(all(r["cores"] == 4 and r["core_method"] == "boot" for r in native))
        self.assertEqual({r["cores"] for r in plan}, {1, 2, 3, 4})
        self.assertEqual({r["governor"] for r in plan}, {"performance", "powersave", "ondemand"})
        self.assertEqual({r["nice"] for r in plan if r["matrix"]}, {-10, 0, 10, 19})
        self.assertEqual({r["network_mbit"] for r in plan}, {0, 10, 50})
        self.assertTrue(all(r["pinned"] for r in plan if r["matrix"]))
        for rep in range(1, 4):
            block = [r["condition"] for r in plan if r["repetition"] == rep]
            self.assertEqual(len(block), len(set(block)))
            self.assertEqual(len(block), 13)

    def test_ram_changes_only_ram(self):
        for ram in ("4", "2", "1.5"):
            plan = collect.condition_plan(ram, "ram")
            self.assertEqual(len(plan), 3)
            self.assertTrue(all(r["cores"] == 4 and r["governor"] == "performance" and not r["matrix"]
                                and not r["network_mbit"] and r["nice"] == 0 for r in plan))
        with self.assertRaises(ValueError):
            collect.condition_plan("2", "priority")

    def test_boot_edit_preserves_other_options(self):
        original = "console=serial0,115200 root=PARTUUID=123 rootwait quiet mem=4G\n"
        result = collect.change_cmdline(original, "1.5")
        self.assertEqual(result, "console=serial0,115200 root=PARTUUID=123 rootwait quiet mem=1536M\n")
        self.assertNotIn("mem=", collect.change_cmdline(result, "8"))
        self.assertEqual(collect.change_cmdline(result, "1.5"), result)
        with self.assertRaises(ValueError):
            collect.change_cmdline("root=x\nsecond line\n", "4")

    def test_configuration_restores_after_treatment(self):
        with tempfile.TemporaryDirectory() as tmp, mock.patch.object(collect, "CPU", Path(tmp)):
            cpu = Path(tmp)
            for i in range(1, 4):
                (cpu / f"cpu{i}").mkdir()
                (cpu / f"cpu{i}/online").write_text("0" if i == 3 else "1")
            policy = cpu / "cpufreq/policy0"
            policy.mkdir(parents=True)
            initial = dict(scaling_governor="ondemand", scaling_min_freq="1500000", scaling_max_freq="1800000",
                           cpuinfo_min_freq="1000000", cpuinfo_max_freq="2400000",
                           scaling_available_governors="performance powersave ondemand")
            for name, value in initial.items():
                (policy / name).write_text(value)
            (policy / "affected_cpus").write_text("0 1 2")
            state = collect.snapshot()
            collect.configure(dict(cores=3, governor="powersave"))
            self.assertEqual(collect.online_cpus(), [0, 1, 2])
            self.assertEqual((policy / "scaling_max_freq").read_text().strip(), "2400000")
            collect.restore(state)
            self.assertEqual(collect.snapshot(), state)

    def test_core_setup_requires_boot_and_never_writes_hotplug(self):
        with mock.patch.object(collect, "online_cpus", return_value=[0, 1, 2]), \
             mock.patch.object(collect, "read", return_value="root=x maxcpus=3"), \
             mock.patch.object(Path, "write_text") as write:
            collect.check_cores(3, boot=True)
            write.assert_not_called()
            with self.assertRaisesRegex(RuntimeError, "set 'cores 4' and reboot"):
                collect.configure(dict(cores=4, governor="performance"))
            with mock.patch.object(collect, "read", return_value="root=x"):
                with self.assertRaisesRegex(RuntimeError, "accidentally offline"):
                    collect.check_cores(3, boot=True)

    def test_core_plan_cannot_change_other_factors(self):
        for ram, family in (("8", "all"), ("8", "network"), ("4", "cores")):
            with self.assertRaises(ValueError):
                collect.condition_plan(ram=ram, family=family, cores=2)

    def test_inactive_policy_is_excluded_from_setup_and_telemetry(self):
        with tempfile.TemporaryDirectory() as tmp, mock.patch.object(collect, "CPU", Path(tmp)):
            policy = Path(tmp) / "cpufreq/policy3"
            policy.mkdir(parents=True)
            (policy / "affected_cpus").write_text("\n")
            (policy / "scaling_governor").write_text("powersave")
            self.assertEqual(collect.snapshot()["policies"], {})
            self.assertEqual(collect.telemetry()["policies"], {})
            with self.assertRaisesRegex(RuntimeError, "no active"):
                collect.configure(dict(cores=4, governor="performance"))

    def test_boot_core_and_ram_edits_preserve_each_other(self):
        original = "console=tty1 root=x rootwait mem=4G maxcpus=2\n"
        edited = collect.change_cmdline(original, cores=3)
        self.assertIn("mem=4G", edited)
        self.assertIn("maxcpus=3", edited)
        edited = collect.change_cmdline(edited, ram="1.5")
        self.assertIn("maxcpus=3", edited)
        self.assertIn("mem=1536M", edited)
        self.assertNotIn("maxcpus=", collect.change_cmdline(edited, cores=4))

    def test_boot_helpers_share_backup_and_restore_original(self):
        with tempfile.TemporaryDirectory() as tmp, mock.patch.object(collect, "require_pi"), \
             mock.patch.object(collect.os, "sync", create=True), contextlib.redirect_stdout(io.StringIO()):
            path = Path(tmp) / "cmdline.txt"
            original = "console=tty1 root=x rootwait\n"
            path.write_text(original)
            args = argparse.Namespace(action="cores", value="3", cmdline=path)
            collect.boot_change(args)
            self.assertIn("maxcpus=3", path.read_text())
            args.action, args.value = "ram", "4"
            collect.boot_change(args)
            self.assertIn("maxcpus=3", path.read_text())
            self.assertIn("mem=4G", path.read_text())
            args.value = "restore"
            collect.boot_change(args)
            self.assertEqual(path.read_text(), original)
            path.write_text(original.strip() + " new_option=1\n")
            with self.assertRaisesRegex(RuntimeError, "other boot options changed"):
                collect.boot_change(args)

    def test_rejected_control_write_identifies_path_and_value(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "online"
            path.write_text("1\n")
            with mock.patch.object(Path, "write_text", side_effect=OSError(22, "Invalid argument")):
                with self.assertRaisesRegex(RuntimeError, "cannot write '0'.*online.*previous='1'"):
                    collect.write_control(path, "0")

    def test_restore_does_not_retry_broken_cpu_hotplug(self):
        with mock.patch.object(collect, "online_cpus", return_value=[0, 1, 2]), \
             mock.patch.object(collect, "write_control") as write:
            with self.assertRaisesRegex(RuntimeError, "reboot to recover"):
                collect.restore({"online": [0, 1, 2, 3], "policies": {}})
            write.assert_not_called()

    def test_non_pi_cannot_mutate_configuration(self):
        with mock.patch.object(collect.platform, "system", return_value="Darwin"):
            with self.assertRaises(RuntimeError):
                collect.require_pi(root=True)

    def test_startup_as_process_group_leader_needs_no_new_session(self):
        state = {"online": [0, 1, 2, 3], "policies": {"policy0": {
            "scaling_governor": "performance", "scaling_min_freq": "1000000",
            "scaling_max_freq": "2400000", "cpuinfo_min_freq": "1000000",
            "cpuinfo_max_freq": "2400000", "scaling_available_governors": "performance"}}}
        with tempfile.TemporaryDirectory() as tmp, contextlib.ExitStack() as stack:
            args = argparse.Namespace(ram="8", cores=4, family="ram", repetitions=1, seed=2160,
                source="data", binary=Path("/usr/bin/true"), input=HERE / "input.csv",
                matrix=Path(tmp) / "absent-matrix", results=Path(tmp) / "results")
            # sudo can create a process-group leader that is not a session leader.
            for name, value in (("getpid", 42), ("getpgrp", 42), ("getsid", 1), ("sched_getscheduler", 0)):
                stack.enter_context(mock.patch.object(collect.os, name, return_value=value, create=True))
            stack.enter_context(mock.patch.object(collect.os, "SCHED_OTHER", 0, create=True))
            setsid = stack.enter_context(mock.patch.object(collect.os, "setsid", side_effect=PermissionError(1, "Operation not permitted")))
            stack.enter_context(mock.patch.object(collect, "require_pi"))
            stack.enter_context(mock.patch.object(collect, "identity", return_value=(os.getuid(), os.getgid(), "unused")))
            stack.enter_context(mock.patch.object(collect, "online_cpus", return_value=[0, 1, 2, 3]))
            stack.enter_context(mock.patch.object(collect, "memory_check", return_value=7.8))
            stack.enter_context(mock.patch.object(collect, "snapshot", return_value=state))
            stack.enter_context(mock.patch.object(collect, "command_output", return_value={"returncode": 0}))
            stack.enter_context(mock.patch.object(collect.os, "chown"))
            one_run = stack.enter_context(mock.patch.object(collect, "one_run"))
            restore = stack.enter_context(mock.patch.object(collect, "restore"))
            stack.enter_context(contextlib.redirect_stdout(io.StringIO()))
            collect.run(args)
            one_run.assert_called_once()
            setsid.assert_not_called()
            one_run.side_effect = RuntimeError("original core failure")
            restore.side_effect = RuntimeError("secondary restoration failure")
            with contextlib.redirect_stderr(io.StringIO()), self.assertRaisesRegex(RuntimeError, "original core failure"):
                collect.run(args)

    def test_setup_failure_still_restores_settings_and_records_failure(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            args = argparse.Namespace(source="data", schedule="periodic", binary=HERE / "input.csv",
                                      input=HERE / "input.csv", duration=1, period_ms=100, deadline_ms=100)
            condition = collect.condition_plan(repetitions=1)[0]
            account = (os.getuid(), os.getgid(), "unused")
            with mock.patch.object(collect, "configure", side_effect=RuntimeError("configuration failed")), \
                 mock.patch.object(collect.os, "chown"), mock.patch.object(collect, "restore") as restore, \
                 mock.patch.object(collect, "snapshot", return_value={"online": [0, 1, 2, 3]}):
                with self.assertRaisesRegex(RuntimeError, "configuration failed"):
                    collect.one_run(args, condition, root / "run", account, {"original": True})
                restore.assert_called_once_with({"original": True})
            metadata = json.loads((root / "run/metadata.json").read_text())
            self.assertEqual(metadata["status"], "failed")
            self.assertIn("configuration failed", metadata["error"])

    def test_run_and_restoration_errors_are_both_preserved(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            args = argparse.Namespace(source="data", schedule="periodic", binary=HERE / "input.csv",
                                      input=HERE / "input.csv", duration=1, period_ms=100, deadline_ms=100)
            condition = collect.condition_plan(repetitions=1)[0]
            with mock.patch.object(collect, "configure", side_effect=RuntimeError("CPU3 offline failed")), \
                 mock.patch.object(collect.os, "chown"), \
                 mock.patch.object(collect, "restore", side_effect=RuntimeError("CPU3 online failed")):
                with self.assertRaisesRegex(RuntimeError, "CPU3 offline failed; restoration also failed: CPU3 online failed"):
                    collect.one_run(args, condition, root / "run", (os.getuid(), os.getgid(), "unused"), {})
            metadata = json.loads((root / "run/metadata.json").read_text())
            self.assertEqual(metadata["error"], "CPU3 offline failed")
            self.assertEqual(metadata["restoration_error"], "CPU3 online failed")

    def test_governor_mismatch_saves_observed_configuration(self):
        configured = {"online": [0, 1, 2, 3], "policies": {
            "/mock/policy0": {"scaling_governor": "powersave"}}}
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            args = argparse.Namespace(source="data", schedule="periodic", binary=HERE / "input.csv",
                input=HERE / "input.csv", duration=1, period_ms=100, deadline_ms=100, settle=0)
            condition = collect.condition_plan(family="ram", repetitions=1)[0]
            with mock.patch.object(collect, "configure"), mock.patch.object(collect, "check_cores"), \
                 mock.patch.object(collect.os, "chown"), mock.patch.object(collect, "restore"), \
                 mock.patch.object(collect, "snapshot", return_value=configured):
                with self.assertRaisesRegex(RuntimeError, "policy0: requested governor 'performance', observed 'powersave'"):
                    collect.one_run(args, condition, root / "run", (os.getuid(), os.getgid(), "unused"), configured)
            metadata = json.loads((root / "run/metadata.json").read_text())
            self.assertEqual(metadata["configured"], configured)
            self.assertEqual(metadata["status"], "failed")


class ExecutableTests(unittest.TestCase):
    def test_periodic_pipeline_and_input_output_separation(self):
        if BINARY is None:
            self.skipTest("pass --binary to exercise the compiled pipeline")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            input_path = root / "input.csv"
            content = "timestamp_s,temperature_c\n1,29.75\n"
            input_path.write_text(content)
            subprocess.run([str(BINARY), "--output", str(root), "--input", str(input_path),
                            "--duration", "1", "--period-ms", "20", "--deadline-ms", "20"], check=True, timeout=10)
            info = json.loads((root / "experiment.json").read_text())
            with (root / "timing.csv").open() as f:
                rows = [{k: int(v) for k, v in r.items()} for r in csv.DictReader(f)]
            result = analyze.metrics(info, rows)
            self.assertEqual(result["scheduled_cycles"], 50)
            self.assertGreater(result["successful_reads"], 0)
            self.assertFalse(info["operation_failed"])
            self.assertTrue(info["analysis_ok"])
            self.assertEqual(input_path.read_text(), content)
            with (root / "samples.csv").open() as f:
                self.assertTrue(all(float(r["temperature_c"]) == 29.75 for r in csv.DictReader(f)))

    def test_failed_source_produces_auditable_failure(self):
        if BINARY is None:
            self.skipTest("pass --binary to exercise the compiled pipeline")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            result = subprocess.run([str(BINARY), "--output", str(root), "--input", str(root / "missing.csv"),
                                     "--duration", "0.2"], timeout=10)
            self.assertEqual(result.returncode, 1)
            info = json.loads((root / "experiment.json").read_text())
            self.assertTrue(info["operation_failed"])
            self.assertEqual(analyze.analyze(root)[0]["deadline_miss_pct"], 100)

    def test_relative_schedule_remains_measurable(self):
        if BINARY is None:
            self.skipTest("pass --binary to exercise the compiled pipeline")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run([str(BINARY), "--output", str(root), "--input", str(HERE / "input.csv"),
                            "--duration", "0.3", "--schedule", "relative"], check=True, timeout=10)
            self.assertEqual(json.loads((root / "experiment.json").read_text())["schedule"], "relative")
            self.assertEqual(analyze.analyze(root)[0]["scheduled_cycles"], 3)

    def test_matrix_source_executes(self):
        if MATRIX is None:
            self.skipTest("pass --matrix to exercise the instructor workload")
        result = subprocess.run([str(MATRIX)], capture_output=True, text=True, timeout=90)
        self.assertEqual(result.returncode, 0)
        self.assertIn("Multiplication complete.", result.stdout)

    def test_background_process_group_cleanup(self):
        process = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(30)"], start_new_session=True)
        try:
            collect.stop(process)
            self.assertIsNotNone(process.poll())
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path)
    parser.add_argument("--matrix", type=Path)
    args, remaining = parser.parse_known_args()
    BINARY, MATRIX = args.binary, args.matrix
    unittest.main(argv=[sys.argv[0]] + remaining)
