/* ============================================================
   HASZNÁLTOK — NUI logika
   ============================================================ */
/* Futtatási mód felismerése.
   FONTOS: a RoadPhone iframe-ben a GetParentResourceName NEM elérhető,
   ezért a hosztnévből (cfx-nui-<resource>) ismerjük fel a FiveM-et. Így a
   fejlesztői DEMO-mód SOSEM aktiválódik a telefonban. */
function detectRes() {
  if (typeof GetParentResourceName === 'function') { try { return GetParentResourceName(); } catch (e) { } }
  const h = location.hostname || '';
  if (h.indexOf('cfx-nui-') === 0) return h.substring('cfx-nui-'.length);
  return 'autosapp_dealer';
}
const RES = detectRes();
const HAS_GPRN = typeof GetParentResourceName === 'function';
const IS_CFX = /^cfx-nui-/.test(location.hostname || '') || location.protocol === 'nui:' || HAS_GPRN;
const IS_BROWSER = !IS_CFX;                       // valódi böngésző (csak ekkor megy a mock)
// RoadPhone iframe: nested frame, ahova a FiveM NEM injektálja a GetParentResourceName-et;
// a saját, teljes képernyős ui_page-ünkbe VISZONT igen. Egyes FiveM-build-ek a saját
// ui_page-et is iframe-be teszik, ezért a window.top önmagában FÉLREVEZET — a !HAS_GPRN
// zárja ki, hogy az ÖNÁLLÓ app magától, teljes képernyőn ráüljön a játékra belépéskor.
const EMBEDDED = IS_CFX && (window.self !== window.top) && !HAS_GPRN;

const root = document.getElementById('root');
const content = document.getElementById('content');
const tierChip = document.getElementById('tierChip');
const tabbar = document.getElementById('tabbar');
const toastEl = document.getElementById('toast');
const photoOverlay = document.getElementById('photoOverlay');

let CFG = {
  categories: [], promoPrice: 15000000, maxWeeks: 8, maxImages: 1, accessPrice: 1000000, maxDesc: 600, maxReview: 300, phoneRes: 'roadphone',
  massCategories: [], tiers: [], tasks: [], points: { AccessWeek: 40, AdPosted: 35, Sale: 70, PromoWeek: 50, Task: 120 }
};
let STATE = { hasAccess: false, accessUntil: 0, isAdmin: false, member: null, accessPrice: 1000000 };
let currentTab = 'market';
let marketFilter = { search: '', category: '', sort: 'newest' };
let uploadState = { vehicles: [], selected: null, images: [], category: '' };
let detailState = { car: null, galleryIndex: 0 };

// Autó-lista cache: null = nem töltöttött, Array = teljes (szűrés nélküli) lista.
// Inválidáljuk írási műveletek után (létrehoz, törlés, eladott, kiemelés).
// Lájk/kedvenc-változásnál az elemet helyben módosítjuk, út nélkül.
let carListCache = null;
function invalidateCarCache() { carListCache = null; }

// Kliensoldali szűrés + rendezés a cacheltt lista alapján.
// A szerver az "újabb előre, kiemelt első" sorrendet adja — ez az alap-sorrend.
function localFilterSort(filter) {
  if (!carListCache) return [];
  const q = (filter.search || '').trim().toLowerCase();
  const cat = filter.category || '';
  let list = carListCache.filter(c => {
    if (q && !(c.title || '').toLowerCase().includes(q)) return false;
    if (cat && c.category !== cat) return false;
    return true;
  });
  // Promoted always first, then sort by chosen criteria.
  // "newest" = preserve server order (no extra comparator needed).
  if (filter.sort === 'price_asc') {
    list.sort((a, b) => a.promoted !== b.promoted ? (a.promoted ? -1 : 1) : (a.price - b.price));
  } else if (filter.sort === 'price_desc') {
    list.sort((a, b) => a.promoted !== b.promoted ? (a.promoted ? -1 : 1) : (b.price - a.price));
  } else if (filter.sort === 'most_viewed') {
    list.sort((a, b) => a.promoted !== b.promoted ? (a.promoted ? -1 : 1) : ((b.views || 0) - (a.views || 0)));
  } else {
    // newest: sort by created_at desc, promoted first
    list.sort((a, b) => a.promoted !== b.promoted ? (a.promoted ? -1 : 1) : ((b.created_at || 0) - (a.created_at || 0)));
  }
  return list;
}

/* ---------- RoadPhone input-fókusz ----------
   A RoadPhone SetNuiFocusKeepInput-et használ: alapból a JÁTÉK is kapja a
   gombnyomást, és csak akkor fogja meg a billentyűzetet, ha az ŐSAJÁT mezője
   van fókuszban (inputfocus callback). A mi iframe-ünk mezőit a telefon nem
   látja, ezért magunk szólunk neki — különben a gépelés/gombok a játékba mennek. */
let rpFocusOn = null;
function phoneInputFocus(on) {
  if (!EMBEDDED) return;                 // standalone: a saját SetNuiFocus(true,true) kezeli
  on = !!on;
  if (rpFocusOn === on) return;          // ne küldjünk felesleges/ismétlő net eventet
  rpFocusOn = on;
  fetch(`https://${CFG.phoneRes || 'roadphone'}/inputfocus`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({ focus: on }),
  }).catch(() => { });
}

/* ---------- NUI fetch ---------- */
async function post(name, data = {}) {
  try {
    const res = await fetch(`https://${RES}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch (e) { return false; }
}

/* ---------- Segédek ---------- */
const fmtMoney = n => (Number(n) || 0).toLocaleString('hu-HU') + ' $';
const fmtNum = n => (Number(n) || 0).toLocaleString('hu-HU');
const esc = s => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const catLabel = v => (CFG.categories.find(c => c.value === v) || {}).label || v;
// MassCategoryLabel helyi feloldása a CFG.massCategories tömbből.
// A Lua tömb JSON-ként: [[min,max,key,label],...] → így érjük el a negyedik mezőt.
const massCatLabel = key => { if (!key) return null; const r = CFG.massCategories.find(m => m[2] === key); return r ? r[3] : null; };
function imgStyle(url) { return url ? `style="background-image:url('${esc(url)}')"` : ''; }

let toastTimer;
function toast(msg, type = '') {
  toastEl.textContent = msg;
  toastEl.className = 'toast show ' + type;
  if (type === 'err') sfx('error'); else if (type === 'ok') sfx('success');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { toastEl.className = 'toast ' + type; }, 2600);
}

/* In-app megerősítő ablak (a csúnya natív confirm() helyett) */
function uiConfirm(msg, opts = {}) {
  return new Promise(resolve => {
    const wrap = document.createElement('div');
    wrap.className = 'modal-wrap';
    wrap.innerHTML = `
      <div class="modal">
        <div class="modal-msg">${esc(msg)}</div>
        <div class="modal-btns">
          <button class="btn btn-ghost btn-sm" data-no>Mégse</button>
          <button class="btn ${opts.danger ? 'btn-danger' : 'btn-primary'} btn-sm" data-yes>${esc(opts.ok || 'Igen')}</button>
        </div>
      </div>`;
    (document.querySelector('.phone') || document.body).appendChild(wrap);
    const done = v => { wrap.remove(); resolve(v); };
    wrap.querySelector('[data-yes]').addEventListener('click', () => { sfx('click'); done(true); });
    wrap.querySelector('[data-no]').addEventListener('click', () => { sfx('click'); done(false); });
    wrap.addEventListener('click', e => { if (e.target === wrap) done(false); });
  });
}

function remainText(until) {
  const ms = until - Date.now();
  if (ms <= 0) return 'lejárt';
  const d = Math.floor(ms / 86400000);
  const h = Math.floor((ms % 86400000) / 3600000);
  if (d > 0) return `${d} nap ${h} óra`;
  const m = Math.floor((ms % 3600000) / 60000);
  return `${h} óra ${m} perc`;
}

/* ============================================================
   (2) HANGOK — szintetizált, kikapcsolható (nincs hangfájl)
   ============================================================ */
function lsGet(k, def) { try { const v = localStorage.getItem(k); return v == null ? def : v === '1'; } catch (e) { return def; } }
function lsSet(k, v) { try { localStorage.setItem(k, v ? '1' : '0'); } catch (e) { } }
const SETTINGS = { sound: lsGet('hasznaltok_sound', true), ambient: lsGet('hasznaltok_ambient', false) };

let actx;
function ac() {
  if (!actx) { try { actx = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) { return null; } }
  if (actx.state === 'suspended') actx.resume();
  return actx;
}
function tone(freq, dur, type = 'sine', gain = 0.06, when = 0) {
  const c = ac(); if (!c) return;
  const o = c.createOscillator(), g = c.createGain();
  o.type = type; o.frequency.value = freq;
  o.connect(g); g.connect(c.destination);
  const t = c.currentTime + when;
  g.gain.setValueAtTime(0.0001, t);
  g.gain.linearRampToValueAtTime(gain, t + 0.012);
  g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
  o.start(t); o.stop(t + dur + 0.03);
}
function sfx(name) {
  if (!SETTINGS.sound) return;
  switch (name) {
    case 'click': tone(420, 0.07, 'triangle', 0.04); break;
    case 'tab': tone(540, 0.08, 'sine', 0.045); break;
    case 'open': tone(330, 0.12, 'sine', 0.05); tone(495, 0.16, 'sine', 0.045, 0.06); break;
    case 'success': tone(523, 0.10, 'sine', 0.06); tone(784, 0.18, 'sine', 0.05, 0.09); break;
    case 'error': tone(190, 0.18, 'sawtooth', 0.05); break;
    case 'like': tone(680, 0.06, 'triangle', 0.05); tone(900, 0.08, 'triangle', 0.045, 0.05); break;
    case 'cash': tone(740, 0.07, 'square', 0.035); tone(988, 0.10, 'square', 0.035, 0.06); tone(1245, 0.12, 'square', 0.03, 0.13); break;
  }
}

/* Halk háttér-hangulat (lassan pulzáló pad) */
let amb = null;
function ambientStart() {
  const c = ac(); if (!c || amb) return;
  const master = c.createGain(); master.gain.value = 0.0; master.connect(c.destination);
  const filter = c.createBiquadFilter(); filter.type = 'lowpass'; filter.frequency.value = 480; filter.connect(master);
  const o1 = c.createOscillator(); o1.type = 'sine'; o1.frequency.value = 96;
  const o2 = c.createOscillator(); o2.type = 'sine'; o2.frequency.value = 144.5;
  o1.connect(filter); o2.connect(filter);
  const lfo = c.createOscillator(); lfo.type = 'sine'; lfo.frequency.value = 0.07;
  const lfoG = c.createGain(); lfoG.gain.value = 0.012; lfo.connect(lfoG); lfoG.connect(master.gain);
  master.gain.linearRampToValueAtTime(0.02, c.currentTime + 2.5);
  o1.start(); o2.start(); lfo.start();
  amb = { master, nodes: [o1, o2, lfo] };
}
function ambientStop() {
  if (!amb) return;
  const c = ac();
  try { amb.master.gain.linearRampToValueAtTime(0.0001, c.currentTime + 0.6); } catch (e) { }
  setTimeout(() => { try { amb.nodes.forEach(n => n.stop()); } catch (e) { } amb = null; }, 700);
}
function syncAmbient() { if (SETTINGS.ambient) ambientStart(); else ambientStop(); }

/* ============================================================
   FEJLÉC — tagsági chip (18)
   ============================================================ */
function renderTierChip() {
  const t = STATE.member && STATE.member.tier;
  if (!t) { tierChip.textContent = '—'; return; }
  tierChip.innerHTML = `<span class="dot" style="color:${t.color}"></span>${esc(t.name)}`;
}
function sellerBadge(seller) {
  if (!seller) return '';
  return `<span class="seller-badge" style="color:${seller.color}"><span class="dot"></span>${esc(seller.name)}</span>`;
}
function availBadge(inline) { return `<span class="badge-avail${inline ? ' inline' : ''}"><span class="pulse"></span>Elérhető</span>`; }

function ratingStars(avg, big) {
  const full = Math.round(Number(avg) || 0);
  let s = '';
  for (let i = 1; i <= 5; i++) s += `<span class="star ${i <= full ? 'on' : ''}">★</span>`;
  return `<span class="stars ${big ? 'big' : ''}">${s}</span>`;
}
function ratingChip(seller) {
  if (!seller) return '';
  if (!seller.ratingCount) return `<span class="tag">☆ nincs értékelés</span>`;
  return `<span class="tag rating">★ ${seller.rating} (${seller.ratingCount})</span>`;
}

/* ============================================================
   (17) LOCK KÉPERNYŐ — heti hozzáférés
   ============================================================ */
function renderLock() {
  tabbar.classList.add('hidden');
  content.innerHTML = `
    <div class="lock">
      <div class="ic">🔒</div>
      <h2>Használtautó hozzáférés</h2>
      <p>Az app használata heti díjas. Old fel egy hétre, és máris hirdethetsz, böngészhetsz és gyűjtheted a tagsági pontokat.</p>
      <div class="price">${fmtMoney(STATE.accessPrice)}</div>
      <div class="per">/ 1 hét — bankszámláról</div>
      <button class="btn btn-primary" id="buyAccess">🔓 Hozzáférés feloldása</button>
    </div>`;
  document.getElementById('buyAccess').addEventListener('click', async (e) => {
    const btn = e.currentTarget; btn.disabled = true; btn.textContent = 'Fizetés…';
    const r = await post('buyAccess');
    if (r && r.ok) {
      sfx('cash');
      STATE.hasAccess = true; STATE.accessUntil = r.accessUntil; STATE.member = r.member;
      renderTierChip(); tabbar.classList.remove('hidden');
      toast('Hozzáférés feloldva egy hétre! 🎉', 'ok');
      goTab('market');
    } else {
      btn.disabled = false; btn.textContent = '🔓 Hozzáférés feloldása';
      toast((r && r.msg) || 'Sikertelen feloldás.', 'err');
    }
  });
}

/* ============================================================
   KÁRTYA
   ============================================================ */
function cardHTML(c, opts = {}) {
  const promo = c.promoted ? `<div class="badge-promo">⭐ KIEMELT</div>` : '';
  const sold = c.sold ? `<div class="badge-sold">ELADVA</div>` : '';
  const avail = (c.available && !opts.noReact) ? availBadge() : '';
  let actions = '';
  if (!opts.noReact) {
    actions = `
      <div class="card-actions">
        <button class="icon-btn ${c.liked ? 'active-like' : ''}" data-like="${c.id}">${c.liked ? '❤️' : '🤍'} ${fmtNum(c.likes)}</button>
        <button class="icon-btn ${c.fav ? 'active-fav' : ''}" data-fav="${c.id}">${c.fav ? '⭐' : '☆'}</button>
      </div>`;
  }
  const tags = `
    <div class="card-tags">
      ${c.category ? `<span class="tag cat">${esc(catLabel(c.category))}</span>` : ''}
      ${c.massCategory ? `<span class="tag tip">Tipp: ${esc(massCatLabel(c.massCategory) || c.massCategory)}</span>` : ''}
      ${c.tuned ? `<span class="tag tuned">🔧 ${c.tuned}%</span>` : ''}
      ${c.extraspeed ? `<span class="tag tuned">🚀 +${c.extraspeed}</span>` : ''}
      ${!opts.noReact ? sellerBadge(c.seller) : ''}
      ${!opts.noReact ? ratingChip(c.seller) : ''}
    </div>`;
  return `
    <div class="card ${c.promoted ? 'promoted' : ''}" data-open="${c.id}">
      <div class="card-img" ${imgStyle(c.image)}>${c.image ? '' : '🚙'}${promo}${sold}${avail}</div>
      <div class="card-body">
        <div class="card-title"><span>${esc(c.title)}</span><span class="card-price">${fmtMoney(c.price)}</span></div>
        ${tags}
        <div class="card-meta">
          <span class="stat">👁️ ${fmtNum(c.views)}</span>
          <span class="stat">❤️ ${fmtNum(c.likes)}</span>
          ${actions}
        </div>
      </div>
    </div>`;
}

function wireCards(container) {
  container.querySelectorAll('[data-open]').forEach(el => {
    el.addEventListener('click', e => {
      if (e.target.closest('[data-like],[data-fav]')) return;
      sfx('click');
      openDetail(parseInt(el.dataset.open, 10));
    });
  });
  container.querySelectorAll('[data-like]').forEach(b => b.addEventListener('click', async e => {
    e.stopPropagation();
    const id = parseInt(b.dataset.like, 10);
    const r = await post('toggleLike', { id });
    if (r && r.ok) {
      sfx('like');
      b.classList.toggle('active-like', r.liked);
      b.innerHTML = `${r.liked ? '❤️' : '🤍'} ${fmtNum(r.likes)}`;
      // Helyben frissítés a cache-ben — nem kell újra lekérni a listát
      if (carListCache) { const c = carListCache.find(x => x.id === id); if (c) { c.liked = r.liked; c.likes = r.likes; } }
    }
  }));
  container.querySelectorAll('[data-fav]').forEach(b => b.addEventListener('click', async e => {
    e.stopPropagation();
    const id = parseInt(b.dataset.fav, 10);
    const r = await post('toggleFavorite', { id });
    if (r && r.ok) {
      sfx('click');
      b.classList.toggle('active-fav', r.fav);
      b.innerHTML = r.fav ? '⭐' : '☆';
      // Helyben frissítés a cache-ben
      if (carListCache) { const c = carListCache.find(x => x.id === id); if (c) { c.fav = r.fav; } }
      if (currentTab === 'favorites') renderFavorites();
    }
  }));
}

/* ============================================================
   PIACTÉR
   ============================================================ */
async function renderMarket() {
  currentTab = 'market';

  // Első betöltés: szerveről kérjük a teljes listát, majd cacheljük.
  // Szűrés/rendezés/keresés után NEM küldünk új hálózati kérést.
  if (!carListCache) {
    content.innerHTML = `<div class="loader">Betöltés…</div>`;
    const r = await post('getCars');
    if (!r) { content.innerHTML = `<div class="empty">Hiba a betöltéskor.</div>`; return; }
    if (r.locked) return showLockAndStay();
    if (r.ready === false) { content.innerHTML = `<div class="loader">Az app indul…</div>`; setTimeout(renderMarket, 800); return; }
    carListCache = r.cars || [];
  }

  const filtered = localFilterSort(marketFilter);
  const catOpts = `<option value="">Minden típus</option>` + CFG.categories.map(c => `<option value="${c.value}" ${marketFilter.category === c.value ? 'selected' : ''}>${esc(c.label)}</option>`).join('');
  const sortOpts = [['newest', 'Legújabb'], ['price_asc', 'Ár ↑'], ['price_desc', 'Ár ↓'], ['most_viewed', 'Legnézettebb']]
    .map(([v, l]) => `<option value="${v}" ${marketFilter.sort === v ? 'selected' : ''}>${l}</option>`).join('');

  const cards = filtered.length
    ? filtered.map(c => cardHTML(c)).join('')
    : `<div class="empty"><span class="big">🔎</span>Nincs találat.<br>Tölts fel te az elsőt!</div>`;

  content.innerHTML = `
    <div class="toolbar">
      <input id="search" type="text" placeholder="Keresés…" value="${esc(marketFilter.search)}">
      <select id="cat">${catOpts}</select>
      <select id="sort">${sortOpts}</select>
    </div>${cards}`;

  const searchEl = document.getElementById('search');
  let deb;
  // Keresés: csak a debounce-idő után renderel — hálózati hívás nincs, csak helyi szűrés
  searchEl.addEventListener('input', () => { clearTimeout(deb); deb = setTimeout(() => { marketFilter.search = searchEl.value.trim(); renderMarket(); }, 200); });
  document.getElementById('cat').addEventListener('change', e => { marketFilter.category = e.target.value; renderMarket(); });
  document.getElementById('sort').addEventListener('change', e => { marketFilter.sort = e.target.value; renderMarket(); });
  wireCards(content);
}

/* ============================================================
   KEDVENCEK
   ============================================================ */
async function renderFavorites() {
  currentTab = 'favorites';
  content.innerHTML = `<div class="loader">Betöltés…</div>`;
  const r = await post('getFavorites');
  if (!r) { content.innerHTML = `<div class="empty">Hiba.</div>`; return; }
  if (r.locked) return showLockAndStay();
  const cards = (r.cars && r.cars.length)
    ? r.cars.map(c => cardHTML(c)).join('')
    : `<div class="empty"><span class="big">⭐</span>Még nincs kedvenced.<br>A kártyákon a ☆ gombbal adhatsz hozzá.</div>`;
  content.innerHTML = `<div class="section-title">Kedvenceim</div>${cards}`;
  wireCards(content);
}

/* ============================================================
   RÉSZLETES NÉZET
   ============================================================ */
async function openDetail(id) {
  content.innerHTML = `<div class="loader">Betöltés…</div>`;
  const car = await post('getCar', { id });
  if (!car) { content.innerHTML = `<div class="empty">Az autó nem található.</div>`; return; }
  if (car.locked) return showLockAndStay();
  detailState = { car, galleryIndex: 0 };
  renderDetail();
}

function tuningPanel(t) {
  if (!t || !t.parts) return '';
  const rows = t.parts.map(p => {
    let segs = '';
    for (let i = 0; i < p.max; i++) segs += `<div class="tune-seg ${i < p.val ? 'on' : ''}"></div>`;
    return `<div class="tune-row"><div class="lbl">${esc(p.label)}</div><div class="tune-bars">${segs}</div><div class="num">${p.val}/${p.max}</div></div>`;
  }).join('');
  return `
    <div class="panel">
      <h4>🔧 Tuning állapot</h4>
      <div class="tune-overall"><span class="pct">${t.percent}%</span><span class="muted">összesített feltuningoltság</span></div>
      ${rows}
    </div>`;
}

function chipPanel(chip) {
  if (!chip) return '';
  const col = (obj, title, sub) => {
    if (!obj || typeof obj !== 'object') return '';
    const keys = Object.keys(obj).sort((a, b) => (parseInt(a) || 0) - (parseInt(b) || 0));
    const cells = keys.map(k => `<div class="kv"><div class="k">${esc(k.replace(' RPM', ''))}</div><div class="v">${esc(obj[k])}</div></div>`).join('');
    return `<div><h5>${title}</h5><div class="chip-sub">${sub}</div><div class="kv-grid">${cells}</div></div>`;
  };
  return `
    <div class="panel">
      <h4>⚡ Chiptuning <span class="muted" style="font-weight:500">(motorvezérlés)</span></h4>
      <div class="hint" style="margin-bottom:10px">Magyarán: a <b>fordulatszám</b> (a bal oldali szám, RPM) szerint mennyi a turbónyomás és az üzemanyag. Minél nagyobb a szám, annál durvább a motor azon a fordulaton.</div>
      <div class="chip-cols">
        ${col(chip.turbo, 'Turbónyomás', 'mennyi turbó van az adott fordulaton — több = nagyobb erő')}
        ${col(chip.fuel, 'Üzemanyag', 'mennyit lő be az adott fordulaton — több = erősebb, többet fogyaszt')}
      </div>
    </div>`;
}

// (14) magyar nevek + paraszt-nyelvű magyarázat az anti-lag kulcsokhoz
const ANTILAG_HU = {
  Antilag: { name: 'Visszadurrogás', desc: 'gázelvételkor durrog/lángol a kipufogó' },
  TwoStep: { name: 'Rajtfordulat (two-step)', desc: 'fordulatszám-tartó a kipörgős, durva rajthoz' },
  Fuel: { name: 'Üzemanyag-dúsítás', desc: 'mennyi pluszüzemanyag megy a durrogáshoz' },
  Muffler: { name: 'Kipufogó-durranás', desc: 'be/ki kapcsolja a hangos durranást' },
};
function antilagVal(key, v) {
  if (key === 'Muffler') return (Number(v) >= 1 || v === true) ? 'Be' : 'Ki';
  return v;
}
function antilagPanel(a) {
  if (!a || typeof a !== 'object') return '';
  const order = ['Antilag', 'TwoStep', 'Fuel', 'Muffler'];
  const keys = Object.keys(a).sort((x, y) => (order.indexOf(x) + 1 || 99) - (order.indexOf(y) + 1 || 99));
  const rows = keys.map(k => {
    const hu = ANTILAG_HU[k] || { name: k, desc: '' };
    return `<div class="kvl">
      <div class="kvl-main"><div class="kvl-name">${esc(hu.name)}</div>${hu.desc ? `<div class="kvl-desc">${esc(hu.desc)}</div>` : ''}</div>
      <div class="kvl-val">${esc(antilagVal(k, a[k]))}</div>
    </div>`;
  }).join('');
  return `<div class="panel">
    <h4>💥 Anti-lag <span class="muted" style="font-weight:500">(visszadurrogás)</span></h4>
    <div class="hint" style="margin-bottom:10px">Magyarán: ettől <b>durrog és lángol</b> a kipufogó, amikor leveszed a gázt.</div>
    <div class="kv-list">${rows}</div>
  </div>`;
}

// Extra sebesség panel — a hirdetésre feladáskor rögzített owned_vehicles érték (0/5/10)
function extraSpeedPanel(c) {
  const s = Number(c.extraspeed) || 0;
  if (s <= 0) return '';
  return `<div class="panel">
    <h4>🚀 Extra sebesség <span class="muted" style="font-weight:500">(+${s})</span></h4>
    <div class="hint">Ezen az autón <b>+${s} extra sebesség</b> van — a rendszer a rendszám alapján automatikusan a hirdetéshez csatolta.</div>
  </div>`;
}

function massTipPanel(c) {
  const lbl = massCatLabel(c.massCategory);
  if (!lbl) return '';
  return `
    <div class="panel tip-box">
      <h4>📊 Kategória Rendszer szerint</h4>
      <div class="tip-val">${esc(lbl)}</div>
      <div class="tip-disclaimer">Ez egy TIPP a jármű tömege alapján — nem biztos és nem 100%. Tájékoztató jellegű mind a vásárlónak, mind az eladónak.</div>
    </div>`;
}

function renderDetail() {
  const c = detailState.car;
  const imgs = c.images && c.images.length ? c.images : [];
  const cur = imgs[detailState.galleryIndex];
  const dots = imgs.length > 1
    ? `<div class="gallery-nav">${imgs.map((_, i) => `<div class="gallery-dot ${i === detailState.galleryIndex ? 'on' : ''}" data-dot="${i}"></div>`).join('')}</div>`
    : '';

  let ownerBlock = '';
  if (c.isOwner) {
    const promoActive = c.promoted
      ? `<div class="promo-active">⭐ Aktív kiemelés — hátralévő: ${remainText(c.promotedUntil)}</div>
         <button class="btn btn-ghost" id="cancelPromo">Kiemelés lemondása (visszatérítéssel)</button>`
      : '';
    ownerBlock = `
      <div class="promo-box">
        <h4>⭐ Kiemelt hirdetés <span class="muted" style="font-weight:500">(${fmtMoney(CFG.promoPrice)}/hét)</span></h4>
        ${promoActive}
        <div class="week-row">
          <div class="stepper"><button id="wMinus">−</button><div class="val" id="wVal">1</div><button id="wPlus">+</button></div>
          <span class="muted" style="font-size:13px">hét</span>
          <span class="promo-cost" id="wCost">${fmtMoney(CFG.promoPrice)}</span>
        </div>
        <button class="btn btn-gold" id="doPromote">${c.promoted ? 'Kiemelés hosszabbítása' : 'Kiemelés indítása'}</button>
      </div>
      <div class="btn-row">
        <button class="btn btn-ghost btn-sm" id="toggleSold" style="flex:1">${c.sold ? '↩️ Újra elérhető' : '✅ Eladottnak jelöl'}</button>
        <button class="btn btn-danger btn-sm" id="deleteCar" style="flex:1">🗑️ Törlés</button>
      </div>`;
  }

  const adminDelete = (!c.isOwner && STATE.isAdmin)
    ? `<button class="btn btn-danger btn-sm" id="adminDelete" style="margin-bottom:14px">🛡️ Admin törlés</button>` : '';

  content.innerHTML = `
    <button class="back-link" id="back">← Vissza</button>
    <div class="detail-gallery" ${imgStyle(cur)}>${cur ? '' : '🚙'}${dots}</div>
    <div class="detail-head">
      <div class="detail-title">${esc(c.title)}</div>
      <div class="detail-price">${fmtMoney(c.price)}</div>
    </div>
    <div class="detail-sub">
      <span class="tag cat">${esc(catLabel(c.category))}</span>
      ${sellerBadge(c.seller)}
      ${ratingChip(c.seller)}
      ${c.available ? availBadge(true) : ''}
    </div>
    <button class="btn btn-ghost btn-sm" id="openProfile" style="width:100%;margin-bottom:14px">👤 Eladó profilja & vélemények</button>
    <div class="detail-stats">
      <span>👁️ ${fmtNum(c.views)} megtekintés</span>
      <span>❤️ ${fmtNum(c.likes)} lájk</span>
    </div>
    ${massTipPanel(c)}
    ${extraSpeedPanel(c)}
    ${tuningPanel(c.tuning)}
    ${chipPanel(c.chip)}
    ${antilagPanel(c.antilag)}
    ${c.description ? `<div class="desc">${esc(c.description)}</div>` : ''}
    ${!c.isOwner ? `
      <div class="detail-actions">
        <button class="icon-btn ${c.liked ? 'active-like' : ''}" id="dLike">${c.liked ? '❤️ Lájkolva' : '🤍 Lájk'}</button>
        <button class="icon-btn ${c.fav ? 'active-fav' : ''}" id="dFav">${c.fav ? '⭐ Kedvenc' : '☆ Kedvencekhez'}</button>
      </div>
      <div id="contactArea"><button class="btn btn-blue" id="contactBtn">📞 Kapcsolatfelvétel</button></div>
      ${adminDelete}
    ` : ownerBlock}
  `;

  document.getElementById('back').addEventListener('click', () => { sfx('click'); goTab(currentTab); });
  content.querySelectorAll('[data-dot]').forEach(d => d.addEventListener('click', () => { detailState.galleryIndex = parseInt(d.dataset.dot, 10); renderDetail(); }));
  const op = document.getElementById('openProfile');
  if (op) op.addEventListener('click', () => { sfx('click'); openProfile(c.id); });

  if (!c.isOwner) {
    document.getElementById('dLike').addEventListener('click', async () => {
      const r = await post('toggleLike', { id: c.id });
      if (r && r.ok) { sfx('like'); c.liked = r.liked; c.likes = r.likes; renderDetail(); }
    });
    document.getElementById('dFav').addEventListener('click', async () => {
      const r = await post('toggleFavorite', { id: c.id });
      if (r && r.ok) { c.fav = r.fav; renderDetail(); toast(r.fav ? 'Kedvencekhez adva' : 'Eltávolítva', 'ok'); }
    });
    document.getElementById('contactBtn').addEventListener('click', async () => {
      sfx('click');
      const r = await post('getContact', { id: c.id });
      if (!r) return toast('Nem sikerült lekérni.', 'err');
      document.getElementById('contactArea').innerHTML = `
        <div class="contact-box">
          <div class="row"><span class="k">Eladó</span><span class="v">${esc(r.name)}</span></div>
          <div class="row"><span class="k">Telefonszám</span><span class="v">${esc(r.phone)}</span></div>
          <div class="row"><span class="k">Állapot</span><span class="v" style="color:${r.available ? 'var(--green)' : 'var(--muted)'}">${r.available ? 'Elérhető ✅' : 'Jelenleg offline'}</span></div>
        </div>`;
    });
    const ad = document.getElementById('adminDelete');
    if (ad) ad.addEventListener('click', async () => {
      if (!(await uiConfirm('Admin: biztosan törlöd ezt a hirdetést?', { danger: true, ok: 'Törlés' }))) return;
      const r = await post('deleteCar', { id: c.id });
      if (r && r.ok) { toast('Hirdetés törölve (admin).', 'ok'); goTab('market'); }
      else toast((r && r.msg) || 'Sikertelen.', 'err');
    });
  } else {
    wireOwnerControls(c);
  }
}

function wireOwnerControls(c) {
  let weeks = 1;
  const wVal = document.getElementById('wVal'), wCost = document.getElementById('wCost');
  const upd = () => { wVal.textContent = weeks; wCost.textContent = fmtMoney(weeks * CFG.promoPrice); };
  document.getElementById('wMinus').addEventListener('click', () => { if (weeks > 1) { weeks--; upd(); sfx('click'); } });
  document.getElementById('wPlus').addEventListener('click', () => { if (weeks < CFG.maxWeeks) { weeks++; upd(); sfx('click'); } });

  document.getElementById('doPromote').addEventListener('click', async () => {
    const r = await post('promote', { id: c.id, weeks });
    if (r && r.ok) {
      sfx('cash'); toast(`Kiemelve! Levonva: ${fmtMoney(r.charged)}`, 'ok');
      if (r.member) { STATE.member = r.member; renderTierChip(); }
      invalidateCarCache();   // kiemelés változtatja a promoted mezőt
      const fresh = await post('getCar', { id: c.id });
      if (fresh && !fresh.locked) { detailState.car = fresh; renderDetail(); }
    } else { toast((r && r.msg) || 'Sikertelen.', 'err'); }
  });

  const cancel = document.getElementById('cancelPromo');
  if (cancel) cancel.addEventListener('click', async () => {
    const r = await post('cancelPromo', { id: c.id });
    if (r && r.ok) {
      toast(`Lemondva. Visszatérítve: ${fmtMoney(r.refund)}`, 'ok');
      invalidateCarCache();   // kiemelés vége
      const fresh = await post('getCar', { id: c.id });
      if (fresh && !fresh.locked) { detailState.car = fresh; renderDetail(); }
    } else { toast((r && r.msg) || 'Sikertelen.', 'err'); }
  });

  document.getElementById('toggleSold').addEventListener('click', async () => {
    const r = await post('markSold', { id: c.id, sold: !c.sold });
    if (r && r.ok) {
      invalidateCarCache();   // eladott állapot változása — a piactérről le kell kerülnie
      c.sold = r.sold; toast(r.sold ? 'Eladottnak jelölve' : 'Újra elérhető', 'ok'); renderDetail();
    }
  });

  document.getElementById('deleteCar').addEventListener('click', async () => {
    if (!(await uiConfirm('Biztosan törlöd ezt a hirdetést?', { danger: true, ok: 'Törlés' }))) return;
    const r = await post('deleteCar', { id: c.id });
    if (r && r.ok) {
      invalidateCarCache();   // autó eltűnt
      toast(r.refund > 0 ? `Törölve. Visszatérítve: ${fmtMoney(r.refund)}` : 'Hirdetés törölve.', 'ok');
      goTab('mine');
    } else toast((r && r.msg) || 'Sikertelen.', 'err');
  });
}

/* ============================================================
   SAJÁT AUTÓIM
   ============================================================ */
async function renderMine() {
  currentTab = 'mine';
  content.innerHTML = `<div class="loader">Betöltés…</div>`;
  const r = await post('getMyCars');
  if (!r) { content.innerHTML = `<div class="empty">Hiba.</div>`; return; }
  if (r.locked) return showLockAndStay();
  const cards = (r.cars && r.cars.length)
    ? r.cars.map(c => cardHTML(c, { noReact: true })).join('')
    : `<div class="empty"><span class="big">📋</span>Még nincs feltöltött autód.<br>Nyomd meg a „Feltöltés” fület!</div>`;
  content.innerHTML = `<div class="section-title">Saját hirdetéseim</div>${cards}`;
  wireCards(content);
}

/* ============================================================
   FELTÖLTÉS — (12) owned_vehicles választó
   ============================================================ */
function vehItemHTML(v, i) {
  const flags = `
    <div class="veh-flags">
      ${v.inside ? `<span class="flag in">beleülsz ✓</span>` : ''}
      ${v.hasChip ? `<span class="flag on">⚡ chip</span>` : ''}
      ${v.hasAntilag ? `<span class="flag on">💥 anti-lag</span>` : ''}
      ${v.extraspeed ? `<span class="flag on">🚀 +${v.extraspeed}</span>` : ''}
      ${v.tuning ? `<span class="flag">🔧 ${v.tuning.percent}%</span>` : ''}
      ${v.alreadyListed ? `<span class="flag">már hirdeted</span>` : ''}
    </div>`;
  const sel = uploadState.selected && uploadState.selected.plate === v.plate ? ' sel' : '';
  return `<div class="veh-item ${v.alreadyListed ? 'disabled' : ''}${sel}" data-veh="${i}">
    <div class="veh-ico">🚗</div>
    <div class="veh-main"><div class="veh-name">${esc(v.label)}</div><div class="veh-plate">${esc(v.plate)}</div>${flags}</div>
  </div>`;
}

/* A járműlista (újra)renderelése rendszám/név szűréssel. Az eredeti indexet
   tartjuk meg a data-veh-ben, hogy a kiválasztás szűrve is helyes maradjon. */
function renderVehList(query) {
  const pick = document.getElementById('vehPick');
  if (!pick) return;
  const q = (query || '').trim().toLowerCase();
  if (!uploadState.vehicles.length) {
    pick.innerHTML = `<div class="empty"><span class="big">🚗</span>Nincs a nevedre írt autó.</div>`;
    return;
  }
  const items = uploadState.vehicles
    .map((v, i) => ({ v, i }))
    .filter(({ v }) => !q || (v.plate || '').toLowerCase().includes(q) || (v.label || '').toLowerCase().includes(q));
  pick.innerHTML = items.length
    ? items.map(({ v, i }) => vehItemHTML(v, i)).join('')
    : `<div class="empty" style="padding:18px">Nincs a keresésre illő autó.</div>`;
  pick.querySelectorAll('[data-veh]').forEach(el => el.addEventListener('click', () => {
    const v = uploadState.vehicles[parseInt(el.dataset.veh, 10)];
    if (!v || v.alreadyListed) return;
    sfx('click');
    uploadState.selected = v;
    pick.querySelectorAll('.veh-item').forEach(x => x.classList.remove('sel'));
    el.classList.add('sel');
    renderSelInfo();
  }));
}

async function renderUpload() {
  currentTab = 'upload';
  content.innerHTML = `<div class="loader">Autóid betöltése…</div>`;
  const r = await post('getMyVehicles');
  if (!r) { content.innerHTML = `<div class="empty">Hiba az autók lekérésekor.</div>`; return; }
  if (r.locked) return showLockAndStay();

  uploadState = { vehicles: r.vehicles || [], selected: null, images: [], category: CFG.categories[0] ? CFG.categories[0].value : '' };

  const catOpts = CFG.categories.map(c => `<option value="${c.value}">${esc(c.label)}</option>`).join('');

  content.innerHTML = `
    <div class="section-title">Új hirdetés feladása</div>
    <div class="form-group">
      <label>Válaszd ki az autót (a nevére írt járművek) <span class="req">*</span></label>
      ${uploadState.vehicles.length > 4 ? `<input class="form-control" id="vehSearch" type="text" placeholder="🔍 Keresés rendszám szerint…" autocomplete="off">` : ''}
      <div class="veh-pick" id="vehPick"></div>
      <div class="hint">Ülj be az autóba a pontosabb <b>kategória-tipphez</b> (a tömeg alapján). A tuning, chip és anti-lag adatokat a rendszer automatikusan kitölti.</div>
    </div>
    <div id="selInfo"></div>
    <div class="form-group"><label>Hirdetés típusa <span class="req">*</span></label><select class="form-control" id="f_cat">${catOpts}</select></div>
    <div class="form-group"><label>Ár ($) <span class="req">*</span></label><input class="form-control" id="f_price" type="number" placeholder="pl. 25000000"></div>
    <div class="form-group">
      <label>Leírás</label>
      <textarea class="form-control" id="f_desc" maxlength="${CFG.maxDesc}" placeholder="Írd le az autó állapotát, extráit…"></textarea>
      <div class="char-count"><span id="descCount">0</span>/${CFG.maxDesc}</div>
    </div>
    <div class="form-group">
      <label>Képek (max ${CFG.maxImages}) — csak in-game fotó</label>
      <button class="btn btn-blue btn-sm" id="photoBtn" style="width:100%">📸 Fotó készítése</button>
      <div class="img-grid" id="imgGrid"></div>
      <div class="hint">A fotózáshoz nézz az autóra — az app egy pillanatra elrejtődik.</div>
    </div>
    <button class="btn btn-primary" id="submitBtn">🚗 Hirdetés feladása</button>`;

  document.getElementById('f_cat').addEventListener('change', e => { uploadState.category = e.target.value; });
  uploadState.category = document.getElementById('f_cat').value;
  const desc = document.getElementById('f_desc');
  desc.addEventListener('input', () => { document.getElementById('descCount').textContent = desc.value.length; });
  document.getElementById('photoBtn').addEventListener('click', takePhoto);
  document.getElementById('submitBtn').addEventListener('click', submitCar);
  renderImgGrid();

  const vehSearch = document.getElementById('vehSearch');
  if (vehSearch) {
    let vdeb;
    vehSearch.addEventListener('input', () => { clearTimeout(vdeb); vdeb = setTimeout(() => renderVehList(vehSearch.value), 120); });
  }
  renderVehList('');
}

function massTipFromMass(mass) {
  if (!mass || mass <= 0) return null;
  const ranges = [[2000, 2599, 'Autokeres'], [2600, 2999, 'Privát Autokeres'], [3000, 3889, 'Limitált'], [3890, 5000, 'Egyedi']];
  for (const [a, b, l] of ranges) if (mass >= a && mass <= b) return l;
  return null;
}

function renderSelInfo() {
  const v = uploadState.selected;
  const box = document.getElementById('selInfo');
  if (!v) { box.innerHTML = ''; return; }
  const tip = v.inside ? massTipFromMass(v.mass) : null;
  let tipHtml;
  if (!v.inside) {
    tipHtml = `<div class="tip-disclaimer">Ülj be ebbe az autóba, hogy a tömeg alapján megjelenjen a kategória-tipp.</div>`;
  } else if (tip) {
    tipHtml = `<div class="tip-val">${esc(tip)}</div><div class="tip-disclaimer">Ez egy TIPP a tömeg (${Math.round(v.mass)} kg) alapján — nem 100%.</div>`;
  } else {
    tipHtml = `<div class="tip-disclaimer">A tömeg (${Math.round(v.mass || 0)} kg) nem esik a kategória-tartományokba — nincs tipp.</div>`;
  }
  box.innerHTML = `
    <div class="panel tip-box">
      <h4>📊 Kategória Rendszer szerint (TIPP)</h4>
      ${tipHtml}
    </div>
    ${v.tuning ? tuningPanel(v.tuning) : ''}
    <div class="panel"><h4>⚙️ Automatikus adatok</h4>
      <div class="card-tags">
        <span class="tag ${v.hasChip ? 'tuned' : ''}">⚡ Chiptuning: ${v.hasChip ? 'van' : 'nincs'}</span>
        <span class="tag ${v.hasAntilag ? 'tuned' : ''}">💥 Anti-lag: ${v.hasAntilag ? 'van' : 'nincs'}</span>
        <span class="tag ${v.extraspeed ? 'tuned' : ''}">🚀 Extra sebesség: ${v.extraspeed ? '+' + v.extraspeed : 'nincs'}</span>
      </div>
      <div class="hint">Ezeket a rendszer a rendszám alapján automatikusan a hirdetéshez csatolja.</div>
    </div>`;
}

function renderImgGrid() {
  const grid = document.getElementById('imgGrid');
  if (!grid) return;
  grid.innerHTML = uploadState.images.map((u, i) =>
    `<div class="img-thumb" style="background-image:url('${esc(u)}')"><button class="rm" data-rm="${i}">✕</button></div>`).join('');
  grid.querySelectorAll('[data-rm]').forEach(b => b.addEventListener('click', () => { uploadState.images.splice(parseInt(b.dataset.rm, 10), 1); renderImgGrid(); }));
  // (3b) 1 autó = 1 kép: ha már van kép, a gomb törlésre vált, új fotóhoz előbb törölni kell
  const pbtn = document.getElementById('photoBtn');
  if (pbtn) {
    const full = uploadState.images.length >= CFG.maxImages;
    pbtn.disabled = full;
    pbtn.textContent = full ? '🗑️ Töröld a képet új fotóhoz' : '📸 Fotó készítése';
  }
}

async function takePhoto() {
  if (uploadState.images.length >= CFG.maxImages) return toast(`Max ${CFG.maxImages} kép — töröld a meglévőt új fotóhoz.`, 'err');
  const pbtn = document.getElementById('photoBtn');
  if (pbtn) { pbtn.disabled = true; pbtn.textContent = '⏳ Kérlek várj…'; }
  const r = await post('takePhoto');
  if (r && r.ok && r.url) { uploadState.images.push(r.url); toast('Fotó hozzáadva!', 'ok'); }
  else toast((r && r.msg) || 'A fotó nem sikerült.', 'err');
  renderImgGrid();   // visszaállítja / frissíti a gomb feliratát és állapotát
}

async function submitCar() {
  const v = uploadState.selected;
  if (!v) return toast('Válassz egy autót a listából.', 'err');
  const price = parseInt(document.getElementById('f_price').value, 10);
  if (!price || price < 1) return toast('Add meg az árat.', 'err');

  const payload = {
    plate: v.plate,
    title: v.label,
    modelName: v.spawnName,
    mass: v.inside ? v.mass : 0,
    category: uploadState.category,
    price,
    description: document.getElementById('f_desc').value.trim(),
    images: uploadState.images,
  };

  const btn = document.getElementById('submitBtn');
  btn.disabled = true; btn.textContent = 'Feltöltés…';
  const r = await post('createCar', { car: payload });
  btn.disabled = false; btn.textContent = '🚗 Hirdetés feladása';
  if (r && r.ok) {
    sfx('success');
    if (r.member) { STATE.member = r.member; renderTierChip(); }
    invalidateCarCache();   // új hirdetsés került fel
    toast('Hirdetés feladva! 🎉', 'ok');
    goTab('mine');
  } else if (r && r.locked) { showLockAndStay(); }
  else { toast((r && r.msg) || 'Sikertelen feltöltés.', 'err'); }
}

/* ============================================================
   (18) TAGSÁG OLDAL
   ============================================================ */
async function renderMembership() {
  setActiveTab(null);
  // Ha a STATE.member már töltött (getState boot-ból vagy egy művelet válaszból),
  // a szerver felhívása felesleges — a tagság adatait helyben rendezzük ki.
  // A getMembership csak akkor fut, ha a member még null (pl. úgyan keri renderel).
  if (!STATE.member) {
    content.innerHTML = `<div class="loader">Betöltés…</div>`;
    const r = await post('getMembership');
    if (!r) { content.innerHTML = `<div class="empty">Hiba.</div>`; return; }
    STATE.member = r.member;
    renderTierChip();
  }
  renderMembershipView(STATE.member);
}

function renderMembershipView(m) {
  const nextT = tiers[m.tierIndex];

  let progHtml = '';
  if (nextT) {
    const span = Math.max(1, nextT.minPoints - cur.minPoints);
    const pct = Math.max(0, Math.min(100, Math.round((m.points - cur.minPoints) / span * 100)));
    const needs = [];
    if (m.points < nextT.minPoints) needs.push(`${fmtNum(nextT.minPoints - m.points)} pont`);
    if (m.adsPosted < (nextT.minAds || 0)) needs.push(`${nextT.minAds - m.adsPosted} hirdetés`);
    if ((m.tasksDone.length) < (nextT.minTasks || 0)) needs.push(`${nextT.minTasks - m.tasksDone.length} feladat`);
    progHtml = `
      <div class="muted" style="font-size:12px;margin-top:10px">Következő: <b style="color:var(--txt)">${esc(nextT.name)}</b></div>
      <div class="progress"><i style="width:${pct}%"></i></div>
      <div class="muted" style="font-size:11px">${needs.length ? 'Még kell: ' + needs.join(', ') : 'Feltételek teljesítve!'}</div>`;
  } else {
    progHtml = `<div class="muted" style="font-size:12px;margin-top:10px">Elérted a legmagasabb tagságot! 🏆</div>`;
  }

  const tierCards = tiers.map((t, i) => {
    const reqs = [];
    reqs.push(`${fmtNum(t.minPoints)} pont`);
    if (t.minAds) reqs.push(`${t.minAds} hirdetés`);
    if (t.minTasks) reqs.push(`${t.minTasks} feladat`);
    return `
      <div class="tier-card ${i + 1 === m.tierIndex ? 'current' : ''}">
        <div class="tmedal" style="background:${t.color}">${i + 1}</div>
        <div style="flex:1">
          <div class="tname" style="color:${t.color}">${esc(t.name)}</div>
          <div class="treq">Feltétel: ${reqs.join(' · ')}</div>
        </div>
        ${i + 1 === m.tierIndex ? `<div class="you">Te</div>` : ''}
      </div>`;
  }).join('');

  const doneSet = new Set(m.tasksDone);
  const taskList = tasks.map(t => `
    <div class="task ${doneSet.has(t.key) ? 'done' : ''}">
      <div class="tick">${doneSet.has(t.key) ? '✓' : ''}</div>
      <div class="tinfo"><div class="tlabel">${esc(t.label)}</div><div class="thint">${esc(t.hint)} · +${points.Task} pont</div></div>
    </div>`).join('');

  content.innerHTML = `
    <button class="back-link" id="back">← Vissza</button>
    <div class="member-hero">
      <div class="now" style="color:${cur ? cur.color : '#fff'}"><span class="dot"></span>${esc(cur ? cur.name : '—')}</div>
      <div class="muted" style="font-size:13px">${fmtNum(m.points)} pont</div>
      ${progHtml}
      <div class="member-stats">
        <div class="ms"><div class="n">${fmtNum(m.adsPosted)}</div><div class="l">hirdetés</div></div>
        <div class="ms"><div class="n">${fmtNum(m.sales)}</div><div class="l">eladás</div></div>
        <div class="ms"><div class="n">${fmtNum(m.promos)}</div><div class="l">kiemelés</div></div>
        <div class="ms"><div class="n">${m.tasksDone.length}/${tasks.length}</div><div class="l">feladat</div></div>
      </div>
    </div>
    <button class="btn btn-ghost btn-sm" id="myProfile" style="width:100%;margin-bottom:16px">👤 Saját profilom & rólam írt vélemények</button>
    <div class="section-title">Tagsági szintek</div>
    <div class="tier-list">${tierCards}</div>
    <div class="section-title" style="margin-top:18px">Feladatok</div>
    <div class="hint" style="margin-bottom:10px">Minél többet használod az appot, annál nagyobb tag vagy. A felső szintekhez nem elég az idő — hirdetned és feladatokat is kell teljesítened.</div>
    <div class="task-list">${taskList}</div>
    <div class="hint" style="margin-top:14px">Pontok: heti hozzáférés +${r.points.AccessWeek} · hirdetés +${r.points.AdPosted} · eladás +${r.points.Sale} · kiemelés/hét +${r.points.PromoWeek} · feladat +${r.points.Task}.</div>`;

  document.getElementById('back').addEventListener('click', () => { sfx('click'); goTab(currentTab); });
  document.getElementById('myProfile').addEventListener('click', () => { sfx('click'); openMyProfile(); });
}

/* ============================================================
   ELADÓI PROFIL + VÉLEMÉNYEK
   ============================================================ */
let profileState = { data: null, carId: null, back: null, pickRating: 0 };

function openProfile(carId) {
  profileState.back = () => openDetail(carId);
  renderProfile({ id: carId, carId });
}
function openMyProfile() {
  profileState.back = () => renderMembership();
  renderProfile({ me: true });
}

async function renderProfile(opts) {
  setActiveTab(null);
  content.innerHTML = `<div class="loader">Betöltés…</div>`;
  const r = opts.me ? await post('getMyProfile') : await post('getProfileByCar', { id: opts.id });
  if (!r) { content.innerHTML = `<div class="empty">Hiba.</div>`; return; }
  if (r.locked) return showLockAndStay();
  profileState.data = r;
  profileState.carId = opts.carId || null;
  profileState.pickRating = (r.myReview && r.myReview.rating) || 0;
  renderProfileView();
}

function renderProfileView() {
  const r = profileState.data, p = r.profile, reviews = r.reviews || [];
  const MAXR = CFG.maxReview || 300;

  const reviewCards = reviews.length ? reviews.map(rv => `
    <div class="review">
      <div class="review-head">
        <div class="review-who">${rv.authorAvatar ? `<img class="rev-av" src="${esc(rv.authorAvatar)}" alt="" onerror="this.style.display='none'">` : ''}${esc(rv.authorName)} ${rv.mine ? '<span class="mine-tag">te</span>' : ''} ${ratingStars(rv.rating)}</div>
        <div class="review-date">${rv.updatedAt ? new Date(rv.updatedAt).toLocaleDateString('hu-HU') : ''}</div>
      </div>
      ${rv.comment ? `<div class="review-text">${esc(rv.comment)}</div>` : `<div class="review-text" style="color:var(--muted)">(nincs szöveg)</div>`}
      ${r.canModerate ? `<div class="review-actions"><button class="btn btn-danger btn-sm" data-delrev="${rv.id}">🛡️ Admin törlés</button></div>` : ''}
    </div>`).join('') : `<div class="empty" style="padding:24px"><span class="big">💬</span>Még nincs vélemény.</div>`;

  let formHtml = '';
  if (!r.isOwnProfile && profileState.carId) {
    const stars = [1, 2, 3, 4, 5].map(i => `<span class="sp ${i <= profileState.pickRating ? 'on' : ''}" data-star="${i}">★</span>`).join('');
    const myc = (r.myReview && r.myReview.comment) || '';
    formHtml = `
      <div class="review-form">
        <h4>${r.myReview ? '✏️ Véleményed szerkesztése' : '⭐ Értékeld az eladót'}</h4>
        <div class="star-pick" id="starPick">${stars}</div>
        <textarea class="form-control" id="revText" maxlength="${MAXR}" placeholder="Írd le a tapasztalatod az eladóval…">${esc(myc)}</textarea>
        <div class="char-count"><span id="revCount">${myc.length}</span>/${MAXR}</div>
        <div class="btn-row" style="margin-top:8px">
          <button class="btn btn-primary" id="submitReview" style="flex:1">${r.myReview ? 'Frissítés' : 'Vélemény küldése'}</button>
          ${r.myReview ? `<button class="btn btn-danger btn-sm" id="delMyReview">🗑️</button>` : ''}
        </div>
      </div>`;
  }

  const adminClear = (r.canModerate && !r.isOwnProfile && profileState.carId && reviews.length)
    ? `<button class="btn btn-danger btn-sm" id="adminClear" style="margin-bottom:14px;width:100%">🛡️ Profil ürítése (összes vélemény)</button>` : '';

  content.innerHTML = `
    <button class="back-link" id="back">← Vissza</button>
    <div class="profile-hero">
      <div class="profile-top">
        <div class="profile-av">${p.avatar ? `<img src="${esc(p.avatar)}" alt="" onerror="this.parentElement.textContent='👤'">` : '👤'}</div>
        <div style="flex:1;min-width:0">
          <div class="profile-name">${esc(p.name)} <span class="seller-badge" style="color:${p.tier.color}"><span class="dot"></span>${esc(p.tier.name)}</span></div>
          <div class="profile-rating">${ratingStars(p.rating)} <span class="num">${p.ratingCount ? p.rating : '—'}</span><span class="cnt">(${p.ratingCount} értékelés)</span>${p.online ? availBadge(true) : ''}</div>
        </div>
      </div>
      <div class="profile-stats">
        <div class="ms"><div class="n">${fmtNum(p.adsActive)}</div><div class="l">aktív hirdetés</div></div>
        <div class="ms"><div class="n">${fmtNum(p.sales)}</div><div class="l">eladás</div></div>
        <div class="ms"><div class="n">${fmtNum(p.points)}</div><div class="l">tagsági pont</div></div>
      </div>
    </div>
    ${formHtml}
    <div class="section-title">Vélemények (${reviews.length})</div>
    ${adminClear}
    ${reviewCards}`;

  document.getElementById('back').addEventListener('click', () => { sfx('click'); (profileState.back || (() => goTab('market')))(); });

  content.querySelectorAll('[data-star]').forEach(s => s.addEventListener('click', () => {
    profileState.pickRating = parseInt(s.dataset.star, 10);
    content.querySelectorAll('#starPick .sp').forEach(x => x.classList.toggle('on', parseInt(x.dataset.star, 10) <= profileState.pickRating));
    sfx('click');
  }));
  const rt = document.getElementById('revText');
  if (rt) rt.addEventListener('input', () => { document.getElementById('revCount').textContent = rt.value.length; });

  const sb = document.getElementById('submitReview');
  if (sb) sb.addEventListener('click', async () => {
    if (!profileState.pickRating) return toast('Válassz csillagot (1-5).', 'err');
    const r2 = await post('submitReview', { id: profileState.carId, rating: profileState.pickRating, comment: rt.value.trim() });
    if (r2 && r2.ok) {
      sfx('success'); toast(r2.updated ? 'Vélemény frissítve' : 'Köszi a véleményt!', 'ok');
      profileState.data = r2.profile; profileState.pickRating = (r2.profile.myReview && r2.profile.myReview.rating) || 0; renderProfileView();
    } else toast((r2 && r2.msg) || 'Sikertelen.', 'err');
  });
  const dmr = document.getElementById('delMyReview');
  if (dmr) dmr.addEventListener('click', async () => {
    const r2 = await post('deleteMyReview', { id: profileState.carId });
    if (r2 && r2.ok) { toast('Véleményed törölve', 'ok'); profileState.data = r2.profile; profileState.pickRating = 0; renderProfileView(); }
    else toast((r2 && r2.msg) || 'Sikertelen.', 'err');
  });

  content.querySelectorAll('[data-delrev]').forEach(b => b.addEventListener('click', async () => {
    if (!(await uiConfirm('Biztosan törlöd ezt a véleményt?', { danger: true, ok: 'Törlés' }))) return;
    const r2 = await post('adminDeleteReview', { reviewId: parseInt(b.dataset.delrev, 10), id: profileState.carId });
    if (r2 && r2.ok) { toast('Vélemény törölve', 'ok'); if (r2.profile) { profileState.data = r2.profile; renderProfileView(); } }
    else toast((r2 && r2.msg) || 'Sikertelen.', 'err');
  }));
  const ac = document.getElementById('adminClear');
  if (ac) ac.addEventListener('click', async () => {
    if (!(await uiConfirm('ADMIN: az eladó ÖSSZES véleményét törlöd?', { danger: true, ok: 'Ürítés' }))) return;
    const r2 = await post('adminClearProfile', { id: profileState.carId });
    if (r2 && r2.ok) { toast('Profil ürítve', 'ok'); profileState.data = r2.profile; renderProfileView(); }
    else toast((r2 && r2.msg) || 'Sikertelen.', 'err');
  });
}

/* ============================================================
   BEÁLLÍTÁSOK — (2) hangok
   ============================================================ */
function renderSettings() {
  setActiveTab(null);
  const sw = (on) => `<div class="switch ${on ? 'on' : ''}"><i></i></div>`;
  content.innerHTML = `
    <button class="back-link" id="back">← Vissza</button>
    <div class="section-title">Beállítások</div>
    <div class="toggle-row" id="t_sound">
      <div><div class="t-main">🔊 Felület hangok</div><div class="t-sub">Kattintás, siker, hiba és lájk hangok.</div></div>
      ${sw(SETTINGS.sound)}
    </div>
    <div class="toggle-row" id="t_ambient">
      <div><div class="t-main">🎵 Háttér hangulat</div><div class="t-sub">Halk, lassan pulzáló háttérhang az app alatt.</div></div>
      ${sw(SETTINGS.ambient)}
    </div>
    <div class="hint">A hangok a böngésződben szintetizálódnak — nincs külön hangfájl, és bármikor kikapcsolhatók.</div>`;

  document.getElementById('back').addEventListener('click', () => { sfx('click'); goTab(currentTab); });
  document.getElementById('t_sound').addEventListener('click', () => {
    SETTINGS.sound = !SETTINGS.sound; lsSet('hasznaltok_sound', SETTINGS.sound);
    document.querySelector('#t_sound .switch').classList.toggle('on', SETTINGS.sound);
    if (SETTINGS.sound) sfx('click');
  });
  document.getElementById('t_ambient').addEventListener('click', () => {
    SETTINGS.ambient = !SETTINGS.ambient; lsSet('hasznaltok_ambient', SETTINGS.ambient);
    document.querySelector('#t_ambient .switch').classList.toggle('on', SETTINGS.ambient);
    syncAmbient(); sfx('click');
  });
}

/* ============================================================
   NAVIGÁCIÓ
   ============================================================ */
function setActiveTab(tab) {
  document.querySelectorAll('.tab').forEach(t => t.classList.toggle('active', t.dataset.tab === tab));
}
function showLockAndStay() { STATE.hasAccess = false; renderLock(); }

function goTab(tab) {
  if (!STATE.hasAccess) return renderLock();
  setActiveTab(tab);
  if (tab === 'market') renderMarket();
  else if (tab === 'favorites') renderFavorites();
  else if (tab === 'upload') renderUpload();
  else if (tab === 'mine') renderMine();
}

document.querySelectorAll('.tab').forEach(t => t.addEventListener('click', () => { sfx('tab'); goTab(t.dataset.tab); }));
document.getElementById('closeBtn').addEventListener('click', () => { sfx('click'); closeApp(); });
document.getElementById('settingsBtn').addEventListener('click', () => { sfx('click'); renderSettings(); });
tierChip.addEventListener('click', () => { sfx('click'); renderMembership(); });

function closeApp() {
  ambientStop();
  phoneInputFocus(false);          // engedjük el a billentyűzetet, bárhogy is zárunk
  if (EMBEDDED) return;            // a telefonban a RoadPhone kezeli a bezárást
  post('close');
}

/* ============================================================
   ÁLLAPOT BETÖLTÉS
   ============================================================ */
async function boot() {
  const s = await post('getState');
  if (!s) { content.innerHTML = `<div class="empty">Hiba a betöltéskor.</div>`; return; }
  if (s.cfg) CFG = Object.assign(CFG, s.cfg);     // config a szerverről (telefon iframe)
  STATE.hasAccess = !!s.hasAccess;
  STATE.accessUntil = s.accessUntil || 0;
  STATE.accessPrice = s.accessPrice || CFG.accessPrice;
  STATE.isAdmin = !!s.isAdmin;
  STATE.member = s.member || null;
  renderTierChip();
  if (STATE.hasAccess) { tabbar.classList.remove('hidden'); goTab('market'); }
  else renderLock();
}

/* ============================================================
   NUI ÜZENETEK
   ============================================================ */
window.addEventListener('message', e => {
  const d = e.data || {};
  if (d.action === 'open') {
    if (d.config) CFG = Object.assign(CFG, d.config);
    // A massCategories-t is idevárjuk, ha a Lua elküldi (opcionális bővítés a jövőre).
    root.classList.remove('hidden');
    sfx('open'); syncAmbient();
    boot();
  } else if (d.action === 'close') {
    root.classList.add('hidden'); ambientStop(); phoneInputFocus(false);
  } else if (d.action === 'hideForPhoto') {
    phoneInputFocus(false);          // fotó közben semmi mező nincs fókuszban
    root.style.visibility = 'hidden'; photoOverlay.classList.remove('hidden');
  } else if (d.action === 'showAfterPhoto') {
    root.style.visibility = 'visible'; photoOverlay.classList.add('hidden');
  }
});

document.addEventListener('keydown', e => { if (!EMBEDDED && e.key === 'Escape' && !root.classList.contains('hidden')) closeApp(); });

/* ESC-fix (RoadPhone-ban beágyazva is): kattintás után a gomb ne maradjon fókuszban/
   "kijelölve" — a fókuszált gomb elnyeli az elsö ESC-et, ezért nem zár be egyböl.
   Kattintás után + ESC-re levesszük a fókuszt; az ESC-et NEM nyeljük el. */
(function () {
  document.addEventListener('pointerup', function (e) {
    var b = e.target && e.target.closest && e.target.closest('button,[role="button"],.btn,.tab,.icon-btn');
    if (b) setTimeout(function () { try { b.blur(); } catch (_) {} }, 0);
  }, true);
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      var a = document.activeElement;
      if (a && a !== document.body && typeof a.blur === 'function') { try { a.blur(); } catch (_) {} }
    }
  }, true);
})();

/* (2) Input-fókusz jelzése a RoadPhone-nak: amíg a mezőinkbe gépelnek, a telefon
   fogja meg a billentyűzetet, így a gombnyomás nem szivárog át a játékba. */
document.addEventListener('focusin', e => {
  if (e.target && e.target.matches && e.target.matches('input, textarea, select')) phoneInputFocus(true);
});
document.addEventListener('focusout', e => {
  if (e.target && e.target.matches && e.target.matches('input, textarea, select')) phoneInputFocus(false);
});

/* RoadPhone iframe: nincs Lua 'open' üzenet — magunk indulunk és kitöltjük a telefont */
function selfInit() {
  if (EMBEDDED) document.documentElement.classList.add('embedded');
  if (!EMBEDDED) return;            // a standalone NUI-t a Lua 'open' üzenete indítja
  root.classList.remove('hidden');
  sfx('open'); syncAmbient();
  boot();
}
if (IS_CFX) {
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', selfInit);
  else selfInit();
}

/* ============================================================
   FEJLESZTŐI MOCK — csak böngészőben (NEM FiveM-ben)
   ============================================================ */
if (IS_BROWSER) {
  const TUNE = {
    percent: 67, parts: [
      { key: 'engine', label: 'Motor', val: 3, max: 3 }, { key: 'brakes', label: 'Fék', val: 2, max: 2 },
      { key: 'trans', label: 'Váltó', val: 1, max: 2 }, { key: 'susp', label: 'Felfüggesztés', val: 2, max: 3 },
      { key: 'armor', label: 'Páncél', val: 0, max: 4 }, { key: 'turbo', label: 'Turbó', val: 1, max: 1 },
    ]
  };
  const CHIP = {
    turbo: { '1000 RPM': '2.4', '2000 RPM': '2.4', '3000 RPM': '2.5', '4000 RPM': '2.5', '5000 RPM': '2.6', '6000 RPM': '2.6', '7000 RPM': '2.7', '8000 RPM': '2.7', '9000 RPM': '2.8' },
    fuel: { '1000 RPM': '27', '2000 RPM': '27', '3000 RPM': '27', '4000 RPM': '27', '5000 RPM': '27', '6000 RPM': '27', '7000 RPM': '27', '8000 RPM': '27', '9000 RPM': '27' }
  };
  const ANTILAG = { Antilag: 5.0, TwoStep: 5.0, Fuel: 5.0, Muffler: 1 };
  const tier = (k, n, c) => ({ key: k, name: n, color: c });
  const T_BRONZ = Object.assign(tier('bronz', 'Bronz Kereskedő', '#cd7f32'), { rating: 4.1, ratingCount: 6 });
  const S_ARANY = Object.assign(tier('arany', 'Arany Kereskedő', '#ffce4d'), { rating: 4.6, ratingCount: 14 });
  let mockMyReview = null;
  function mockProfile(name, st, isOwn, carId) {
    const t = st || MOCK.member.tier;
    const reviews = [
      { id: 101, authorName: 'Nagy Károly', authorAvatar: 'https://i.pravatar.cc/100?img=12', rating: 5, comment: 'Korrekt eladó, az autó hibátlan volt!', updatedAt: Date.now() - 2 * 86400000, mine: false, canDelete: true },
      { id: 102, authorName: 'Tóth Anna', authorAvatar: 'https://i.pravatar.cc/100?img=45', rating: 4, comment: 'Gyors, korrekt ügyintézés.', updatedAt: Date.now() - 5 * 86400000, mine: false, canDelete: true },
    ];
    if (mockMyReview && !isOwn) reviews.unshift({ id: 999, authorName: 'Te', authorAvatar: 'https://i.pravatar.cc/100?img=33', rating: mockMyReview.rating, comment: mockMyReview.comment, updatedAt: Date.now(), mine: true, canDelete: true });
    const cnt = reviews.length, avg = Math.round(reviews.reduce((s, r) => s + r.rating, 0) / cnt * 10) / 10;
    return {
      isOwnProfile: !!isOwn, canModerate: true,
      profile: { name, avatar: 'https://i.pravatar.cc/120?img=' + (isOwn ? 33 : 8), tier: { key: t.key, name: t.name, color: t.color }, adsActive: 3, sales: 7, points: 320, rating: avg, ratingCount: cnt, online: true },
      reviews, myReview: (!isOwn && mockMyReview) ? mockMyReview : null
    };
  }
  const MOCK = {
    member: { points: 320, adsPosted: 4, sales: 1, promos: 1, tasksDone: ['first_post', 'first_sale'], tierIndex: 2, tier: T_BRONZ },
    cars: [
      { id: 1, title: 'Karin Sultan RS', price: 18500000, category: 'egyedi', categoryLabel: 'Egyedi', massCategory: 'egyedi', massCategoryLabel: 'Egyedi', tuned: 67, views: 342, likes: 51, promoted: true, sold: false, liked: false, fav: false, available: true, seller: S_ARANY, image: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800', isOwner: false, description: 'Full tuning, chip + anti-lag.', images: ['https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800'], tuning: TUNE, chip: CHIP, antilag: ANTILAG, extraspeed: 10, mass: 3950 },
      { id: 2, title: 'Übermacht Sentinel', price: 9500000, category: 'limitalt', categoryLabel: 'Limitált', massCategory: 'limitalt', massCategoryLabel: 'Limitált', tuned: 33, views: 210, likes: 33, promoted: true, sold: false, liked: true, fav: true, available: false, seller: T_BRONZ, image: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800', isOwner: false, description: 'Szép állapot.', images: ['https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800'], tuning: { percent: 33, parts: TUNE.parts }, chip: null, antilag: ANTILAG, extraspeed: 5, mass: 3200 },
      { id: 3, title: 'Declasse Tampa', price: 2400000, category: 'keres_sima', categoryLabel: 'Autókereskedés Sima', massCategory: 'autokeres', massCategoryLabel: 'Autokeres', tuned: 0, views: 98, likes: 12, promoted: false, sold: false, liked: false, fav: false, available: true, seller: T_BRONZ, image: '', isOwner: true, description: 'Megbízható.', images: [], tuning: null, chip: null, antilag: null, extraspeed: 0, mass: 2300 },
    ],
  };
  const find = id => MOCK.cars.find(c => c.id === id);
  window.post = async (name, data = {}) => {
    await new Promise(r => setTimeout(r, 110));
    switch (name) {
      case 'getState': return { ready: true, hasAccess: true, accessUntil: Date.now() + 5 * 86400000, accessPrice: 1000000, wallet: 50000000, isAdmin: true, member: MOCK.member };
      case 'buyAccess': return { ok: true, accessUntil: Date.now() + 7 * 86400000, wallet: 49000000, member: MOCK.member };
      case 'getMembership': return { member: MOCK.member };
      case 'getCars': return { ready: true, cars: MOCK.cars.filter(c => !c.sold) };
      case 'getMyCars': return { cars: MOCK.cars.filter(c => c.isOwner).map(c => ({ ...c, promotedUntil: Date.now() + 3 * 86400000, refund: 0 })) };
      case 'getFavorites': return { cars: MOCK.cars.filter(c => c.fav) };
      case 'getCar': return find(data.id) || false;
      case 'getContact': return { name: 'Kovács Béla', phone: '555-0142', available: true };
      case 'getMyVehicles': return {
        vehicles: [
          { plate: 'SULT001', label: 'Karin Sultan RS', spawnName: 'sultanrs', model: 1, inside: true, mass: 3950, hasChip: true, hasAntilag: true, extraspeed: 10, tuning: TUNE, alreadyListed: false },
          { plate: 'TAMPA22', label: 'Declasse Tampa', spawnName: 'tampa', model: 2, inside: false, hasChip: false, hasAntilag: false, extraspeed: 0, tuning: { percent: 12, parts: TUNE.parts }, alreadyListed: true },
        ]
      };
      case 'toggleLike': { const c = find(data.id); c.liked = !c.liked; c.likes += c.liked ? 1 : -1; return { ok: true, liked: c.liked, likes: c.likes }; }
      case 'toggleFavorite': { const c = find(data.id); c.fav = !c.fav; return { ok: true, fav: c.fav }; }
      case 'createCar': return { ok: true, id: 99, member: MOCK.member };
      case 'promote': return { ok: true, charged: data.weeks * CFG.promoPrice, member: MOCK.member, promotedUntil: Date.now() + data.weeks * 7 * 86400000 };
      case 'cancelPromo': return { ok: true, refund: 5000000 };
      case 'markSold': return { ok: true, sold: data.sold };
      case 'deleteCar': return { ok: true, refund: 0 };
      case 'takePhoto': return { ok: true, url: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800' };
      case 'getProfileByCar': { const c = find(data.id); return mockProfile(c && c.isOwner ? 'Te' : 'Kovács Béla', c && c.seller, c && c.isOwner, data.id); }
      case 'getMyProfile': return mockProfile('Te (Declasse Tampa)', MOCK.member.tier, true, null);
      case 'submitReview': { const upd = !!mockMyReview; mockMyReview = { rating: data.rating, comment: data.comment }; return { ok: true, updated: upd, profile: mockProfile('Eladó', S_ARANY, false, data.id) }; }
      case 'deleteMyReview': { mockMyReview = null; return { ok: true, profile: mockProfile('Eladó', S_ARANY, false, data.id) }; }
      case 'adminDeleteReview': return { ok: true, profile: mockProfile('Eladó', S_ARANY, false, data.id) };
      case 'adminClearProfile': return { ok: true, profile: mockProfile('Eladó', S_ARANY, false, data.id) };
      default: return { ok: true };
    }
  };
  window.addEventListener('DOMContentLoaded', () => {
    // A dev mock az 'open' üzenetet szimulálja; a CFG.tiers/tasks/points-ot
    // is feltöltjük, hogy a renderMembership() CFG-ből olvasson (mint élesben).
    const mockTiers = [
      { key: 'ujonc', name: 'Újonc', color: '#9aa6b2', minPoints: 0, minAds: 0, minTasks: 0 },
      { key: 'bronz', name: 'Bronz Kereskedő', color: '#cd7f32', minPoints: 150, minAds: 0, minTasks: 0 },
      { key: 'ezust', name: 'Ezüst Kereskedő', color: '#c0c7d0', minPoints: 500, minAds: 0, minTasks: 0 },
      { key: 'arany', name: 'Arany Kereskedő', color: '#ffce4d', minPoints: 1500, minAds: 12, minTasks: 0 },
      { key: 'gyemant', name: 'Gyémánt Legenda', color: '#5fd0ff', minPoints: 4000, minAds: 30, minTasks: 5 },
    ];
    const mockTasks = [
      { key: 'first_post', label: 'Add fel az első autódat', hint: '1 hirdetés feladása' },
      { key: 'post_10', label: 'Hirdess összesen 10 autót', hint: '10 hirdetés összesen' },
      { key: 'first_sale', label: 'Adj el egy autót', hint: 'jelölj egy hirdetést eladottnak' },
      { key: 'promote', label: 'Emelj ki egy hirdetést', hint: 'indíts 1 kiemelést' },
      { key: 'views_250', label: 'Érj el összesen 250 megtekintést', hint: 'a hirdetéseiden összesen' },
    ];
    window.dispatchEvent(new MessageEvent('message', {
      data: {
        action: 'open', config: {
          categories: [{ value: 'egyedi', label: 'Egyedi' }, { value: 'limitalt', label: 'Limitált' }, { value: 'pps', label: 'PP-s' }, { value: 'keres_sima', label: 'Autókereskedés Sima' }, { value: 'keres_szerelo', label: 'Autókereskedés Szerelő' }],
          massCategories: [[2000, 2599, 'autokeres', 'Autokeres'], [2600, 2999, 'privat', 'Privát Autokeres'], [3000, 3889, 'limitalt', 'Limitált'], [3890, 5000, 'egyedi', 'Egyedi']],
          tiers: mockTiers, tasks: mockTasks,
          points: { AccessWeek: 40, AdPosted: 35, Sale: 70, PromoWeek: 50, Task: 120 },
          promoPrice: 15000000, maxWeeks: 8, maxImages: 1, accessPrice: 1000000, maxDesc: 600, maxReview: 300,
        }
      }
    }));
  });
}
