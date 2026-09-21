/* FactionHQ breach minigame - a self-contained lockpick.

   An indicator sweeps the track; the player presses SPACE to lock the
   current pin while the needle is inside the green success zone. Each pin
   is faster and the zone is smaller. A miss costs a strike; running out of
   strikes fails the whole breach. Clearing every pin opens the door.

   Runs entirely in the NUI (no ox_lib); the result is posted back to Lua,
   which keeps the server-authoritative timing. */
(() => {
  const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bc_factionhq';
  const root = document.getElementById('breach');
  const card = document.getElementById('brc-card');
  const track = document.getElementById('brc-track');
  const zoneEl = document.getElementById('brc-zone');
  const needleEl = document.getElementById('brc-needle');
  const pinsEl = document.getElementById('brc-pins');
  const strikesEl = document.getElementById('brc-strikes');
  const statusEl = document.getElementById('brc-status');

  const STRIKE_SVG = '<svg class="st" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2 2 22h20L12 2z"/></svg>';

  const DEF = { pins: 6, strikes: 2, zoneStart: 26, zoneEnd: 12, speedStart: 105, speedEnd: 215 };

  let cfg = DEF;
  let raf = 0;
  let running = false;   // gameplay loop active
  let posted = false;    // result already sent to Lua
  let locking = false;   // brief pause after a hit/miss (ignore input)

  // Live state
  let pinIndex = 0;      // pins secured so far
  let strikesUsed = 0;
  let pos = 0;           // needle position 0..100
  let dir = 1;
  let speed = 0;         // % per second
  let zonePos = 0;       // zone left edge (%)
  let zoneW = 0;         // zone width (%)
  let last = 0;

  const clampNum = (v, lo, hi, d) => {
    const n = Number(v);
    return Number.isFinite(n) ? Math.min(hi, Math.max(lo, n)) : d;
  };

  function lerp(a, b, t) { return a + (b - a) * t; }

  function post(name, body) {
    fetch(`https://${RES}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(body || {}),
    }).catch(() => {});
  }

  function renderPins() {
    let html = '';
    for (let i = 0; i < cfg.pins; i++) {
      const cls = i < pinIndex ? 'done' : (i === pinIndex ? 'active' : '');
      html += `<div class="pin ${cls}"></div>`;
    }
    pinsEl.innerHTML = html;

    let sh = '';
    for (let i = 0; i < cfg.strikes; i++) {
      sh += STRIKE_SVG.replace('class="st"', `class="st${i < strikesUsed ? ' used' : ''}"`);
    }
    strikesEl.innerHTML = sh;
  }

  // Set up the geometry for the current pin (speed ramps up, zone shrinks)
  function setupPin() {
    const t = cfg.pins > 1 ? pinIndex / (cfg.pins - 1) : 1;
    speed = lerp(cfg.speedStart, cfg.speedEnd, t);
    zoneW = lerp(cfg.zoneStart, cfg.zoneEnd, t);
    zonePos = Math.random() * (100 - zoneW);
    zoneEl.style.left = zonePos + '%';
    zoneEl.style.width = zoneW + '%';
    statusEl.className = 'brc-status';
    statusEl.textContent = `Zár #${pinIndex + 1}`;
    renderPins();
  }

  function draw() {
    needleEl.style.left = pos + '%';
  }

  function loop(ts) {
    if (!running) return;
    if (!last) last = ts;
    const dt = Math.min((ts - last) / 1000, 0.05); // clamp big frame gaps
    last = ts;

    if (!locking) {
      pos += dir * speed * dt;
      if (pos >= 100) { pos = 100; dir = -1; }
      else if (pos <= 0) { pos = 0; dir = 1; }
      draw();
    }
    raf = requestAnimationFrame(loop);
  }

  function stopLoop() {
    running = false;
    if (raf) cancelAnimationFrame(raf);
    raf = 0;
  }

  function finish(success) {
    if (posted) return;
    posted = true;
    stopLoop();
    root.classList.add('hidden');
    post('breachDone', { success });
  }

  function flash(el, cls, ms) {
    el.classList.add(cls);
    setTimeout(() => el.classList.remove(cls), ms);
  }

  function attempt() {
    if (!running || locking || posted) return;
    locking = true;

    const inside = pos >= zonePos && pos <= (zonePos + zoneW);
    if (inside) {
      flash(track, 'hit', 200);
      pinIndex++;
      renderPins();
      if (pinIndex >= cfg.pins) {
        statusEl.className = 'brc-status ok';
        statusEl.textContent = 'ZÁR FELTÖRVE';
        setTimeout(() => finish(true), 320);
        return;
      }
      statusEl.className = 'brc-status ok';
      statusEl.textContent = 'Zár nyitva!';
      setTimeout(() => { locking = false; setupPin(); }, 220);
    } else {
      strikesUsed++;
      flash(track, 'bad', 220);
      flash(card, 'miss', 320);
      renderPins();
      if (strikesUsed > cfg.strikes) {
        statusEl.className = 'brc-status err';
        statusEl.textContent = 'A ZÁR BERAGADT';
        setTimeout(() => finish(false), 360);
        return;
      }
      statusEl.className = 'brc-status err';
      statusEl.textContent = 'Elrontottad!';
      setTimeout(() => { locking = false; statusEl.className = 'brc-status'; statusEl.textContent = `Zár #${pinIndex + 1}`; }, 260);
    }
  }

  function start(inCfg) {
    cfg = {
      pins:       clampNum(inCfg && inCfg.pins, 1, 12, DEF.pins) | 0,
      strikes:    clampNum(inCfg && inCfg.strikes, 0, 8, DEF.strikes) | 0,
      zoneStart:  clampNum(inCfg && inCfg.zoneStart, 4, 60, DEF.zoneStart),
      zoneEnd:    clampNum(inCfg && inCfg.zoneEnd, 4, 60, DEF.zoneEnd),
      speedStart: clampNum(inCfg && inCfg.speedStart, 20, 600, DEF.speedStart),
      speedEnd:   clampNum(inCfg && inCfg.speedEnd, 20, 600, DEF.speedEnd),
    };
    pinIndex = 0; strikesUsed = 0; pos = 0; dir = 1; last = 0;
    posted = false; locking = false; running = true;
    setupPin();
    draw();
    root.classList.remove('hidden');
    raf = requestAnimationFrame(loop);
  }

  window.addEventListener('message', e => {
    const m = e.data || {};
    if (m.action === 'breachStart') start(m.cfg || {});
    else if (m.action === 'breachAbort') finish(false);
  });

  document.addEventListener('keydown', e => {
    if (root.classList.contains('hidden')) return;
    if (e.code === 'Space' || e.key === 'Enter') {
      e.preventDefault();
      if (!e.repeat) attempt();
    } else if (e.key === 'Escape' || e.key === 'Backspace') {
      e.preventDefault();
      finish(false);
    }
  });

  // Click / tap also locks the pin (useful for testing in a browser)
  track.addEventListener('mousedown', () => attempt());
})();
