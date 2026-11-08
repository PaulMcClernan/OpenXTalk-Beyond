# Copyright (C) 2026 OXT-Beyond contributors.
#
# This file is part of OXT-Beyond.
#
# OXT-Beyond is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License v3 as published by the Free
# Software Foundation.
#
# OXT-Beyond is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License
# along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.

"""The time limits of .github/workflows/ci-checks.yml leave room for the
unit tests it runs.

In November 2026 tools/ci/tests took 584 s on the Linux job, whose limit
was 10 minutes: run 42451358354 printed "Ran 1716 tests ... OK" and was
cancelled before its next step. macos-15 took 14 of its 15 minutes. A
cancelled run reads as a failure on every pull request, so each limit is
about twice what the job takes.

  python3 -m unittest discover -s tools/ci/tests
"""

import os
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
WORKFLOW = os.path.join(REPO, '.github', 'workflows', 'ci-checks.yml')


def jobs():
    import yaml
    with open(WORKFLOW, encoding='utf-8') as f:
        return yaml.safe_load(f)['jobs']


class TimeLimits(unittest.TestCase):

    def test_every_job_runs_the_unit_tests(self):
        # The limits below are for jobs that run the whole suite
        for name, job in jobs().items():
            runs = ' '.join(str(s.get('run', '')) for s in job['steps'])
            self.assertIn('unittest discover -s tools/ci/tests', runs, name)

    def test_linux_has_twice_what_the_tests_took(self):
        self.assertGreaterEqual(jobs()['checks']['timeout-minutes'], 20)

    def test_windows_and_macos_have_twice_what_macos_took(self):
        other = jobs()['other-os']
        self.assertEqual(other['strategy']['matrix']['os'], ['windows-latest', 'macos-15'])
        self.assertGreaterEqual(other['timeout-minutes'], 30)

    def test_no_step_has_a_shorter_limit_of_its_own(self):
        for name, job in jobs().items():
            for step in job['steps']:
                self.assertNotIn('timeout-minutes', step, (name, step.get('name')))


if __name__ == '__main__':
    unittest.main()
