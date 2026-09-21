const RES = 'bc_fonokipanel';
const app = document.getElementById('app');
let DATA = null;
let HQ = null;      // Frakcio HQ tab data (bc_factionhq); false = module missing
let curStore = null;
let empState = { employees: [], gradesLabels: {} };
let busy = false;
const HEAVY = ['move','buy','mission','buyrank','delrank','moveup','movedn','deposit','withdraw','promote','fire','recruit','setsalary','bonussend','hqmoveentry','hqfreemove','hqrevoke'];

// Employees tab extras: search, bonus drawer, two-step fire confirm
let empQuery = '';
let myIdent = null;       // boss's own identifier (their row hides fire/promote)
let bonusOpenId = null;   // row whose inline bonus form is open
let bonusAnim = false;    // play the drawer animation only on open, not on refresh
let fireArmId = null;     // row whose fire button is in confirm state
let fireArmTimer = null;
let nearbyList = null;    // nearby hireable players; survives list re-renders

/* ---- Icons: Tabler outline, size comes from CSS (em) ---- */
const svg = p => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">${p}</svg>`;

const IC = {
  clock: svg('<circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15.5 14"/>'),
  edit: svg('<path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>'),
  trash: svg('<polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>'),
  up: svg('<polyline points="18 15 12 9 6 15"/>'),
  down: svg('<polyline points="6 9 12 15 18 9"/>'),
  x: svg('<path d="M18 6 6 18M6 6l12 12"/>'),
  crown: svg('<path d="M3 7.5 7.5 12 12 4l4.5 8L21 7.5 19 19H5L3 7.5Z"/>')
};

/* Tab icon = sidebar icon + the skewed watermark of the open page */
const TAB_IC = {
  ov: svg('<rect x="4" y="4" width="6.5" height="8" rx="1.2"/><rect x="4" y="15.5" width="6.5" height="4.5" rx="1.2"/><rect x="13.5" y="12" width="6.5" height="8" rx="1.2"/><rect x="13.5" y="4" width="6.5" height="4.5" rx="1.2"/>'),
  act: svg('<path d="M3 12h4l3 8 4-16 3 8h4"/>'),
  money: svg('<path d="M17 8V6a2 2 0 0 0-2-2H5a2 2 0 0 0 0 4h13a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6"/><circle cx="16.5" cy="14" r="1.2"/>'),
  emp: svg('<circle cx="9" cy="8" r="3.6"/><path d="M2.8 20v-1.6a4 4 0 0 1 4-4h4.4a4 4 0 0 1 4 4V20"/><path d="M16 4.6a3.6 3.6 0 0 1 0 6.9"/><path d="M21.2 20v-1.6a4 4 0 0 0-3-3.8"/>'),
  salary: svg('<path d="M5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16l-3-2-2 2-2-2-2 2-3-2Z"/><path d="M9 8h6M9 12h6M9 16h3"/>'),
  rank: svg('<path d="m12 3 9 5-9 5-9-5 9-5Z"/><path d="m3 12 9 5 9-5"/><path d="m3 16.5 9 5 9-5"/>'),
  move: svg('<path d="M12 3v18M3 12h18"/><path d="m9 6 3-3 3 3M9 18l3 3 3-3M6 9l-3 3 3 3M18 9l3 3-3 3"/>'),
  buy: svg('<circle cx="9.5" cy="20" r="1.4"/><circle cx="18" cy="20" r="1.4"/><path d="M2.5 4H5l2.6 11.5h11L21.5 7.5H6"/>'),
  miss: svg('<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4"/><circle cx="12" cy="12" r=".9" fill="currentColor" stroke="none"/>'),
  store: svg('<rect x="3.5" y="4.5" width="17" height="15" rx="2"/><path d="M3.5 9.5h17"/><circle cx="12" cy="14" r="1.9"/><path d="M12 15.9V17.5"/>'),
  hq: svg('<path d="M3 21h18"/><path d="M5 21V7.5L12 3l7 4.5V21"/><path d="M9.5 21v-5h5v5"/><path d="M9.5 10.5h.01M14.5 10.5h.01"/>')
};

const NAV = [
  ['ov', 'Áttekintés', 'Pillanatkép'],
  ['act', 'Aktivitás', 'Utolsó belépések'],
  ['money', 'Pénzügyek', 'Kassza kezelés'],
  ['emp', 'Alkalmazottak', 'Léptetés, bónusz'],
  ['salary', 'Fizetések', 'Rangonkénti bér'],
  ['rank', 'Rangok', 'Átnevezés, sorrend'],
  ['move', 'CP áthelyezés', 'Pont új helyre'],
  ['buy', 'CP vásárlás', 'Új pont vétele'],
  ['miss', 'Küldetések', 'Progress, jutalmak'],
  ['store', 'Tárolók', 'Széfek, hozzáférés'],
  ['hq', 'Frakció HQ', 'Interior, belépő CP']
];

const nf = new Intl.NumberFormat('hu-HU');
const fmt = n => nf.format(Math.round(Number(n) || 0));
const esc = s => String(s == null ? '' : s).replace(/[&<>"]/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;' }[c]));
// Accent-insensitive compare for the name search (ő -> o, ű -> u, etc.)
const norm = s => String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');

/* ---- Header patterns (BC design: eyebrow + big title) ---- */
function head(k, ttl, sub, price) {
  return `<div class="head"><div><div class="k">${k}</div><div class="ttl">${ttl}</div></div>` +
    (price ? `<div class="pricetag">${price}</div>` : '') + '</div>' +
    `<div class="sub">${sub}</div>`;
}
const shead = (t, m) => `<div class="shead"><span class="st">${t}</span>${m ? `<span class="sm">${m}</span>` : ''}</div>`;

/* ---- Reset visszaszámláló segédek ---- */
let clockOff = 0; // szerver-kliens óra eltolódás (mp), a getPanelData "now" mezőjéből
const nowSec = () => Date.now() / 1000 + clockOff;
const syncClock = () => { if (DATA && DATA.now) clockOff = DATA.now - Date.now() / 1000; };

const RESET_LBL = { daily: 'Napi', weekly: 'Heti' };

function fmtDur(s) {
  s = Math.max(0, Math.floor(s));
  const d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600), m = Math.floor((s % 3600) / 60);
  if (d > 0) return d + 'n ' + h + 'ó';
  if (h > 0) return h + 'ó ' + m + 'p';
  if (m > 0) return m + 'p';
  return s + 'mp';
}

// Élőben frissülő visszaszámláló chip (a ticker a .t elemet írja át)
function resetChip(resetAt, prefix) {
  if (!resetAt) return '';
  return `<span class="fp-tag reset" data-reset-at="${resetAt}">${IC.clock}` +
    `<span>${esc(prefix)}<b class="t">${fmtDur(resetAt - nowSec())}</b></span></span>`;
}

function post(name, body) {
  return fetch(`https://${RES}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body || {})
  }).catch(() => {});
}

const TYPE_ABBR = { safe: 'Szé', stash: 'Tár', wardrobe: 'Ruh', garage_buyable: 'Gar', garage: 'Gar' };
const typeAbbr = t => TYPE_ABBR[t] || String(t || 'CP').slice(0, 3);

function show() { app.classList.remove('hidden'); }
function hide() { app.classList.add('hidden'); }

/* ---- Sidebar nav (icon-box + title + description) ---- */
function buildNav() {
  document.getElementById('hp-logo').innerHTML = IC.crown;
  document.getElementById('btn-close').innerHTML = IC.x;
  document.getElementById('fp-nav').innerHTML = NAV.map(([t, title, desc], i) =>
    `<div class="fp-item${i === 0 ? ' on' : ''}" data-t="${t}">
      <div class="ico">${TAB_IC[t]}</div>
      <div class="lbl"><div class="t">${title}</div><div class="d">${desc}</div></div>
    </div>`).join('');
  setWatermark('ov');
}
function setWatermark(tab) { document.getElementById('wm').innerHTML = TAB_IC[tab] || ''; }

window.addEventListener('message', e => {
  const m = e.data || {};
  if (['open','data','money','employees','salaries','activity','hq'].indexOf(m.action) !== -1) busy = false;
  if (m.action === 'open') { DATA = m.data; curStore = null; HQ = null; syncClock(); render(); show(); post('getHQ'); }
  else if (m.action === 'data') { DATA = m.data; syncClock(); render(); }
  else if (m.action === 'close') { hide(); }
  else if (m.action === 'access') { renderAccess(m.id, m.stype, m.info); }
  else if (m.action === 'money') { renderMoney(m.balance); }
  else if (m.action === 'employees') {
    empState = { employees: m.employees || [], gradesLabels: m.gradesLabels || {} };
    if (m.myIdentifier) myIdent = m.myIdentifier;
    renderEmployees();
  }
  else if (m.action === 'nearby') { nearbyList = m.list || []; renderNearbyBox(); }
  else if (m.action === 'salaries') { renderSalaries(m.grades || []); }
  else if (m.action === 'activity') { renderActivity(m.list || []); }
  else if (m.action === 'hq') { HQ = m.data; renderHQ(); }
});

/* ---- Custom number stepper + select (replaces native arrows/scrollbar) ---- */
function enhanceNumberInputs() {
  document.querySelectorAll('input[type=number].fp-in:not([data-enh])').forEach(inp => {
    inp.dataset.enh = '1';
    const wrap = document.createElement('span');
    wrap.className = 'fp-num';
    if (inp.style.width && inp.style.width !== 'auto') wrap.style.width = inp.style.width;
    else { wrap.style.flex = '1'; wrap.style.minWidth = '0'; }
    inp.style.width = '100%';
    inp.parentNode.insertBefore(wrap, inp);
    wrap.appendChild(inp);
    wrap.insertAdjacentHTML('beforeend',
      `<span class="fp-num-btns"><span class="fp-num-btn" data-step="up">${IC.up}</span>` +
      `<span class="fp-num-btn" data-step="down">${IC.down}</span></span>`);
  });
}

function enhanceSelects() {
  document.querySelectorAll('select.fp-in:not([data-enh])').forEach(sel => {
    sel.dataset.enh = '1';
    sel.style.display = 'none';
    const box = document.createElement('div');
    box.className = 'fp-sel';
    if (sel.style.width && sel.style.width !== 'auto') box.style.width = sel.style.width;
    sel.parentNode.insertBefore(box, sel);
    box.appendChild(sel);
    const trig = document.createElement('div');
    trig.className = 'fp-sel-trigger';
    trig.innerHTML = `<span class="lbl"></span><span class="car">${IC.down}</span>`;
    box.appendChild(trig);
    const pop = document.createElement('div');
    pop.className = 'fp-sel-pop';
    box.appendChild(pop);
    const sync = () => {
      const o = sel.options[sel.selectedIndex];
      const lbl = o ? o.textContent : '';
      trig.querySelector('.lbl').textContent = lbl;
      trig.title = lbl; // full label on hover when the trigger is ellipsized
      pop.innerHTML = Array.from(sel.options).map((op, i) =>
        `<div class="fp-sel-opt${i === sel.selectedIndex ? ' sel' : ''}" data-i="${i}">${esc(op.textContent)}</div>`).join('');
    };
    sync();
    const place = () => {
      const panel = box.closest('.fp');
      const pr = panel ? panel.getBoundingClientRect()
        : { left: 0, right: window.innerWidth, width: window.innerWidth };
      const r = trig.getBoundingClientRect();
      pop.style.minWidth = r.width + 'px';
      pop.style.maxWidth = Math.min(320, pr.width - 16) + 'px';
      const ph = pop.offsetHeight, pw = pop.offsetWidth;
      const below = window.innerHeight - r.bottom;
      pop.style.top = (below < ph + 8 && r.top > below ? r.top - ph - 4 : r.bottom + 4) + 'px';
      let left = r.left;
      if (left + pw > pr.right - 8) left = pr.right - 8 - pw;
      if (left < pr.left + 8) left = pr.left + 8;
      pop.style.left = left + 'px';
    };
    box._place = place;
    trig.addEventListener('click', e => {
      e.stopPropagation();
      const wasOpen = box.classList.contains('open');
      document.querySelectorAll('.fp-sel.open').forEach(o => o.classList.remove('open'));
      if (wasOpen) return;
      box.classList.add('open');
      place();
    });
    pop.addEventListener('click', e => {
      const opt = e.target.closest('.fp-sel-opt'); if (!opt) return;
      sel.selectedIndex = +opt.dataset.i;
      sel.dispatchEvent(new Event('change', { bubbles: true }));
      sync();
      box.classList.remove('open');
    });
  });
}

function enhance() { enhanceNumberInputs(); enhanceSelects(); }

document.addEventListener('click', () => {
  document.querySelectorAll('.fp-sel.open').forEach(o => o.classList.remove('open'));
});
document.addEventListener('scroll', e => {
  // keep the popup glued to its trigger; don't close it (e.g. when scrolling inside the list)
  document.querySelectorAll('.fp-sel.open').forEach(o => o._place && o._place());
}, true);
window.addEventListener('resize', () => {
  document.querySelectorAll('.fp-sel.open').forEach(o => o._place && o._place());
});

document.addEventListener('click', e => {
  const b = e.target.closest('.fp-num-btn'); if (!b) return;
  const inp = b.closest('.fp-num').querySelector('input');
  const step = parseFloat(inp.step) || 1;
  const min = inp.min !== '' ? parseFloat(inp.min) : -Infinity;
  const max = inp.max !== '' ? parseFloat(inp.max) : Infinity;
  let v = parseFloat(inp.value) || 0;
  v += b.dataset.step === 'up' ? step : -step;
  v = Math.min(max, Math.max(min, v));
  inp.value = v;
  inp.dispatchEvent(new Event('input', { bubbles: true }));
  inp.dispatchEvent(new Event('change', { bubbles: true }));
});

function render() {
  if (!DATA) return;
  document.getElementById('hp-job').textContent = DATA.jobLabel || 'Frakció';
  document.getElementById('hp-members').textContent = DATA.members || 0;
  document.getElementById('hp-pp').textContent = fmt(DATA.pp);
  document.getElementById('if-job').textContent = DATA.jobLabel || '–';
  document.getElementById('if-cps').textContent = DATA.cps.length;
  document.getElementById('if-ranks').textContent = DATA.ranks.length;
  document.getElementById('if-pp').textContent = fmt(DATA.pp) + ' PP';
  renderOverview();
  renderMove();
  renderBuy();
  renderRank();
  renderMiss();
  renderStore();
  renderHQ();
  enhance();
}

function renderOverview() {
  const d = DATA;
  let mh = d.missions.map(m => {
    const pct = m.required ? Math.min(100, Math.round(m.current / m.required * 100)) : 100;
    const fill = m.ready ? ' class="ok"' : (m.claimed ? ' class="done"' : '');
    const mini = m.resetAt ? `<span class="fp-reset-mini" data-reset-at="${m.resetAt}">${IC.clock}<b class="t">${fmtDur(m.resetAt - nowSec())}</b></span>` : '';
    const right = m.claimed ? '<span class="txt-ok">megszerezve</span>'
      : (m.ready ? '<span class="txt-ok">kész</span>'
        : `<span class="txt-2">${m.current} / ${m.required}</span>`);
    return `<div><div class="mline">
      <span class="l">${esc(m.label)} &rarr; ${esc(m.rewardLabel)}</span>
      <span class="r">${mini}${right}</span></div>
      <div class="fp-bar"><i${fill} style="width:${pct}%"></i></div></div>`;
  }).join('');
  document.getElementById('sec-ov').innerHTML =
    head('Pillanatkép', 'Frakció <b>áttekintés</b>', 'A frakció aktuális állapota és a küldetések állása.') + `
    <div class="fp-grid g3 mb">
      <div class="fp-card fp-metric"><div class="v">${fmt(d.pp)}</div><div class="l">Saját PP</div></div>
      <div class="fp-card fp-metric"><div class="v">${d.members}</div><div class="l">Tagok</div></div>
      <div class="fp-card fp-metric"><div class="v">${d.cps.length}</div><div class="l">Checkpointok</div></div>
    </div>
    <div class="fp-card"><div class="bt">Küldetések</div>
      <div class="mlist">${mh || '<div class="fp-empty">Nincs küldetés.</div>'}</div></div>`;
}

function renderMove() {
  const d = DATA, price = d.config.movePrice, can = d.pp >= price;
  let rows = d.cps.map(cp => `
    <div class="fp-row"><div class="fp-ico">${esc(typeAbbr(cp.type))}</div>
      <div class="fp-rt"><div class="a">${esc(cp.label)} <span class="id">#${cp.id}</span></div>
        <div class="b">${esc(cp.type)}</div></div>
      <button class="fp-btn" data-act="move" data-cp="${cp.id}" data-lbl="${esc(cp.label)}" ${can ? '' : 'disabled'}>Áthelyez</button></div>`).join('');
  document.getElementById('sec-move').innerHTML =
    head('Checkpointok', 'CP <b>áthelyezés</b>',
      can ? 'Válassz egy pontot, majd a lehelyező nézetben tedd új helyre.' : 'Nincs elég PP-d az áthelyezéshez.',
      `${fmt(price)} PP / db`) +
    `<div class="fp-grid">${rows || '<div class="fp-empty">Nincs áthelyezhető CP.</div>'}</div>`;
}

function renderBuy() {
  const d = DATA, price = d.config.buyPrice, can = d.pp >= price;
  let cards = d.config.buyableTypes.map(t => `
    <div class="fp-card"><div class="fp-row plain">
      <div class="fp-ico">${esc(typeAbbr(t.type))}</div><div class="fp-rt"><div class="a">${esc(t.label)}</div></div></div>
      <div class="rowcard between">
        <span class="fp-tag bl">${fmt(price)} PP</span>
        <button class="fp-btn" data-act="buy" data-idx="${t.index}" data-lbl="${esc(t.label)}" ${can ? '' : 'disabled'}>Vásárlás</button></div></div>`).join('');
  document.getElementById('sec-buy').innerHTML =
    head('Checkpointok', 'CP <b>vásárlás</b>',
      can ? 'A lehelyezésnél állítsd be a formáját, színét, méretét.' : 'Nincs elég PP-d a vásárláshoz.',
      `${fmt(price)} PP / db`) +
    `<div class="fp-grid g2">${cards}</div>`;
}

function renderRank() {
  const d = DATA, price = d.config.renamePrice, can = d.pp >= price;
  const buyPrice = d.config.buyRankPrice, delPrice = d.config.deleteRankPrice;
  const canBuy = d.pp >= buyPrice, canDel = d.pp >= delPrice;
  const ranks = d.ranks;
  const cobossGrade = ranks.length >= 2 ? ranks[ranks.length - 2].grade : 0;

  let rows = ranks.map(r => {
    const canUp = !r.protected && r.grade < cobossGrade - 1;
    const canDown = !r.protected && r.grade > 0;
    const arrows = `<div class="arrows">
      <button class="fp-iconbtn" data-act="moveup" data-grade="${r.grade}" ${canUp ? '' : 'disabled'} title="Feljebb">${IC.up}</button>
      <button class="fp-iconbtn" data-act="movedn" data-grade="${r.grade}" ${canDown ? '' : 'disabled'} title="Lejjebb">${IC.down}</button></div>`;
    const delBtn = r.protected
      ? '<span class="fp-tag muted">védett</span>'
      : `<button class="fp-iconbtn danger" data-act="delrank" data-rankid="${r.id}" ${canDel ? '' : 'disabled'} title="Törlés (${fmt(delPrice)} PP)">${IC.trash}</button>`;
    return `<div class="fp-row">${arrows}
      <span class="gnum">[${r.grade}]</span>
      <input class="fp-in" value="${esc(r.label)}" maxlength="50">
      <button class="fp-iconbtn primary" data-act="rank" data-grade="${r.grade}" ${can ? '' : 'disabled'} title="Átnevezés (${fmt(price)} PP)">${IC.edit}</button>
      ${delBtn}</div>`;
  }).join('');

  let posOpts = '<option value="0">Legalulra</option>';
  ranks.forEach(r => { if (r.grade < cobossGrade) posOpts += `<option value="${r.grade + 1}">${esc(r.label)} fölé</option>`; });

  const buyForm = shead('Új rang vétele', `${fmt(buyPrice)} PP`) +
    `<div class="sub">${canBuy ? 'A boss/coboss a két legfelső marad; az új rang a coboss alá kerül.' : 'Nincs elég PP-d új rang vételéhez.'}</div>
    <div class="fp-card rowcard">
      <input class="fp-in" id="newRankLabel" style="flex:1;min-width:10em" placeholder="Rang neve" maxlength="50">
      <select class="fp-in" id="newRankPos" style="width:auto">${posOpts}</select>
      <button class="fp-btn green" data-act="buyrank" ${canBuy ? '' : 'disabled'}>Vétel</button>
    </div>`;

  const fnPrice = d.config.renameFactionPrice, canFn = d.pp >= fnPrice;
  const factionForm = shead('Frakció átnevezése', `${fmt(fnPrice)} PP`) +
    `<div class="sub">${canFn ? 'Csak a frakció megjelenő neve változik, az azonosítója nem.' : 'Nincs elég PP-d a frakció átnevezéséhez.'}</div>
    <div class="fp-card rowcard">
      <input class="fp-in" id="newFactionLabel" style="flex:1;min-width:10em" placeholder="Új frakció név" maxlength="50" value="${esc(d.jobLabel || '')}">
      <button class="fp-btn" data-act="renameFaction" ${canFn ? '' : 'disabled'}>Átnevezés</button>
    </div>`;

  document.getElementById('sec-rank').innerHTML =
    head('Hierarchia', 'Rangok <b>kezelése</b>',
      can ? 'Csak a rang nevét írod át, a fizetést és a jogokat nem.' : 'Nincs elég PP-d az átíráshoz.',
      `${fmt(price)} PP / átnevezés`) +
    `<div class="fp-grid">${rows || '<div class="fp-empty">Nincs rang.</div>'}</div>
    ${buyForm}
    ${factionForm}`;
}

function renderMiss() {
  let cards = DATA.missions.map(m => {
    const pct = m.required ? Math.min(100, Math.round(m.current / m.required * 100)) : 100;
    const period = m.reset ? `<span class="fp-tag bl">${esc(RESET_LBL[m.reset] || m.reset)}</span>` : '';
    let status, btn = '';
    if (m.claimed) status = '<span class="fp-tag muted">megszerezve</span>';
    else if (m.ready) { status = '<span class="fp-tag ok">begyűjthető</span>'; btn = `<button class="fp-btn green full" data-act="mission" data-mid="${esc(m.id)}">Jutalom lerakása</button>`; }
    else status = `<span class="fp-tag muted">${m.current} / ${m.required}</span>`;
    const fill = m.ready ? ' class="ok"' : (m.claimed ? ' class="done"' : '');
    // Reset kijelzés: begyűjtött reseteseknél "újra elérhető", futóknál "reset";
    // a reset nélküli aktivitás-küldiknél a napi progress nullázását mutatjuk.
    let chip = '';
    if (m.reset) chip = resetChip(m.resetAt, m.claimed ? 'újra elérhető: ' : 'reset: ');
    else if (!m.claimed && m.resetAt) chip = resetChip(m.resetAt, 'nullázódik: ');
    return `<div class="fp-card">
      <div class="mtop"><span class="mn">${esc(m.label)}</span>
        <span class="mt">${period}${status}</span></div>
      <div class="mrew">Jutalom: ${esc(m.rewardLabel)}</div>
      <div class="fp-bar"><i${fill} style="width:${pct}%"></i></div>
      <div class="fp-bar-meta"><span>${pct}%</span>${chip}</div>${btn}</div>`;
  }).join('');
  let daily = (DATA.dailyRewards || []).map(m => {
    const pct = m.concurrent ? Math.min(100, Math.round(m.online / m.concurrent * 100)) : 0;
    const status = m.doneToday
      ? '<span class="fp-tag ok">ma megvolt</span>'
      : `<span class="fp-tag muted">jelenleg ${m.online} / ${m.concurrent} fent</span>`;
    const chip = m.doneToday && m.resetAt ? resetChip(m.resetAt, 'újraindul: ') : '';
    return `<div class="fp-card">
      <div class="mtop"><span class="mn">${esc(m.label)} egyszerre</span><span class="mt">${status}</span></div>
      <div class="mrew">Mindenki kap: ${esc(m.rewardText)}</div>
      <div class="fp-bar"><i${m.doneToday ? ' class="done"' : ''} style="width:${pct}%"></i></div>
      <div class="fp-bar-meta"><span>${pct}%</span>${chip}</div></div>`;
  }).join('');

  const dailyBlock = daily ? shead('Napi csapat-jutalmak') +
    '<div class="sub">Ha a frakció egyszerre eléri a létszámot, mindenki kap valamit, aki fent van. Naponta egyszer, automatikus.</div>' +
    `<div class="fp-grid">${daily}</div>` : '';

  document.getElementById('sec-miss').innerHTML =
    head('Fejlődés', 'Frakció <b>küldetések</b>', 'A fejlődésért ingyen pontokat kaptok &mdash; a jutalmat ti rakjátok le.') +
    `<div class="fp-grid">${cards || '<div class="fp-empty">Nincs küldetés.</div>'}</div>
    ${dailyBlock}`;
}

function renderStore() {
  let chips = DATA.storages.map(s => {
    const lbl = (s.type === 'safe' ? 'Széf #' : 'Tároló #') + s.id;
    const sel = curStore && curStore.id === s.id ? ' sel' : '';
    return `<span class="fp-pill chip${sel}" data-act="chip" data-id="${s.id}" data-stype="${s.type}">${lbl}</span>`;
  }).join('');
  document.getElementById('sec-store').innerHTML =
    head('Hozzáférés', 'Tárolók <b>&amp; széfek</b>', 'Csak a frakciótok pontjai. Állítsd, melyik rang férhet hozzá.') +
    `<div class="chips">${chips || '<div class="fp-empty">Nincs tároló vagy széf.</div>'}</div>
    <div id="acc-box"></div>`;
  if (curStore) post('getAccess', { id: curStore.id, stype: curStore.stype });
}

function renderAccess(id, stype, info) {
  const box = document.getElementById('acc-box');
  if (!box) return;
  if (!info) { box.innerHTML = '<div class="fp-empty">Ehhez nincs jogosultságod, vagy nem te vagy a főnök.</div>'; return; }
  const title = (stype === 'safe' ? 'Széf #' : 'Tároló #') + id;
  const unit = (stype === 'safe' ? 'pénz' : 'tárgy');
  let rows = info.ranks.map(r => `
    <div class="acc-row">
      <span class="an">${esc(r.label)}</span>
      <span class="fp-pill ${r.withdraw ? 'on' : 'off'}" data-act="acc" data-id="${id}" data-stype="${stype}" data-kind="withdraw" data-grade="${r.grade}" data-cur="${r.withdraw ? 1 : 0}">Kivét</span>
      <span class="fp-pill ${r.deposit ? 'on' : 'off'}" data-act="acc" data-id="${id}" data-stype="${stype}" data-kind="deposit" data-grade="${r.grade}" data-cur="${r.deposit ? 1 : 0}">Betét</span>
      <input class="fp-in" style="width:6em" type="number" min="0" step="1" value="${Math.round(r.withdrawLimit || 0)}" data-act="limit" data-id="${id}" data-stype="${stype}" data-grade="${r.grade}" title="Max kivét egyszerre (0 = korlátlan)">
    </div>`).join('');
  box.innerHTML = `<div class="fp-card"><div class="bt">Hozzáférés &mdash; ${title}</div>
    <div class="acc-list">${rows}</div>
    <div class="fp-hint">A pillek a kivét/betét engedélyt kapcsolják. A szám = max ${unit} egyszerre kivéve (0 = korlátlan).</div></div>`;
  enhance();
}

function renderMoney(balance) {
  document.getElementById('sec-money').innerHTML =
    head('Pénzügyek', 'Társasági <b>kassza</b>', 'A frakció számlájának egyenlege és kezelése.') + `
    <div class="fp-card fp-metric mb"><div class="v">${fmt(balance)} $</div><div class="l">Társasági egyenleg</div></div>
    <div class="fp-grid g2">
      <div class="fp-card"><div class="bt">Befizetés</div>
        <div class="money-row"><input class="fp-in" id="depAmount" type="number" min="1" placeholder="Összeg"><button class="fp-btn green" data-act="deposit">Befizet</button></div></div>
      <div class="fp-card"><div class="bt">Kivét</div>
        <div class="money-row"><input class="fp-in" id="wdAmount" type="number" min="1" placeholder="Összeg"><button class="fp-btn" data-act="withdraw">Kivesz</button></div></div>
    </div>`;
  enhance();
}

function renderEmployees() {
  const sec = document.getElementById('sec-emp');

  // Preserve the search box, the open bonus draft and the scroll position
  // across re-renders (the list auto-refreshes every 5s while the panel is open)
  const main = sec.closest('.fp-main');
  const scrollY = main ? main.scrollTop : 0;
  const act = document.activeElement;
  const oldQ = document.getElementById('emp-q');
  if (oldQ) empQuery = oldQ.value;
  const searchFocus = act && act.id === 'emp-q';
  const selStart = searchFocus ? act.selectionStart : 0;
  const oldB = document.getElementById('bonus-amt');
  const bonusDraft = oldB ? oldB.value : '';
  const bonusFocus = act && act.id === 'bonus-amt';

  const ranks = (DATA && DATA.ranks) || [];
  const gl = empState.gradesLabels || {};

  const all = empState.employees.slice().sort((a, b) =>
    (b.job_grade - a.job_grade) ||
    `${a.firstname || ''} ${a.lastname || ''}`.localeCompare(`${b.firstname || ''} ${b.lastname || ''}`, 'hu'));

  const q = norm(empQuery.trim());
  const list = q ? all.filter(e => norm(`${e.firstname || ''} ${e.lastname || ''}`).includes(q)) : all;

  let rows = list.map(e => {
    const name = `${esc(e.firstname || '')} ${esc(e.lastname || '')}`.trim();
    const cur = e.job_grade;
    const id = esc(e.identifier);
    const isSelf = myIdent && e.identifier === myIdent;
    const onl = e.online !== false;
    const dot = `<i class="fp-dot${onl ? ' on' : ''}"></i>`;
    const open = bonusOpenId === e.identifier;

    const bonusBtn = `<button class="fp-btn ghost" data-act="bonusopen" data-identifier="${id}"` +
      ` ${onl ? '' : 'disabled title="Csak online tagnak adható"'}>Bónusz</button>`;

    let controls;
    if (isSelf) {
      // Saját sor: nincs léptetés/kirúgás (magadat nem rúghatod ki)
      controls = '<span class="fp-tag bl">Te</span>';
    } else {
      const opts = ranks.map(r => `<option value="${r.grade}" ${r.grade == cur ? 'selected' : ''}>${esc(r.label)}</option>`).join('');
      const fireBtn = fireArmId === e.identifier
        ? `<button class="fp-btn danger armed" data-act="fire" data-identifier="${id}">Biztos?</button>`
        : `<button class="fp-btn danger" data-act="firearm" data-identifier="${id}">Kirúg</button>`;
      controls = `<select class="fp-in" style="width:auto" data-promo="${id}">${opts}</select>
      <button class="fp-btn" data-act="promote" data-identifier="${id}">Léptet</button>
      ${fireBtn}`;
    }

    let drawer = '';
    if (open) {
      drawer = `<div class="fp-bonus${bonusAnim ? ' anim' : ''}">
        <input class="fp-in" type="number" min="1" placeholder="Összeg ($)" id="bonus-amt" style="width:9em">
        <span class="fp-hint">A frakció kasszájából megy, csak online tagnak.</span>
        <button class="fp-btn green" data-act="bonussend" data-identifier="${id}">Kiküldés</button>
        <button class="fp-btn ghost" data-act="bonuscancel">Mégse</button>
      </div>`;
    }

    return `<div>
      <div class="fp-row${open ? ' open' : ''}">
        <div class="fp-rt"><div class="a">${name || 'Ismeretlen'}</div>
          <div class="b">${dot}${esc(gl[cur] || ('grade ' + cur))} &middot; ${onl ? 'online' : 'offline'}</div></div>
        ${bonusBtn}
        ${controls}
      </div>${drawer}
    </div>`;
  }).join('');

  sec.innerHTML =
    head('Személyzet', 'Alkalmazottak <b>kezelése</b>',
      'Rang léptetés, kirúgás, bónusz, közeli játékos felvétele. Saját magadat nem rúghatod ki.',
      `${all.length} fő`) + `
    <div class="fp-emp-top">
      <input class="fp-in" id="emp-q" placeholder="Keresés név szerint..." maxlength="40" autocomplete="off">
      <button class="fp-btn" data-act="getnearby">Felvétel (közeli játékos)</button>
    </div>
    <div id="nearby-box"></div>
    <div class="fp-grid">${rows || `<div class="fp-empty">${q ? 'Nincs találat a keresésre.' : 'Nincs alkalmazott.'}</div>`}</div>`;

  renderNearbyBox();

  const qEl = document.getElementById('emp-q');
  qEl.value = empQuery;
  qEl.addEventListener('input', () => { renderEmployees(); });
  if (searchFocus) { qEl.focus(); qEl.setSelectionRange(selStart, selStart); }

  const bEl = document.getElementById('bonus-amt');
  if (bEl) {
    bEl.value = bonusDraft;
    bEl.addEventListener('keydown', ev => { if (ev.key === 'Enter') sendBonusNow(); });
    if (bonusFocus) bEl.focus();
  }
  enhance();
  bonusAnim = false;
  if (main) main.scrollTop = scrollY;
}

function sendBonusNow() {
  const b = document.getElementById('bonus-amt');
  if (!b || !bonusOpenId) return;
  const val = Math.floor(Number(b.value));
  if (!Number.isFinite(val) || val < 1) { b.focus(); return; }
  post('giveBonus', { identifier: bonusOpenId, amount: val });
  bonusOpenId = null;
  renderEmployees();
}

function renderNearbyBox() {
  const box = document.getElementById('nearby-box');
  if (!box) return;
  if (nearbyList === null) { box.innerHTML = ''; return; }
  const hd = `<div class="nearby-head">
    <span class="nt">Közeli játékosok</span>
    <button class="fp-btn ghost" data-act="nearbyclose">Bezárás</button></div>`;
  let rows = nearbyList.map(p => `<div class="fp-row nb">
    <div class="fp-rt"><div class="a">${esc(p.label)}</div></div>
    <span class="fp-tag muted">ID: ${+p.serverId || '?'}</span>
    <button class="fp-btn green" data-act="recruit" data-sid="${p.serverId}">Felvesz</button></div>`).join('');
  box.innerHTML = `<div class="fp-card mb">${hd}
    ${rows || '<div class="fp-empty">Nincs felvehető közeli játékos.</div>'}</div>`;
}

function renderSalaries(grades) {
  let rows = grades.map(g => `<div class="fp-row">
    <span class="gnum">[${g.grade}]</span>
    <div class="fp-rt"><div class="a">${esc(g.label)}</div></div>
    <input class="fp-in" style="width:8em" type="number" min="0" value="${Math.round(g.salary || 0)}" data-sal="${g.id}">
    <button class="fp-btn green" data-act="setsalary" data-gradeid="${g.id}" data-grade="${g.grade}">Mentés</button></div>`).join('');
  document.getElementById('sec-salary').innerHTML =
    head('Bérezés', 'Fizetések <b>rangonként</b>', 'Rangonkénti fizetés beállítása.') +
    `<div class="fp-grid">${rows || '<div class="fp-empty">Nincs rang.</div>'}</div>`;
  enhance();
}

function renderActivity(list) {
  let rows = list.map(p => {
    const name = `${esc(p.firstname || '')} ${esc(p.lastname || '')}`.trim() || esc(p.identifier || '');
    const seen = esc(p.ls || '-');
    return `<div class="fp-row"><div class="fp-rt"><div class="a">${name}</div>
      <div class="b">Utoljára aktív: ${seen}</div></div></div>`;
  }).join('');
  document.getElementById('sec-act').innerHTML =
    head('Tagok', 'Utolsó <b>aktivitás</b>', 'A frakció tagjainak utolsó belépése.', `${list.length} tag`) +
    `<div class="fp-grid">${rows || '<div class="fp-empty">Nincs adat.</div>'}</div>`;
}

document.getElementById('fp-nav').addEventListener('click', e => {
  const it = e.target.closest('.fp-item'); if (!it) return;
  document.querySelectorAll('.fp-item').forEach(n => n.classList.remove('on'));
  it.classList.add('on');
  const t = it.dataset.t;
  document.querySelectorAll('.fp-sec').forEach(s => s.classList.toggle('on', s.dataset.s === t));
  setWatermark(t);
  it.scrollIntoView({ block: 'nearest' }); // the nav scrolls: keep the active tab in view
  document.getElementById('fp-main').scrollTop = 0;
  if (t === 'money') post('getMoney');
  else if (t === 'emp') post('getEmployees');
  else if (t === 'salary') post('getSalaries');
  else if (t === 'act') post('getActivity');
  else if (t === 'hq') post('getHQ');
});

document.getElementById('btn-close').addEventListener('click', () => { hide(); post('close'); });

/* ---- Frakció HQ fül (bc_factionhq) ---- */
function renderHQ() {
  const sec = document.getElementById('sec-hq');
  if (!sec) return;

  if (HQ === false) {
    sec.innerHTML = head('Ingatlan', 'Frakció <b>HQ</b>', 'A HQ modul nem elérhető.') +
      '<div class="fp-empty">A HQ modul (bc_factionhq) nem fut a szerveren.</div>';
    return;
  }
  if (!HQ) {
    sec.innerHTML = head('Ingatlan', 'Frakció <b>HQ</b>', 'Adatok lekérése…') +
      '<div class="fp-empty">Betöltés…</div>';
    return;
  }

  const d = HQ;

  /* Még nincs HQ: a vásárlás a mapon, az admin által lerakott pontnál történik */
  if (!d.owned) {
    sec.innerHTML =
      head('Ingatlan', 'Frakció <b>HQ</b>', 'A frakciónak még nincs HQ-ja.', `${fmt(d.prices.hq)} $ a kasszából`) + `
      <div class="fp-card">
        <div class="hqtext">
          Keress a mapon egy <b>Eladó Frakció HQ</b> pontot (zöld ház ikon),
          állj rá boss rangként, és az <b>E</b> menüből választhatsz interiort
          (megtekintés is van), majd ott vásárolhatod meg <b>${fmt(d.prices.hq)} $</b>-ért
          a frakciókasszából. Vásárlás után minden jobcreator CP egyszer <b>ingyen</b>
          áthelyezhető — vidd be őket a HQ-ba.
        </div>
      </div>`;
    return;
  }

  /* Van HQ: állapot + belépő CP áthelyezés + ingyenes CP-kör + engedélyek */
  const h = d.hq;
  const freeLeft = h.freeCPs.filter(c => !c.used).length;
  const canMove = DATA && DATA.pp >= d.prices.entryMove && d.ppAvailable;
  const paidPrice = DATA && DATA.config ? DATA.config.movePrice : 500;

  const freeRows = h.freeCPs.map(cp => `
    <div class="fp-row"><div class="fp-ico">${esc(typeAbbr(cp.type))}</div>
      <div class="fp-rt"><div class="a">${esc(cp.label)} <span class="id">#${cp.id}</span></div>
        <div class="b">${esc(cp.type)}</div></div>
      ${cp.used
        ? '<span class="fp-tag muted">felhasználva</span>'
        : `<button class="fp-btn green" data-act="hqfreemove" data-cp="${cp.id}" data-lbl="${esc(cp.label)}" ${d.jcAvailable ? '' : 'disabled'}>Ingyen áthelyez</button>`}
    </div>`).join('');

  const accRows = h.accessList.map(a => `
    <div class="fp-row">
      <div class="fp-rt"><div class="a">${esc(a.name)}</div><div class="b">${esc(a.identifier)}</div></div>
      <button class="fp-btn danger" data-act="hqrevoke" data-id="${esc(a.identifier)}">Visszavon</button>
    </div>`).join('');

  sec.innerHTML =
    head('Ingatlan', 'Frakció <b>HQ</b>',
      'A belépő CP-nél a tagok bemehetnek, külsősök a CP-nél behívhatók. Az interior fixen a vásárláskori pont fölött van, a belépő CP áthelyezése nem mozgatja.',
      esc(h.interiorLabel)) + `
    <div class="fp-grid g3 mb">
      <div class="fp-card fp-metric"><div class="v">${h.occupancy}</div><div class="l">Bent most</div></div>
      <div class="fp-card fp-metric"><div class="v">${freeLeft}</div><div class="l">Ingyenes áthelyezés hátra</div></div>
      <div class="fp-card fp-metric"><div class="v sm">${Math.round(h.entry.x)}, ${Math.round(h.entry.y)}</div><div class="l">Belépő CP helye</div></div>
    </div>
    ${d.entryMoveAllowed ? `<div class="fp-card rowcard mb">
      <div class="fp-rt"><div class="a">Belépő CP áthelyezése</div>
        <div class="b">Bárhova a mapon — az interior és a benti CP-k változatlanok maradnak.</div></div>
      <button class="fp-btn" data-act="hqmoveentry" ${canMove ? '' : 'disabled'}>Áthelyezés (${fmt(d.prices.entryMove)} PP)</button>
    </div>` : `<div class="fp-card mb">
      <div class="fp-rt"><div class="a">Belépő CP áthelyezése</div>
        <div class="b">A HQ helyét csak admin tudja áthelyezni.</div></div>
    </div>`}
    ${shead('Ingyenes CP áthelyezés', `minden CP egyszer, utána ${fmt(paidPrice)} PP/db a CP áthelyezés fülön`)}
    <div class="fp-grid gap-t mb">${freeRows || '<div class="fp-empty">Nincs jobcreator CP-tek.</div>'}</div>
    ${shead('Belépési engedélyek', 'behívás a belépő CP menüjéből')}
    <div class="fp-grid gap-t">${accRows || '<div class="fp-empty">Nincs kiadott engedély.</div>'}</div>`;
}

document.addEventListener('click', e => {
  const el = e.target.closest('[data-act]'); if (!el) return;
  const a = el.dataset.act;
  if (HEAVY.indexOf(a) !== -1) {
    if (busy) return;
    busy = true;
    setTimeout(() => { busy = false; }, 4000);
  }
  if (a === 'move') { hide(); post('moveCP', { cpId: +el.dataset.cp, cpLabel: el.dataset.lbl }); }
  else if (a === 'buy') { hide(); post('buyCP', { typeIndex: +el.dataset.idx, typeLabel: el.dataset.lbl }); }
  else if (a === 'rank') {
    const inp = el.closest('.fp-row').querySelector('input');
    const v = (inp.value || '').trim();
    if (v.length > 0) post('renameRank', { grade: +el.dataset.grade, label: v });
  }
  else if (a === 'renameFaction') {
    const inp = document.getElementById('newFactionLabel');
    const v = (inp.value || '').trim();
    if (v.length > 0) post('renameFaction', { label: v });
  }
  else if (a === 'mission') { hide(); post('claimMission', { missionId: el.dataset.mid }); }
  else if (a === 'chip') { curStore = { id: +el.dataset.id, stype: el.dataset.stype }; renderStore(); }
  else if (a === 'acc') {
    post('setAccess', { id: +el.dataset.id, stype: el.dataset.stype, kind: el.dataset.kind, grade: +el.dataset.grade, allowed: el.dataset.cur !== '1' });
  }
  else if (a === 'buyrank') {
    const label = (document.getElementById('newRankLabel').value || '').trim();
    const pos = parseInt(document.getElementById('newRankPos').value, 10) || 0;
    post('buyRank', { label: label, insertGrade: pos });
  }
  else if (a === 'delrank') {
    post('deleteRank', { rankId: +el.dataset.rankid });
  }
  else if (a === 'moveup') { post('moveRank', { grade: +el.dataset.grade, dir: 1 }); }
  else if (a === 'movedn') { post('moveRank', { grade: +el.dataset.grade, dir: -1 }); }
  else if (a === 'deposit') {
    const inp = document.getElementById('depAmount');
    const v = Math.floor(+inp.value || 0);
    if (v > 0) { post('deposit', { amount: v }); inp.value = ''; }
  }
  else if (a === 'withdraw') {
    const inp = document.getElementById('wdAmount');
    const v = Math.floor(+inp.value || 0);
    if (v > 0) { post('withdraw', { amount: v }); inp.value = ''; }
  }
  else if (a === 'promote') {
    const id = el.dataset.identifier;
    const sel = document.querySelector(`[data-promo="${CSS.escape(id)}"]`);
    if (sel) post('promote', { identifier: id, grade: +sel.value });
  }
  else if (a === 'fire') {
    // Second click of the two-step confirm
    clearTimeout(fireArmTimer); fireArmId = null;
    post('fire', { identifier: el.dataset.identifier });
    renderEmployees();
  }
  else if (a === 'firearm') {
    // First click arms the button ("Biztos?"), auto-resets after 3.5s
    fireArmId = el.dataset.identifier; bonusOpenId = null;
    renderEmployees();
    clearTimeout(fireArmTimer);
    fireArmTimer = setTimeout(() => { fireArmId = null; renderEmployees(); }, 3500);
  }
  else if (a === 'bonusopen') {
    const id = el.dataset.identifier;
    const opening = bonusOpenId !== id;
    bonusOpenId = opening ? id : null;
    if (opening) bonusAnim = true;
    fireArmId = null;
    renderEmployees();
    const b = document.getElementById('bonus-amt');
    if (b) b.focus();
  }
  else if (a === 'nearbyclose') { nearbyList = null; renderNearbyBox(); }
  else if (a === 'bonuscancel') { bonusOpenId = null; renderEmployees(); }
  else if (a === 'bonussend') { sendBonusNow(); }
  else if (a === 'getnearby') {
    post('getNearby');
  }
  else if (a === 'recruit') {
    post('recruit', { serverId: +el.dataset.sid });
    // A felvett jatekos mar frakciotag, tunjon el a kozeli listabol is
    setTimeout(() => post('getNearby'), 900);
  }
  else if (a === 'setsalary') {
    const inp = document.querySelector(`[data-sal="${el.dataset.gradeid}"]`);
    const v = Math.max(0, Math.floor(+(inp ? inp.value : 0) || 0));
    post('setSalary', { gradeId: +el.dataset.gradeid, grade: +el.dataset.grade, amount: v });
  }
  /* Frakció HQ fül */
  else if (a === 'hqmoveentry') { hide(); post('hqMoveEntry'); }
  else if (a === 'hqfreemove') { hide(); post('hqFreeMove', { cpId: +el.dataset.cp, cpLabel: el.dataset.lbl }); }
  else if (a === 'hqrevoke') { post('hqRevoke', { identifier: el.dataset.id }); setTimeout(() => post('getHQ'), 700); }
});

document.addEventListener('change', e => {
  const el = e.target.closest('[data-act="limit"]'); if (!el) return;
  let v = Math.max(0, Math.floor(+el.value || 0));
  el.value = v;
  post('setLimit', { id: +el.dataset.id, stype: el.dataset.stype, grade: +el.dataset.grade, limit: v });
});

document.addEventListener('keydown', e => {
  if (e.key === 'Escape') { hide(); post('close'); }
});

/* ---- Reset visszaszámlálók: mp-enként frissül, lejáratkor újratölti az adatokat ---- */
let lastAutoRefresh = 0;
setInterval(() => {
  if (app.classList.contains('hidden')) return;
  const els = document.querySelectorAll('[data-reset-at]');
  if (!els.length) return;
  let expired = false;
  els.forEach(el => {
    const rem = (+el.dataset.resetAt) - nowSec();
    const t = el.querySelector('.t');
    if (t) t.textContent = fmtDur(rem);
    if (rem <= 0) expired = true;
  });
  // Resetkor egyszer újrakérjük a panel-adatot (15 mp-es védelemmel a spam ellen)
  if (expired && Date.now() - lastAutoRefresh > 15000) {
    lastAutoRefresh = Date.now();
    post('refresh');
  }
}, 1000);

buildNav();
