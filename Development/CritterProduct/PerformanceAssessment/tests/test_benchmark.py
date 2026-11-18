"""Check hardware capture handling using a sensor fixture at the driver boundary."""

import csv
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch


HERE = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("benchmark", HERE / "benchmark.py")
BENCH = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BENCH)

TEST_SENSOR = r'''
#include "sense_hat_environment.h"
#include <stdlib.h>
int sense_hat_environment_init(sense_hat_environment_t *s, const char *d,
    sense_hat_hts_odr_t h, sense_hat_pressure_odr_t p)
{
    (void)d; (void)h; (void)p;
    s->initialized = getenv("TEST_SENSOR_FAIL") == NULL;
    return s->initialized ? 0 : -1;
}
int sense_hat_environment_read(sense_hat_environment_t *s, sense_hat_environment_reading_t *r)
{
    if (!s->initialized) return -1;
    r->temperature_c = strtod(getenv("TEST_SENSOR_BASE"), NULL);
    r->humidity_percent = 32.123456789;
    r->pressure_hpa = 982.123456789;
    return 0;
}
void sense_hat_environment_close(sense_hat_environment_t *s) { s->initialized = false; }
'''


@unittest.skipUnless(shutil.which("cc"), "A C compiler is required")
class HardwareCaptureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="critter_capture_tests_")
        cls.directory = Path(cls.temp.name)
        sensor = cls.directory / "sensor.c"
        sensor.write_text(TEST_SENSOR)
        cls.programs = {}
        for unit, number in (("io", 1), ("pipeline", 4)):
            for variant in ("O0", "O2"):
                program = cls.directory / f"{unit}_{variant}"
                sources = [HERE / "benchmark.c", BENCH.PILOT / "IO/critter_io.c", sensor]
                if unit == "pipeline":
                    sources += BENCH.MEMORY + BENCH.COMPUTATION
                subprocess.run(["cc", "-Wall", "-Wextra", "-Werror", "-std=c11", "-ffp-contract=off",
                                f"-{variant}", f"-DBENCH_UNIT={number}", "-DBENCH_SENSOR_REAL=1",
                                "-I", str(BENCH.PILOT), "-I", str(BENCH.SENSE_HAT),
                                *map(str, sources), "-lm", "-o", str(program)],
                               check=True, capture_output=True, text=True)
                cls.programs[variant, unit] = program

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def test_live_values_and_timestamps_are_captured_and_checked(self):
        with tempfile.TemporaryDirectory(dir=self.directory) as folder:
            folder = Path(folder)
            for unit in ("io", "pipeline"):
                with self.subTest(unit=unit), patch.dict(os.environ, TEST_SENSOR_BASE="35.123456789"):
                    keep = folder / unit
                    result = BENCH.trial(self.programs["O2", unit], unit, "evaluate", 1, folder,
                                         keep=keep, sensor="sense-hat", oracle=self.programs["O0", unit])
                    self.assertEqual(result["sense_hat_samples"], 600)
                    self.assertEqual(result["validation"], "O0_same_capture")
                    with (keep / "samples.csv").open() as stream:
                        samples = list(csv.DictReader(stream))
                    self.assertEqual(len(samples), 600)
                    self.assertEqual(float(samples[0]["temperature_c"]), 35.123457)
                    self.assertGreater(float(samples[0]["timestamp_s"]), 1_000_000_000)
                    self.assertTrue(all(r["source"] == "sense_hat" for r in samples))
                    self.assertGreater((keep / "capture.bin").stat().st_size, 0)
                    checked = json.loads((keep / "O0_check.json").read_text())
                    self.assertEqual(result["samples_sha256"], checked["samples_sha256"])
                    if unit == "pipeline":
                        self.assertEqual(result["outliers"], 0)
                        self.assertEqual(result["metrics_sha256"], checked["metrics_sha256"])
                        self.assertAlmostEqual(result["prediction_checksum"], 35.123456789)

    def test_missing_sensor_stops_collection(self):
        with tempfile.TemporaryDirectory(dir=self.directory) as folder:
            with patch.dict(os.environ, TEST_SENSOR_BASE="35.0", TEST_SENSOR_FAIL="1"):
                with self.assertRaisesRegex(RuntimeError, "Sense HAT acquisition failed"):
                    BENCH.trial(self.programs["O0", "io"], "io", "evaluate", 1, Path(folder), sensor="sense-hat")

    def test_profile_training_and_lto_with_capture_validation(self):
        if not shutil.which("clang") or not shutil.which("xcrun"):
            self.skipTest("This profile-workflow check uses Xcode's Clang and llvm-profdata")
        with tempfile.TemporaryDirectory(dir=self.directory) as folder:
            folder = Path(folder)
            driver = folder / "driver"
            driver.mkdir()
            (driver / "sense_hat_environment.c").write_text(TEST_SENSOR)
            shutil.copyfile(BENCH.SENSE_HAT / "sense_hat_environment.h", driver / "sense_hat_environment.h")
            with patch.object(BENCH, "SENSE_HAT", driver), patch.dict(os.environ, TEST_SENSOR_BASE="35.123456789"):
                for unit in ("io", "pipeline"):
                    for variant in ("O2_pgo", "O2_lto"):
                        with self.subTest(unit=unit, variant=variant):
                            program = BENCH.build("clang", "clang", "objdump", ["xcrun", "llvm-profdata"],
                                                  variant, unit, folder, sensor="sense-hat",
                                                  oracle=self.programs["O0", unit])
                            result = BENCH.trial(program, unit, "evaluate", 1, folder, sensor="sense-hat",
                                                 oracle=self.programs["O0", unit])
                            self.assertEqual(result["sense_hat_samples"], 600)
                            self.assertEqual(result["validation"], "O0_same_capture")

    def test_optimized_output_difference_fails_the_check(self):
        with self.assertRaisesRegex(RuntimeError, "prediction_checksum differs"):
            BENCH.verify({"prediction_checksum": 22.0}, {"prediction_checksum": 23.0}, "O2", "pipeline")


if __name__ == "__main__":
    unittest.main()
