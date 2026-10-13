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

"""The MCP server of the xTalk MCP Bridge
(ide/Extensions/org.openxtalk.plugin.mcpbridge/mcp/server.js), driven as
Claude's apps drive it: JSON-RPC over its standard input and output, with
a stand-in for OXT-Beyond's side (a socket server on 127.0.0.1 that answers
as mcpbridge-tools.livecodescript does, and the file with its port and
token). OXT-Beyond's side itself is tested by tests/lcs/mcpbridge.

It checks that the server answers initialize, ping and tools/list without
OXT-Beyond, that its tools are the ones OXT-Beyond knows (its kTools) and
those the desktop extension's manifest lists, that a call goes to OXT-Beyond
with the token after a hello and comes back as MCP content (a picture as an
image), that a refused token, a missing file or a closed IDE comes back as
a tool error that says what to do, and that calls go one at a time.

Skipped where Node.js is not installed.

  python3 -m unittest discover -s tools/ci/tests
"""

import json
import os
import re
import shutil
import socket
import subprocess
import tempfile
import threading
import unittest

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
PLUGIN = os.path.join(REPO, 'ide', 'Extensions', 'org.openxtalk.plugin.mcpbridge')
SERVER = os.path.join(PLUGIN, 'mcp', 'server.js')
NODE = shutil.which('node')


class FakeOXT:
    """OXT-Beyond's side: answers each line with handler(request)."""

    def __init__(self, handler, token='0123456789abcdef0123456789abcdef'):
        self.handler = handler
        self.token = token
        self.requests = []
        self.connections = 0
        self.in_flight = 0
        self.most_in_flight = 0
        self.lock = threading.Lock()
        self.listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.listener.bind(('127.0.0.1', 0))
        self.listener.listen(5)
        self.port = self.listener.getsockname()[1]
        threading.Thread(target=self.serve, daemon=True).start()

    def serve(self):
        while True:
            try:
                conn, _ = self.listener.accept()
            except OSError:
                return
            self.connections += 1
            threading.Thread(target=self.client, args=(conn,), daemon=True).start()

    def client(self, conn):
        data = b''
        with conn:
            while True:
                try:
                    chunk = conn.recv(65536)
                except OSError:
                    return
                if not chunk:
                    return
                data += chunk
                while b'\n' in data:
                    line, data = data.split(b'\n', 1)
                    request = json.loads(line.decode('utf-8'))
                    self.requests.append(request)
                    with self.lock:
                        self.in_flight += 1
                        self.most_in_flight = max(self.most_in_flight, self.in_flight)
                    if request.get('token') != self.token:
                        reply = {'ok': False, 'error': 'The token is not the bridge\'s.'}
                    elif request.get('method') == 'hello':
                        reply = {'ok': True, 'protocol': 1, 'tools': 'x'}
                    else:
                        reply = self.handler(request)
                    with self.lock:
                        self.in_flight -= 1
                    if reply is None:
                        return
                    reply = dict(reply, id=request.get('id'))
                    conn.sendall((json.dumps(reply) + '\n').encode('utf-8'))

    def close(self):
        self.listener.close()


@unittest.skipUnless(NODE, 'Node.js is not installed')
class McpBridgeServerTest(unittest.TestCase):

    def setUp(self):
        self.folder = tempfile.mkdtemp()
        self.info = os.path.join(self.folder, 'mcp-bridge.json')
        self.oxt = None
        self.proc = None
        self.next_id = 1

    def tearDown(self):
        if self.proc:
            self.proc.stdin.close()
            try:
                self.proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                self.proc.kill()
            self.proc.stdout.close()
            self.proc.stderr.close()
        if self.oxt:
            self.oxt.close()
        shutil.rmtree(self.folder, ignore_errors=True)

    def start_oxt(self, handler, protocol=1, token=None):
        self.oxt = FakeOXT(handler)
        with open(self.info, 'w') as f:
            json.dump({'protocol': protocol, 'port': self.oxt.port,
                       'token': token or self.oxt.token, 'engine': 'test'}, f)

    def start_server(self):
        env = dict(os.environ, OXT_MCP_BRIDGE_FILE=self.info, OXT_MCP_TIMEOUT_MS='20000')
        self.proc = subprocess.Popen([NODE, SERVER], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE, env=env)

    def send(self, method, params=None, notify=False):
        message = {'jsonrpc': '2.0', 'method': method}
        if params is not None:
            message['params'] = params
        if not notify:
            message['id'] = self.next_id
            self.next_id += 1
        self.proc.stdin.write((json.dumps(message) + '\n').encode('utf-8'))
        self.proc.stdin.flush()
        return message.get('id')

    def receive(self):
        line = self.proc.stdout.readline()
        if not line:
            self.fail('the server ended: ' + self.proc.stderr.read().decode('utf-8', 'replace'))
        return json.loads(line)

    def request(self, method, params=None):
        sent = self.send(method, params)
        reply = self.receive()
        self.assertEqual(reply.get('id'), sent)
        return reply

    def call(self, name, arguments=None):
        reply = self.request('tools/call', {'name': name, 'arguments': arguments or {}})
        self.assertIn('result', reply, reply)
        return reply['result']

    def initialize(self, version='2025-06-18'):
        reply = self.request('initialize', {'protocolVersion': version, 'capabilities': {},
                                            'clientInfo': {'name': 'test', 'version': '1'}})
        self.send('notifications/initialized', notify=True)
        return reply

    # --- without OXT-Beyond --------------------------------------------------

    def test_initialize_and_list_without_the_ide(self):
        self.start_server()
        reply = self.initialize('2025-06-18')
        result = reply['result']
        self.assertEqual(result['protocolVersion'], '2025-06-18')
        self.assertIn('tools', result['capabilities'])
        self.assertEqual(result['serverInfo']['name'], 'oxt-beyond')
        self.assertIn('xtalk_guide', result['instructions'])
        self.assertEqual(self.request('ping')['result'], {})
        tools = self.request('tools/list')['result']['tools']
        for tool in tools:
            self.assertEqual(tool['inputSchema']['type'], 'object', tool['name'])
            self.assertTrue(tool['description'], tool['name'])
            self.assertIn('readOnlyHint', tool['annotations'], tool['name'])
        names = [t['name'] for t in tools]
        self.assertEqual(len(names), len(set(names)))
        self.assertEqual(self.request('nothing/here').get('error', {}).get('code'), -32601)

    def test_an_unknown_version_gets_the_newest(self):
        self.start_server()
        reply = self.initialize('1999-01-01')
        self.assertRegex(reply['result']['protocolVersion'], r'^\d{4}-\d{2}-\d{2}$')
        self.assertNotEqual(reply['result']['protocolVersion'], '1999-01-01')

    def test_the_tools_are_those_oxt_and_the_manifest_know(self):
        self.start_server()
        self.initialize()
        names = [t['name'] for t in self.request('tools/list')['result']['tools']]
        with open(os.path.join(PLUGIN, 'mcpbridge-tools.livecodescript'), encoding='utf-8') as f:
            match = re.search(r'^constant kTools = "([^"]*)"', f.read(), re.M)
        self.assertIsNotNone(match, 'kTools in mcpbridge-tools.livecodescript')
        self.assertEqual(names, match.group(1).split(','))
        with open(os.path.join(PLUGIN, 'mcp', 'manifest.json'), encoding='utf-8') as f:
            manifest = json.load(f)
        self.assertEqual([t['name'] for t in manifest['tools']], names)
        self.assertEqual(manifest['server']['entry_point'], 'server.js')

    def test_a_call_without_the_ide_says_how_to_turn_it_on(self):
        self.start_server()
        self.initialize()
        result = self.call('list_stacks')
        self.assertTrue(result['isError'])
        self.assertIn('xTalk MCP Bridge', result['content'][0]['text'])

    def test_a_tool_there_is_not(self):
        self.start_server()
        self.initialize()
        result = self.call('format_disk')
        self.assertTrue(result['isError'])

    # --- with a stand-in for OXT-Beyond ---------------------------------------

    def test_a_call_goes_to_the_ide_with_the_token(self):
        def handler(request):
            return {'ok': True, 'isError': False, 'text': 'read ' + json.dumps(request['arguments'])}
        self.start_oxt(handler)
        self.start_server()
        self.initialize()
        result = self.call('read_stack', {'stack': 'Héllo', 'id': 1003})
        self.assertFalse(result['isError'])
        self.assertEqual(result['content'], [{'type': 'text', 'text': 'read {"stack": "H\\u00e9llo", "id": 1003}'}])
        methods = [r['method'] for r in self.oxt.requests]
        self.assertEqual(methods, ['hello', 'call'])
        call = self.oxt.requests[1]
        self.assertEqual(call['tool'], 'read_stack')
        self.assertEqual(call['token'], self.oxt.token)
        self.assertEqual(call['arguments'], {'stack': 'Héllo', 'id': 1003})
        # The connection is kept for the next call
        self.call('list_stacks')
        self.assertEqual(self.oxt.connections, 1)

    def test_a_picture_comes_back_as_an_image(self):
        def handler(request):
            return {'ok': True, 'isError': False, 'text': 'A picture', 'image': 'iVBORw0KGgo=', 'imageType': 'image/png'}
        self.start_oxt(handler)
        self.start_server()
        self.initialize()
        result = self.call('look_at_card')
        self.assertEqual(result['content'][1], {'type': 'image', 'data': 'iVBORw0KGgo=', 'mimeType': 'image/png'})

    def test_a_tool_error_is_a_tool_error(self):
        self.start_oxt(lambda request: {'ok': True, 'isError': True, 'text': 'Nothing was changed'})
        self.start_server()
        self.initialize()
        result = self.call('make_changes', {'changes': []})
        self.assertTrue(result['isError'])
        self.assertEqual(result['content'][0]['text'], 'Nothing was changed')

    def test_a_wrong_token_is_refused(self):
        self.start_oxt(lambda request: {'ok': True, 'isError': False, 'text': 'should not run'}, token='f' * 32)
        self.start_server()
        self.initialize()
        result = self.call('list_stacks')
        self.assertTrue(result['isError'])
        self.assertIn('token', result['content'][0]['text'])
        self.assertEqual([r['method'] for r in self.oxt.requests], ['hello'])

    def test_another_protocol_is_refused(self):
        self.start_oxt(lambda request: {'ok': True, 'isError': False, 'text': 'x'}, protocol=2)
        self.start_server()
        self.initialize()
        result = self.call('list_stacks')
        self.assertTrue(result['isError'])
        self.assertIn('protocol', result['content'][0]['text'])
        self.assertEqual(self.oxt.requests, [])

    def test_the_ide_closing_mid_call(self):
        self.start_oxt(lambda request: None)
        self.start_server()
        self.initialize()
        result = self.call('run_code', {'code': 'put 1'})
        self.assertTrue(result['isError'])
        self.assertIn('closed the connection', result['content'][0]['text'])

    def test_calls_go_one_at_a_time(self):
        import time

        def handler(request):
            time.sleep(0.2)
            return {'ok': True, 'isError': False, 'text': request['tool']}
        self.start_oxt(handler)
        self.start_server()
        self.initialize()
        sent = [self.send('tools/call', {'name': name, 'arguments': {}})
                for name in ('list_stacks', 'xtalk_guide', 'list_changes')]
        replies = {}
        for _ in sent:
            reply = self.receive()
            replies[reply['id']] = reply['result']['content'][0]['text']
        self.assertEqual([replies[i] for i in sent], ['list_stacks', 'xtalk_guide', 'list_changes'])
        self.assertEqual(self.oxt.most_in_flight, 1)


if __name__ == '__main__':
    unittest.main()
