// SpawnSelector — 2. koncepció: Filmes (BC design)
// Ugyanazt az üzenet-szerződést használja, mint a régi felület:
//   be:  openUI {data, last} | openwelcome | closewelcome
//   ki:  loaded | teleport {index}  (utolsó helyszínnél index nélkül)
(() => {
	'use strict';

	const RES = typeof window.GetParentResourceName === 'function' ? window.GetParentResourceName() : 'SpawnSelector';
	const post = (cb, body) => fetch(`https://${RES}/${cb}`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json; charset=UTF-8' },
		body: JSON.stringify(body || {}),
	}).catch(() => {});

	// GTA hang (Config.UiSounds): a NUI csak jelez, a kliens játssza le — most csak a "deny"
	const sound = (name) => post('sound', { name });

	// Saját UI-hangok (ui/sounds): ráhúzás és kiválasztás. Előre dekódolt pufferekből szólnak,
	// így a rövid kattanás azonnal megy, és nem függ egy NUI-médiastreamtől.
	let sfxVolume = 0.1; // a Testreszabás "Hangerő" csúszkája állítja (50% = 0.1)
	const SFX_FILES = { hover: 'sounds/rahuzod.mp3', select: 'sounds/kivalasztod.mp3' };
	const sfxBuf = {};
	const sfxLast = {};
	let actx = null;
	try {
		actx = new (window.AudioContext || window.webkitAudioContext)();
		Object.entries(SFX_FILES).forEach(([k, url]) => {
			fetch(url)
				.then((r) => r.arrayBuffer())
				.then((b) => actx.decodeAudioData(b))
				.then((ab) => { sfxBuf[k] = ab; })
				.catch(() => {});
		});
	} catch (e) {
		actx = null;
	}
	const sfx = (k) => {
		const now = performance.now();
		if (sfxLast[k] && now - sfxLast[k] < 45) return;
		sfxLast[k] = now;
		try {
			if (actx && sfxBuf[k]) {
				if (actx.state === 'suspended') actx.resume().catch(() => {});
				const src = actx.createBufferSource();
				const gain = actx.createGain();
				gain.gain.value = sfxVolume;
				src.buffer = sfxBuf[k];
				src.connect(gain).connect(actx.destination);
				src.start();
				return;
			}
			const a = new Audio(SFX_FILES[k]);
			a.volume = Math.min(1, sfxVolume);
			a.play().catch(() => {});
		} catch (e) { /* hang nélkül is menjen tovább */ }
	};

	const ICON = {
		pin: '<path d="M9 11a3 3 0 1 0 6 0a3 3 0 0 0 -6 0"/><path d="M17.657 16.657l-4.243 4.243a2 2 0 0 1 -2.827 0l-4.244 -4.243a8 8 0 1 1 11.314 0z"/>',
		history: '<path d="M12 8l0 4l2 2"/><path d="M3.05 11a9 9 0 1 1 .5 4m-.5 5v-5h5"/>',
		reset: '<path d="M19.95 11a8 8 0 1 0 -.5 4m.5 5v-5h-5"/>',
		lock: '<path d="M5 13a2 2 0 0 1 2 -2h10a2 2 0 0 1 2 2v6a2 2 0 0 1 -2 2h-10a2 2 0 0 1 -2 -2v-6z"/><path d="M11 16a1 1 0 1 0 2 0a1 1 0 0 0 -2 0"/><path d="M8 11v-4a4 4 0 1 1 8 0v4"/>',
		star: '<path d="M12 17.75l-6.172 3.245l1.179 -6.873l-5 -4.867l6.9 -1l3.086 -6.253l3.086 6.253l6.9 1l-5 4.867l1.179 6.873z"/>',
		login: '<path d="M15 8v-2a2 2 0 0 0 -2 -2h-7a2 2 0 0 0 -2 2v12a2 2 0 0 0 2 2h7a2 2 0 0 0 2 -2v-2"/><path d="M21 12h-13l3 -3"/><path d="M11 15l-3 -3"/>',
		check: '<path d="M5 12l5 5l10 -10"/>',
		building: '<path d="M3 21l18 0"/><path d="M9 8l1 0"/><path d="M9 12l1 0"/><path d="M9 16l1 0"/><path d="M14 8l1 0"/><path d="M14 12l1 0"/><path d="M14 16l1 0"/><path d="M5 21v-16a2 2 0 0 1 2 -2h10a2 2 0 0 1 2 2v16"/>',
		car: '<path d="M5 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"/><path d="M15 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"/><path d="M5 17h-2v-6l2 -5h9l4 5h1a2 2 0 0 1 2 2v4h-2m-4 0h-6m-6 -6h15m-6 0v-5"/>',
		trees: '<path d="M16 5l3 3l-2 1l4 4l-3 1l4 4h-9"/><path d="M15 21l0 -3"/><path d="M8 13l-2 -2"/><path d="M8 12l2 -2"/><path d="M8 21v-13"/><path d="M5.824 16a3 3 0 0 1 -2.743 -3.69a3 3 0 0 1 .304 -4.833a3 3 0 0 1 4.615 -3.707a3 3 0 0 1 4.614 3.707a3 3 0 0 1 .305 4.833a3 3 0 0 1 -2.919 3.695h-4z"/>',
		sun: '<path d="M8 12a4 4 0 1 0 8 0a4 4 0 1 0 -8 0"/><path d="M3 12h1m8 -9v1m8 8h1m-9 8v1m-6.4 -15.4l.7 .7m12.1 -.7l-.7 .7m0 11.4l.7 .7m-12.1 -.7l-.7 .7"/>',
	};
	const svg = (n) => `<svg viewBox="0 0 24 24">${ICON[n] || ICON.pin}</svg>`;
	// ikon a kép neve alapján — új helyszín automatikusan a sima tűt kapja
	const PLACE_ICON = { 'public.webp': 'building', 'piac.webp': 'car', 'paleto.webp': 'trees', 'sandy.webp': 'sun' };

	const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
	const img = (file) => `images/${encodeURI(String(file || ''))}`;
	const xy = (v) => {
		if (Array.isArray(v) && v.length >= 2) return { x: +v[0], y: +v[1] };
		if (v && typeof v === 'object' && isFinite(v.x) && isFinite(v.y)) return { x: +v.x, y: +v.y };
		return null;
	};
	const area = (it) => it.zone || (it.coords ? (it.coords.y > 1400 ? 'Blaine megye' : 'Los Santos') : null);
	const title = (name) => {
		const w = String(name || '').trim().split(/\s+/);
		if (w.length < 2) return `<b>${esc(w[0])}</b>`;
		const last = w.pop();
		return `${esc(w.join(' '))} <b>${esc(last)}</b>`;
	};
	const split = (desc) => {
		const i = String(desc || '').indexOf(' — ');
		return i < 0 ? null : [desc.slice(0, i), desc.slice(i + 3)];
	};

	// sötét úttérkép-textúra a "legutóbbi helyszín" kártyára; ha a Lua a last.Coords-ot is
	// küldi, a kilépés helyére áll, különben a belvárosra. (8192-es GTA V úttérkép-kivágás)
	const MAP = { sx: 1350, sy: 450, sw: 5200, sh: 7500 };
	const toMap = (c) => ({
		l: ((0.66304 * c.x + 3753.6) - MAP.sx) / MAP.sw,
		t: ((-0.656 * c.y + 5529.6) - MAP.sy) / MAP.sh,
	});
	const onMap = (p) => !!p && p.l >= 0 && p.l <= 1 && p.t >= 0 && p.t <= 1;
	function mapTex(coords) {
		let p = coords && toMap(coords);
		if (!onMap(p)) p = toMap({ x: 150, y: -800 });
		return `<img class="mtex" src="images/map.webp" alt="" draggable="false" style="transform:translate(-${(p.l * 100).toFixed(3)}%,-${(p.t * 100).toFixed(3)}%)">`;
	}

	const $ = (id) => document.getElementById(id);
	const stage = $('stage'), rail = $('rail'), cta = $('cta');
	const arrive = $('arrive'), arriveSub = $('arriveSub');
	const bg = $('bg');
	let bgTimer = null;
	// a háttérkép a választás után is marad, amíg a Lua el nem sötétíti a képernyőt (openwelcome),
	// így nem villan be a játékkamera; biztonsági tartalék, ha az openwelcome nem jönne meg
	const hideBg = () => { clearTimeout(bgTimer); bgTimer = null; bg.hidden = true; };

	let items = [];
	let sel = null;
	let busy = false;
	let chosen = null;
	const cur = () => items.find((i) => i.id === sel);

	function build(data, last) {
		items = [];
		if (last) {
			items.push({ id: 'last', kind: 'last', name: last.Name || 'Utolsó helyszín', desc: last.Description || '', locked: !!last.Locked, coords: xy(last.Coords), zone: last.Zone });
		}
		data.forEach((d, i) => {
			if (!d) return;
			items.push({
				id: `d${i + 1}`, index: i + 1, hot: i + 1 <= 9 ? i + 1 : null,
				kind: d.Custom ? 'custom' : 'public', name: d.Name || '', desc: d.Description || '',
				image: d.Image, locked: !!d.Locked, coords: xy(d.Coords), zone: d.Zone,
			});
		});
	}

	const order = () => [
		...items.filter((i) => i.kind === 'last'),
		...items.filter((i) => i.kind === 'public'),
		...items.filter((i) => i.kind === 'custom'),
	];

	function cardHTML(it) {
		const parts = split(it.desc);
		let ph, icon, desc = it.desc, metaL, metaR, tag = '';

		if (it.kind === 'last') {
			icon = 'history';
			ph = `${mapTex(it.coords)}<div class="big"><span>${svg(it.locked ? 'lock' : 'history')}</span></div>`;
			desc = it.locked ? it.desc : 'Ott folytatod, ahol legutóbb kiléptél.';
			metaL = area(it) || 'Ahol kiléptél';
			metaR = it.locked ? '<span class="r">Zárolva</span>' : '<span>Folytatás</span>';
		} else {
			icon = it.kind === 'custom' ? 'star' : (PLACE_ICON[it.image] || 'pin');
			ph = it.locked ? `<div class="lockc">${svg('lock')}</div>` : '';
			if (it.kind === 'custom') {
				tag = it.locked ? `<em class="tag grey">${svg('lock')}Zárolva</em>` : `<em class="tag gold">${svg('star')}Egyedi</em>`;
				if (it.locked) {
					desc = parts ? parts[1].charAt(0).toUpperCase() + parts[1].slice(1) : it.desc;
					metaL = parts ? parts[0] : 'Megvásárolható';
					metaR = '<span>Nincs megvéve</span>';
				} else {
					desc = parts ? parts[0] : it.desc;
					metaL = parts ? parts[1].replace(/ van hátra$/, '') : (area(it) || '');
					metaR = '<span class="g">Saját</span>';
				}
			} else {
				metaL = area(it) || '';
				metaR = '<span>Publikus</span>';
			}
		}

		const bg = it.kind === 'last' ? '' : ` style="background-image:url('${img(it.image)}')"`;
		return `<div class="card ${it.kind}${it.locked ? ' locked' : ''}" data-k="${it.id}">
			<div class="ph"${bg}>${ph}${it.hot ? `<span class="kc">${it.hot}</span>` : ''}${tag}<div class="chk">${svg('check')}</div></div>
			<div class="info">
				<div class="nm"><div class="ci">${svg(icon)}</div><div class="nt">${esc(it.name)}</div></div>
				<div class="ds">${esc(desc)}</div>
				<div class="meta"><span>${esc(metaL)}</span>${metaR}</div>
			</div>
		</div>`;
	}

	function renderRail() {
		const o = order();
		rail.style.setProperty('--n', Math.max(o.length, 1));
		rail.innerHTML = o.map(cardHTML).join('');
	}

	function renderCta() {
		const it = cur();
		if (!it) { cta.innerHTML = ''; return; }
		const parts = split(it.desc);
		let sub, warn = false;
		if (it.kind === 'last') { sub = it.locked ? it.desc : 'Ott folytatod, ahol legutóbb kiléptél'; warn = it.locked; }
		else if (it.kind === 'custom') sub = it.locked ? (parts ? `Megvásárolható: ${parts[1]}` : it.desc) : it.desc;
		else sub = [area(it), it.desc].filter(Boolean).join(' · ');

		const btn = it.locked
			? `<button class="btn off" id="go" aria-disabled="true">${svg('lock')}Nem elérhető</button>`
			: `<button class="btn green" id="go">${svg('login')}Megjelenés<span class="kc">Enter</span></button>`;
		cta.innerHTML = `<div class="ct"><div class="ck">${it.kind === 'last' ? 'Folytatás' : 'Kiválasztva'}</div>
			<div class="cn">${title(it.name)}</div><div class="cs${warn ? ' warn' : ''}">${esc(sub)}</div></div>${btn}`;
	}

	function pickDefault() {
		const o = order();
		return ((o.find((i) => !i.locked) || o[0]) || {}).id || null;
	}

	function select(id, quiet) {
		if (busy || !items.some((i) => i.id === id)) return;
		const changed = id !== sel;
		sel = id;
		rail.querySelectorAll('.card').forEach((c) => c.classList.toggle('on', c.dataset.k === id));
		renderCta();
		if (changed && !quiet) sfx('select');
	}

	function deny() {
		sound('deny');
		const b = $('go');
		if (!b) return;
		b.classList.remove('deny');
		void b.offsetWidth;
		b.classList.add('deny');
	}

	function confirmSpawn() {
		if (busy) return;
		const it = cur();
		if (!it) return;
		if (it.locked) { deny(); return; }
		busy = true;
		chosen = it;
		closeCustom();
		endDrag();
		sfx('select');
		stage.classList.add('leaving');
		setTimeout(() => {
			post('teleport', it.kind === 'last' ? {} : { index: it.index });
			stage.hidden = true;
			stage.classList.remove('leaving');
			clearTimeout(bgTimer);
			bgTimer = setTimeout(hideBg, 4000);
		}, 250);
	}

	function open(m) {
		busy = false;
		chosen = null;
		arrive.hidden = true;
		clearTimeout(bgTimer);
		// bg: "camera" -> élő játékkamera a város fölött (Config.BackgroundCam), a kép nem takarja;
		// minden más (vagy hiányzó mező) -> a NUI háttérképe
		bg.hidden = m.bg === 'camera';
		camMode = m.bg === 'camera';
		stage.classList.toggle('cam', camMode);
		closeCustom();
		loadSettings(m.settings); // a játékos saját méretei/helyei (Lua KVP)
		const data = Array.isArray(m.data) ? m.data : Object.values(m.data || {});
		build(data, m.last);
		renderRail();
		stage.classList.remove('leaving');
		stage.hidden = false;
		sel = null;
		select(pickDefault(), true);
	}

	function showArrive() {
		hideBg();
		const it = chosen;
		arriveSub.innerHTML = it
			? (it.kind === 'last' ? `Folytatás: <b>${esc(it.name)}</b>` : `Érkezés: <b>${esc(it.name)}</b>`)
			: 'Jó játékot!';
		arrive.classList.remove('out');
		arrive.hidden = false;
	}

	function hideArrive() {
		if (arrive.hidden) return;
		arrive.classList.add('out');
		setTimeout(() => { arrive.hidden = true; arrive.classList.remove('out'); }, 400);
	}

	window.addEventListener('message', (e) => {
		const m = e.data || {};
		if (m.action === 'openUI') open(m);
		else if (m.action === 'openwelcome') showArrive();
		else if (m.action === 'closewelcome') hideArrive();
	});

	// ráhúzás-hang: kártyára vagy a gombra érve egyszer szól, amíg az egér rajta marad
	let hoverKey = null;
	const hoverOn = (key) => {
		if (key === hoverKey) return;
		hoverKey = key;
		if (key && !busy && !stage.hidden && !dragging && !editing) sfx('hover');
	};
	rail.addEventListener('mouseover', (e) => { const c = e.target.closest('.card'); hoverOn(c ? `card:${c.dataset.k}` : null); });
	rail.addEventListener('mouseleave', () => { hoverKey = null; });
	cta.addEventListener('mouseover', (e) => { hoverOn(e.target.closest('#go') ? 'go' : null); });
	cta.addEventListener('mouseleave', () => { hoverKey = null; });

	// ---- élő háttér forgatása nyomva tartott egérrel (csak "camera" módban) ----
	// A húzás a városon indul (nem kártyán/gombon); a mozgást ~30/mp csomagban küldjük a Luának,
	// a kamera ott, képkockánként puhán fordul.
	let camMode = false;
	let dragging = false;
	let dragLast = null;
	let dragAcc = { dx: 0, dy: 0, dz: 0 };
	let dragTimer = null;
	const flushDrag = () => {
		dragTimer = null;
		if (!dragAcc.dx && !dragAcc.dy && !dragAcc.dz) return;
		post('camdrag', dragAcc);
		dragAcc = { dx: 0, dy: 0, dz: 0 };
	};
	const onUi = (t) => !!(t.closest && t.closest('.card, .cta, .keys, button, .cust-panel'));
	function endDrag() {
		if (!dragging) return;
		dragging = false;
		stage.classList.remove('dragging');
		clearTimeout(dragTimer);
		flushDrag();
	}

	// ---- Testreszabás: méretek, láthatóság, hangerő és a részek helye (játékosonként, Lua KVP-ben) ----
	const SETTINGS = [
		{ key: 'scale', label: 'Teljes méret', group: 'size', min: 70, max: 130, def: 100 },
		{ key: 'width', label: 'Sáv szélessége', group: 'size', min: 50, max: 100, def: 100 },
		{ key: 'cards', label: 'Kártyák', group: 'size', min: 60, max: 140, def: 100 },
		{ key: 'title', label: 'Cím', group: 'size', min: 40, max: 150, def: 100 },
		{ key: 'text', label: 'Szövegek', group: 'size', min: 80, max: 150, def: 100 },
		{ key: 'cta', label: 'Kiválasztva doboz', group: 'size', min: 70, max: 160, def: 100 },
		{ key: 'hints', label: 'Tippek', group: 'size', min: 60, max: 160, def: 100 },
		{ key: 'showHints', label: 'Billentyű-tippek', type: 'toggle', def: true },
		{ key: 'showSub', label: 'Alcím a cím alatt', type: 'toggle', def: true },
		{ key: 'volume', label: 'Hangerő', min: 0, max: 100, def: 50 },
	];
	const MOVABLE = ['keys', 'hero', 'cta', 'rail'];
	const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
	const defaults = () => {
		const d = {};
		SETTINGS.forEach((o) => { d[o.key] = o.def; });
		MOVABLE.forEach((m) => { d[`${m}X`] = 0; d[`${m}Y`] = 0; });
		return d;
	};
	let ui = defaults();
	let editing = false;
	let moving = null;
	let saveTimer = null;
	const custom = $('custom'), customBody = $('customBody');
	const moveEl = (m) => document.querySelector(`[data-move="${m}"]`);

	function applySettings() {
		const root = document.documentElement;
		root.style.setProperty('--ui-scale', ui.scale / 100);
		root.style.setProperty('--s-width', ui.width / 100);
		root.style.setProperty('--s-cards', ui.cards / 100);
		root.style.setProperty('--s-title', ui.title / 100);
		root.style.setProperty('--s-text', ui.text / 100);
		root.style.setProperty('--s-cta', ui.cta / 100);
		root.style.setProperty('--s-hints', ui.hints / 100);
		root.classList.toggle('no-hints', !ui.showHints);
		root.classList.toggle('no-sub', !ui.showSub);
		sfxVolume = 0.2 * (ui.volume / 100);
		MOVABLE.forEach((m) => {
			const el = moveEl(m);
			if (!el) return;
			el.style.setProperty('--mx', ui[`${m}X`]);
			el.style.setProperty('--my', ui[`${m}Y`]);
		});
	}

	// a Luától kapott (KVP-ből betöltött) beállítások ellenőrizve; ami hiányzik/hibás, az alapérték
	function loadSettings(raw) {
		const d = defaults();
		if (raw && typeof raw === 'object') {
			SETTINGS.forEach((o) => {
				const v = raw[o.key];
				if (o.type === 'toggle') { if (typeof v === 'boolean') d[o.key] = v; }
				else if (typeof v === 'number' && isFinite(v)) d[o.key] = clamp(Math.round(v), o.min, o.max);
			});
			MOVABLE.forEach((m) => ['X', 'Y'].forEach((ax) => {
				const v = raw[m + ax];
				if (typeof v === 'number' && isFinite(v)) d[m + ax] = clamp(v, -1, 1);
			}));
		}
		ui = d;
		applySettings();
	}

	const scheduleSave = () => {
		clearTimeout(saveTimer);
		saveTimer = setTimeout(() => post('saveSettings', ui), 400);
	};

	// a csúszka kitöltött része (--p) az aktuális értékig
	const fill = (o) => `${((ui[o.key] - o.min) / (o.max - o.min)) * 100}%`;

	// tömör sorok: név | csúszka | érték (a kapcsolóknál a sor bárhol kattintható)
	function renderCustom() {
		const row = (o) => (o.type === 'toggle'
			? `<label class="c-row c-tog"><span class="c-l">${esc(o.label)}</span><span class="switch"><input type="checkbox" data-k="${o.key}"${ui[o.key] ? ' checked' : ''}><span class="sl"></span></span></label>`
			: `<div class="c-row c-sl"><span class="c-l" title="${esc(o.label)}">${esc(o.label)}</span><input type="range" min="${o.min}" max="${o.max}" step="1" value="${ui[o.key]}" data-k="${o.key}" style="--p:${fill(o)}"><span class="c-v" data-v="${o.key}">${ui[o.key]}%</span></div>`);
		customBody.innerHTML = `<div class="c-sec">Méretek</div>${SETTINGS.filter((o) => o.group === 'size').map(row).join('')}`
			+ `<div class="c-sec">Egyéb</div>${SETTINGS.filter((o) => o.group !== 'size').map(row).join('')}`
			+ `<div class="c-row c-pos" title="Nyitott panelnél a kék keretes részek egérrel húzhatók"><span class="c-l">Részek helye</span><button class="btn ghost" type="button" data-act="resetPos">${svg('reset')}Eredeti hely</button></div>`;
	}

	function openCustom() {
		if (busy || stage.hidden) return;
		endDrag();
		renderCustom();
		custom.hidden = false;
		editing = true;
		stage.classList.add('editing');
	}

	function closeCustom() {
		if (!editing && custom.hidden) return;
		custom.hidden = true;
		editing = false;
		stage.classList.remove('editing');
		if (moving) { moving = null; stage.classList.remove('moving'); scheduleSave(); }
	}

	$('customBtn').addEventListener('click', () => (editing ? closeCustom() : openCustom()));
	$('customClose').addEventListener('click', closeCustom);
	$('customDone').addEventListener('click', closeCustom);
	$('customReset').addEventListener('click', () => {
		ui = defaults();
		applySettings();
		renderCustom();
		scheduleSave();
	});
	customBody.addEventListener('input', (e) => {
		const t = e.target;
		const o = t.dataset && SETTINGS.find((x) => x.key === t.dataset.k);
		if (!o) return;
		ui[o.key] = o.type === 'toggle' ? t.checked : clamp(Math.round(+t.value), o.min, o.max);
		const pill = customBody.querySelector(`[data-v="${o.key}"]`);
		if (pill) pill.textContent = `${ui[o.key]}%`;
		if (o.type !== 'toggle') t.style.setProperty('--p', fill(o));
		applySettings();
		if (o.key === 'volume') sfx('select');
		scheduleSave();
	});
	// a panel a fejlécénél fogva áthúzható (ne takarja azt, amit épp mozgatni akarnak); a helye nem mentődik
	let panelMove = null;
	custom.querySelector('.c-head').addEventListener('mousedown', (e) => {
		if (e.button !== 0 || e.target.closest('.c-close')) return;
		const r = custom.getBoundingClientRect();
		panelMove = {
			x0: e.clientX, y0: e.clientY, left: r.left, top: r.top, w: r.width,
			px: parseFloat(custom.style.getPropertyValue('--px')) || 0,
			py: parseFloat(custom.style.getPropertyValue('--py')) || 0,
		};
		e.preventDefault();
		e.stopPropagation();
	});
	customBody.addEventListener('click', (e) => {
		if (!e.target.closest('[data-act="resetPos"]')) return;
		MOVABLE.forEach((m) => { ui[`${m}X`] = 0; ui[`${m}Y`] = 0; });
		applySettings();
		scheduleSave();
	});

	stage.addEventListener('mousedown', (e) => {
		if (busy || e.button !== 0) return;
		// szerkesztő módban a kék keretes rész megfogható és áthúzható
		if (editing) {
			const blk = e.target.closest('[data-move]');
			if (blk && !e.target.closest('.cust-panel')) {
				const r = blk.getBoundingClientRect();
				const m = blk.dataset.move;
				moving = { m, x0: e.clientX, y0: e.clientY, bx: ui[`${m}X`], by: ui[`${m}Y`], cx: r.left + r.width / 2, cy: r.top + r.height / 2 };
				stage.classList.add('moving');
				e.preventDefault();
				return;
			}
		}
		if (!camMode || onUi(e.target)) return;
		dragging = true;
		dragLast = { x: e.clientX, y: e.clientY };
		stage.classList.add('dragging');
		e.preventDefault();
	});
	window.addEventListener('mousemove', (e) => {
		if (panelMove) {
			// a fejléc mindig a képernyőn marad
			const W = window.innerWidth, H = window.innerHeight;
			const dx = clamp(e.clientX - panelMove.x0, 80 - panelMove.left - panelMove.w, W - 80 - panelMove.left);
			const dy = clamp(e.clientY - panelMove.y0, -panelMove.top, H - 60 - panelMove.top);
			custom.style.setProperty('--px', `${panelMove.px + dx}px`);
			custom.style.setProperty('--py', `${panelMove.py + dy}px`);
			return;
		}
		if (moving) {
			// a rész közepe a képernyőn belül marad
			const W = window.innerWidth, H = window.innerHeight;
			const dx = clamp(e.clientX - moving.x0, -moving.cx, W - moving.cx);
			const dy = clamp(e.clientY - moving.y0, -moving.cy, H - moving.cy);
			ui[`${moving.m}X`] = clamp(moving.bx + dx / W, -1, 1);
			ui[`${moving.m}Y`] = clamp(moving.by + dy / H, -1, 1);
			const el = moveEl(moving.m);
			el.style.setProperty('--mx', ui[`${moving.m}X`]);
			el.style.setProperty('--my', ui[`${moving.m}Y`]);
			return;
		}
		if (!dragging) return;
		dragAcc.dx += e.clientX - dragLast.x;
		dragAcc.dy += e.clientY - dragLast.y;
		dragLast = { x: e.clientX, y: e.clientY };
		if (!dragTimer) dragTimer = setTimeout(flushDrag, 33);
	});
	const endAll = () => {
		panelMove = null;
		if (moving) { moving = null; stage.classList.remove('moving'); scheduleSave(); }
		endDrag();
	};
	window.addEventListener('mouseup', endAll);
	window.addEventListener('blur', endAll);
	// görgő: előre-hátra (a kép közepe felé / attól távolodva); a panel fölött a panel görög
	stage.addEventListener('wheel', (e) => {
		if (!camMode || busy || e.target.closest('.cust-panel')) return;
		let d = e.deltaY;
		if (e.deltaMode === 1) d *= 33;
		else if (e.deltaMode === 2) d *= 100;
		dragAcc.dz += d;
		if (!dragTimer) dragTimer = setTimeout(flushDrag, 33);
		e.preventDefault();
	}, { passive: false });

	rail.addEventListener('click', (e) => { if (editing) return; const c = e.target.closest('.card'); if (c) select(c.dataset.k); });
	rail.addEventListener('dblclick', (e) => { if (editing) return; const c = e.target.closest('.card'); if (c) { select(c.dataset.k); confirmSpawn(); } });
	cta.addEventListener('click', (e) => { if (editing) return; if (e.target.closest('#go')) confirmSpawn(); });

	document.addEventListener('keydown', (e) => {
		if (stage.hidden || busy) return;
		if (editing) {
			if (e.key === 'Escape') { closeCustom(); e.preventDefault(); }
			return;
		}
		const o = order().map((i) => i.id);
		const i = o.indexOf(sel);
		if (e.key === 'ArrowRight' || e.key === 'ArrowDown') { select(o[(i + 1) % o.length]); e.preventDefault(); }
		else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') { select(o[(i - 1 + o.length) % o.length]); e.preventDefault(); }
		else if (e.key === 'Enter') { confirmSpawn(); e.preventDefault(); }
		else if (/^[1-9]$/.test(e.key)) { const it = items.find((x) => x.hot === +e.key); if (it) select(it.id); }
	});

	post('loaded');
})();
