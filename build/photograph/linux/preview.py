#!/usr/bin/env python3
"""One take of one variant of the preview shots, inside a fresh container.

photograph.ps1 writes /work/shots.json (this variant's shots: name, show) and
/work/scene.env, mounts the repo read-only at /inglenook, and runs this. It
serves the repo over HTTP, opens Ports/preview/dist/<variant>/index.html in
the pinned headless Chromium, and writes /work/<name>.png for each shot.

The page is the bare page: no scene, frame or margin. Reduced motion is
forced. A shot is taken once the page has loaded, every font is
in, and two grabs 300 ms apart are equal. The top of the page is the
1280x960 viewport. A section is found by its accessible name (aria-label, or
the text its aria-labelledby points at) on a 1280x6400 viewport, and cropped
to its box plus 16 px of the page around it.

Any request the page makes that fails (Google Fonts, an image)
fails the take.
"""
import base64
import functools
import http.server
import json
import os
import subprocess
import sys
import threading
import time

TOP = (1280, 960)
TALL = (1280, 6400)
SECTION_MARGIN = 16
SETTLE = 0.3
TIMEOUT = 60


def fail(message):
    print(f"photograph: {message}", file=sys.stderr)
    sys.exit(1)


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def serve(root):
    handler = functools.partial(QuietHandler, directory=root)
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server.server_address[1]


class Browser:
    """Chromium over --remote-debugging-pipe: JSON messages ended by a NUL byte."""

    def __init__(self):
        to_chrome_r, self.to_chrome = os.pipe()
        self.from_chrome, from_chrome_w = os.pipe()

        def fds():
            # Chromium reads commands from fd 3 and writes replies to fd 4.
            r, w = os.dup(to_chrome_r), os.dup(from_chrome_w)
            os.dup2(r, 3)
            os.dup2(w, 4)

        # Software drawing, every compositor stage run before a frame is drawn, and
        # nothing drawn in parts or late: without these, takes can differ by a level
        # along rounded corners.
        self.proc = subprocess.Popen(
            ["chromium", "--headless=new", "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
             "--remote-debugging-pipe", "--user-data-dir=/tmp/chromium", "--no-first-run",
             "--no-default-browser-check", "--force-color-profile=srgb", "--force-device-scale-factor=1",
             "--force-prefers-reduced-motion", "--disable-extensions", "--mute-audio",
             "--disable-partial-raster", "--disable-checker-imaging", "--run-all-compositor-stages-before-draw",
             "--disable-features=PaintHolding", "about:blank"],
            pass_fds=(3, 4), preexec_fn=fds,
            stdout=open("/tmp/chromium.log", "wb"), stderr=subprocess.STDOUT)
        os.close(to_chrome_r)
        os.close(from_chrome_w)
        self.buffer = b""
        self.next_id = 0
        self.events = []
        self.session = None

    def _read(self):
        while b"\0" not in self.buffer:
            chunk = os.read(self.from_chrome, 1 << 20)
            if not chunk:
                fail("Chromium closed the debugging pipe. Its log:\n" + open("/tmp/chromium.log", errors="replace").read()[-2000:])
            self.buffer += chunk
        message, self.buffer = self.buffer.split(b"\0", 1)
        return json.loads(message)

    def call(self, method, params=None, browser=False):
        self.next_id += 1
        message = {"id": self.next_id, "method": method, "params": params or {}}
        if self.session and not browser:
            message["sessionId"] = self.session
        os.write(self.to_chrome, json.dumps(message).encode() + b"\0")
        while True:
            reply = self._read()
            if reply.get("id") == self.next_id:
                if "error" in reply:
                    fail(f"Chromium refused {method}: {reply['error'].get('message')}")
                return reply.get("result", {})
            if "method" in reply:
                self.events.append(reply)

    def evaluate(self, expression):
        result = self.call("Runtime.evaluate", {"expression": expression, "awaitPromise": True, "returnByValue": True})
        if "exceptionDetails" in result:
            fail(f"the page threw: {result['exceptionDetails'].get('text')} {result['exceptionDetails'].get('exception', {}).get('description', '')}")
        return result["result"].get("value")

    def drain(self):
        # Events that arrived without a reply: ask for nothing, read what is there.
        self.evaluate("0")
        events, self.events = self.events, []
        return events


def main():
    variant = os.environ["INGLENOOK_VARIANT"]
    shots = json.load(open("/work/shots.json"))
    port = serve("/inglenook")
    url = f"http://127.0.0.1:{port}/Ports/preview/dist/{variant}/index.html"

    b = Browser()
    target = b.call("Target.createTarget", {"url": "about:blank"})["targetId"]
    b.session = b.call("Target.attachToTarget", {"targetId": target, "flatten": True}, browser=True)["sessionId"]
    for domain in ("Page", "Network", "Runtime"):
        b.call(f"{domain}.enable")
    b.call("Network.setCacheDisabled", {"cacheDisabled": True})
    b.call("Emulation.setEmulatedMedia", {"features": [{"name": "prefers-reduced-motion", "value": "reduce"}]})

    def viewport(size):
        b.call("Emulation.setDeviceMetricsOverride", {"width": size[0], "height": size[1], "deviceScaleFactor": 1, "mobile": False})

    viewport(TOP)
    b.call("Page.navigate", {"url": url})

    # Loaded, every request answered and none failed, fonts in.
    urls, pending, failed = {}, set(), []
    loaded = False
    start = time.monotonic()
    while True:
        for e in b.drain():
            m, p = e["method"], e.get("params", {})
            if m == "Page.loadEventFired":
                loaded = True
            elif m == "Network.requestWillBeSent":
                if p["request"]["url"].endswith("/favicon.ico"):
                    continue  # the browser's own, not the page's
                urls[p["requestId"]] = p["request"]["url"]
                pending.add(p["requestId"])
            elif p.get("requestId") not in urls:
                continue
            elif m == "Network.responseReceived" and p["response"]["status"] >= 400:
                failed.append(f"{p['response']['url']} answered {p['response']['status']}")
            elif m == "Network.loadingFailed":
                pending.discard(p["requestId"])
                failed.append(f"{urls.get(p['requestId'], p['requestId'])} failed: {p.get('errorText')}")
            elif m == "Network.loadingFinished":
                pending.discard(p["requestId"])
        if failed:
            fail(f"the preview page ({variant}) could not load everything it asks for:\n    " + "\n    ".join(failed))
        if loaded and not pending and b.evaluate(
                "document.fonts.ready.then(() => document.fonts.status === 'loaded'"
                " && [...document.fonts].every(f => f.status !== 'loading'))"):
            break
        if time.monotonic() - start > TIMEOUT:
            fail(f"the preview page ({variant}) was not ready after {TIMEOUT}s: "
                 f"{len(pending)} requests open ({', '.join(sorted(urls[r] for r in pending if r in urls))}).")
        time.sleep(0.2)

    def settled(clip=None):
        # Two equal grabs, 300 ms apart.
        params = {"format": "png", "captureBeyondViewport": False}
        if clip:
            params["clip"] = dict(clip, scale=1)
        a = b.call("Page.captureScreenshot", params)["data"]
        t = time.monotonic()
        while True:
            time.sleep(SETTLE)
            c = b.call("Page.captureScreenshot", params)["data"]
            if c == a:
                return base64.b64decode(c)
            a = c
            if time.monotonic() - t > TIMEOUT:
                fail(f"the preview page ({variant}) never settled after {TIMEOUT}s.")

    find = """(name => {
      const label = s => s.getAttribute('aria-label') ||
        (s.getAttribute('aria-labelledby') ? (document.getElementById(s.getAttribute('aria-labelledby')) || {}).textContent || '' : '');
      const s = [...document.querySelectorAll('section')].find(s => label(s).trim() === name);
      if (!s) return null;
      const r = s.getBoundingClientRect();
      return { x: r.left + scrollX, y: r.top + scrollY, width: r.width, height: r.height, page: document.documentElement.scrollHeight };
    })(%s)"""
    tops = [s for s in shots if s["show"] == "top"]
    sections = [s for s in shots if s["show"] != "top"]
    for s in tops:
        open(f"/work/{s['name']}.png", "wb").write(settled())
        print(f"{s['name']}: top of the page, {TOP[0]}x{TOP[1]}", file=sys.stderr)
    if sections:
        viewport(TALL)
        b.evaluate("window.scrollTo(0, 0)")
        for s in sections:
            box = b.evaluate(find % json.dumps(s["show"]))
            if not box:
                fail(f"Ports/preview/shots.json: the preview page ({variant}) has no section named \"{s['show']}\".")
            x1 = max(0, int(box["x"]) - SECTION_MARGIN)
            y1 = max(0, int(box["y"]) - SECTION_MARGIN)
            x2 = min(TALL[0], int(-(-(box["x"] + box["width"]) // 1)) + SECTION_MARGIN)
            y2 = int(-(-(box["y"] + box["height"]) // 1)) + SECTION_MARGIN
            if y2 > TALL[1]:
                fail(f"the section \"{s['show']}\" ends below {TALL[1]} px; the Photographer's tall viewport is too short for the page.")
            clip = {"x": x1, "y": y1, "width": x2 - x1, "height": y2 - y1}
            open(f"/work/{s['name']}.png", "wb").write(settled(clip))
            print(f"{s['name']}: section \"{s['show']}\", {clip['width']}x{clip['height']}+{x1}+{y1}", file=sys.stderr)
    b.proc.terminate()


if __name__ == "__main__":
    main()
