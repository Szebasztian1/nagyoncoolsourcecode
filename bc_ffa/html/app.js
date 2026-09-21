/* ══════════════════════════════════════════════════════════════
   BC FFA — panel logika
   ══════════════════════════════════════════════════════════════ */

const RES = (typeof GetParentResourceName === 'function')
  ? GetParentResourceName()
  : 'bc_ffa';

// böngészős előnézet: nincs NUI backend
const PREVIEW = (typeof GetParentResourceName !== 'function');

const $ = (id) => document.getElementById(id);

const el = {
  stage:    $('stage'),
  close:    $('btnClose'),
  cancel:   $('btnCancel'),
  cancel2:  $('btnCancel2'),
  cancel3:  $('btnCancel3'),
  join:     $('btnJoin'),
  leave:    $('btnLeave'),
  refresh:  $('btnRefresh'),
  search:   $('search'),
  sort:     $('sort'),
  grid:     $('grid'),
  page:     $('page'),
  empty:    $('emptyState'),
  toast:    $('toast'),
  plate:    $('statusPlate'),
  statusTx: $('statusText'),
  cntAll:   $('cntAll'),
  fcAll:    $('fcAll'),
  fcBet:    $('fcBet'),
  fcFree:   $('fcFree'),
  fcVeh:    $('fcVeh'),
  infoBox:  $('infoBox'),
  infoEmpty:$('infoEmpty'),
  infoRows: $('infoRows'),
  infoName: $('infoName'),
  infoPl:   $('infoPlayers'),
  infoBet:  $('infoBet'),
  infoSp:   $('infoSpawn'),
  infoRg:   $('infoRange'),
  infoFa:   $('infoFall'),

  // nézetek
  viewArenas: $('viewArenas'),
  viewBoard:  $('viewBoard'),
  viewMine:   $('viewMine'),

  // szezon doboz
  seasonBox:  $('seasonBox'),
  seasonName: $('seasonName'),
  resetTime:  $('resetTime'),

  // ranglista
  boardSeason:  $('boardSeason'),
  podium:       $('podium'),
  boardTable:   $('boardTable'),
  boardEmpty:   $('boardEmpty'),
  boardLoading: $('boardLoading'),
  boardRefresh: $('btnBoardRefresh'),

  // saját statisztika
  mineSeason:  $('mineSeason'),
  mineTop:     $('mineTop'),
  mineDetail:  $('mineDetail'),
  mineRows:    $('mineRows'),
  mineArenasBox: $('mineArenasBox'),
  mineArenas:  $('mineArenas'),
  mineEmpty:   $('mineEmpty'),
  mineLoading: $('mineLoading'),
  mineRefresh: $('btnMineRefresh'),

  // HUD
  hud:      $('hud'),
  hudName:  $('hudName'),
  hudPl:    $('hudPlayers'),
  hudBet:   $('hudBet'),
  hudBetVal:$('hudBetVal'),
  hudStreak:$('hudStreak'),
  hudStreakVal: $('hudStreakVal'),
  hudProt:  $('hudProtect'),
  hudProtT: $('hudProtectT'),
  hudProtB: $('hudProtectBar'),
  hudKills: $('hudKills'),
  hudDeaths:$('hudDeaths'),
};

let FFAS     = [];      // teljes lista a Lua-tól
let filter   = 'all';
let selected = null;    // kiválasztott aréna id
let current  = null;    // amiben ÉPPEN bent van a játékos
let view     = 'arenas';

/* ── segédek ─────────────────────────────────────────────────── */

const money = (n) => Number(n).toLocaleString('hu-HU') + '$';

// a config.lua-ból jövő szöveg soha ne kerüljön nyersen a DOM-ba
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, c => ({
  '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'
}[c]));

// másodperc -> "3ó 24p" / "12p"
function dur(sec) {
  sec = Math.max(0, Math.floor(sec || 0));
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  if (h > 0) return h + 'ó ' + m + 'p';
  if (m > 0) return m + 'p';
  return sec + 'mp';
}

// másodperc -> "12 nap 04:31" (reset visszaszámláló)
function countdown(sec) {
  sec = Math.max(0, Math.floor(sec || 0));
  const d = Math.floor(sec / 86400);
  const h = Math.floor((sec % 86400) / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const s = sec % 60;
  const pad = (n) => String(n).padStart(2, '0');
  if (d > 0) return `${d} nap ${pad(h)}:${pad(m)}`;
  return `${pad(h)}:${pad(m)}:${pad(s)}`;
}

function kd(kills, deaths) {
  if (!deaths) return Number(kills || 0).toFixed(2);
  return (kills / deaths).toFixed(2);
}

const MONTHS = ['január','február','március','április','május','június',
                'július','augusztus','szeptember','október','november','december'];
function seasonLabel(season) {
  if (!season) return '—';
  const [y, m] = String(season).split('-');
  const idx = parseInt(m, 10) - 1;
  return `${y}. ${MONTHS[idx] || m}`;
}

function post(name, data) {
  if (PREVIEW) { console.log('[preview] post', name, data); return Promise.resolve({}); }
  return fetch(`https://${RES}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data || {})
  }).then(r => r.json()).catch(() => ({}));
}

let toastTimer = null;
function toast(msg) {
  el.toast.textContent = msg;
  el.toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.toast.classList.remove('show'), 2200);
}

/* ── arénalista ──────────────────────────────────────────────── */

const ICON = { bet:'#i-cash', veh:'#i-car', norm:'#i-cross' };

function matchesFilter(a) {
  if (filter === 'bet')  return !!a.bet;
  if (filter === 'free') return !a.bet;
  if (filter === 'veh')  return !!a.vehicle;
  return true;
}

function matchesSearch(a, q) {
  if (!q) return true;
  if (a.name.toLowerCase().includes(q)) return true;
  return a.weapons.some(w => w.toLowerCase().includes(q));
}

function sortList(list) {
  const mode = el.sort.value;
  return list.slice().sort((x, y) => {
    if (mode === 'name')   return x.name.localeCompare(y.name, 'hu');
    if (mode === 'bet')    return (y.bet || 0) - (x.bet || 0) || y.players - x.players;
    return y.players - x.players || x.name.localeCompare(y.name, 'hu');
  });
}

function cardHTML(a) {
  const cls = [
    'arena',
    a.bet ? 'bet' : '',
    a.id === selected ? 'on' : '',
    a.id === current ? 'live' : '',
  ].filter(Boolean).join(' ');

  const icon = a.bet ? ICON.bet : (a.vehicle ? ICON.veh : ICON.norm);

  const shown = a.weapons.slice(0, 3);
  let chips = shown.map(w => `<span class="wchip">${esc(w)}</span>`).join('');
  if (a.weapons.length > shown.length) {
    chips += `<span class="wchip more">+${a.weapons.length - shown.length}</span>`;
  }

  const tags = [];
  if (a.bet)     tags.push(`<span class="tag gold">${money(a.bet)} / HALÁL</span>`);
  if (a.vehicle) tags.push(`<span class="tag blue">JÁRMŰVES</span>`);
  if (a.id === current) tags.push(`<span class="tag blue">ITT VAGY</span>`);

  return `
    <div class="${cls}" data-id="${a.id}">
      <div class="here"></div>
      <div class="aico"><svg viewBox="0 0 24 24"><use href="${icon}"/></svg></div>
      <div class="amid">
        <div class="an" title="${esc(a.name)}">${esc(a.name)}</div>
        <div class="ameta">${tags.join('')}${chips}</div>
      </div>
      <div class="acnt">
        <div class="n ${a.players > 0 ? 'hot' : ''}">${a.players}</div>
        <div class="l">játékos</div>
      </div>
      <div class="chk"><svg viewBox="0 0 24 24"><path d="M5 12l5 5L20 7"/></svg></div>
    </div>`;
}

function render() {
  const q = el.search.value.trim().toLowerCase();
  const list = sortList(FFAS.filter(a => matchesFilter(a) && matchesSearch(a, q)));

  el.grid.innerHTML = list.map(cardHTML).join('');
  el.empty.classList.toggle('hidden', list.length > 0);
  el.grid.classList.toggle('hidden', list.length === 0);

  el.grid.querySelectorAll('.arena').forEach(node => {
    node.addEventListener('click', () => selectArena(Number(node.dataset.id)));
    node.addEventListener('dblclick', () => { selectArena(Number(node.dataset.id)); doJoin(); });
  });

  el.cntAll.textContent = FFAS.length;
  el.fcAll.textContent  = FFAS.length;
  el.fcBet.textContent  = FFAS.filter(a => a.bet).length;
  el.fcFree.textContent = FFAS.filter(a => !a.bet).length;
  el.fcVeh.textContent  = FFAS.filter(a => a.vehicle).length;
}

function renderInfo() {
  const a = FFAS.find(x => x.id === selected);

  if (!a) {
    el.infoEmpty.classList.remove('hidden');
    el.infoRows.classList.add('hidden');
    el.join.classList.add('disabled');
    return;
  }

  el.infoEmpty.classList.add('hidden');
  el.infoRows.classList.remove('hidden');

  el.infoName.textContent = a.name;
  el.infoPl.textContent   = a.players;
  el.infoBet.innerHTML    = a.bet
    ? `<span class="badge gold">${money(a.bet)}</span>`
    : `<span class="badge">Nincs</span>`;
  el.infoSp.textContent = (a.spawnTime / 1000).toFixed(0) + ' mp';
  el.infoRg.textContent = Math.round(a.range) + ' m';
  el.infoFa.textContent = a.fallout ? 'Igen' : 'Nem';

  el.join.classList.toggle('disabled', a.id === current);
}

function renderStatus() {
  if (current) {
    const a = FFAS.find(x => x.id === current);
    el.plate.classList.add('live');
    el.statusTx.textContent = a ? a.name : 'FFA-ban vagy';
    el.leave.classList.remove('hidden');
  } else {
    el.plate.classList.remove('live');
    el.statusTx.textContent = 'Nem vagy FFA-ban';
    el.leave.classList.add('hidden');
  }
}

function selectArena(id) {
  selected = id;
  render();
  renderInfo();
}

/* ── nézetváltás ─────────────────────────────────────────────── */

let resetTimer = null;
let resetLeft  = 0;

function startResetCountdown(sec) {
  resetLeft = sec || 0;
  clearInterval(resetTimer);
  el.resetTime.textContent = countdown(resetLeft);
  resetTimer = setInterval(() => {
    resetLeft = Math.max(0, resetLeft - 1);
    el.resetTime.textContent = countdown(resetLeft);
  }, 1000);
}

function setView(v) {
  view = v;

  el.viewArenas.classList.toggle('hidden', v !== 'arenas');
  el.viewBoard .classList.toggle('hidden', v !== 'board');
  el.viewMine  .classList.toggle('hidden', v !== 'mine');

  el.infoBox  .classList.toggle('hidden', v !== 'arenas');
  el.seasonBox.classList.toggle('hidden', v === 'arenas');

  document.querySelectorAll('.nav-btn').forEach(n =>
    n.classList.toggle('on', n.dataset.view === v));

  if (v === 'board') loadBoard();
  if (v === 'mine')  loadMine();
}

/* ── ranglista ───────────────────────────────────────────────── */

function loadBoard() {
  el.boardLoading.classList.remove('hidden');
  el.boardEmpty.classList.add('hidden');
  el.podium.innerHTML = '';
  el.boardTable.innerHTML = '';
  post('leaderboard');
}

const POD_CLS = ['gold', 'silver', 'bronze'];

function renderBoard(d) {
  el.boardLoading.classList.add('hidden');

  const rows = (d && d.rows) || [];
  el.boardSeason.textContent = seasonLabel(d && d.season) + ' — havi ranglista';
  el.seasonName.textContent  = seasonLabel(d && d.season);
  startResetCountdown(d && d.resetIn);

  if (!rows.length) {
    el.boardEmpty.classList.remove('hidden');
    el.podium.innerHTML = '';
    el.boardTable.innerHTML = '';
    return;
  }
  el.boardEmpty.classList.add('hidden');

  // dobogó — az 1. hely a "boss"
  el.podium.innerHTML = rows.slice(0, 3).map((r, i) => `
    <div class="pod ${POD_CLS[i]}">
      ${i === 0 ? '<svg class="crown" viewBox="0 0 24 24"><use href="#i-crown"/></svg>' : ''}
      <div class="pr">${i + 1}. hely</div>
      <div class="pn" title="${esc(r.name)}">${esc(r.name)}</div>
      <div class="pk">${r.kills}</div>
      <div class="pl">kill</div>
      <div class="pa" title="${esc(r.favArenaName || '')}">${r.favArenaName ? esc(r.favArenaName) : '—'}</div>
      ${i === 0 ? '<div class="boss-tag">BOSS</div>' : ''}
    </div>`).join('');

  // táblázat
  const head = `
    <div class="trow thead">
      <span class="rk">#</span><span>Játékos</span>
      <span class="num">Kill</span><span class="num">Halál</span><span class="num">K/D</span>
    </div>`;

  el.boardTable.innerHTML = head + rows.map(r => `
    <div class="trow ${r.me ? 'me' : ''}">
      <span class="rk">${r.rank}</span>
      <span class="nm" title="${esc(r.name)}">${esc(r.name)}
        <span class="fav">${r.favArenaName ? esc(r.favArenaName) : 'nincs adat'}</span>
      </span>
      <span class="num k">${r.kills}</span>
      <span class="num d">${r.deaths}</span>
      <span class="num r">${kd(r.kills, r.deaths)}</span>
    </div>`).join('');
}

/* ── saját statisztika ───────────────────────────────────────── */

function loadMine() {
  el.mineLoading.classList.remove('hidden');
  el.mineEmpty.classList.add('hidden');
  el.mineTop.innerHTML = '';
  el.mineRows.innerHTML = '';
  el.mineArenas.innerHTML = '';
  el.mineDetail.classList.add('hidden');
  el.mineArenasBox.classList.add('hidden');
  post('mystats');
}

function renderMine(d) {
  el.mineLoading.classList.add('hidden');
  d = d || {};

  el.mineSeason.textContent = seasonLabel(d.season) + ' — saját statisztika';
  el.seasonName.textContent = seasonLabel(d.season);
  startResetCountdown(d.resetIn);

  if (!d.kills && !d.deaths && !d.playtime) {
    el.mineEmpty.classList.remove('hidden');
    return;
  }
  el.mineEmpty.classList.add('hidden');
  el.mineDetail.classList.remove('hidden');

  el.mineTop.innerHTML = `
    <div class="stat kill"><div class="sv">${d.kills || 0}</div><div class="sl">kill</div></div>
    <div class="stat death"><div class="sv">${d.deaths || 0}</div><div class="sl">halál</div></div>
    <div class="stat kd"><div class="sv">${kd(d.kills, d.deaths)}</div><div class="sl">K/D arány</div></div>
    <div class="stat rank"><div class="sv">${d.rank ? d.rank + '.' : '—'}</div><div class="sl">helyezés${d.players ? ' / ' + d.players : ''}</div></div>`;

  const net = (d.earned || 0) - (d.lost || 0);
  const rows = [
    ['#i-flame',  'Leghosszabb sorozat', (d.bestStreak || 0) + ' kill', ''],
    ['#i-clock',  'FFA-ban töltött idő', dur(d.playtime), ''],
    ['#i-cash',   'Tétből nyert',        money(d.earned || 0), 'good'],
    ['#i-cash',   'Tétből vesztett',     money(d.lost || 0),   'bad'],
    ['#i-chart',  'Egyenleg',            (net >= 0 ? '+' : '') + money(net), net >= 0 ? 'good' : 'bad'],
  ];

  el.mineRows.innerHTML = rows.map(([icon, label, value, cls]) => `
    <div class="drow">
      <span class="dl"><svg viewBox="0 0 24 24"><use href="${icon}"/></svg>${label}</span>
      <span class="dv ${cls}">${value}</span>
    </div>`).join('');

  const arenas = d.arenas || [];
  if (arenas.length) {
    el.mineArenasBox.classList.remove('hidden');
    const head = `
      <div class="trow thead">
        <span>Pálya</span><span class="num">Kill</span><span class="num">Halál</span><span class="num">Idő</span>
      </div>`;
    el.mineArenas.innerHTML = head + arenas.map(a => `
      <div class="trow">
        <span class="nm" title="${esc(a.name)}">${esc(a.name)}</span>
        <span class="num k">${a.kills}</span>
        <span class="num d">${a.deaths}</span>
        <span class="num r">${dur(a.playtime)}</span>
      </div>`).join('');
  }
}

/* ── HUD ─────────────────────────────────────────────────────── */

let protectTimer = null;

function bump(node, value) {
  const old = Number(node.textContent) || 0;
  node.textContent = value;
  if (value > old) {
    node.classList.remove('bump');
    void node.offsetWidth;          // az animáció újraindításához kell
    node.classList.add('bump');
  }
}

function hudShow(d) {
  el.hudName.textContent   = d.name || '';
  el.hudPl.textContent     = d.players ?? 0;
  el.hudKills.textContent  = d.kills ?? 0;
  el.hudDeaths.textContent = d.deaths ?? 0;
  el.hudStreak.classList.add('hidden');

  if (d.bet) {
    el.hudBetVal.textContent = money(d.bet) + ' / halál';
    el.hudBet.classList.remove('hidden');
  } else {
    el.hudBet.classList.add('hidden');
  }

  el.hud.classList.remove('hidden');
}

function hudHide() {
  el.hud.classList.add('hidden');
  hudProtectStop();
}

function hudPlayers(n) {
  el.hudPl.textContent = n ?? 0;
}

// kill / halál frissítés a menet közben
function hudStats(kills, deaths, streak) {
  bump(el.hudKills,  kills  ?? 0);
  bump(el.hudDeaths, deaths ?? 0);

  // sorozat csak 3 killtől jelenik meg, hogy ne legyen zajos
  if (streak && streak >= 3) {
    el.hudStreakVal.textContent = streak + ' killes sorozat';
    el.hudStreak.classList.remove('hidden');
  } else {
    el.hudStreak.classList.add('hidden');
  }
}

function hudProtectStop() {
  if (protectTimer) { cancelAnimationFrame(protectTimer); protectTimer = null; }
  el.hudProt.classList.add('hidden');
}

// spawn védelem visszaszámláló — a Lua adja meg, hány ms-ig tart
function hudProtect(ms) {
  hudProtectStop();
  if (!ms || ms <= 0) return;

  const started = performance.now();
  el.hudProt.classList.remove('hidden');

  const tick = () => {
    const left = ms - (performance.now() - started);
    if (left <= 0) { hudProtectStop(); return; }
    el.hudProtT.textContent = (left / 1000).toFixed(1);
    el.hudProtB.style.width = (left / ms * 100) + '%';
    protectTimer = requestAnimationFrame(tick);
  };
  tick();
}

/* ── műveletek ───────────────────────────────────────────────── */

function close() {
  el.stage.classList.add('hidden');
  clearInterval(resetTimer);
  post('close');
}

function doJoin() {
  if (!selected || selected === current) return;
  const a = FFAS.find(x => x.id === selected);
  if (!a) return;
  el.stage.classList.add('hidden');
  clearInterval(resetTimer);
  post('join', { id: selected });
}

function doLeave() {
  if (!current) return;
  el.stage.classList.add('hidden');
  clearInterval(resetTimer);
  post('leave');
}

function doRefresh() {
  el.refresh.classList.add('disabled');
  post('refresh').then(() => {
    setTimeout(() => el.refresh.classList.remove('disabled'), 400);
  });
  if (PREVIEW) setTimeout(() => el.refresh.classList.remove('disabled'), 400);
}

/* ── NUI üzenetek ────────────────────────────────────────────── */

window.addEventListener('message', (ev) => {
  const d = ev.data || {};

  if (d.action === 'open') {
    FFAS     = d.ffas || [];
    current  = d.current || null;
    selected = current || null;
    el.search.value = '';
    filter = 'all';
    document.querySelectorAll('.fchip').forEach(n =>
      n.classList.toggle('on', n.dataset.filter === 'all'));
    el.stage.classList.remove('hidden');
    el.page.scrollTop = 0;
    setView('arenas');
    render(); renderInfo(); renderStatus();
  }

  else if (d.action === 'close') {
    el.stage.classList.add('hidden');
    clearInterval(resetTimer);
  }

  // csak a számlálók / állapot frissítése, a nézet megmarad
  else if (d.action === 'update') {
    if (d.ffas)  FFAS = d.ffas;
    if (d.current !== undefined) current = d.current || null;
    render(); renderInfo(); renderStatus();
  }

  else if (d.action === 'toast')       toast(d.message || '');
  else if (d.action === 'leaderboard') renderBoard(d.data);
  else if (d.action === 'mystats')     renderMine(d.data);

  /* HUD */
  else if (d.action === 'hudShow')     hudShow(d);
  else if (d.action === 'hudHide')     hudHide();
  else if (d.action === 'hudPlayers')  hudPlayers(d.players);
  else if (d.action === 'hudProtect')  hudProtect(d.ms);
  else if (d.action === 'hudStats')    hudStats(d.kills, d.deaths, d.streak);
});

/* ── események ───────────────────────────────────────────────── */

el.close.addEventListener('click', close);
el.cancel.addEventListener('click', close);
el.cancel2.addEventListener('click', close);
el.cancel3.addEventListener('click', close);
el.join.addEventListener('click', doJoin);
el.leave.addEventListener('click', doLeave);
el.refresh.addEventListener('click', doRefresh);
el.boardRefresh.addEventListener('click', loadBoard);
el.mineRefresh.addEventListener('click', loadMine);

el.search.addEventListener('input', render);
el.sort.addEventListener('change', render);

document.querySelectorAll('.nav-btn').forEach(node => {
  node.addEventListener('click', () => setView(node.dataset.view));
});

document.querySelectorAll('.fchip').forEach(node => {
  node.addEventListener('click', () => {
    filter = node.dataset.filter;
    document.querySelectorAll('.fchip').forEach(n => n.classList.remove('on'));
    node.classList.add('on');
    el.page.scrollTop = 0;
    render();
  });
});

document.addEventListener('keydown', (e) => {
  if (el.stage.classList.contains('hidden')) return;
  if (e.key === 'Escape') { e.preventDefault(); close(); }
  if (e.key === 'Enter' && view === 'arenas') { e.preventDefault(); doJoin(); }
});
