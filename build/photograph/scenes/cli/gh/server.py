"""The GitHub API for gh's part of the CLI/TUI scene: a few fixed answers on a Unix
socket, so gh repo view renders the staged README without a network or a login.
gh reaches it through its own http_unix_socket setting. Run with: python3 server.py SOCKET README"""
import base64
import json
import os
import socketserver
import sys
from http.server import BaseHTTPRequestHandler

socket_path, readme_path = sys.argv[1], sys.argv[2]
with open(readme_path, "rb") as f:
    readme = base64.b64encode(f.read()).decode()

REPO = {"name": "inglenook", "owner": {"login": "inglenook"},
        "description": "A cozy day and night color theme"}


class Handler(BaseHTTPRequestHandler):
    def answer(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self):
        self.rfile.read(int(self.headers.get("Content-Length", 0)))
        if self.path.endswith("/graphql"):
            self.answer(200, {"data": {"repository": REPO}})
        else:
            self.answer(404, {"message": "Not Found"})

    def do_GET(self):
        if self.path.split("?")[0].endswith("/repos/inglenook/inglenook/readme"):
            self.answer(200, {"name": "README.md", "content": readme, "encoding": "base64",
                              "html_url": "https://github.com/inglenook/inglenook/blob/main/README.md"})
        else:
            self.answer(404, {"message": "Not Found"})

    def log_message(self, *args):
        pass

    def address_string(self):
        return "scene"


if os.path.exists(socket_path):
    os.remove(socket_path)
with socketserver.UnixStreamServer(socket_path, Handler) as server:
    server.serve_forever()
