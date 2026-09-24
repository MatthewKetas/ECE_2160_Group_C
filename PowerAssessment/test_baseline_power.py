"""Check rail summation and output placement without collecting fake Pi results."""

import contextlib
import csv
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import baseline_power


ADC_OUTPUT = "\n".join(
    f"RAIL{i}_A current({i})=0.5A\nRAIL{i}_V volt({i + 12})=2.0V"
    for i in range(12)
) + "\nEXT5V_V volt(24)=5.0V\nBATT_V volt(25)=3.0V"


class BaselineTest(unittest.TestCase):
    def test_measurement(self):
        watts, rails = baseline_power.parse_readings(ADC_OUTPUT)
        self.assertEqual(watts, 12.0)
        self.assertEqual(len(rails), 24)
        with self.assertRaises(ValueError):
            baseline_power.parse_readings(ADC_OUTPUT.replace("RAIL0_V", "MISSING_V"))
        with self.assertRaises(ValueError):
            baseline_power.parse_readings("unavailable")

        # All simulated results stay in a temporary directory, outside results/.
        with tempfile.TemporaryDirectory() as temporary:
            script = Path(temporary) / "baseline_power.py"
            clock = [0.0]

            def sleep(seconds):
                clock[0] += seconds

            with patch.object(baseline_power, "__file__", str(script)), \
                 patch.object(baseline_power, "DURATION_SECONDS", 2), \
                 patch.object(baseline_power.subprocess, "check_output", return_value=ADC_OUTPUT), \
                 patch.object(baseline_power.time, "monotonic", side_effect=lambda: clock[0]), \
                 patch.object(baseline_power.time, "sleep", side_effect=sleep), \
                 contextlib.redirect_stdout(io.StringIO()):
                baseline_power.main()
                baseline_power.main()

            files = list((Path(temporary) / "results").glob("baseline_idle_*.csv"))
            self.assertEqual(len(files), 2)
            self.assertEqual(clock[0], 4.0)
            with files[0].open(newline="") as file:
                rows = list(csv.DictReader(file))
            self.assertEqual(len(rows), 2)
            self.assertEqual(float(rows[0]["pmic_power_watts"]), 12.0)


if __name__ == "__main__":
    unittest.main()
