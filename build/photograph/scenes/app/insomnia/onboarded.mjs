// Stands in for three clicks the reader makes: Continue on Insomnia's first-run Welcome
// page, Create order (the request seed.sh made) in the Scratch Pad's sidebar, and its
// Body tab. The Welcome page keeps its answer only in the window's localStorage, which
// no config file sets, so this sets the same key over the DevTools protocol and opens the
// app's start page, the local Scratch Pad when no one has logged in. It changes nothing else.
// Run with Insomnia's own Node: ELECTRON_RUN_AS_NODE=1 insomnia onboarded.mjs <port>
const port = process.argv[2] || '9222';
const key = 'hasSeenOnboardingV13.3';
const sleep = ms => new Promise(r => setTimeout(r, ms));

async function mainPage() {
  for (let i = 0; i < 120; i++) {
    try {
      const pages = await (await fetch(`http://127.0.0.1:${port}/json`)).json();
      const page = pages.find(p => p.type === 'page' && /\/onboarding/.test(p.url));
      if (page) return page;
    } catch {}
    await sleep(500);
  }
  throw new Error('no Insomnia Welcome page on the DevTools port');
}

const page = await mainPage();
const ws = new WebSocket(page.webSocketDebuggerUrl);
await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });
let id = 0;
const waiting = new Map();
ws.onmessage = e => {
  const m = JSON.parse(e.data);
  if (waiting.has(m.id)) { waiting.get(m.id)(m.result?.result?.value); waiting.delete(m.id); }
};
const run = expression => new Promise(resolve => {
  id += 1;
  waiting.set(id, resolve);
  ws.send(JSON.stringify({ id, method: 'Runtime.evaluate', params: { expression, returnByValue: true } }));
});
// Clicks the first element matching a selector once it shows up.
async function click(selector) {
  for (let i = 0; i < 120; i++) {
    if (await run(`(() => { const e = document.querySelector(${JSON.stringify(selector)}); if (e) e.click(); return !!e; })()`)) return;
    await sleep(500);
  }
  throw new Error(`nothing matches ${selector}`);
}

await run(`localStorage.setItem(${JSON.stringify(key)}, 'true'); location.assign('/');`);
await sleep(2000);
await click('[data-testid="request-node-Create order"]');
await click('[role="tab"][id$="-tab-content-type"]');
// No focus, so no caret blinks in the editors while the Photographer waits for a still screen.
await sleep(1000);
await run('document.activeElement && document.activeElement.blur()');
ws.close();
