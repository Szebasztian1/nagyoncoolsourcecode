/* bc_keysystem NUI — BC design system, vanilla JS (no build step).
 *
 * Contract with client/nui.lua + client/management.lua (unchanged):
 *   in : { action:"show", enable:true|false }
 *   out: exit {} · prices {} · getcars {} · getkeys {plate} · delkey {plate,kid}
 *        newkey {plate,label,bank} · getalarm {plate} · buyalarm {plate,alarmtyp,bank}
 *        removealarm {plate} · getpos {plate}
 * Lua closes the NUI itself after delkey / newkey / buyalarm / removealarm / getpos.
 */
(() => {
	'use strict';

	/* ------------------------------------------------------------ helpers */

	const $ = (id) => document.getElementById(id);

	const resource = () => (typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bc_keysystem');

	// Every callback goes out as POST + JSON; the answer is JSON (table, string, false or 1).
	const post = (name, payload) =>
		fetch(`https://${resource()}/${name}`, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json; charset=UTF-8' },
			body: JSON.stringify(payload || {}),
		})
			.then((r) => r.json())
			.catch(() => null);

	// An empty Lua table arrives as {} (or []), a filled one as an array.
	const asList = (v) => (Array.isArray(v) ? v : v && typeof v === 'object' ? Object.values(v) : []);

	const ESC_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
	const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ESC_MAP[c]);

	// 2500 -> "$2.500"
	const money = (n) => {
		const v = Number(n);
		if (n === null || n === undefined || n === '' || !isFinite(v)) return '—';
		return '$' + String(Math.round(v)).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
	};

	const norm = (s) => String(s || '').toLowerCase().replace(/\s+/g, '');

	const ICON = {
		car: '<path d="M7 17m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"/><path d="M17 17m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"/><path d="M5 17h-2v-6l2 -5h9l4 5h1a2 2 0 0 1 2 2v4h-2m-4 0h-6m-6 -6h15m-6 0v-5"/>',
		key: '<path d="M16.555 3.843l3.602 3.602a2.877 2.877 0 0 1 0 4.069l-2.643 2.643a2.877 2.877 0 0 1 -4.069 0l-.301 -.301l-6.558 6.558a2 2 0 0 1 -1.239 .578l-.175 .008h-1.172a1 1 0 0 1 -.993 -.883l-.007 -.117v-1.172a2 2 0 0 1 .467 -1.284l.119 -.13l.414 -.414h2v-2h2v-2l2.144 -2.144l-.301 -.301a2.877 2.877 0 0 1 0 -4.069l2.643 -2.643a2.877 2.877 0 0 1 4.069 0z"/><path d="M15 9h.01"/>',
		trash: '<path d="M4 7l16 0"/><path d="M10 11l0 6"/><path d="M14 11l0 6"/><path d="M5 7l1 12a2 2 0 0 0 2 2h8a2 2 0 0 0 2 -2l1 -12"/><path d="M9 7v-3a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v3"/>',
		search: '<path d="M10 10m-7 0a7 7 0 1 0 14 0a7 7 0 1 0 -14 0"/><path d="M21 21l-6 -6"/>',
	};
	const svg = (name) =>
		`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${ICON[name]}</svg>`;

	const emptyBlock = (icon, title, text) =>
		`<div class="empty"><span class="e-ico">${svg(icon)}</span>${title ? `<div class="e-t">${esc(title)}</div>` : ''}<div class="e-d">${esc(text)}</div></div>`;

	const skeletonCars = (n) =>
		'<div class="nav-btn car sk"><span class="ico"></span><span class="lbl"><span class="ln w1"></span><span class="ln w2"></span></span></div>'.repeat(n);

	const skeletonKeys = (n) =>
		'<div class="krow sk"><span class="ki"></span><span class="ln w3"></span><span class="del-sk"></span></div>'.repeat(n);

	/* ------------------------------------------------------------ state */

	const el = {
		plate: $('bar-plate'), plateTxt: $('bar-plate-txt'), close: $('btn-close'),
		carCount: $('car-count'), carRefresh: $('car-refresh'), search: $('car-search'), carList: $('car-list'),
		pick: $('pick'), detail: $('detail'), page: $('page'), dTag: $('d-tag'), dTitle: $('d-title'),
		kCount: $('k-count'), kRefresh: $('k-refresh'), kRows: $('k-rows'), kHint: $('k-hint'),
		nkName: $('nk-name'), nkPrice: $('nk-price'), nkBuy: $('nk-buy'),
		alNone: $('al-none'), alLoading: $('al-loading'), alOn: $('al-on'), alOff: $('al-off'),
		alLabel: $('al-label'), alDesc: $('al-desc'), alPos: $('al-pos'), alRemove: $('al-remove'),
		alOpts: $('al-opts'), alPrice: $('al-price'), alBuy: $('al-buy'),
		pAlarm: $('al-p-alarm'), pAlarmGps: $('al-p-alarmgps'),
	};

	const S = {
		cars: [], carsLoading: true, carsSeq: 0, query: '',
		plate: false,                            // selected plate, or false
		keys: [], keysLoading: false, keysSeq: 0,
		alarm: null, alarmSeq: 0,                // null = loading · false = none · string = installed label
		prices: null, pricesLoading: false,
		keyBank: false, alarmType: null, alarmBank: false,
		armed: null, armTimer: 0,                // data-confirm token of the armed button ("key:<id>" | "alarm-remove")
		busy: false,                             // an action callback is in flight
	};

	const ALARM_DESC = {
		'Riasztó': 'Hangjelzés illetéktelen nyitáskor',
		'Riasztó + GPS': 'Hangjelzés + a jármű bemérhető',
	};

	/* ------------------------------------------------------------ cars */

	const FACTION = /\s*\(Frakci.\)\s*$/;

	const toCar = (c) => {
		const raw = c && c.label != null ? String(c.label) : '';
		const faction = FACTION.test(raw);
		const name = raw.replace(FACTION, '').trim() || 'Ismeretlen';
		const plate = c && c.plate != null ? String(c.plate) : '';
		return { plate, name, faction, hay: `${norm(plate)}|${norm(name)}${faction ? '|frakció' : ''}` };
	};

	function loadCars() {
		const seq = ++S.carsSeq;
		S.carsLoading = true;
		renderCars();
		post('getcars', {}).then((res) => {
			if (seq !== S.carsSeq) return;
			S.cars = asList(res).map(toCar).filter((c) => c.plate);
			S.carsLoading = false;
			renderCars();
			if (S.plate) renderTitle();
		});
	}

	function renderCars() {
		const q = norm(S.query);
		const shown = q ? S.cars.filter((c) => c.hay.indexOf(q) !== -1) : S.cars;

		el.carRefresh.classList.toggle('spin', S.carsLoading);

		if (S.carsLoading && !S.cars.length) {
			el.carCount.textContent = '…';
			el.carList.innerHTML = skeletonCars(7);
			return;
		}

		el.carCount.textContent = q ? `${shown.length} / ${S.cars.length}` : String(S.cars.length);

		if (!S.cars.length) {
			el.carList.innerHTML = emptyBlock('car', 'Nincs járműved', 'Nincs a nevedre írt jármű.');
			return;
		}
		if (!shown.length) {
			el.carList.innerHTML = emptyBlock('search', 'Nincs találat', 'Egyik járműved sem felel meg a keresésnek.');
			return;
		}

		el.carList.innerHTML = shown
			.map(
				(c) => `<button type="button" class="nav-btn car${c.plate === S.plate ? ' on' : ''}" data-plate="${esc(c.plate)}">
					<span class="ico">${svg('car')}</span>
					<span class="lbl"><span class="t">${esc(c.plate)}</span><span class="d">${esc(c.name)}</span></span>
					${c.faction ? '<span class="tag">Frakció</span>' : ''}
				</button>`
			)
			.join('');
	}

	/* ------------------------------------------------------------ selection */

	function select(plate) {
		// clicking the already selected car deselects it (old behaviour)
		if (!plate || plate === S.plate) {
			clearSelection();
			return;
		}
		S.plate = plate;
		S.keys = [];
		S.alarmType = null;
		el.nkName.value = '';
		disarm();
		renderSelection();
		el.page.scrollTop = 0;
		loadKeys();
		loadAlarm();
	}

	function clearSelection() {
		S.plate = false;
		S.keysSeq++; // late answers for the old car are dropped
		S.alarmSeq++;
		disarm();
		renderSelection();
	}

	function renderSelection() {
		const has = !!S.plate;

		el.plate.classList.toggle('off', !has);
		el.plateTxt.textContent = has ? S.plate : 'Nincs kiválasztott jármű';

		for (const row of el.carList.querySelectorAll('.car')) row.classList.toggle('on', row.dataset.plate === S.plate);

		el.pick.hidden = has;
		el.detail.hidden = !has;
		if (!has) return;

		renderTitle();
		renderKeys();
		renderAlarm();
		refreshButtons();
	}

	function renderTitle() {
		const car = S.cars.find((c) => c.plate === S.plate);
		el.dTitle.innerHTML = `${esc(S.plate)}${car ? ` <b>${esc(car.name)}</b>` : ''}`;
		el.dTag.hidden = !(car && car.faction);
	}

	/* ------------------------------------------------------------ keys */

	function loadKeys() {
		const plate = S.plate;
		if (!plate) return;
		const seq = ++S.keysSeq;
		S.keysLoading = true;
		renderKeys();
		post('getkeys', { plate }).then((res) => {
			if (seq !== S.keysSeq) return;
			S.keys = asList(res).map((k) => ({ id: k ? k.id : undefined, label: k && k.label != null ? String(k.label) : '' }));
			S.keysLoading = false;
			if (S.armed !== null && S.armed.indexOf('key:') === 0) disarm(); // the key list may have changed
			renderKeys();
		});
	}

	function renderKeys() {
		el.kRefresh.classList.toggle('spin', S.keysLoading);
		el.kHint.hidden = !S.keys.length;

		if (S.keysLoading && !S.keys.length) {
			el.kCount.textContent = '…';
			el.kRows.innerHTML = skeletonKeys(3);
			return;
		}

		el.kCount.textContent = String(S.keys.length);

		if (!S.keys.length) {
			el.kRows.innerHTML = emptyBlock('key', null, 'Ehhez a járműhöz még nincs kiadott kulcs.');
			return;
		}

		el.kRows.innerHTML = S.keys
			.map(
				(k, i) => `<div class="krow">
					<span class="ki">${svg('key')}</span>
					<span class="kn">${esc(k.label || 'Névtelen kulcs')}</span>
					<span class="kid">#${esc(k.id)}</span>
					<button type="button" class="btn danger sm del" data-i="${i}" data-confirm="key:${esc(k.id)}" data-armed="Biztos?">${svg('trash')}<span class="btxt">Törlés</span></button>
				</div>`
			)
			.join('');
		paintArmed();
		refreshButtons();
	}

	/* Two-step confirm, shared by key delete and alarm removal.
	 * A button opts in with data-confirm="<token>" + data-armed="<label>" and a .btxt label span:
	 * the first click arms it for 3 s, only a second click on the same armed button runs the action. */
	function confirmThen(btn, action) {
		if (S.armed !== null && S.armed === btn.dataset.confirm) {
			disarm();
			action();
		} else {
			arm(btn.dataset.confirm);
		}
	}

	function arm(token) {
		clearTimeout(S.armTimer);
		S.armed = token;
		S.armTimer = setTimeout(disarm, 3000);
		paintArmed();
	}

	function disarm() {
		clearTimeout(S.armTimer);
		S.armed = null;
		paintArmed();
	}

	function paintArmed() {
		for (const b of document.querySelectorAll('[data-confirm]')) {
			const on = S.armed !== null && b.dataset.confirm === S.armed;
			if (b.classList.contains('armed') === on) continue;
			const label = b.querySelector('.btxt');
			if (!b.dataset.idle) b.dataset.idle = label.textContent;
			b.classList.toggle('armed', on);
			label.textContent = on ? b.dataset.armed : b.dataset.idle;
		}
	}

	/* ------------------------------------------------------------ alarm */

	function loadAlarm() {
		const plate = S.plate;
		if (!plate) return;
		const seq = ++S.alarmSeq;
		S.alarm = null;
		renderAlarm();
		post('getalarm', { plate }).then((res) => {
			if (seq !== S.alarmSeq) return;
			S.alarm = res ? String(res) : false;
			renderAlarm();
		});
	}

	function renderAlarm() {
		const loading = S.alarm === null;
		el.alLoading.hidden = !loading;
		el.alOn.hidden = loading || !S.alarm;
		el.alOff.hidden = loading || !!S.alarm;
		el.alNone.hidden = S.alarm !== false;

		if (S.alarm) {
			el.alLabel.textContent = S.alarm;
			el.alDesc.textContent = ALARM_DESC[S.alarm] || 'Beszerelve';
		}
		paintAlarmCards();
		refreshButtons();
	}

	function paintAlarmCards() {
		for (const card of el.alOpts.querySelectorAll('.stage-card')) {
			const on = card.dataset.type === S.alarmType;
			card.classList.toggle('on', on);
			card.setAttribute('aria-checked', on ? 'true' : 'false');
		}
		const p = S.prices;
		if (!S.alarmType) el.alPrice.textContent = '—';
		else if (p) el.alPrice.textContent = money(S.alarmType === 'alarmgps' ? p.alarmgpsprice : p.alarmprice);
		else el.alPrice.textContent = S.pricesLoading ? '…' : '—';
	}

	/* ------------------------------------------------------------ prices + payment */

	function loadPrices() {
		S.pricesLoading = true;
		renderPrices();
		post('prices', {}).then((res) => {
			if (res && typeof res === 'object') S.prices = res;
			S.pricesLoading = false;
			renderPrices();
		});
	}

	function renderPrices() {
		const p = S.prices;
		const txt = (v) => (p ? money(v) : S.pricesLoading ? '…' : '—');
		el.nkPrice.textContent = txt(p && p.newkey);
		el.pAlarm.textContent = txt(p && p.alarmprice);
		el.pAlarmGps.textContent = txt(p && p.alarmgpsprice);
		paintAlarmCards();
	}

	function paintSeg() {
		for (const seg of document.querySelectorAll('.seg')) {
			const bank = seg.dataset.seg === 'newkey' ? S.keyBank : S.alarmBank;
			for (const chip of seg.querySelectorAll('.chip')) {
				const on = (chip.dataset.bank === '1') === bank;
				chip.classList.toggle('on', on);
				chip.setAttribute('aria-checked', on ? 'true' : 'false');
			}
		}
	}

	/* ------------------------------------------------------------ actions */

	function refreshButtons() {
		el.nkBuy.disabled = S.busy || !S.plate || !el.nkName.value.trim();
		el.alBuy.disabled = S.busy || !S.plate || !S.alarmType;
		el.alPos.disabled = S.busy;
		el.alRemove.disabled = S.busy;
		for (const b of el.kRows.querySelectorAll('.del')) b.disabled = S.busy;
	}

	// Fire an action callback once; buttons stay locked until Lua answers (it closes the NUI anyway).
	function send(name, payload) {
		if (S.busy) return;
		S.busy = true;
		refreshButtons();
		post(name, payload).then(() => {
			S.busy = false;
			refreshButtons();
		});
	}

	const exit = () => {
		clearSelection();
		post('exit', {});
	};

	/* ------------------------------------------------------------ events */

	el.close.addEventListener('click', exit);

	document.addEventListener('keydown', (e) => {
		if (e.keyCode === 27) exit();
	});

	el.carRefresh.addEventListener('click', () => loadCars());

	el.search.addEventListener('input', () => {
		S.query = el.search.value;
		renderCars();
	});

	el.carList.addEventListener('click', (e) => {
		const row = e.target.closest('.car');
		if (row && !row.classList.contains('sk')) select(row.dataset.plate);
	});

	el.kRefresh.addEventListener('click', () => loadKeys());

	el.kRows.addEventListener('click', (e) => {
		const btn = e.target.closest('.del');
		if (!btn || btn.disabled) return;
		const key = S.keys[+btn.dataset.i];
		if (key) confirmThen(btn, () => send('delkey', { plate: S.plate, kid: key.id }));
	});

	el.nkName.addEventListener('input', refreshButtons);

	el.nkBuy.addEventListener('click', () => {
		const label = el.nkName.value.trim();
		if (!S.plate || !label) return;
		send('newkey', { plate: S.plate, label, bank: S.keyBank });
	});

	for (const seg of document.querySelectorAll('.seg')) {
		seg.addEventListener('click', (e) => {
			const chip = e.target.closest('.chip');
			if (!chip) return;
			const bank = chip.dataset.bank === '1';
			if (seg.dataset.seg === 'newkey') S.keyBank = bank;
			else S.alarmBank = bank;
			paintSeg();
		});
	}

	el.alOpts.addEventListener('click', (e) => {
		const card = e.target.closest('.stage-card');
		if (!card) return;
		S.alarmType = card.dataset.type;
		paintAlarmCards();
		refreshButtons();
	});

	el.alBuy.addEventListener('click', () => {
		if (!S.plate || !S.alarmType) return;
		send('buyalarm', { plate: S.plate, alarmtyp: S.alarmType, bank: S.alarmBank });
	});

	el.alPos.addEventListener('click', () => {
		if (S.plate) send('getpos', { plate: S.plate });
	});

	el.alRemove.addEventListener('click', () => {
		if (S.plate) confirmThen(el.alRemove, () => send('removealarm', { plate: S.plate }));
	});

	window.addEventListener('message', (e) => {
		const d = e.data;
		if (!d || d.action !== 'show') return;
		document.body.style.display = d.enable ? 'block' : 'none';
		if (d.enable) open();
		else disarm();
	});

	// Every open starts clean: no selection, fresh car list, default payment = cash.
	function open() {
		S.busy = false;
		S.query = '';
		el.search.value = '';
		S.keyBank = false;
		S.alarmBank = false;
		S.alarmType = null;
		el.nkName.value = '';
		S.cars = [];
		clearSelection();
		paintSeg();
		loadCars();
		loadPrices();
	}

	/* ------------------------------------------------------------ boot */

	renderCars();
	renderSelection();
	renderPrices();
	paintSeg();
})();
