#!/usr/bin/env python

# This script runs the command that links the web engine: emcc turns the
# relocatable WebAssembly object that gyp links (standalone-community.o) into
# standalone-community-<version>.js and .wasm, with the engine's JavaScript
# libraries, and writes an HTML page for it from the shell template.
#
# It runs under the Python 2.7 that gyp uses, and under Python 3.

from __future__ import print_function

import os
import re
import subprocess
import sys

# Link settings
# -------------
#
# The compiler settings are in config/emscripten-settings.gypi; these only
# apply when linking.
settings = {
    # The engine's main loop yields to the browser and is resumed by events
    # and timers (em-async.js). Asyncify saves and restores the WebAssembly
    # call stack for that, so a wait can yield from inside a handler too.
    'ASYNCIFY': 1,
    # Room for the saved locals of every function on the stack when the
    # engine yields; deep script recursion needs more than the default.
    'ASYNCIFY_STACK_SIZE': 4 * 1024 * 1024,
    # Asyncify assumes that every call through a function pointer can
    # yield, so it instruments nearly everything, and its largest
    # functions made Safari's optimizing WebAssembly compiler use
    # gigabytes of memory until Safari reloaded the page. So code that the
    # engine never yields inside is left out of it (ASYNCIFY_REMOVE,
    # below), and wasm-opt does not inline a large function into its one
    # caller.
    'BINARYEN_EXTRA_PASSES': '--one-caller-inline-max-function-size=200',

    # The C stack. The engine stops a script's recursion well before this
    # (the recursionLimit, 400000 bytes by default).
    'STACK_SIZE': 4 * 1024 * 1024,

    'ALLOW_MEMORY_GROWTH': 1,
    'INITIAL_MEMORY': 64 * 1024 * 1024,

    # The function pointers of LCB handlers (callbacks that extensions give
    # C code) are JavaScript functions added to the function table
    # (libfoundation/src/foundation-handler.cpp)
    'ALLOW_TABLE_GROWTH': 1,

    # The engine only runs in web pages
    'ENVIRONMENT': 'web',

    # C++ exceptions are caught where code was compiled to catch them. The
    # engine is not (-fno-exceptions), but revDB's SQLite driver catches
    # what the SQLite library throws on an SQL error (revdb/revdb.gyp,
    # thirdparty/libsqlite/libsqlite.gyp); without this, a throw aborts the
    # engine.
    'DISABLE_EXCEPTION_CATCHING': 0,

    # Runtime functions that the engine's JavaScript (em-*.js) and the page
    # call through Module
    'EXPORTED_RUNTIME_METHODS': [
        'ccall',
        'cwrap',
        'HEAPU8',
        'writeArrayToMemory',
        'addRunDependency',
        'removeRunDependency',
        ],
    }

# The functions that Asyncify leaves alone (names as the C++ demangler
# writes them, * for any characters). Only code that the engine can never
# yield inside belongs here: the engine yields only in MCScreenDC::wait
# (em-async.js), so a library belongs here when nothing it calls back
# (a draw, a read, a comparison, a log function) runs script or waits. If
# the engine did yield inside one of these, the stack would be restored
# wrongly; an engine linked with Asyncify's asserts traps there instead
# (BINARYEN_EXTRA_PASSES with --pass-arg=asyncify-asserts added).
asyncify_remove = [
    # Skia, ICU, FreeType and HarfBuzz: drawing, text and Unicode
    'Sk*', '(anonymous namespace)::Sk*', 'sk_*',
    'icu_78::*', '*_78',
    'FT_*', 'ft_*', 'tt_*', 'TT_*', 'cff_*', 'cf2_*', 'ps_*', 'af_*', 'T1_*', 't1_*', 'sfnt_*',
    'pfr_*', 'pcf_*', 'bdf_*', 'gray_*', 'psh_*',
    'hb_*', 'OT::*',
    # OpenSSL: its certificate check (opensslsocket.cpp) runs no script
    'ossl_*', 'OSSL_*', 'EVP_*', 'evp_*', 'RSA_*', 'rsa_*', 'AES_*', 'aes_*', 'BN_*', 'bn_*',
    'CRYPTO_*', 'ASN1_*', 'asn1_*', 'kdf_*', 'v2i_*', 'i2r_*', 'X509*', 'x509*', 'SHA1*',
    'SHA256*', 'SHA512*', 'sha1_*', 'sha256_*', 'sha512_*', 'MD5*', 'md5_*', 'HMAC*', 'PEM_*',
    'PKCS*', 'OPENSSL_*', 'RAND_*',
    # PCRE and the engine's regular expressions (regex.cpp), which set no
    # callouts
    'MCR_compile*', 'MCR_exec*', 'MCR_free*', 'MCR_clearcache*',
    'pcre16_*', 'match', 'match_ref', 'internal_dfa_exec', 'compile_regex', 'compile_branch',
    'find_minlength', 'set_start_bits', 'find_fixedlength', 'could_be_empty_branch',
    'auto_possessify', 'check_escape', 'add_to_class', 'add_list_to_class',
    'add_not_list_to_class', 'first_significant_code', 'find_recurse', 'is_anchored',
    'is_startline', 'find_firstassertedchar', 'compare_opcodes', 'get_chr_property_list',
    'check_posix_syntax', 'read_repeat_counts', 'expand_workspace', 'adjust_recurse',
    'get_othercase_range', 'set_table_bit', 'set_type_bits', 'set_nottype_bits',
    # libpng, libjpeg and zlib: an image is decoded from data already read
    'png_*', 'jpeg_*', 'jinit_*', 'read_markers',
    'inflate*', 'deflate*', 'crc32*', 'adler32*', '_tr_*',
    # SQLite, whose sync no longer waits for the browser's storage
    # (thirdparty/libsqlite/libsqlite.gyp), and whose callbacks (revDB's
    # row counts, its lpad() function) run no script; its largest static
    # functions by name
    'sqlite3*', 'fts3*', 'fts5*', 'yy_reduce', 'balance', 'resolveExprStep', 'exprAnalyze',
    'multiSelect',
    # operator new calls a new handler through a pointer, and the engine
    # sets none; leaving it out leaves out much of the engine that only
    # allocates
    'operator new*',
    ]
settings['ASYNCIFY_REMOVE'] = asyncify_remove

# Engine functions that JavaScript calls by name are exported. Those that
# the engine's own libraries call with ccall() are found in them (below).
exported_functions = [
    '_main',
    '_malloc',
    '_free',
    # runs an LCB handler for the function that stands for it
    # (libfoundation/src/foundation-handler.cpp)
    '_MCHandlerEmscriptenInvoke',
    ]

# Get the build type and the compiler command
# -------------------------------------------

env_verbose = os.getenv('V', '0')
# em++ rather than emcc, so that the C++ library is linked
env_emcc = os.getenv('EMXX', 'em++')
env_build_type = os.getenv('BUILDTYPE', 'Debug')
env_cflags = os.getenv('CFLAGS', '')

if env_build_type == 'Release':
    optimisation_flags = ['-Os', '-g0']
    settings['ASSERTIONS'] = 0
else:
    # Keep function names, so that stack traces can be read
    optimisation_flags = ['-O2', '-g2']
    settings['ASSERTIONS'] = 1

# Separate out separate elements of command line
emcc = env_emcc.split()
cflags = env_cflags.split()

# Process command line options
# ----------------------------
#
# Each option absorbs all subsequent arguments up to the next option.
# Options are identified by the fact they start with "--".

option = None
options = {}
for arg in sys.argv[1:]:
    if arg.startswith('--'):
        option = arg[2:]
        options[option] = []
    else:
        if option is None:
            print('ERROR: unrecognized option \'{}\''.format(arg))
            sys.exit(1)
        options[option].append(arg)

for required in ['input', 'output']:
    if required not in options or len(options[required]) == 0:
        print('ERROR: missing option \'--{}\''.format(required))
        sys.exit(1)

# Export every engine function that the JavaScript libraries call with
# ccall('<name>', ...)
ccall_re = re.compile(r'''\bccall\(\s*['"]([A-Za-z_][A-Za-z0-9_]*)['"]''')
for library in options.get('js-library', []):
    with open(library) as library_file:
        for name in ccall_re.findall(library_file.read()):
            if '_' + name not in exported_functions:
                exported_functions.append('_' + name)

settings['EXPORTED_FUNCTIONS'] = exported_functions

# Construct emcc command line
# ---------------------------

command = emcc + optimisation_flags + cflags

for input in options['input']:
    command.append(input)

command += ['-o', options['output'][0]]

for setting in sorted(settings.keys()):
    value = settings[setting]
    if isinstance(value, list):
        value = ','.join(value)
    command += ['-s', '{}={}'.format(setting, value)]

for option in ['pre-js', 'shell-file', 'js-library']:
    if option in options:
        for value in options[option]:
            command += ['--' + option, value]

# The browser's storage (IndexedDB) as a file system, which keeps the home
# folder between visits (em-system.js)
command += ['-lidbfs.js']

# Run emcc
# --------

if env_verbose.strip() != '0':
    print(" ".join(command))

emcc_result = subprocess.call(command)
sys.exit(emcc_result)
