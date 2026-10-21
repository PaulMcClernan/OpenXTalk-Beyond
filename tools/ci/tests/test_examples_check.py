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

"""The stacks tools/ci/examples_check.py prints into a log, and takes from
one: a delta from the committed stack makes the stack built, and
--from-log writes it back, checked against its SHA256 line.

  python3 -m unittest discover -s tools/ci/tests
"""

import contextlib
import hashlib
import io
import os
import random
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import examples_check  # noqa: E402


def printed(kind, name, data):
    """The lines print_lines writes, each after a time as in a GitHub log"""
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        examples_check.print_lines(kind, name, data)
    return ''.join('2026-10-21T16:40:00.0000000Z ' + x + '\n' for x in out.getvalue().splitlines())


class DeltaTest(unittest.TestCase):
    def setUp(self):
        rng = random.Random(7)
        self.old = bytes(rng.randrange(256) for _ in range(200000))

    def check(self, new):
        data = examples_check.delta(self.old, new)
        self.assertEqual(examples_check.undelta(self.old, data), new)
        return data

    def test_the_same(self):
        self.assertLess(len(self.check(self.old)), 100)

    def test_a_script_changed(self):
        new = bytearray(self.old)
        new[120000:120400] = b'on arrowKey pKey\n   pass arrowKey\nend arrowKey\n' * 20
        new[10:14] = b'\x00\x01\x02\x03'
        new = bytes(new)
        self.assertLess(len(self.check(new)), 2000)

    def test_nothing_shared(self):
        self.check(bytes(random.Random(8).randrange(256) for _ in range(5000)))
        self.check(b'')
        self.check(self.old[:5])

    def test_not_a_delta(self):
        with self.assertRaises(Exception):
            examples_check.undelta(self.old, b'not zlib')


class FromLogTest(unittest.TestCase):
    def test_writes_the_stacks(self):
        with tempfile.TemporaryDirectory() as tmp:
            old = b'the committed stack ' * 500
            new = old.replace(b'committed', b'built', 3)
            fresh = b'a stack with nothing committed'
            with open(os.path.join(tmp, 'A Stack.oxtstack'), 'wb') as f:
                f.write(old)
            text = 'the build\n'
            text += printed('DELTA', 'A Stack.oxtstack', examples_check.delta(old, new))
            text += '2026-10-21T16:40:00Z SHA256 A_Stack.oxtstack %s %d\n' % (hashlib.sha256(new).hexdigest(), len(new))
            text += printed('STACK', 'New One.oxtstack', fresh)
            text += 'SHA256 New_One.oxtstack %s %d\n' % (hashlib.sha256(fresh).hexdigest(), len(fresh))
            path = os.path.join(tmp, 'log.txt')
            with open(path, 'w') as f:
                f.write(text)
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(examples_check.from_log(path, tmp), [])
            with open(os.path.join(tmp, 'A Stack.oxtstack'), 'rb') as f:
                self.assertEqual(f.read(), new)
            with open(os.path.join(tmp, 'New One.oxtstack'), 'rb') as f:
                self.assertEqual(f.read(), fresh)

    def test_refuses_a_wrong_sum(self):
        with tempfile.TemporaryDirectory() as tmp:
            text = printed('STACK', 'X.oxtstack', b'built')
            text += 'SHA256 X.oxtstack %s 5\n' % hashlib.sha256(b'other').hexdigest()
            path = os.path.join(tmp, 'log.txt')
            with open(path, 'w') as f:
                f.write(text)
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(len(examples_check.from_log(path, tmp)), 1)
            self.assertFalse(os.path.exists(os.path.join(tmp, 'X.oxtstack')))

    def test_a_bad_delta_leaves_the_others(self):
        # (a line copied out of a log by hand with a slip in it)
        with tempfile.TemporaryDirectory() as tmp:
            old = b'the committed stack ' * 500
            new = old.replace(b'committed', b'built', 3)
            for name in ('A.oxtstack', 'B.oxtstack'):
                with open(os.path.join(tmp, name), 'wb') as f:
                    f.write(old)
            good = examples_check.delta(old, new)
            bad = good[:6] + bytes([good[6] ^ 0xff]) + good[7:]
            text = printed('DELTA', 'A.oxtstack', bad)
            text += 'SHA256 A.oxtstack %s %d\n' % (hashlib.sha256(new).hexdigest(), len(new))
            text += printed('DELTA', 'B.oxtstack', good)
            text += 'SHA256 B.oxtstack %s %d\n' % (hashlib.sha256(new).hexdigest(), len(new))
            path = os.path.join(tmp, 'log.txt')
            with open(path, 'w') as f:
                f.write(text)
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(len(examples_check.from_log(path, tmp)), 1)
            with open(os.path.join(tmp, 'A.oxtstack'), 'rb') as f:
                self.assertEqual(f.read(), old)
            with open(os.path.join(tmp, 'B.oxtstack'), 'rb') as f:
                self.assertEqual(f.read(), new)


if __name__ == '__main__':
    unittest.main()
