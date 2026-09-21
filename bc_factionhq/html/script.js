/* FactionHQ menu - single static listener set, re-rendered per open (no
   timers, no dangling handlers -> nothing to leak). */
const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bc_factionhq';
const root = document.getElementById('menu');
const panel = document.getElementById('hqm');
const itemsEl = document.getElementById('m-items');

let items = [];
let sel = -1;

const esc = s => String(s == null ? '' : s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

const IC = {
  enter:   '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>',
  invite:  '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>',
  access:  '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0 3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>',
  users:   '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>',
  house:   '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/><path d="M10 21v-6h4v6"/></svg>',
  preview: '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>',
  buy:     '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>',
  breach:  '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
  tp:      '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>',
  trash:   '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>',
  check:   '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>',
  back:    '<svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>',
};
const CAR = '<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';

function post(name, body) {
  fetch(`https://${RES}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body || {}),
  }).catch(() => {});
}

function firstSelectable(from, dir) {
  const n = items.length;
  let i = from;
  for (let k = 0; k < n; k++) {
    i = ((i % n) + n) % n;
    if (!items[i].disabled) return i;
    i += dir;
  }
  return -1;
}

function paintSel() {
  itemsEl.querySelectorAll('.it').forEach((el, i) => el.classList.toggle('sel', i === sel));
  const el = itemsEl.children[sel];
  if (el) el.scrollIntoView({ block: 'nearest' });
}

function render(menu) {
  document.getElementById('m-title').textContent = menu.title || '';
  document.getElementById('m-sub').textContent = menu.subtitle || '';

  items = menu.items || [];
  itemsEl.innerHTML = items.map((it, i) => `
    <div class="it${it.disabled ? ' disabled' : ''}${it.danger ? ' danger' : ''}" data-i="${i}" style="animation-delay:${45 + i * 32}ms">
      <div class="ic">${IC[it.icon] || IC.house}</div>
      <div class="tx">
        <div class="lb">${esc(it.label)}</div>
        ${it.desc ? `<div class="ds">${esc(it.desc)}</div>` : ''}
      </div>
      ${it.right ? `<div class="rt">${esc(it.right)}</div>` : ''}
      ${it.disabled ? '' : `<div class="car">${CAR}</div>`}
    </div>`).join('');

  sel = firstSelectable(0, 1);
  paintSel();

  // Replay the panel entrance animation on every (sub)menu open
  panel.style.animation = 'none';
  void panel.offsetWidth;
  panel.style.animation = '';

  root.classList.remove('hidden');
}

window.addEventListener('message', e => {
  const m = e.data || {};
  if (m.action === 'open') render(m.menu || {});
  else if (m.action === 'close') root.classList.add('hidden');
});

document.addEventListener('keydown', e => {
  if (root.classList.contains('hidden')) return;
  if (e.key === 'ArrowDown') { sel = firstSelectable(sel + 1, 1); paintSel(); }
  else if (e.key === 'ArrowUp') { sel = firstSelectable(sel - 1, -1); paintSel(); }
  else if (e.key === 'Enter') {
    const it = items[sel];
    if (it && !it.disabled) post('select', { id: it.id });
  } else if (e.key === 'Escape' || e.key === 'Backspace') {
    post('back');
  }
});

itemsEl.addEventListener('click', e => {
  const el = e.target.closest('.it');
  if (!el || el.classList.contains('disabled')) return;
  const it = items[+el.dataset.i];
  if (it) post('select', { id: it.id });
});

itemsEl.addEventListener('mousemove', e => {
  const el = e.target.closest('.it');
  if (!el || el.classList.contains('disabled')) return;
  if (sel !== +el.dataset.i) { sel = +el.dataset.i; paintSel(); }
});
