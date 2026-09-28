import unittest
from combine_runs import summarize


class CombineTest(unittest.TestCase):
    def test_constant_power_and_invalid_time(self):
        rows = [dict(elapsed_seconds=i + 0.02, pmic_power_watts=6,
                     **{f'rail{j}_A': 0.25 for j in range(12)},
                     **{f'rail{j}_V': 2 for j in range(12)}) for i in range(60)]
        self.assertEqual(summarize(rows), (6, 360))
        rows[20]['elapsed_seconds'] = rows[19]['elapsed_seconds']
        with self.assertRaises(ValueError):
            summarize(rows)


if __name__ == '__main__':
    unittest.main()
