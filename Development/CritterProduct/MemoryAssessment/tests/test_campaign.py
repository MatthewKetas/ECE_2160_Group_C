import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import time
import unittest

HERE = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('campaign', HERE/'campaign.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)


class WorkflowTests(unittest.TestCase):
    def test_plan_is_unique_and_keeps_all_groups(self):
        plan = c.variants()
        self.assertEqual(len(plan), 29)
        self.assertEqual(len({v['name'] for v in plan}), 29)
        self.assertTrue({'O0','O1','O2','O3','Ofast','Os','Oz'} <= {v['name'] for v in plan})

    def test_equivalence_rejects_bad_numbers_and_changed_decisions(self):
        a = dict.fromkeys(c.FIELDS, 0)
        self.assertTrue(c.equivalent(a, a))
        self.assertFalse(c.equivalent(a, dict(a, outliers=1)))
        self.assertFalse(c.equivalent(a, dict(a, mean=float('nan'))))
        self.assertFalse(c.equivalent(a, dict(a, prediction=float('inf'))))

    def test_time_parser_does_not_invent_missing_rss(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp)/'time.txt'
            self.assertEqual(c.time_metrics(p), {})
            p.write_text('\tMaximum resident set size (kbytes): 1600\n\tUser time (seconds): 0.25\n')
            self.assertEqual(c.time_metrics(p), {'peak_rss_kib':1600, 'user_s':0.25})

    def test_timeout_and_budget_are_enforced(self):
        with tempfile.TemporaryDirectory() as tmp:
            campaign = c.Campaign(Path(tmp)/'run', minutes=10, mac=sys.platform=='darwin')
            r = campaign.command([sys.executable,'-c','import time; time.sleep(30)'],
                                 campaign.out, campaign.out/'timeout', timeout=0.15)
            self.assertTrue(r['timed_out'])
            self.assertLess(r['duration_s'], 2)
            self.assertNotEqual(r['returncode'], 0)
            campaign.work_deadline = time.monotonic()-1
            with self.assertRaises(c.BudgetExpired):
                campaign.command(['not-a-command'], campaign.out, campaign.out/'budget')
            campaign.lock.close()

    def test_single_writer_lock(self):
        with tempfile.TemporaryDirectory() as tmp:
            campaign = c.Campaign(Path(tmp)/'run', minutes=10)
            with self.assertRaises(BlockingIOError):
                c.Campaign(campaign.out, minutes=10, resume=True)
            campaign.lock.close()

    def test_source_patch_refuses_ambiguous_input(self):
        with self.assertRaises(ValueError): c.replace_once('x x', 'x', 'y')
        with self.assertRaises(ValueError): c.replace_once('z', 'x', 'y')

    def test_resume_preserves_completed_slot(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)/'run'
            campaign = c.Campaign(out, minutes=10)
            saved = {'status':'ok','output':{'checksum':1}}
            c.write_json(out/'runs'/'done'/'result.json', saved)
            campaign.resume=True
            self.assertEqual(campaign.run_one({}, 'pipeline', 'done'), saved)
            campaign.lock.close()

    @unittest.skipUnless(sys.platform=='darwin', 'Mac build integration check')
    def test_real_c_allocation_variants_and_probes(self):
        with tempfile.TemporaryDirectory() as tmp:
            campaign = c.Campaign(Path(tmp)/'run', minutes=10, mac=True)
            (campaign.out/'input.csv').write_text('timestamp_s,temperature_c\n1000,22.5\n')
            for name, calls in [('O2', None), ('workspace',2), ('arena',1), ('static_storage',0)]:
                b = campaign.build({'name':name,'flags':['-O2']}, probe=True)
                self.assertTrue(b['valid'])
                r = campaign.run_one(b, 'pipeline', name, diagnostic=True)
                self.assertEqual(r['status'], 'ok')
                probe = r['allocation_probe']
                self.assertEqual(probe['requested_remaining_bytes'],0)
                if calls is None: self.assertGreater(probe['allocation_calls'],500)
                else: self.assertEqual(probe['allocation_calls'],calls)
                if name == 'O2': reference=r['output']
                else: self.assertTrue(c.equivalent(reference,r['output']))
                if name == 'arena':
                    required = r['output']['capacity']*(r['output']['record_bytes']+8)
                    exact = campaign.run_one(b,'pipeline','arena_exact',limits={'ASSESS_ARENA_BYTES':required})
                    short = campaign.run_one(b,'pipeline','arena_short',limits={'ASSESS_ARENA_BYTES':required-1})
                    self.assertEqual(exact['status'],'ok')
                    self.assertEqual(short['process']['returncode'],3)
            campaign.metadata()
            campaign.lock.close()
            resumed = c.Campaign(campaign.out,minutes=10,mac=True,resume=True)
            resumed.metadata()
            b = resumed.build({'name':'arena','flags':['-O2']},probe=True)
            self.assertEqual(resumed.run_one(b,'pipeline','arena_exact')['status'],'ok')
            resumed.lock.close()


if __name__=='__main__': unittest.main(verbosity=2)
