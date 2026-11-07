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

"""The Android engine built here with a current NDK (the Android plan's phase
2): config.py's and prebuilt/scripts/android.inc's choice of toolchain (the
NDK's own when there is no standalone toolchain, which is used as before
when there is one), OpenSSL's Android targets, the linker the gyp settings
name, tools/ci/build-android.sh's names, tools/ci/android_engine.py's
checks on made-up ELF files, and android-engine.yml. No NDK, SDK or engine
is needed.

  python3 -m unittest discover -s tools/ci/tests
"""

import contextlib
import importlib.util
import io
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest
import warnings
import zipfile
from unittest import mock

CI = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.dirname(os.path.dirname(CI))
sys.path.insert(0, CI)

import android_engine as ae  # noqa: E402
import android_java  # noqa: E402

BASH = shutil.which('bash') if os.name != 'nt' else None


def read(*path):
    with open(os.path.join(REPO, *path), encoding='utf-8') as f:
        return f.read()


def load_config():
    """config.py as a module (Python 2 code that Python 3 can import: its
    functions that the tests call are both)."""
    spec = importlib.util.spec_from_file_location('oxt_config', os.path.join(REPO, 'config.py'))
    module = importlib.util.module_from_spec(spec)
    with warnings.catch_warnings():
        warnings.simplefilter('ignore')     # its regular expressions' escapes
        spec.loader.exec_module(module)
    return module


CONFIG = load_config()
HOSTS = {'Linux': 'linux-x86_64', 'Darwin': 'darwin-x86_64', 'Windows': 'windows-x86_64'}


def touch(path, data=b''):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(data)


def fake_ndk(root, hosts=('linux-x86_64', 'darwin-x86_64', 'windows-x86_64')):
    """An NDK folder with its own toolchain's clang for the hosts."""
    ndk = os.path.join(root, 'ndk')
    touch(os.path.join(ndk, 'source.properties'), b'Pkg.Revision = 30.0.16248370\n')
    for host in hosts:
        touch(os.path.join(ndk, 'toolchains', 'llvm', 'prebuilt', host, 'bin',
                           'clang.exe' if host.startswith('windows') else 'clang'))
    return ndk


def llvm_bin(ndk, host):
    return os.path.join(ndk, 'toolchains', 'llvm', 'prebuilt', host, 'bin')


# ---------------------------------------------------------------------------
# config.py


class ConfigToolchain(unittest.TestCase):
    """config.py's validate_android_tools: the NDK's own toolchain when there
    is no standalone toolchain, and the standalone toolchain as before."""

    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.tmp)
        self.ndk = fake_ndk(self.tmp)
        self.sdk = os.path.join(self.tmp, 'sdk')
        os.makedirs(os.path.join(self.sdk, 'build-tools', '36.0.0'))
        self.toolchains = os.path.join(self.tmp, 'toolchain')
        os.makedirs(self.toolchains)
        self.system = mock.patch.object(CONFIG.platform, 'system', return_value='Linux')
        self.system.start()
        self.addCleanup(self.system.stop)

    def options(self, arch, **extra):
        opts = {}
        with mock.patch.dict(os.environ, {}, clear=True):
            CONFIG.process_env_options(opts)
        opts.update(TARGET_ARCH=arch, ANDROID_NDK=self.ndk, ANDROID_SDK=self.sdk,
                    ANDROID_TOOLCHAIN_DIR=self.toolchains)
        opts.update(extra)
        CONFIG.validate_android_tools(opts)
        return opts

    def test_the_ndks_own_toolchain(self):
        bin_ = llvm_bin(self.ndk, 'linux-x86_64')
        o = self.options('arm64')
        self.assertEqual(o['ANDROID_NDK_PLATFORM_VERSION'], '21')
        self.assertEqual(o['ANDROID_FUSE_LD'], 'lld')
        self.assertEqual(o['AR'], os.path.join(bin_, 'llvm-ar'))
        self.assertEqual(o['OBJCOPY'], os.path.join(bin_, 'llvm-objcopy'))
        self.assertEqual(o['OBJDUMP'], os.path.join(bin_, 'llvm-objdump'))
        self.assertEqual(o['STRIP'], os.path.join(bin_, 'llvm-strip'))
        self.assertEqual(o['CC'].split(), [os.path.join(bin_, 'clang'), '-target', 'aarch64-linux-android21',
                                           '-Qunused-arguments'])
        self.assertEqual(o['CXX'].split()[0], os.path.join(bin_, 'clang++'))
        self.assertEqual(o['LINK'].split(), [os.path.join(bin_, 'clang++'), '-target', 'aarch64-linux-android21',
                                             '-fuse-ld=lld', '-static-libstdc++'])
        self.assertEqual(o['ANDROID_LIB_PATH'],
                         os.path.join(os.path.dirname(bin_), 'sysroot', 'usr', 'lib', 'aarch64-linux-android', '21'))
        self.assertIsNone(o['ANDROID_TOOLCHAIN'])

    def test_each_architecture(self):
        bin_ = llvm_bin(self.ndk, 'linux-x86_64')
        cases = {
            'armv7': ('armv7a-linux-androideabi21', ['-march=armv7-a', '-mfloat-abi=softfp', '-mfpu=vfpv3-d16',
                                                    '-mthumb'], 'arm-linux-androideabi'),
            'arm64': ('aarch64-linux-android21', [], 'aarch64-linux-android'),
            'x86': ('i686-linux-android21', ['-march=i686'], 'i686-linux-android'),
            'x86_64': ('x86_64-linux-android21', [], 'x86_64-linux-android'),
        }
        for arch, (target, flags, libdir) in cases.items():
            with self.subTest(arch=arch):
                o = self.options(arch)
                cc = o['CC'].split()
                self.assertEqual(cc[1:3], ['-target', target])
                for flag in flags:
                    self.assertIn(flag, cc)
                link = o['LINK'].split()
                self.assertEqual(link[1:3], ['-target', target])
                self.assertIn('-fuse-ld=lld', link)
                self.assertNotIn('-fuse-ld=bfd', link)
                self.assertNotIn('-integrated-as', cc)
                if arch == 'armv7':
                    self.assertIn('-Wl,--fix-cortex-a8', link)
                self.assertEqual(o['ANDROID_LIB_PATH'],
                                 os.path.join(os.path.dirname(bin_), 'sysroot', 'usr', 'lib', libdir, '21'))

    def test_a_platform_version_that_is_set_stays(self):
        o = self.options('x86_64', ANDROID_NDK_PLATFORM_VERSION='24')
        self.assertEqual(o['ANDROID_NDK_PLATFORM_VERSION'], '24')
        self.assertIn('x86_64-linux-android24', o['CC'])
        self.assertTrue(o['ANDROID_LIB_PATH'].endswith(os.path.join('x86_64-linux-android', '24')))

    def test_tools_that_are_set_stay(self):
        o = self.options('arm64', CC='my-cc', AR='my-ar', ANDROID_FUSE_LD='gold', ANDROID_LIB_PATH='/libs')
        self.assertEqual(o['CC'], 'my-cc')
        self.assertEqual(o['AR'], 'my-ar')
        self.assertEqual(o['ANDROID_FUSE_LD'], 'gold')
        self.assertEqual(o['ANDROID_LIB_PATH'], '/libs')
        self.assertIn('clang++', o['CXX'])

    def test_each_host(self):
        for system, host in HOSTS.items():
            with self.subTest(system=system), mock.patch.object(CONFIG.platform, 'system', return_value=system):
                self.assertEqual(CONFIG.guess_ndk_llvm_bin(self.ndk), llvm_bin(self.ndk, host))
        with mock.patch.object(CONFIG.platform, 'system', return_value='CYGWIN_NT-10.0'):
            self.assertEqual(CONFIG.guess_ndk_llvm_bin(self.ndk), llvm_bin(self.ndk, 'windows-x86_64'))

    def test_an_ndk_without_its_own_toolchain(self):
        old = os.path.join(self.tmp, 'old-ndk')
        os.makedirs(old)
        self.assertIsNone(CONFIG.guess_ndk_llvm_bin(old))
        with self.assertRaises(SystemExit), contextlib.redirect_stdout(io.StringIO()) as out:
            self.options('arm64', ANDROID_NDK=old)
        self.assertIn('Android toolchain not found for architecture arm64', out.getvalue())

    def test_a_standalone_toolchain_is_used_as_before(self):
        # (what config.py did before the NDK's own toolchain: the standalone
        # toolchain of make_standalone_toolchain.py in the toolchain folder,
        # API 16, the bfd linker)
        for arch, folder, prefix, triple in (('arm64', 'standalone-arm64', 'aarch64-linux-android-',
                                              'aarch64-linux-android'),
                                             ('armv7', 'standalone-arm', 'arm-linux-androideabi-',
                                              'armv7-linux-androideabi')):
            with self.subTest(arch=arch):
                os.makedirs(os.path.join(self.toolchains, folder), exist_ok=True)
                o = self.options(arch)
                tc = os.path.join(self.toolchains, folder, 'bin', prefix)
                self.assertEqual(o['ANDROID_TOOLCHAIN'], tc)
                self.assertEqual(o['ANDROID_NDK_PLATFORM_VERSION'], '16')
                self.assertEqual(o['ANDROID_FUSE_LD'], 'bfd')
                self.assertEqual(o['AR'], tc + 'ar ')
                self.assertEqual(o['OBJCOPY'], tc + 'objcopy ')
                self.assertTrue(o['CC'].startswith(tc + 'clang -target %s ' % triple))
                self.assertIn('-integrated-as', o['CC'])
                self.assertIn('-fuse-ld=bfd', o['LINK'])
                self.assertNotIn('-static-libstdc++', o['LINK'])

    def test_a_named_toolchain_is_used_as_before(self):
        o = self.options('x86', ANDROID_TOOLCHAIN='/opt/tc/bin/i686-linux-android-')
        self.assertEqual(o['CC'].split()[:3], ['/opt/tc/bin/i686-linux-android-clang', '-target',
                                               'i686-linux-android'])
        self.assertEqual(o['ANDROID_FUSE_LD'], 'bfd')
        self.assertEqual(o['ANDROID_NDK_PLATFORM_VERSION'], '16')

    def test_the_linker_reaches_gyp(self):
        text = read('config.py')
        configure = text[text.index('def configure_android('):]
        configure = configure[:configure.index('\ndef ')]
        self.assertIn("'ANDROID_FUSE_LD'", configure)
        env = text[text.index('def process_env_options('):]
        self.assertIn("'ANDROID_FUSE_LD'", env[:env.index('\ndef ')])
        gypi = read('config', 'android-settings.gypi')
        self.assertIn("'android_fuse_ld%': '<!(echo ${ANDROID_FUSE_LD:-bfd})'", gypi)
        self.assertIn("'-fuse-ld=<(android_fuse_ld)'", gypi)
        self.assertNotIn("'-fuse-ld=bfd'", gypi)


# ---------------------------------------------------------------------------
# prebuilt/scripts/android.inc and build-openssl.sh


@unittest.skipUnless(BASH, 'needs bash (not on Windows)')
class PrebuiltToolchain(unittest.TestCase):
    """configureAndroidToolchain, which every prebuilt library's script
    builds with."""

    VARS = ('ANDROID_CC', 'ANDROID_CFLAGS', 'ANDROID_CXX', 'ANDROID_CXXFLAGS', 'ANDROID_LINK', 'ANDROID_LDFLAGS', 'ANDROID_AR',
            'ANDROID_OBJCOPY', 'ANDROID_RANLIB', 'ANDROID_STRIP', 'ANDROID_TOOLCHAIN_BASE', 'ANDROID_LLVM_BIN',
            'ANDROID_API', 'ANDROID_TRIPLE')

    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.tmp)
        self.home = os.path.join(self.tmp, 'home')
        os.makedirs(self.home)
        self.ndk = fake_ndk(self.tmp)

    def configure(self, arch, ok=True, **env):
        script = ('source "$1"; configureAndroidToolchain "$2"; ' +
                  ' '.join('echo "%s=${%s}";' % (v, v) for v in self.VARS))
        environ = {'PATH': os.environ.get('PATH', ''), 'HOME': self.home, 'ANDROID_NDK': self.ndk}
        environ.update(env)
        p = subprocess.run([BASH, '-c', script, 'bash', os.path.join(REPO, 'prebuilt', 'scripts', 'android.inc'),
                            arch], env=environ, capture_output=True, text=True)
        if not ok:
            self.assertNotEqual(p.returncode, 0)
            return p.stderr
        self.assertEqual(p.returncode, 0, p.stderr)
        return dict(line.split('=', 1) for line in p.stdout.splitlines())

    def host(self):
        system = subprocess.run(['uname', '-s'], capture_output=True, text=True).stdout.strip()
        return 'darwin-x86_64' if system.startswith('Darwin') else 'linux-x86_64'

    def test_the_ndks_own_toolchain(self):
        bin_ = llvm_bin(self.ndk, self.host())
        v = self.configure('arm64')
        self.assertEqual(v['ANDROID_LLVM_BIN'], bin_)
        self.assertEqual(v['ANDROID_API'], '21')
        self.assertEqual(v['ANDROID_CC'], bin_ + '/clang')
        self.assertEqual(v['ANDROID_CXX'], bin_ + '/clang++')
        self.assertEqual(v['ANDROID_LINK'], bin_ + '/clang++')
        for name, tool in (('AR', 'llvm-ar'), ('OBJCOPY', 'llvm-objcopy'), ('RANLIB', 'llvm-ranlib'),
                           ('STRIP', 'llvm-strip')):
            self.assertEqual(v['ANDROID_' + name], bin_ + '/' + tool)
        self.assertEqual(v['ANDROID_TOOLCHAIN_BASE'], os.path.dirname(bin_))
        for name in ('CFLAGS', 'CXXFLAGS', 'LDFLAGS'):
            self.assertEqual(v['ANDROID_' + name], '-target aarch64-linux-android21')

    def test_each_architecture(self):
        cases = {
            'armv7': ('-target armv7a-linux-androideabi21 -mthumb', 'arm-linux-androideabi'),
            'arm64': ('-target aarch64-linux-android21', 'aarch64-linux-android'),
            'x86': ('-target i686-linux-android21 -march=i686', 'i686-linux-android'),
            'x86_64': ('-target x86_64-linux-android21', 'x86_64-linux-android'),
        }
        for arch, (flags, triple) in cases.items():
            with self.subTest(arch=arch):
                v = self.configure(arch)
                self.assertEqual(v['ANDROID_CFLAGS'], flags)
                self.assertEqual(v['ANDROID_TRIPLE'], triple)    # ICU's --host

    def test_the_platform_version(self):
        v = self.configure('x86_64', ANDROID_NDK_PLATFORM_VERSION='26')
        self.assertEqual(v['ANDROID_API'], '26')
        self.assertEqual(v['ANDROID_CFLAGS'], '-target x86_64-linux-android26')

    def test_armv6_is_refused(self):
        self.assertIn('does not build for armv6', self.configure('armv6', ok=False))

    def test_a_standalone_toolchain_is_used_as_before(self):
        os.makedirs(os.path.join(self.home, 'android', 'toolchain', 'standalone-arm64'))
        v = self.configure('arm64')
        tc = os.path.join(self.home, 'android', 'toolchain', 'standalone-arm64', 'bin', 'aarch64-linux-android-')
        self.assertEqual(v['ANDROID_LLVM_BIN'], '')
        self.assertEqual(v['ANDROID_CC'], tc + 'clang')
        self.assertEqual(v['ANDROID_AR'], tc + 'ar')
        self.assertEqual(v['ANDROID_CFLAGS'], '-target aarch64-linux-android')
        self.assertEqual(v['ANDROID_TOOLCHAIN_BASE'], os.path.join(self.home, 'android', 'toolchain',
                                                                   'standalone-arm64'))

    def test_a_named_toolchain_is_used_as_before(self):
        v = self.configure('armv7', ANDROID_TOOLCHAIN='/opt/arm/bin/arm-linux-androideabi-')
        self.assertEqual(v['ANDROID_LLVM_BIN'], '')
        self.assertEqual(v['ANDROID_CC'], '/opt/arm/bin/arm-linux-androideabi-clang')
        self.assertEqual(v['ANDROID_CFLAGS'], '-target arm-linux-androideabi -march=armv7a -mthumb')
        self.assertEqual(v['ANDROID_TOOLCHAIN_BASE'], '/opt/arm')

    def test_a_custom_toolchain_is_used_as_before(self):
        v = self.configure('arm64', OBJCOPY='objcopy', CC='my-cc', CXX='my-c++', LINK='my-link')
        self.assertEqual(v['ANDROID_LLVM_BIN'], '')
        self.assertEqual((v['ANDROID_CC'], v['ANDROID_CXX'], v['ANDROID_LINK']), ('my-cc', 'my-c++', 'my-link'))

    def test_an_old_ndk_names_the_standalone_toolchain_as_before(self):
        old = os.path.join(self.tmp, 'old-ndk')
        os.makedirs(old)
        v = self.configure('x86', ANDROID_NDK=old)
        self.assertEqual(v['ANDROID_LLVM_BIN'], '')
        self.assertEqual(v['ANDROID_CC'], os.path.join(self.home, 'android', 'toolchain', 'standalone-x86', 'bin',
                                                       'i686-linux-android-clang'))


def openssl_case():
    """buildOpenSSL's case on the platform (build-openssl.sh), the part that
    chooses OpenSSL's target and its environment."""
    text = read('prebuilt', 'scripts', 'build-openssl.sh')
    body = text[text.index('function buildOpenSSL'):]
    start = body.index('\tcase "${PLATFORM}" in')
    end = body.index('\n\tesac\n', start) + len('\n\tesac\n')
    return body[start:end]


@unittest.skipUnless(BASH, 'needs bash (not on Windows)')
class OpenSSLTarget(unittest.TestCase):
    """build-openssl.sh's Android targets, with configureAndroidToolchain
    standing in for android.inc's."""

    def run_case(self, arch, llvm_bin='/ndk/llvm/bin'):
        script = ('configureAndroidToolchain() { ANDROID_LLVM_BIN=%s; ANDROID_API=21; '
                  'ANDROID_TOOLCHAIN_BASE=/tc; }\n' % (llvm_bin or "''") +
                  'PLATFORM=android; ARCH=%s; ANDROID_NDK=/ndk; export CROSS_SYSROOT=/sysroot; '
                  'export ANDROID_NDK_HOME=/old; CFLAGS=; EXTRA_OPTIONS=\n' % arch +
                  openssl_case() +
                  'echo "SPEC=$SPEC"; echo "EXTRA=$EXTRA_OPTIONS"; echo "ROOT=${ANDROID_NDK_ROOT-unset}"; '
                  'echo "HOME=${ANDROID_NDK_HOME-unset}"; echo "SYSROOT=${CROSS_SYSROOT-unset}"; '
                  'echo "PATH1=${PATH%%:*}"; echo "CFLAGS=$CFLAGS"; echo "CC=$CONFIGURE_CC_FOR_TARGET"\n')
        p = subprocess.run([BASH, '-c', script], capture_output=True, text=True,
                           env={'PATH': os.environ.get('PATH', '')})
        return p.returncode, dict(line.split('=', 1) for line in p.stdout.splitlines() if '=' in line), p.stderr

    def test_the_ndks_own_toolchain(self):
        for arch, spec in (('arm64', 'android-arm64'), ('armv7', 'android-arm'), ('x86', 'android-x86'),
                           ('x86_64', 'android-x86_64')):
            with self.subTest(arch=arch):
                status, v, err = self.run_case(arch)
                self.assertEqual(status, 0, err)
                self.assertEqual(v['SPEC'], spec)
                self.assertEqual(v['EXTRA'], '-D__ANDROID_API__=21')
                self.assertEqual(v['ROOT'], '/ndk')
                self.assertEqual(v['HOME'], 'unset')
                self.assertEqual(v['SYSROOT'], 'unset')
                self.assertEqual(v['PATH1'], '/ndk/llvm/bin')
                self.assertEqual(v['CFLAGS'], '')      # no GNU assembler or bfd linker to ask for
                self.assertEqual(v['CC'], '0')

    def test_armv6_is_refused(self):
        status, _, err = self.run_case('armv6')
        self.assertNotEqual(status, 0)
        self.assertIn('no OpenSSL target for Android armv6', err)

    def test_a_standalone_toolchain_is_used_as_before(self):
        cases = (('arm64', 'android-arm64', '-fno-integrated-as', ''),
                 ('armv7', 'android-arm', '-fno-integrated-as', '-latomic'),
                 ('x86', 'android-x86', '-fuse-ld=bfd', ''),
                 ('x86_64', 'android-x86_64', '', ''))
        for arch, spec, cflags, extra in cases:
            with self.subTest(arch=arch):
                status, v, err = self.run_case(arch, llvm_bin=None)
                self.assertEqual(status, 0, err)
                self.assertEqual(v['SPEC'], spec)
                self.assertEqual(v['CFLAGS'], cflags)
                self.assertEqual(v['EXTRA'], extra)
                self.assertEqual(v['HOME'], '/tc')
                self.assertEqual(v['PATH1'], '/tc/bin')
                self.assertEqual(v['ROOT'], 'unset')
                self.assertEqual(v['SYSROOT'], '/sysroot')


# ---------------------------------------------------------------------------
# tools/ci/build-android.sh


def bash_assoc(text, name):
    """A bash associative array's [key]=value pairs (declare -A NAME=(...))."""
    m = re.search(r'declare -A %s=\((.*?)\)\n' % name, text, re.S)
    return dict(re.findall(r'\[([^\]]+)\]=(\S+)', m.group(1)))


def bash_array(text, name):
    m = re.search(r'^%s=\((.*?)\)\n' % name, text, re.S | re.M)
    return m.group(1).split()


class BuildScript(unittest.TestCase):
    """build-android.sh names what android_engine.py and android_java.py
    check, and what the gyp files build."""

    @classmethod
    def setUpClass(cls):
        cls.text = read('tools', 'ci', 'build-android.sh')

    def test_the_architectures(self):
        abis = bash_assoc(self.text, 'ABIS')
        self.assertEqual(abis, {'arm64': 'arm64-v8a', 'armv7': 'armeabi-v7a', 'x86_64': 'x86_64', 'x86': 'x86'})
        self.assertEqual(set(abis.values()), set(ae.ABIS))
        self.assertEqual(set(abis.values()), set(android_java.ABIS))

    def test_the_folder(self):
        self.assertEqual(set(bash_assoc(self.text, 'LIBRARIES').values()), {ae.ENGINE} | set(ae.EXTERNALS))
        self.assertEqual(set(bash_assoc(self.text, 'FILES').values()), set(ae.TOP_FILES))
        self.assertEqual(ae.ENGINE, android_java.ENGINE_NAME)

    def test_the_targets_make_the_libraries(self):
        """Each gyp target the script builds names, for Android, one of the
        products the script takes from the build folder."""
        targets = bash_array(self.text, 'ENGINE_TARGETS')
        products = set(bash_assoc(self.text, 'LIBRARIES'))
        found = set()
        gyps = ('engine/engine.gyp', 'revdb/revdb.gyp', 'revxml/revxml.gyp', 'revzip/revzip.gyp',
                'revpdfprinter/revpdfprinter.gyp', 'thirdparty/libopenssl/libopenssl.gyp')
        texts = dict((g, read(*g.split('/'))) for g in gyps)
        for target in targets:
            holders = [g for g, t in texts.items() if "'target_name': '%s'" % target in t]
            self.assertEqual(len(holders), 1, target)
            # (every target of that name: a gyp file can have one for each
            # platform, as libopenssl.gyp's revsecurity)
            text = texts[holders[0]]
            names = set()
            for m in re.finditer(r"'target_name': '%s'" % re.escape(target), text):
                nxt = text.find("'target_name':", m.end())
                block = text[m.start():nxt if nxt > 0 else len(text)]
                names |= set(re.findall(r"'product_name': '([^']+)'", block)) & products
            self.assertEqual(len(names), 1, '%s: %s' % (target, names))
            found |= names
        self.assertEqual(found, products)

    def test_the_lowest_android(self):
        self.assertEqual(re.search(r'^ANDROID_MIN_API=(\d+)$', self.text, re.M).group(1), str(ae.MIN_API))

    def test_the_ndk_version(self):
        version = read('config', 'android-ndk-version').strip()
        self.assertRegex(version, r'^\d+\.\d+\.\d+$')
        self.assertIn('config/android-ndk-version', self.text)
        # the libraries' folder: ndk<API>r<major>, as config/android.gypi's
        # android_subplatform names it from the same two variables
        self.assertIn('export ANDROID_NDK_VERSION="r${NDK_WANTED%%.*}"', self.text)
        self.assertIn('SUBPLATFORM="ndk${ANDROID_NDK_PLATFORM_VERSION}${ANDROID_NDK_VERSION}"', self.text)
        self.assertIn("'android_subplatform%': 'ndk<(android_ndk_platform_version)<(android_ndk_version)'",
                      read('config', 'android.gypi'))

    def test_the_libraries_it_builds(self):
        for lib in ('icu', 'thirdparty', 'openssl'):
            self.assertRegex(self.text, r'PREBUILT_BUILD_LIBS=%s \./build-libraries\.sh android "\$\{ARCH\}" '
                                        r'"\$\{SUBPLATFORM\}"' % lib)
        self.assertIn('export PREBUILT_SKIP_FETCH=1', self.text)
        self.assertIn('Thirdparty_LIBS_android', self.text)

    def test_stripped_with_the_debug_information_kept(self):
        self.assertIn('llvm-strip" --strip-debug -o "${OUT}/${ABI}/', self.text)
        self.assertIn('cp "${FILE}" "${OUT}/debug/${ABI}/', self.text)

    @unittest.skipUnless(BASH and sys.platform.startswith('linux'), 'needs bash 4 on Linux')
    def test_arguments(self):
        script = os.path.join(REPO, 'tools', 'ci', 'build-android.sh')
        p = subprocess.run([BASH, script], capture_output=True, text=True)
        self.assertEqual(p.returncode, 2)
        self.assertIn('usage:', p.stderr)
        p = subprocess.run([BASH, script, 'mips', '--libraries'], capture_output=True, text=True)
        self.assertEqual(p.returncode, 1)
        self.assertIn('no Android architecture mips', p.stderr)
        with tempfile.TemporaryDirectory() as tmp:
            touch(os.path.join(tmp, 'out', 'old'))
            p = subprocess.run([BASH, script, 'arm64', os.path.join(tmp, 'out')], capture_output=True, text=True)
            self.assertEqual(p.returncode, 1)
            self.assertIn('exists and is not empty', p.stderr)


# ---------------------------------------------------------------------------
# tools/ci/android_engine.py on made-up ELF files


def elf(is64=True, machine=183, align=16384, needed=('libc.so', 'liblog.so'), textrel=None, api=21,
        project='last', exports=('JNI_OnLoad',), etype=3):
    """A small ELF file with what android_engine.py reads: LOAD and DYNAMIC
    segments, .dynstr, .dynsym, .dynamic, .note.android.ident and .project.
    Addresses are file offsets. project: None (no .project), 'last',
    'section-after' (an allocated section after it), 'segment-after' (an
    empty LOAD segment after its own) or 'padded' (its segment's data goes
    on after it)."""
    e = '<'
    word = 'Q' if is64 else 'I'
    ehsize, phentsize, shentsize = (64, 56, 64) if is64 else (52, 32, 40)

    dynstr = b'\0'
    names = {}
    for n in list(needed) + list(exports) + ['abort']:
        names[n] = len(dynstr)
        dynstr += n.encode() + b'\0'

    sym_size = 24 if is64 else 16

    def sym(name, shndx):
        if is64:
            return struct.pack(e + 'IBBHQQ', name, 0x12, 0, shndx, 0, 0)
        return struct.pack(e + 'IIIBBH', name, 0, 0, 0x12, 0, shndx)

    dynsym = sym(0, 0) + b''.join(sym(names[n], 7) for n in exports) + sym(names['abort'], 0)
    note = struct.pack(e + 'III', 8, 4, 1) + b'Android\0' + struct.pack(e + 'I', api) if api is not None else b''

    phnum = 2 + (1 if project == 'segment-after' else 0)
    off = ehsize + phnum * phentsize
    blobs = []

    def place(name, data, sh_type, flags=2, link=0, entsize=0):
        nonlocal off
        off = (off + 7) & ~7
        blobs.append({'name': name, 'data': data, 'type': sh_type, 'flags': flags, 'addr': off, 'offset': off,
                      'link': link, 'entsize': entsize})
        off += len(data)

    place('.dynstr', dynstr, 3)
    dynstr_addr = blobs[-1]['addr']
    place('.dynsym', dynsym, 11, link=1, entsize=sym_size)
    tags = [(1, names[n]) for n in needed] + [(5, dynstr_addr), (10, len(dynstr))]
    if textrel == 'tag':
        tags.append((22, 0))
    elif textrel == 'flag':
        tags.append((30, 4 | 8))
    tags.append((0, 0))
    dynamic = b''.join(struct.pack(e + ('qQ' if is64 else 'iI'), t, v) for t, v in tags)
    place('.dynamic', dynamic, 6, flags=3)
    if note:
        place('.note.android.ident', note, 7)
    if project:
        place('.project', b'#!project' + b'\0' * 55, 1, flags=3)
    if project == 'section-after':
        place('.after', b'\0' * 16, 1, flags=3)
    load_end = off + (16 if project == 'padded' else 0)
    off = load_end
    shstrtab = b'\0'
    sections = [{'name': '', 'type': 0, 'flags': 0, 'addr': 0, 'offset': 0, 'data': b'', 'link': 0,
                 'entsize': 0}] + blobs
    for s in sections[1:]:
        s['name_at'] = len(shstrtab)
        shstrtab += s['name'].encode() + b'\0'
    sections[0]['name_at'] = 0
    place_name = len(shstrtab)
    shstrtab += b'.shstrtab\0'
    sections.append({'name': '.shstrtab', 'name_at': place_name, 'type': 3, 'flags': 0, 'addr': 0,
                     'offset': off, 'data': shstrtab, 'link': 0, 'entsize': 0})
    off += len(shstrtab)
    shoff = (off + 7) & ~7

    out = bytearray(shoff + shentsize * len(sections))
    ident = b'\x7fELF' + bytes([2 if is64 else 1, 1, 1]) + b'\0' * 9
    out[0:16] = ident
    fmt = 'HHI' + word * 3 + 'IHHHHHH'
    struct.pack_into(e + fmt, out, 16, etype, machine, 1, 0, ehsize, shoff, 0, ehsize, phentsize, phnum,
                     shentsize, len(sections), len(sections) - 1)

    def phdr(i, p_type, offset, vaddr, filesz, memsz, flags, p_align):
        at = ehsize + i * phentsize
        if is64:
            struct.pack_into(e + 'IIQQQQQQ', out, at, p_type, flags, offset, vaddr, vaddr, filesz, memsz, p_align)
        else:
            struct.pack_into(e + 'IIIIIIII', out, at, p_type, offset, vaddr, vaddr, filesz, memsz, flags, p_align)

    dyn = [b for b in blobs if b['name'] == '.dynamic'][0]
    phdr(0, 1, 0, 0, load_end, load_end, 7, align)
    phdr(1, 2, dyn['offset'], dyn['addr'], len(dyn['data']), len(dyn['data']), 6, 8)
    if project == 'segment-after':
        later = (load_end + 0xFFFF) & ~0xFFFF
        phdr(2, 1, load_end, later, 0, 16, 6, align)
    for s in sections:
        if s['data']:
            out[s['offset']:s['offset'] + len(s['data'])] = s['data']
    for i, s in enumerate(sections):
        at = shoff + i * shentsize
        if is64:
            struct.pack_into(e + 'IIQQQQIIQQ', out, at, s['name_at'], s['type'], s['flags'], s['addr'], s['offset'],
                             len(s['data']), s['link'], 0, 8, s['entsize'])
        else:
            struct.pack_into(e + 'IIIIIIIIII', out, at, s['name_at'], s['type'], s['flags'], s['addr'],
                             s['offset'], len(s['data']), s['link'], 0, 4, s['entsize'])
    return bytes(out)


ABI_ELF = {'arm64-v8a': dict(is64=True, machine=183), 'armeabi-v7a': dict(is64=False, machine=40),
           'x86_64': dict(is64=True, machine=62), 'x86': dict(is64=False, machine=3)}


def jar():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w') as z:
        z.writestr('com/runrev/android/Engine.class', b'\xca\xfe\xba\xbe')
    return buf.getvalue()


class Runtime(unittest.TestCase):
    """android_engine.py check on a made-up runtime folder."""

    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.tmp)
        self.root = os.path.join(self.tmp, 'Android')

    def make(self, abis=tuple(ABI_ELF), engine=None, external=None, skip=()):
        for abi in abis:
            for name in (ae.ENGINE,) + ae.EXTERNALS:
                if '%s/%s' % (abi, name) in skip:
                    continue
                kw = dict(ABI_ELF[abi])
                if name == ae.ENGINE:
                    kw.update(engine or {})
                else:
                    kw.update(project=None, exports=('getXtable',))
                    kw.update(external or {})
                touch(os.path.join(self.root, abi, name), elf(**kw))
        for name in ae.TOP_FILES:
            if name not in skip:
                touch(os.path.join(self.root, name), jar() if name == 'Classes' else b'<x/>')

    def problems(self, abis=()):
        problems, seen = ae.check(self.root, abis)
        return problems

    def assertProblem(self, problems, *words):
        hits = [p for p in problems if all(w in p for w in words)]
        self.assertTrue(hits, 'no problem with %s in %s' % (words, problems))

    def test_a_good_runtime(self):
        self.make()
        problems, seen = ae.check(self.root)
        self.assertEqual(problems, [])
        self.assertEqual(len(seen), 4 * 8)
        self.assertIn('arm64-v8a/Standalone:', seen[0])
        self.assertIn('LOAD aligned to 16384, API 21, needs libc.so, liblog.so', seen[0])

    def test_one_abi(self):
        self.make(abis=('x86',))
        self.assertEqual(self.problems(['x86']), [])
        self.assertProblem(self.problems(['x86', 'arm64-v8a']), 'has no arm64-v8a folder')
        self.assertProblem(self.problems(['mips']), 'no Android ABI mips')

    def test_no_abi_at_all(self):
        os.makedirs(self.root)
        self.assertProblem(self.problems(), 'has no ABI folder')

    def test_the_wrong_machine(self):
        self.make(abis=('arm64-v8a',), engine={'machine': 62})
        self.assertProblem(self.problems(), 'arm64-v8a/Standalone is for machine 62 (64-bit)')
        self.make(abis=('armeabi-v7a',), external={'is64': True})
        self.assertProblem(self.problems(), 'armeabi-v7a/RevDb is for machine 40 (64-bit)')

    def test_not_a_shared_library(self):
        self.make(abis=('x86_64',), engine={'etype': 2})
        self.assertProblem(self.problems(), 'x86_64/Standalone is not a shared library')

    def test_16_kb_pages(self):
        self.make(abis=('arm64-v8a', 'x86_64'), external={'align': 4096})
        self.assertProblem(self.problems(), 'arm64-v8a/RevZip has LOAD segments aligned to 4096, under 16 KB')
        self.assertProblem(self.problems(), 'x86_64/DbMysql has LOAD segments aligned to 4096')
        # the 32-bit ABIs have no devices with 16 KB pages
        shutil.rmtree(self.root)
        self.make(abis=('armeabi-v7a', 'x86'), engine={'align': 4096}, external={'align': 4096})
        self.assertEqual(self.problems(), [])

    def test_text_relocations(self):
        for how in ('tag', 'flag'):
            with self.subTest(how=how):
                shutil.rmtree(self.root, ignore_errors=True)
                self.make(abis=('x86',), external={'textrel': how})
                self.assertProblem(self.problems(), 'x86/RevXml has text relocations')

    def test_libraries_android_has_not_got(self):
        self.make(abis=('arm64-v8a',), external={'needed': ('libc.so', 'libc++_shared.so')})
        self.assertProblem(self.problems(), 'arm64-v8a/RevSecurity needs libc++_shared.so')
        shutil.rmtree(self.root)
        self.make(abis=('arm64-v8a',), engine={'needed': ('libc.so', 'libssl.so', 'libandroid.so')})
        problems = self.problems()
        self.assertProblem(problems, 'arm64-v8a/Standalone needs libssl.so, not a library of Android')
        self.assertFalse([p for p in problems if 'libandroid.so' in p])

    def test_the_lowest_android(self):
        self.make(abis=('x86_64',), engine={'api': 24})
        self.assertProblem(self.problems(), 'x86_64/Standalone is for Android API 24 and later, not 21')
        shutil.rmtree(self.root)
        self.make(abis=('x86_64',), external={'api': None})
        self.assertProblem(self.problems(), 'x86_64/RevPdfPrinter has no .note.android.ident')

    def test_the_project_section(self):
        cases = {
            None: 'has no .project section',
            'section-after': 'has sections after .project in memory (.after)',
            'segment-after': 'the LOAD segment that holds .project is not the last',
            'padded': ".project does not end its LOAD segment's data",
        }
        for project, words in cases.items():
            with self.subTest(project=project):
                shutil.rmtree(self.root, ignore_errors=True)
                self.make(abis=('armeabi-v7a',), engine={'project': project})
                self.assertProblem(self.problems(), 'armeabi-v7a/Standalone', words)
        # (only the engine needs one)
        shutil.rmtree(self.root)
        self.make(abis=('armeabi-v7a',), external={'project': None})
        self.assertEqual(self.problems(), [])

    def test_jni_onload(self):
        self.make(abis=('arm64-v8a',), engine={'exports': ('Java_com_runrev_android_Engine_doCreate',)})
        self.assertProblem(self.problems(), 'arm64-v8a/Standalone does not export JNI_OnLoad')
        # an undefined JNI_OnLoad is not an export
        self.assertNotIn('abort', ae.Elf(elf(exports=())).exports())

    def test_missing_files(self):
        self.make(abis=('x86',), skip=('x86/DbSqlite', 'Manifest.xml'))
        problems = self.problems()
        self.assertProblem(problems, 'has no x86/DbSqlite')
        self.assertProblem(problems, 'has no Manifest.xml')
        touch(os.path.join(self.root, 'Manifest.xml'))
        self.assertProblem(self.problems(), 'has no Manifest.xml (or it is empty)')

    def test_classes_is_a_jar(self):
        self.make(abis=('x86',))
        touch(os.path.join(self.root, 'Classes'), b'not a jar')
        self.assertProblem(self.problems(), 'Classes is not a jar')

    def test_not_elf(self):
        self.make(abis=('x86',))
        touch(os.path.join(self.root, 'x86', 'RevZip'), b'#!/bin/sh\n')
        self.assertProblem(self.problems(), 'x86/RevZip: not an ELF file')

    def test_the_elf_reader(self):
        for is64 in (True, False):
            with self.subTest(is64=is64):
                f = ae.Elf(elf(is64=is64, needed=('libm.so', 'libz.so'), exports=('JNI_OnLoad', 'Java_x')))
                self.assertEqual(f.needed(), ['libm.so', 'libz.so'])
                self.assertEqual(f.exports(), {'JNI_OnLoad', 'Java_x'})
                self.assertEqual(f.android_api(), 21)
                self.assertFalse(f.text_relocations())
                self.assertEqual([s['name'] for s in f.sections][-2:], ['.project', '.shstrtab'])

    def test_main(self):
        self.make(abis=('x86_64',))
        with contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(ae.main(['check', self.root, '--abi', 'x86_64']), 0)
        self.assertIn('passed every check', out.getvalue())
        touch(os.path.join(self.root, 'x86_64', 'RevDb'), elf(machine=183))
        with contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(ae.main(['check', self.root]), 1)
        self.assertIn('PROBLEM: x86_64/RevDb is for machine 183', out.getvalue())

    def test_the_names_agree_with_the_builder(self):
        """The IDE's Android builder takes these files from Runtime/Android."""
        builder = read('ide-support', 'revsaveasandroidstandalone.livecodescript')
        for name in ae.EXTERNALS + ('Standalone', 'Classes', 'Manifest.xml', 'notify_icon.png'):
            self.assertIn(name, builder, name)


# ---------------------------------------------------------------------------
# .github/workflows/android-engine.yml


class Workflow(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        try:
            import yaml
        except ImportError:
            raise unittest.SkipTest('no PyYAML')
        cls.text = read('.github', 'workflows', 'android-engine.yml')
        cls.wf = yaml.safe_load(cls.text)
        cls.job = cls.wf['jobs']['build']
        cls.steps = dict((s.get('name'), s) for s in cls.job['steps'])

    def test_every_architecture(self):
        include = self.job['strategy']['matrix']['include']
        abis = bash_assoc(read('tools', 'ci', 'build-android.sh'), 'ABIS')
        self.assertEqual(dict((x['arch'], x['abi']) for x in include), abis)
        self.assertFalse(self.job['strategy']['fail-fast'])

    def test_the_container(self):
        self.assertEqual(self.job['container']['image'], 'mirror.gcr.io/library/ubuntu:22.04')
        self.assertIn('/usr/local/lib/android:/usr/local/lib/android', self.job['container']['volumes'])
        self.assertTrue(self.job['env']['ANDROID_SDK'].startswith('/usr/local/lib/android/'))
        self.assertIn('python2', self.job['env']['BUILD_PKGS'].split())
        self.assertIn('openjdk-17-jdk-headless', self.job['env']['BUILD_PKGS'].split())

    def test_the_ndk_of_the_repository(self):
        run = self.steps['Set up the NDK and the SDK']['run']
        self.assertIn('config/android-ndk-version', run)
        self.assertNotIn(read('config', 'android-ndk-version').strip(), self.text)
        key = self.steps['Compute the cache key']['run']
        for name in ('config/android-ndk-version', 'tools/ci/build-android.sh', 'config.py', 'config/*.gypi',
                     'prebuilt/scripts/*.inc', 'prebuilt/scripts/*.sh', 'HEAD:thirdparty', '${ARCH}'):
            self.assertIn(name, key)

    def test_it_builds_and_checks(self):
        self.assertEqual(self.steps['Build the libraries']['run'].strip(),
                         'tools/ci/build-android.sh "$ARCH" --libraries')
        self.assertEqual(self.steps['Build the engine and the externals']['run'].strip(),
                         'tools/ci/build-android.sh "$ARCH" android-runtime')
        self.assertEqual(self.steps['Check what Android and the builder ask of them']['run'].strip(),
                         'python3 tools/ci/android_engine.py check android-runtime --abi "$ABI"')
        jni = ' '.join(self.steps['Check the engine against its Java layer (JNI)']['run'].replace('\\\n', '').split())
        self.assertIn('tools/ci/android_java.py jni --classes android-runtime/Classes --runtime android-runtime',
                      jni)
        upload = self.steps['Upload the runtime']['with']
        self.assertEqual(upload['path'], 'android-runtime/')

    def test_nothing_is_published(self):
        self.assertEqual(self.wf['permissions'], {'contents': 'read'})
        self.assertNotIn('release', self.text.lower().replace('nothing here\n# goes into a package or a release', ''))

    def test_what_starts_it(self):
        on = self.wf[True]
        paths = on['pull_request']['paths']
        self.assertEqual(paths, on['push']['paths'])
        for name in ('.github/workflows/android-engine.yml', 'tools/ci/build-android.sh', 'tools/ci/android_engine.py',
                     'tools/ci/android_java.py'):
            self.assertIn(name, paths)
        self.assertEqual(paths[0], '**')
        # the files the build runs, outside the folders it builds from
        for name in re.findall(r"'\.\./tools/([\w.-]+\.sh)'", read('config', 'java.gypi')):
            self.assertIn('tools/' + name, paths)

    def test_the_desktop_builds_skip_it(self):
        import yaml
        for wf in ('build-linux.yml', 'build-macos.yml', 'build-windows.yml'):
            ignore = yaml.safe_load(read('.github', 'workflows', wf))[True]['push']['paths-ignore']
            for name in ('.github/workflows/android-engine.yml', 'tools/ci/build-android.sh',
                         'tools/ci/android_engine.py', 'config/android-ndk-version'):
                self.assertIn(name, ignore, wf)


if __name__ == '__main__':
    unittest.main()
