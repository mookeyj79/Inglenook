# A stand-in for a language server in the Helix editor scene: answers the LSP handshake and
# reports one error under the misspelled call in each file Helix opens, as the PowerShell
# language server would. Nothing else. Fixed content, no colors.
import json, sys

ERROR = 'Get-Luminence'
MESSAGE = "The term 'Get-Luminence' is not recognized as a name of a cmdlet or function."
inp, out = sys.stdin.buffer, sys.stdout.buffer


def read():
    length = 0
    while True:
        line = inp.readline()
        if not line:
            sys.exit(0)
        line = line.strip()
        if not line:
            break
        name, _, value = line.partition(b':')
        if name.lower() == b'content-length':
            length = int(value)
    return json.loads(inp.read(length))


def send(msg):
    body = json.dumps(msg).encode()
    out.write(b'Content-Length: %d\r\n\r\n' % len(body) + body)
    out.flush()


while True:
    msg = read()
    method = msg.get('method')
    if method == 'initialize':
        send({'jsonrpc': '2.0', 'id': msg['id'], 'result': {
            'capabilities': {'textDocumentSync': 1}, 'serverInfo': {'name': 'scene'}}})
    elif method == 'textDocument/didOpen':
        doc = msg['params']['textDocument']
        diagnostics = []
        for n, text in enumerate(doc['text'].split('\n')):
            col = text.find(ERROR)
            if col >= 0:
                diagnostics.append({
                    'range': {'start': {'line': n, 'character': col},
                              'end': {'line': n, 'character': col + len(ERROR)}},
                    'severity': 1, 'source': 'PowerShell', 'message': MESSAGE})
        send({'jsonrpc': '2.0', 'method': 'textDocument/publishDiagnostics',
              'params': {'uri': doc['uri'], 'diagnostics': diagnostics}})
    elif method == 'exit':
        sys.exit(0)
    elif 'id' in msg:
        send({'jsonrpc': '2.0', 'id': msg['id'], 'result': None})
