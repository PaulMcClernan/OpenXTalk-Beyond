#!/usr/bin/env python3
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

"""Serves the OXT-Beyond web IDE on this computer and opens it.

    python3 serve.py [port]

The IDE is at http://localhost:8000/ (or the port given). Only this
computer can reach it. Press Ctrl+C to stop.

build_site.py --zip puts this file beside the site's index.html, so that
the release's web IDE zip runs with nothing but Python 3 (a browser loads
no WebAssembly from a file: address). Any other web server works too.
The browser is told to check each file again on every visit, so that it
never starts an older IDE from its cache after a newer one was copied
over it. Standard library only.
"""

import functools
import http.server
import os
import sys
import webbrowser

HERE = os.path.dirname(os.path.abspath(__file__))


class Handler(http.server.SimpleHTTPRequestHandler):
    # Older Pythons' tables have no .wasm, and Windows' registry can map
    # .js to text/plain; browsers insist on both
    extensions_map = dict(http.server.SimpleHTTPRequestHandler.extensions_map,
                          **{'.wasm': 'application/wasm', '.js': 'text/javascript'})

    def end_headers(self):
        # Checked again on every visit: a browser keeps no older IDE
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

    def log_message(self, *args):
        pass


class Server(http.server.ThreadingHTTPServer):
    # On Windows, reusing the address lets a second server take a port that
    # another still serves, and the browser keeps reaching the other one (an
    # older IDE, say): there, a port in use is refused instead
    allow_reuse_address = os.name != 'nt'


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    if not os.path.isfile(os.path.join(HERE, 'index.html')):
        sys.exit('There is no index.html beside serve.py: extract the whole zip and run serve.py there.')
    try:
        server = Server(('127.0.0.1', port), functools.partial(Handler, directory=HERE))
    except OSError as e:
        sys.exit('Port %d of this computer is in use (%s), maybe by another web IDE server that is '
                 'still running: close its window (or end python in Task Manager) and start again, '
                 'or run  python serve.py %d  to use another port.' % (port, e.strerror or e, port + 1))
    url = 'http://localhost:%d/' % port
    print('OXT-Beyond web IDE: %s  (Ctrl+C to stop)' % url)
    webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    main()
