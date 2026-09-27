#!/usr/bin/env python3
"""Compare original and edited assembly on a 64-bit ARM Pi or Apple Silicon Mac.

Run from any directory: python3 PowerAssessment/asm/test_equivalence.py
Uses the system C compiler and temporary files; no third-party Python packages.
On macOS, also assembles every file as Linux ELF, then adapts only object-format
directives, symbol spelling and relocations for native execution of the tested
routines. This checks ARM results, not the Linux runtime or physical sensor I/O.
"""

import os
from pathlib import Path
import platform
import re
import shlex
import subprocess
import tempfile


def run(*args):
    subprocess.run(args, check=True)


def main():
    mac = platform.system() == "Darwin"
    if not mac and platform.system() != "Linux":
        raise SystemExit("This test supports macOS and Linux.")
    # On macOS, build explicitly for arm64: Python itself may run under Rosetta.
    if not mac and platform.machine().lower() not in ("arm64", "aarch64"):
        raise SystemExit("Run this test on a 64-bit ARM Pi or Apple Silicon Mac.")
    compiler = shlex.split(os.environ.get("CC", "clang" if mac else "gcc"))
    base = Path(__file__).resolve().parent
    repo = base.parents[1]
    with tempfile.TemporaryDirectory(prefix="critter-assembly-") as directory:
        work = Path(directory)
        native_files = []
        for version, prefix in (("original", "orig_"), ("edited", "edit_")):
            for source in sorted((base / version).glob("*.s")):
                target = ["--target=aarch64-linux-gnu"] if mac else []
                run(*compiler, *target, "-c", str(source), "-o",
                    str(work / (prefix + source.stem + ".elf.o")))
            for unit in ("critter_memory", "critter_computation", "pressure", "sleep"):
                symbol_prefix = "_" if mac else ""
                if unit == "pressure":
                    text = (base / version / "sense_hat_environment.s").read_text()
                    text = re.search(
                        r"^sense_hat_environment_read_pressure:\n.*?^\s*\.size\s+"
                        r"sense_hat_environment_read_pressure,[^\n]*",
                        text, re.M | re.S).group()
                    text = text.replace("sense_hat_environment_read_pressure", "pressure")
                    text = re.sub(r"\bread_register\b", "mock_read_register", text)
                elif unit == "sleep":
                    text = (base / version / "IO_main.s").read_text()
                    text = text.split(".L18:\n", 1)[1].split(
                        "// PowerAssessment/IO/IO_main.c:79:", 1)[0]
                    text = ("sleep:\n\tmov x9, x0\n\tsub sp, sp, #224\n"
                            "\tldr d31, .Lsleep_interval\n\tstr d31, [sp, 168]\n"
                            + text + "\tldp x0, x1, [sp, 64]\n\tstp x0, x1, [x9]\n"
                            "\tadd sp, sp, #224\n\tret\n\t.p2align 3\n"
                            ".Lsleep_interval:\n\t.double 0.1\n")
                else:
                    text = (base / version / (unit + ".s")).read_text()
                names = re.findall(r"^([a-zA-Z_]\w*):", text, re.M)
                for name in names:
                    text = re.sub(r"\b" + name + r"\b", symbol_prefix + prefix + name, text)
                for name in ("malloc", "calloc", "free", "memset", "sqrt", "mock_read_register"):
                    replacement = "mock_" + name if name in ("malloc", "calloc") else name
                    text = re.sub(r"\b" + name + r"\b", symbol_prefix + replacement, text)
                if mac:
                    lines = []
                    for line in text.splitlines():
                        if re.match(r"\s*\.(arch|file|type|size|ident|cfi\w*)\b", line):
                            continue
                        if re.match(r"\s*\.section\s+\.note", line):
                            continue
                        if re.match(r"\s*\.section\s+\.rodata", line):
                            line = "\t.section __TEXT,__const"
                        line = line.replace(".global", ".globl").replace(".L", "L")
                        line = re.sub(r"(\badrp\s+x\d+,\s*)([\w.]+)", r"\1\2@PAGE", line)
                        line = re.sub(r"#?:lo12:([\w.]+)", r"\1@PAGEOFF", line)
                        lines.append(line)
                    text = "\n".join(lines)
                exports = "\n".join("\t.globl " + symbol_prefix + prefix + name for name in names)
                source = work / (prefix + unit + ".s")
                source.write_text("\t.text\n" + exports + "\n" + text + "\n")
                native_files.append(str(source))
        binary = work / "test_equivalence"
        native_target = ["-arch", "arm64"] if mac else []
        run(*compiler, *native_target, "-std=c11", "-O2", "-ffp-contract=off", "-Wall", "-Wextra",
            "-I", str(repo), "-I", str(repo / "Development/CritterProduct/Pilot"),
            str(base / "test_equivalence.c"), *native_files, "-lm", "-o", str(binary))
        run(str(binary))


if __name__ == "__main__":
    main()
