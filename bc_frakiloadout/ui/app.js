// ──────────────────────────────────────────────────
// STATE
// ──────────────────────────────────────────────────
const S = {
	view: 'list',   // list | detail | builder | catpicker
	tab: 'own',
	lists: { own: [], faction: [] },
	detail: null,
	detailItems: [],
	builder: { name: '', shared: false, items: [], editId: null },
	currentCat: null,
	config: null,    // Config.Items-ből kapott kategóriák
};

let modalResolve = null;

// ox_inventory item-képek; a szerveren .webp a bevett formátum
const ICON_BASE = 'nui://ox_inventory/web/images/';
const ICON_EXTS = ['.webp', '.png'];

// itemek, amiknek egyik kiterjesztéssel sincs képe – nem kérjük le újra
const badIcons = {};

// ──────────────────────────────────────────────────
// NUI BRIDGE
// ──────────────────────────────────────────────────
function send(action, data = {}) {
	fetch(`https://${GetParentResourceName()}/${action}`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(data),
	});
}

window.addEventListener('message', e => {
	const d = e.data;
	if (!d || !d.action) return;
	switch (d.action) {
		case 'open': handleOpen(d); break;
		case 'notify': toast(d.msg, d.type || 'info'); break;
		case 'detail': renderDetail(d); break;
	}
});

function handleOpen(d) {
	S.lists.own = d.own || [];
	S.lists.faction = d.faction || [];
	S.config = d.config || [];

	const job = d.jobLabel || '';
	document.getElementById('hdrSub').textContent = job || '—';
	document.getElementById('infoJob').textContent = job || '—';
	document.getElementById('infoOwn').textContent = S.lists.own.length;
	document.getElementById('infoShared').textContent = S.lists.faction.length;

	openApp();
	switchTab(S.tab);
}

// ──────────────────────────────────────────────────
// APP OPEN / CLOSE
// ──────────────────────────────────────────────────
function openApp() {
	document.getElementById('app').classList.add('open');
	showTabs(true);
}

function closeUI() {
	document.getElementById('app').classList.remove('open');
	setTimeout(() => send('close'), 300);
}

// ──────────────────────────────────────────────────
// TAB SWITCH (list view)
// ──────────────────────────────────────────────────
function switchTab(tab) {
	S.tab = tab;
	renderList(S.lists[tab] || []);
	showActions([{ label: 'Új loadout', cls: 'blue', fn: 'startCreate()' }]);
	showPriceBar(false);
	showTabs(true);
}

function renderList(items) {
	S.view = 'list';
	const own = S.tab === 'own';
	const c = document.getElementById('content');

	const head = `
		<div class="head">
			<div class="k">${own ? 'Személyes csomagok' : 'Frakciós csomagok'}</div>
			<div class="ttl">${own ? 'Saját <b>loadoutok</b>' : 'Frakció <b>loadoutok</b>'}</div>
		</div>`;

	if (!items.length) {
		c.innerHTML = head + emptyState(
			own ? ICO.user : ICO.users,
			own ? 'Még nincs saját loadoutod' : 'Nincs megosztott csomag',
			own ? 'Hozz létre egyet az „Új loadout” gombbal.'
				: 'A frakciótagok megosztott csomagjai itt jelennek meg.');
		return;
	}

	c.innerHTML = head + '<div class="list">' + items.map(l => `
		<div class="card" onclick="openDetail(${l.id})">
			<div class="cico">${svg(l.shared ? ICO.users : ICO.pack)}</div>
			<div class="cinfo">
				<div class="cn">
					<span class="nm">${esc(l.name)}</span>
					<span class="tag ${l.shared ? 'blue' : 'grey'}">${l.shared ? 'Közös' : 'Privát'}</span>
				</div>
				<div class="cd">${esc(l.owner_name)} · ${esc(String(l.job || '').toUpperCase())}</div>
			</div>
			<div class="cgo">${svg(ICO.chevron)}</div>
		</div>
	`).join('') + '</div>';
}

// ──────────────────────────────────────────────────
// DETAIL VIEW
// ──────────────────────────────────────────────────
function openDetail(id) {
	document.getElementById('content').innerHTML = '<div class="loader">Betöltés…</div>';
	showActions([]);
	showPriceBar(false);
	send('getDetail', { id });
}

function renderDetail(d) {
	S.view = 'detail';
	S.detail = d.loadout;
	S.detailItems = d.items || [];

	const total = d.total || 0;
	const c = document.getElementById('content');

	const rows = S.detailItems.map(it => `
		<div class="item">
			${itemIco(it.name)}
			<div class="iinfo">
				<div class="inm">${esc(it.label || it.name)}</div>
				<div class="isub">${esc(it.name)} · ${money(it.unit_price)} / db</div>
			</div>
			<div class="iprice">×${esc(it.quantity)}<b>${money(it.unit_price * it.quantity)}</b></div>
		</div>
	`).join('');

	c.innerHTML = `
		<div class="head">
			<div class="k">Loadout részletei</div>
			<div class="ttl">${esc(d.loadout.name)}</div>
		</div>

		<div class="box">
			<div class="bh"><div class="bt">Adatok</div></div>
			<div class="info-row"><span>Tulajdonos</span><span>${esc(d.loadout.owner_name)}</span></div>
			<div class="info-row"><span>Frakció</span><span>${esc(String(d.loadout.job || '').toUpperCase())}</span></div>
			<div class="info-row"><span>Láthatóság</span><span>${d.loadout.shared ? 'Megosztott' : 'Privát'}</span></div>
			<div class="info-row"><span>Elemek</span><span>${S.detailItems.length} db</span></div>
		</div>

		<div class="box">
			<div class="bh"><div class="bt">Tartalom</div><div class="bs">${S.detailItems.length} tétel</div></div>
			${rows ? `<div class="rows">${rows}</div>`
			: emptyState(ICO.box, 'Üres loadout', 'Ehhez a csomaghoz nincs elem rendelve.')}
		</div>
	`;
	wireIcons(c);

	showPriceBar(true, total);

	const btns = [
		{ label: 'Vissza', cls: 'ghost', fn: `switchTab('${S.tab}')` },
	];
	if (d.canDel) {
		btns.push({ label: 'Törlés', cls: 'danger', fn: `deleteConfirm(${d.loadout.id})` });
	}
	if (d.canEdit) {
		btns.push(
			{ label: 'Átnevezés', cls: 'ghost', fn: `startRename(${d.loadout.id})` },
			{ label: 'Szerkesztés', cls: 'ghost', fn: `startEdit(${d.loadout.id})` }
		);
	}
	btns.push({ label: 'Felvétel', cls: 'green', fn: `redeemConfirm(${d.loadout.id},${total})` });

	showActions(btns);
	showTabs(false);
}

// ──────────────────────────────────────────────────
// REDEEM
// ──────────────────────────────────────────────────
function redeemConfirm(id, total) {
	showModal('Loadout felvétele', `Biztosan felveszed?\n\nLevonandó: <b>${money(total)}</b>`)
		.then(ok => { if (ok) send('redeem', { id }); });
}

// ──────────────────────────────────────────────────
// DELETE
// ──────────────────────────────────────────────────
function deleteConfirm(id) {
	showModal('Törlés', 'Biztosan törlöd ezt a loadoutot?\nEz a művelet nem visszavonható.')
		.then(ok => { if (ok) send('delete', { id }); });
}

// ──────────────────────────────────────────────────
// RENAME
// ──────────────────────────────────────────────────
function startRename(id) {
	showModal('Átnevezés', '', `
		<div class="field">
			<label>Új név</label>
			<input id="renameInput" type="text" maxlength="64" placeholder="Loadout neve..." autocomplete="off"/>
		</div>
	`).then(ok => {
		if (!ok) return;
		const name = document.getElementById('renameInput')?.value?.trim();
		if (!name || name.length < 2) { toast('Érvénytelen név.', 'error'); return; }
		send('rename', { id, name });
	});
	setTimeout(() => document.getElementById('renameInput')?.focus(), 100);
}

// ──────────────────────────────────────────────────
// CREATE WIZARD
// ──────────────────────────────────────────────────
function startCreate() {
	showModal('Új loadout', '', `
		<div class="field">
			<label>Név</label>
			<input id="newName" type="text" maxlength="64" placeholder="pl. Járőr csomag..." autocomplete="off"/>
		</div>
	`).then(ok => {
		if (!ok) return;

		// Fontos: Az értéket még azelőtt ki kell nyerni, hogy a DOM-ból esetleg eltűnne
		const inputEl = document.getElementById('newName');
		const name = inputEl ? inputEl.value.trim() : "";

		if (!name || name.length < 2) {
			toast('Érvénytelen név (min. 2 karakter).', 'error');
			return;
		}

		// Inicializáljuk a buildert
		S.builder = {
			name: name,
			shared: false,
			items: [],
			editId: null
		};

		// Átváltunk a szerkesztő nézetre
		openBuilder();
	});

	// Fókusz az inputra
	setTimeout(() => {
		const el = document.getElementById('newName');
		if (el) el.focus();
	}, 150);
}

// ──────────────────────────────────────────────────
// EDIT EXISTING
// ──────────────────────────────────────────────────
function startEdit(id) {
	S.builder = {
		name: S.detail?.name || '',
		shared: S.detail?.shared === 1,
		items: S.detailItems.map(it => ({
			name: it.name,
			label: it.label || it.name,
			quantity: it.quantity,
			unit_price: it.unit_price,
			max: it.max || 99,
		})),
		editId: id,
	};
	openBuilder();
}

// ──────────────────────────────────────────────────
// BUILDER
// ──────────────────────────────────────────────────
function openBuilder() {
	S.view = 'builder';
	showTabs(false);
	renderBuilder();
}

function renderBuilder() {
	const b = S.builder;
	const total = b.items.reduce((s, it) => s + it.unit_price * it.quantity, 0);
	const c = document.getElementById('content');

	// Shared toggle
	const sharedRow = `
		<div class="box">
			<div class="switch-row">
				<div>
					<div class="st">Megosztott loadout</div>
					<div class="sd">A frakció minden tagja látja és felveheti.</div>
				</div>
				<div class="${b.shared ? 'switch on' : 'switch'}" id="sharedToggle" onclick="toggleShared()"></div>
			</div>
		</div>
	`;

	// Category buttons
	const cats = (S.config || []).map(cat => `
		<div class="cat" onclick="openCatPicker('${escHtml(cat.cat)}')">
			<div class="ci">${svg(catIcon(cat.cat))}</div>
			<div class="cl">${esc(cat.cat)}</div>
			<div class="cc">${(cat.items || []).length} tétel</div>
		</div>
	`).join('');

	// Current items
	const itemRows = b.items.length ? b.items.map((it, i) => `
		<div class="item">
			${itemIco(it.name)}
			<div class="iinfo">
				<div class="inm">${esc(it.label || it.name)}</div>
				<div class="isub">${money(it.unit_price)} / db · max ${esc(it.max)}</div>
			</div>
			<div class="qty">
				<div class="qb" onclick="adjustQty(${i},-1)">−</div>
				<div class="qv">${esc(it.quantity)}</div>
				<div class="qb" onclick="adjustQty(${i},+1)">+</div>
			</div>
			<div class="iprice"><b>${money(it.unit_price * it.quantity)}</b></div>
			<div class="rm" onclick="removeItem(${i})" title="Eltávolítás">${svg(ICO.close)}</div>
		</div>
	`).join('') : emptyState(ICO.pack, 'Még üres a csomag', 'Válassz egy kategóriát és adj hozzá elemeket.');

	c.innerHTML = `
		<div class="head">
			<div class="k">${b.editId ? 'Csomag szerkesztése' : 'Új csomag összeállítása'}</div>
			<div class="ttl">${esc(b.name)}</div>
		</div>
		${!b.editId ? sharedRow : ''}
		<div class="box">
			<div class="bh"><div class="bt">Kategóriák</div><div class="bs">Válassz elemeket</div></div>
			<div class="cats">${cats}</div>
		</div>
		<div class="box">
			<div class="bh"><div class="bt">Összeállítás</div><div class="bs">${b.items.length} tétel</div></div>
			${b.items.length ? `<div class="rows">${itemRows}</div>` : itemRows}
		</div>
	`;
	wireIcons(c);

	showPriceBar(true, total);
	showActions([
		{ label: 'Mégse', cls: 'ghost', fn: b.editId ? `openDetail(${b.editId})` : `switchTab('own')` },
		{ label: b.editId ? 'Mentés' : 'Létrehozás', cls: 'green', fn: 'saveBuilder()' },
	]);
}

function toggleShared() {
	S.builder.shared = !S.builder.shared;
	const el = document.getElementById('sharedToggle');
	if (el) el.classList.toggle('on', S.builder.shared);
}

function adjustQty(idx, delta) {
	const it = S.builder.items[idx];
	if (!it) return;
	it.quantity = Math.max(1, Math.min((it.max || 99), it.quantity + delta));
	const qEl = document.querySelectorAll('.qv')[idx];
	if (qEl) qEl.textContent = it.quantity;
	updatePriceBar();
}

function removeItem(idx) {
	S.builder.items.splice(idx, 1);
	renderBuilder();
}

function updatePriceBar() {
	const total = S.builder.items.reduce((s, it) => s + it.unit_price * it.quantity, 0);
	showPriceBar(true, total);
}

function saveBuilder() {
	if (!S.builder.items.length) { toast('Adj hozzá legalább egy elemet!', 'error'); return; }
	const payload = S.builder.items.map(it => ({ name: it.name, quantity: it.quantity }));
	if (S.builder.editId) {
		send('edit', { id: S.builder.editId, items: payload });
	} else {
		S.tab = 'own';   // a friss csomag a saját listába kerül
		send('create', { name: S.builder.name, shared: S.builder.shared, items: payload });
	}
}

// ──────────────────────────────────────────────────
// CAT PICKER
// ──────────────────────────────────────────────────
function openCatPicker(catName) {
	S.currentCat = (S.config || []).find(c => c.cat === catName);
	if (!S.currentCat) return;
	S.view = 'catpicker';
	renderCatPicker();
}

function renderCatPicker() {
	const cat = S.currentCat;
	const c = document.getElementById('content');

	const rows = cat.items.map(it => {
		const existing = S.builder.items.find(b => b.name === it.name);
		const qty = existing ? existing.quantity : 0;
		const gradeStr = it.grade > 0 ? ` · rang ≥ ${it.grade}` : '';
		return `
			<div class="item pick ${existing ? 'on' : ''}" onclick="pickItem('${escHtml(it.name)}')">
				${itemIco(it.name)}
				<div class="iinfo">
					<div class="inm">${esc(it.label)}</div>
					<div class="isub">max ${esc(it.max)} db${gradeStr}</div>
				</div>
				<div class="iprice">${money(it.price)}<b class="${qty > 0 ? 'have' : 'none'}">${qty > 0 ? '× ' + qty : '—'}</b></div>
			</div>
		`;
	}).join('');

	c.innerHTML = `
		<div class="head">
			<div class="k">Kategória</div>
			<div class="ttl">${esc(cat.cat)}</div>
		</div>
		<div class="box">
			<div class="bh"><div class="bt">Elérhető elemek</div><div class="bs">${cat.items.length} tétel</div></div>
			<div class="rows">${rows}</div>
		</div>
	`;
	wireIcons(c);

	showPriceBar(false);
	showActions([
		{ label: 'Vissza az összeállításhoz', cls: 'blue', fn: 'openBuilder()' },
	]);
}

function pickItem(name) {
	const cat = S.currentCat;
	const cfg = cat.items.find(i => i.name === name);
	if (!cfg) return;

	const existing = S.builder.items.find(b => b.name === name);
	const current = existing ? existing.quantity : 0;

	showModal(cfg.label, `Max mennyiség: <b>${cfg.max}</b> · Ár: <b>${money(cfg.price)}/db</b>`, `
		<div class="field">
			<label>Mennyiség (0 = eltávolítás)</label>
			<input id="qtyInput" type="number" min="0" max="${cfg.max}" value="${current}" autocomplete="off"/>
		</div>
	`).then(ok => {
		if (!ok) return;
		const val = parseInt(document.getElementById('qtyInput')?.value || '0', 10);
		const qty = Math.max(0, Math.min(cfg.max, isNaN(val) ? 0 : val));

		if (qty === 0) {
			S.builder.items = S.builder.items.filter(b => b.name !== name);
		} else if (existing) {
			existing.quantity = qty;
		} else {
			S.builder.items.push({
				name: cfg.name, label: cfg.label,
				quantity: qty, unit_price: cfg.price, max: cfg.max,
			});
		}
		renderCatPicker();
	});
	setTimeout(() => {
		const el = document.getElementById('qtyInput');
		if (el) { el.focus(); el.select(); }
	}, 100);
}

// ──────────────────────────────────────────────────
// UI HELPERS
// ──────────────────────────────────────────────────
function showTabs(visible) {
	// az oldalsáv mindig látszik; csak az aktív jelölés követi a nézetet
	document.querySelectorAll('.nav-btn').forEach(t =>
		t.classList.toggle('on', !!visible && t.dataset.tab === S.tab));
}

function showPriceBar(visible, total = 0) {
	const bar = document.getElementById('priceBar');
	bar.style.display = visible ? 'flex' : 'none';
	if (visible) document.getElementById('priceVal').textContent = money(total);
}

function showActions(buttons) {
	const bar = document.getElementById('actionBar');
	if (!buttons.length) { bar.style.display = 'none'; return; }
	bar.style.display = 'flex';
	bar.innerHTML = buttons.map(b =>
		`<div class="btn ${b.cls}" onclick="${b.fn}">${esc(b.label)}</div>`
	).join('');
}

function emptyState(icon, title, sub) {
	return `<div class="empty">${svg(icon, 1.5)}<div class="et">${esc(title)}</div><div class="es">${esc(sub)}</div></div>`;
}

// ──────────────────────────────────────────────────
// MODAL
// ──────────────────────────────────────────────────
function showModal(title, msg, extra = '') {
	document.getElementById('modalTitle').textContent = title;
	document.getElementById('modalMsg').innerHTML = msg.replace(/\n/g, '<br>');
	document.getElementById('modalExtra').innerHTML = extra;
	document.getElementById('modal').classList.add('open');
	return new Promise(res => { modalResolve = res; });
}

function modalConfirm() {
	if (modalResolve) {
		modalResolve(true);
		// Itt ne töröld azonnal a modalResolve-ot, hogy a .then lefusson
	}
	// A lezárás maradjon, de a tartalom törlését (closeModal)
	// érdemes a .then ágba vagy késleltetve tenni
	document.getElementById('modal').classList.remove('open');
}

function closeModal() {
	document.getElementById('modal').classList.remove('open');
	if (modalResolve) { modalResolve(false); modalResolve = null; }
}

// ──────────────────────────────────────────────────
// TOAST
// ──────────────────────────────────────────────────
function toast(msg, type = 'info') {
	const el = document.createElement('div');
	el.className = `toast ${type}`;
	el.textContent = msg;
	document.getElementById('toasts').appendChild(el);
	setTimeout(() => {
		el.classList.add('out');
		setTimeout(() => el.remove(), 300);
	}, 3500);
}

// ──────────────────────────────────────────────────
// ICONS
// ──────────────────────────────────────────────────
const ICO = {
	gun: '<circle cx="12" cy="12" r="7"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3"/>',
	ammo: '<path d="M12 3l3 5v9a3 3 0 0 1-6 0V8z"/><path d="M9 12h6"/>',
	armor: '<path d="M12 3l7 3v5c0 4.5-3 8.2-7 10-4-1.8-7-5.5-7-10V6z"/>',
	bag: '<path d="M8 7V5.5a4 4 0 0 1 8 0V7"/><path d="M4 7h16v13H4z"/><path d="M10 12h4"/>',
	radio: '<path d="M4 9h16v10H4z"/><path d="M8 9V5l9-2"/><path d="M8 13h4"/><circle cx="16" cy="14" r="2"/>',
	cuffs: '<circle cx="7" cy="12" r="3.5"/><circle cx="17" cy="12" r="3.5"/><path d="M10.5 12h3"/>',
	medkit: '<path d="M4 7h16v13H4z"/><path d="M9 7V4h6v3"/><path d="M12 11v5M9.5 13.5h5"/>',
	light: '<path d="M9 3h6v3.5l3 3V13H6V9.5l3-3z"/><path d="M12 13v8"/>',
	spike: '<path d="M3 18h18"/><path d="M5 18l2.5-6L10 18l2-6 2 6 2.5-6L19 18"/>',
	box: '<path d="M12 3l8 4.5v9L12 21l-8-4.5v-9z"/><path d="M12 12l8-4.5M12 12v9M12 12L4 7.5"/>',
	pack: '<path d="M4 6h16v14H4z"/><path d="M4 10h16"/><path d="M10 6V3h4v3"/>',
	user: '<circle cx="12" cy="8" r="3.5"/><path d="M5 20a7 7 0 0 1 14 0"/>',
	users: '<circle cx="9" cy="8" r="3"/><path d="M3 19a6 6 0 0 1 12 0"/><path d="M16 6.2a3 3 0 0 1 0 5.6M17 14.5a5 5 0 0 1 4 4.5"/>',
	chevron: '<path d="m9 6 6 6-6 6"/>',
	close: '<path d="M18 6 6 18M6 6l12 12"/>',
};

const svg = (d, w = 2) =>
	`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round">${d}</svg>`;

function itemIcon(name) {
	const n = String(name || '').toLowerCase();
	if (n.includes('weapon') || n.includes('wepon') || n.includes('shield')) return ICO.gun;
	if (n.includes('ammo')) return ICO.ammo;
	if (n.includes('vest') || n.includes('armor') || n.includes('kit')) return ICO.armor;
	if (n.includes('radio') || n.includes('tracker') || n.includes('gps') || n.includes('cam')
		|| n.includes('mdt') || n.includes('scanner') || n.includes('traffipax')) return ICO.radio;
	if (n.includes('bilincs') || n.includes('cuff')) return ICO.cuffs;
	if (n.includes('medkit') || n.includes('bandage') || n.includes('hullazsak')) return ICO.medkit;
	if (n.includes('flashlight') || n.includes('light')) return ICO.light;
	if (n.includes('spike')) return ICO.spike;
	return ICO.box;
}

function catIcon(cat) {
	const c = String(cat || '').toLowerCase();
	if (c.includes('fegyv')) return ICO.gun;
	if (c.includes('lőszer') || c.includes('loszer')) return ICO.ammo;
	if (c.includes('páncél') || c.includes('pancel')) return ICO.armor;
	if (c.includes('felszer')) return ICO.bag;
	return ICO.box;
}

/**
 * Item ikon: az ox_inventory képe a kategória-glif fölé úsztatva.
 * A kép rejtve indul és csak dekódolás után látszik, így hibás kép
 * esetén sosem villan be semmi – a glif marad.
 */
function itemIco(name) {
	const key = String(name || '').toLowerCase();
	const img = badIcons[key]
		? ''
		: `<img src="${escHtml(ICON_BASE + key + ICON_EXTS[0])}" data-ext="0" alt=""/>`;
	return `<div class="ii" data-item="${escHtml(key)}">${svg(itemIcon(name))}${img}</div>`;
}

function wireIcons(scope) {
	scope.querySelectorAll('.ii img').forEach(img => {
		const holder = img.parentNode;
		const key = holder && holder.dataset.item;

		const ok = () => { img.classList.add('ok'); holder.classList.add('has-img'); };

		const fail = () => {
			const next = (parseInt(img.dataset.ext, 10) || 0) + 1;
			// a következő ismert kiterjesztés, mielőtt feladnánk
			if (key && next < ICON_EXTS.length) {
				img.dataset.ext = next;
				img.src = ICON_BASE + key + ICON_EXTS[next];
				return;
			}
			if (key) badIcons[key] = true;
			img.remove();
		};

		// előbb a handlerek, hogy a lentebb induló újrapróbálkozás is ide fusson
		img.onload = ok;
		img.onerror = fail;
		if (img.complete) { img.naturalWidth > 0 ? ok() : fail(); }
	});
}

// ──────────────────────────────────────────────────
// HELPERS
// ──────────────────────────────────────────────────
const money = n => '$' + Math.floor(Number(n) || 0).toLocaleString('hu-HU');

function esc(s) {
	return String(s ?? '').replace(/[&<>"']/g, m =>
		({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[m]));
}

function escHtml(s) {
	return String(s).replace(/'/g, "&#39;").replace(/"/g, '&quot;');
}

// ──────────────────────────────────────────────────
// DEV PREVIEW (böngészőben teszteléshez)
// ──────────────────────────────────────────────────
if (window.location.protocol === 'file:' || window.location.hostname === 'localhost') {
	window.GetParentResourceName = () => 'bc_frakiloadout';
	window.dispatchEvent(new MessageEvent('message', {
		data: {
			action: 'open',
			jobLabel: 'Police Department',
			own: [
				{ id: 1, name: 'Járőr csomag', shared: 0, job: 'police', owner_name: 'Kovács J.' },
				{ id: 2, name: 'Kommandós felszerelés', shared: 1, job: 'police', owner_name: 'Nagy P.' },
			],
			faction: [
				{ id: 3, name: 'Riadó csomag', shared: 1, job: 'police', owner_name: 'Kiss B.' },
			],
			config: [
				{
					cat: 'Fegyverek', items: [
						{ name: 'weapon_combatpistol', label: 'Combat Pistol', price: 50000, max: 1, grade: 0 },
						{ name: 'weapon_carbinerifle', label: 'Carbine Rifle', price: 50000, max: 1, grade: 2 },
						{ name: 'weapon_nightstick', label: 'Nightstick', price: 400, max: 1, grade: 0 },
					]
				},
				{
					cat: 'Lőszer', items: [
						{ name: 'pistol_ammo', label: 'Pistol Ammo', price: 3000, max: 350, grade: 0 },
						{ name: 'rifle_ammo', label: 'Rifle Ammo', price: 3000, max: 350, grade: 2 },
					]
				},
				{
					cat: 'Felszerelés', items: [
						{ name: 'bilincs', label: 'Handcuffs', price: 250, max: 3, grade: 0 },
						{ name: 'spike', label: 'Spike Strip', price: 15000, max: 2, grade: 0 },
						{ name: 'bodycam', label: 'Bodycam', price: 100000, max: 1, grade: 0 },
					]
				},
				{
					cat: 'Páncél', items: [
						{ name: 'bulletproofvest', label: 'Bulletproof Vest', price: 400, max: 25, grade: 0 },
					]
				},
			],
		}
	}));
}
