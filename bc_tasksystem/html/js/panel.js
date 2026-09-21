/* bc_tasksystem — the BC Küldetések panel: navigation, the task pages' frame (js/tasks.js fills
   them) and the achievement pages: overview, list, landmark map, leaderboard and stats. Every
   open brings one fresh server view; the achievement pages wait while it is still loading. */

(function (A) {
	'use strict';

	// Crop of the 8192x8192 road map that html/img/map.webp was cut from, and the
	// world -> map pixel transform verified on that image.
	const MAP = { sx: 1350, sy: 450, sw: 5200, sh: 7500 };
	const project = (x, y) => ({
		l: ((0.66304 * x + 3753.6) - MAP.sx) / MAP.sw * 100,
		t: ((-0.656 * y + 5529.6) - MAP.sy) / MAP.sh * 100,
	});

	const RENDERERS = {};
	const PAGES = {};   // [page] = { group: 'tasks' | 'achievements', icon, render, chrome? }
	const filter = { category: 'all', status: 'all', q: '', sort: 'default' };

	let view = null;    // the achievement view; null while the server still loads it
	let open = false;
	let page = 'daily';

	A.registerPage = (name, def) => { PAGES[name] = def; };
	let leaderboard = null;
	let leaderboardAt = 0;

	A.isPanelOpen = () => open;

	// Helpers ------------------------------------------------------------------------

	const asObject = (value) => (value && !Array.isArray(value)) ? value : Object.assign({}, value);
	const asList = (value) => Array.isArray(value) ? value : Object.values(value || {});
	const countKeys = (value) => Object.keys(value || {}).length;
	const fold = (text) => String(text || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');

	function normalise(data) {
		data.unlocked = asObject(data.unlocked);
		data.firsts = asObject(data.firsts);
		data.stats = asObject(data.stats);
		data.landmarks = asList(data.landmarks);
		data.secrets = asList(data.secrets);
		data.global = data.global || {};
		data.global.holders = asObject(data.global.holders);
		data.global.firsts = asObject(data.global.firsts);
		data.points = Number(data.points) || 0;
		data.earned = Number(data.earned) || 0;   // dollars paid for achievements so far
		return data;
	}

	const isUnlocked = (def) => !!view.unlocked[def.id];

	function progressOf(def) {
		const unlocked = isUnlocked(def);
		if (def.stat) {
			const value = Number(view.stats[def.stat]) || 0;
			return { value, goal: def.goal, ratio: unlocked ? 1 : Math.min(value / def.goal, 1) };
		}
		return { value: unlocked ? 1 : 0, goal: 1, ratio: unlocked ? 1 : 0 };
	}

	function rarityOf(def) {
		const players = Number(view.global.players) || 0;
		const holders = Number(view.global.holders[def.id]) || 0;
		return players > 0 ? Math.min(holders / players * 100, 100) : 0;
	}

	function rarityLabel(def) {
		const holders = Number(view.global.holders[def.id]) || 0;
		if (holders === 0) return 'Még senki sem szerezte meg';
		const pct = rarityOf(def);
		return `A játékosok ${pct < 0.1 ? '<0,1' : A.num1(pct)}%-a`;
	}

	function statusOf(def) {
		if (isUnlocked(def)) return 'unlocked';
		return progressOf(def).ratio > 0 ? 'progress' : 'locked';
	}

	const emptyNote = (text, icon) => `<div class="empty">${A.icon(icon || 'sparkles')}<div>${A.esc(text)}</div></div>`;

	// Chrome -------------------------------------------------------------------------

	function renderChrome() {
		const defs = A.catalog.achievements;
		const done = defs.filter(isUnlocked).length;
		const pct = defs.length ? Math.round(done / defs.length * 100) : 0;

		A.$('plate').classList.remove('idle');
		A.$('plate-text').textContent = `${done} / ${defs.length} · ${pct}%`;
		A.$('i-earned').textContent = A.num(view.earned) + ' $';
		A.$('i-points').textContent = A.num(view.points);
		A.$('i-count').textContent = `${done} / ${defs.length}`;
		A.$('i-firsts').textContent = A.num(countKeys(view.firsts));
		A.$('nav-list-d').textContent = `Mind a ${defs.length} kihívás`;
	}

	// Overview -----------------------------------------------------------------------

	const tile = (icon, value, label, cls) => `
		<div class="tile${cls ? ' ' + cls : ''}">
			<div class="ti">${A.icon(icon)}</div>
			<div style="min-width:0"><div class="tv">${A.esc(value)}</div><div class="tl">${A.esc(label)}</div></div>
		</div>`;

	function miniProgress(def, p) {
		return `<div class="mini t-${def.tier}">
			<div class="mi">${A.icon(def.icon)}</div>
			<div style="min-width:0">
				<div class="mt">${A.esc(def.title)}</div>
				<div class="ms">${A.esc(A.progressText(def.stat, p.value, p.goal))}</div>
				<div class="bar-line mb"><i style="width:${(p.ratio * 100).toFixed(1)}%"></i></div>
			</div>
			<div class="mr">${Math.floor(p.ratio * 100)}%</div>
		</div>`;
	}

	function miniRecent(def) {
		const first = view.firsts[def.id] ? ' · szerver-első' : '';
		return `<div class="mini on t-${def.tier}">
			<div class="mi">${A.icon(def.icon)}</div>
			<div style="min-width:0">
				<div class="mt">${A.esc(def.title)}</div>
				<div class="ms">${A.date(view.unlocked[def.id])} · ${A.esc(A.tier(def.tier).label)}${first}</div>
			</div>
			<div class="mr">+${A.tier(def.tier).points}</div>
		</div>`;
	}

	RENDERERS.overview = function () {
		const defs = A.catalog.achievements;
		const unlocked = defs.filter(isUnlocked);
		const pct = defs.length ? Math.round(unlocked.length / defs.length * 100) : 0;

		A.$('ov-ring').style.setProperty('--p', pct);
		A.$('ov-pct').textContent = pct + '%';
		A.$('ov-count').textContent = `${unlocked.length} / ${defs.length} feloldva`;

		const secrets = defs.filter((d) => d.hidden);
		const rarest = unlocked.slice().sort((a, b) => rarityOf(a) - rarityOf(b))[0];

		A.$('ov-tiles').innerHTML = [
			tile('star', A.num(view.points), 'Pontszám', 'gold'),
			tile('crown', A.num(countKeys(view.firsts)), 'Szerver-első'),
			tile('eye', `${secrets.filter(isUnlocked).length} / ${secrets.length}`, 'Titkos teljesítmény'),
			tile('diamond', rarest ? `${A.num1(rarityOf(rarest))}%` : '—', rarest ? `Legritkább: ${rarest.title}` : 'Legritkább trófeád'),
		].join('');

		const tierIds = Object.keys(A.catalog.tiers).sort((a, b) => A.tier(a).rank - A.tier(b).rank);
		A.$('ov-tiers').innerHTML = tierIds.map((id) => {
			const all = defs.filter((d) => d.tier === id);
			const got = all.filter(isUnlocked).length;
			const ratio = all.length ? got / all.length * 100 : 0;
			return `<div class="tier-row t-${id}">
				<div class="tr-top"><span class="dot"></span><span class="tr-l">${A.esc(A.tier(id).label)}</span><span class="tr-v">${got} / ${all.length}</span></div>
				<div class="bar-line"><i style="width:${ratio.toFixed(1)}%"></i></div>
			</div>`;
		}).join('');

		const near = defs
			.filter((d) => d.stat && !d.hidden && !isUnlocked(d))
			.map((d) => ({ d, p: progressOf(d) }))
			.filter((x) => x.p.ratio > 0)
			.sort((a, b) => b.p.ratio - a.p.ratio)
			.slice(0, 5);
		A.$('ov-near').innerHTML = near.length
			? near.map(({ d, p }) => miniProgress(d, p)).join('')
			: emptyNote('Még nincs folyamatban lévő cél. Indulj el a városba!', 'compass');

		const recent = unlocked.slice().sort((a, b) => view.unlocked[b.id] - view.unlocked[a.id]).slice(0, 5);
		A.$('ov-recent').innerHTML = recent.length
			? recent.map(miniRecent).join('')
			: emptyNote('Még nem oldottál fel semmit.', 'trophy');

		A.$('ov-cats').innerHTML = A.catalog.categories.map((cat) => {
			const all = defs.filter((d) => d.category === cat.id);
			const got = all.filter(isUnlocked).length;
			const ratio = all.length ? got / all.length * 100 : 0;
			return `<div class="cat-row${all.length && got === all.length ? ' done' : ''}" data-cat="${A.esc(cat.id)}">
				<div class="ci">${A.icon(cat.icon)}</div>
				<div style="min-width:0"><div class="cl">${A.esc(cat.label)}</div><div class="cd">${A.esc(cat.desc)}</div></div>
				<div><div class="cv">${got} / ${all.length}</div><div class="bar-line"><i style="width:${ratio.toFixed(1)}%"></i></div></div>
			</div>`;
		}).join('');
	};

	// Achievement list -----------------------------------------------------------------

	const SORTS = {
		default: (a, b) => a.order - b.order,
		progress: (a, b) => (progressOf(b).ratio - progressOf(a).ratio) || (a.order - b.order),
		rarity: (a, b) => (rarityOf(a) - rarityOf(b)) || (a.order - b.order),
		points: (a, b) => (A.tier(b.tier).points - A.tier(a.tier).points) || (a.order - b.order),
		recent: (a, b) => ((view.unlocked[b.id] || 0) - (view.unlocked[a.id] || 0)) || (a.order - b.order),
	};

	function matches(def) {
		if (filter.category !== 'all' && def.category !== filter.category) return false;
		if (filter.status !== 'all' && statusOf(def) !== filter.status) return false;
		if (filter.q) {
			const secret = def.hidden && !isUnlocked(def);
			const haystack = fold(secret ? 'titkos teljesítmény' : `${def.title} ${def.desc}`);
			if (!haystack.includes(filter.q)) return false;
		}
		return true;
	}

	function card(def) {
		const unlocked = isUnlocked(def);
		const secret = def.hidden && !unlocked;
		const tier = A.tier(def.tier);
		const money = A.catalog.rewards ? Number(A.catalog.rewards[def.tier]) || 0 : 0;
		const first = view.global.firsts[def.id];
		const mine = !!view.firsts[def.id];
		const landmark = def.landmark ? A.landmarkById[def.landmark] : null;

		let body;
		if (unlocked) {
			body = `<div class="bar-line"><i style="width:100%"></i></div>
				<div class="meta"><span>Feloldva: <b>${A.date(view.unlocked[def.id])}</b></span>
				<span class="grow${rarityOf(def) < 5 ? ' rare' : ''}">${rarityLabel(def)}</span></div>`;
		} else if (def.stat && !secret) {
			const p = progressOf(def);
			body = `<div class="bar-line"><i style="width:${(p.ratio * 100).toFixed(1)}%"></i></div>
				<div class="meta"><span><b>${A.esc(A.progressText(def.stat, p.value, p.goal))}</b></span>
				<span>${Math.floor(p.ratio * 100)}%</span><span class="grow">${rarityLabel(def)}</span></div>`;
		} else {
			const hint = secret ? 'Rejtett feltétel' : landmark ? 'Még nem jártál itt' : (def.jobs || def.boss) ? 'Munkához kötött' : 'Különleges esemény';
			const route = landmark && !landmark.hidden
				? `<button class="btn ghost route" data-route="${A.esc(landmark.id)}">${A.icon('navigation')}Útvonal</button>`
				: `<span class="grow">${rarityLabel(def)}</span>`;
			body = `<div class="meta"><span>${hint}</span>${route}</div>`;
		}

		const eligible = !def.noFirst && tier.rank >= A.tier(A.catalog.serverFirstTier).rank;
		let firstLine = '';
		if (!secret && first) {
			firstLine = `<div class="first">${A.icon('crown')}<span>Szerver-első: <b>${A.esc(mine ? 'Te' : first.name)}</b> · ${A.date(first.at)}</span></div>`;
		} else if (!secret && eligible) {
			firstLine = `<div class="first open">${A.icon('crown')}<span>A szerver-első hely még szabad</span></div>`;
		}

		return `<div class="ach t-${def.tier}${unlocked ? ' on' : ''}${secret ? ' secret' : ''}" data-id="${A.esc(def.id)}">
			<div class="ai">${A.icon(secret ? 'lock' : def.icon)}${unlocked ? `<span class="chk">${A.icon('check')}</span>` : ''}</div>
			<div class="ab">
				<div class="top"><div class="tt">${A.esc(secret ? 'Titkos teljesítmény' : def.title)}</div><span class="tier-chip">${A.esc(tier.label)} · ${tier.points}${money ? ' · ' + A.num(money) + ' $' : ''}</span></div>
				<div class="dd">${A.esc(secret ? 'Teljesítsd, és kiderül, mi rejtőzött mögötte.' : def.desc)}</div>
				${body}
				${firstLine}
			</div>
		</div>`;
	}

	function renderChips() {
		const defs = A.catalog.achievements;
		const chip = (id, label, icon, all) => `<div class="chip${filter.category === id ? ' on' : ''}" data-cat="${A.esc(id)}">
			${A.icon(icon)}<span>${A.esc(label)}</span><span class="cn">${all.filter(isUnlocked).length}/${all.length}</span></div>`;

		A.$('l-cats').innerHTML = [chip('all', 'Mind', 'grid', defs)]
			.concat(A.catalog.categories.map((cat) => chip(cat.id, cat.label, cat.icon, defs.filter((d) => d.category === cat.id))))
			.join('');
	}

	RENDERERS.list = function () {
		renderChips();
		document.querySelectorAll('#l-status button').forEach((b) => b.classList.toggle('on', b.dataset.status === filter.status));
		A.$('l-sort').value = filter.sort;

		const cat = A.categoryById[filter.category];
		if (cat) {
			const all = A.catalog.achievements.filter((d) => d.category === cat.id);
			A.$('l-eyebrow').textContent = cat.desc;
			A.$('l-title').innerHTML = `${A.esc(cat.label.toUpperCase())} <b>${all.filter(isUnlocked).length}/${all.length}</b>`;
		} else {
			A.$('l-eyebrow').textContent = 'Gyűjtemény';
			A.$('l-title').innerHTML = 'MINDEN <b>TELJESÍTMÉNY</b>';
		}

		const defs = A.catalog.achievements.filter(matches).sort(SORTS[filter.sort] || SORTS.default);
		A.$('l-grid').innerHTML = defs.map(card).join('');
		A.$('l-empty').hidden = defs.length > 0;
	};

	// Map ----------------------------------------------------------------------------

	RENDERERS.map = function () {
		const known = new Set(view.landmarks);
		const secrets = new Set(view.secrets);
		const isOn = (lm) => lm.hidden ? secrets.has(lm.id) : known.has(lm.id);

		const visible = A.catalog.landmarks.filter((lm) => !lm.hidden);
		const places = A.catalog.landmarks.filter((lm) => !lm.hidden || secrets.has(lm.id));
		const found = visible.filter((lm) => known.has(lm.id)).length;

		A.$('m-count').textContent = `${found} / ${visible.length} felfedezve`;
		A.$('m-bar').style.width = (visible.length ? found / visible.length * 100 : 0).toFixed(1) + '%';

		const here = view.position;
		const pins = places.map((lm) => {
			const pos = project(lm.x, lm.y);
			return `<div class="pin${isOn(lm) ? ' on' : ''}" data-pin="${A.esc(lm.id)}" style="left:${pos.l.toFixed(2)}%;top:${pos.t.toFixed(2)}%">
				${A.icon(isOn(lm) ? 'check' : 'question')}<span class="tip">${A.esc(lm.label)}</span></div>`;
		});
		if (here) {
			const pos = project(here.x, here.y);
			pins.push(`<div class="me" style="left:${pos.l.toFixed(2)}%;top:${pos.t.toFixed(2)}%" title="Itt vagy"></div>`);
		}
		A.$('m-pins').innerHTML = pins.join('');

		const rows = places
			.map((lm) => ({ lm, on: isOn(lm), dist: here ? Math.hypot(lm.x - here.x, lm.y - here.y) : null }))
			.sort((a, b) => (a.on - b.on) || ((a.dist || 0) - (b.dist || 0)));

		A.$('m-list').innerHTML = rows.map(({ lm, on, dist }) => `
			<div class="lm-row${on ? ' on' : ''}" data-lm="${A.esc(lm.id)}">
				<div class="li">${A.icon(on ? 'check' : 'pin')}</div>
				<div style="min-width:0">
					<div class="ll">${A.esc(lm.label)}</div>
					<div class="ls">${on ? 'Felfedezve' : dist !== null ? `${A.formatStat('walk', dist)} távolságra` : 'Még nem jártál itt'}</div>
				</div>
				${on || lm.hidden ? '' : `<button class="btn blue icon" data-route="${A.esc(lm.id)}" title="Útvonal">${A.icon('navigation')}</button>`}
			</div>`).join('');
	};

	function focusLandmark(id, on) {
		document.querySelectorAll(`[data-pin="${id}"],[data-lm="${id}"]`).forEach((el) => el.classList.toggle('focus', on));
	}

	// Leaderboard ----------------------------------------------------------------------

	function renderLeaderboard() {
		const rows = asList(leaderboard.rows);
		const me = leaderboard.me || {};
		const medals = ['gold', 'silver', 'bronze'];

		const pod = (entry, place) => entry ? `
			<div class="pod p${place} t-${medals[place - 1]}${entry.me ? ' me' : ''}">
				<span class="place">#${place}</span>
				<div class="medal">${A.icon(place === 1 ? 'crown' : 'medal')}</div>
				<div class="pn">${A.esc(entry.name)}</div>
				<div class="pp">${A.num(entry.points)}</div>
				<div class="ps">${A.num(entry.unlocked)} feloldva · ${A.num(entry.firsts)} szerver-első</div>
			</div>` : '<div></div>';

		const table = rows.slice(3).map((entry, i) => `
			<div class="lb-row${entry.me ? ' me' : ''}">
				<span class="rk">#${i + 4}</span><span class="nm">${A.esc(entry.name)}</span>
				<span class="pt">${A.num(entry.points)} pont</span><span class="ul">${A.num(entry.unlocked)}</span><span class="fs">${A.num(entry.firsts)}</span>
			</div>`).join('');

		A.$('lb-body').innerHTML = rows.length ? `
			<div class="podium">${pod(rows[1], 2)}${pod(rows[0], 1)}${pod(rows[2], 3)}</div>
			<div class="lb-me">
				<div class="rank">${me.rank ? '#' + A.num(me.rank) : '—'}</div>
				<div><div class="who">${A.esc(me.name || view.name || '')}</div><div class="sub">${A.num(me.points)} pont · ${A.num(me.unlocked)} feloldva · ${A.num(me.firsts)} szerver-első</div></div>
				<div class="upd">Frissítve: ${leaderboard.updatedAt ? A.time(leaderboard.updatedAt) : '—'}</div>
			</div>
			${rows.length > 3 ? `<div class="box">
				<div class="lb-row head-row"><span>Hely</span><span>Játékos</span><span style="text-align:right">Pontszám</span><span style="text-align:right">Feloldva</span><span style="text-align:right">Első</span></div>
				${table}
			</div>` : ''}` : emptyNote('Még üres a toplista. Légy te az első!', 'podium');
	}

	async function loadLeaderboard() {
		if (leaderboard && Date.now() - leaderboardAt < 20000) {
			renderLeaderboard();
			return;
		}

		A.$('lb-body').innerHTML = '<div class="loading"><span class="spin"></span>Toplista betöltése…</div>';
		const data = await A.post('leaderboard');
		if (data && data.rows) {
			leaderboard = data;
			leaderboardAt = Date.now();
		}
		if (!open || page !== 'leaderboard') return;

		if (leaderboard) {
			renderLeaderboard();
		} else {
			A.$('lb-body').innerHTML = emptyNote('A toplista most nem érhető el, próbáld újra pár másodperc múlva.', 'podium');
		}
	}

	RENDERERS.leaderboard = loadLeaderboard;

	// Stats ------------------------------------------------------------------------------

	RENDERERS.stats = function () {
		A.$('st-body').innerHTML = A.catalog.statGroups.map((group) => `
			<div class="box">
				<div class="bh"><div class="bt">${A.icon(group.icon)}${A.esc(group.label)}</div></div>
				<div class="stat-grid">${group.stats.map((key) => {
					const def = A.catalog.stats[key];
					if (!def) return '';
					const value = Number(view.stats[key]) || 0;
					return `<div class="stat${value ? '' : ' zero'}"><div class="sl">${A.esc(def.label)}</div><div class="sv">${A.esc(A.formatStat(key, value))}</div></div>`;
				}).join('')}</div>
			</div>`).join('');
	};

	// Navigation -----------------------------------------------------------------------------

	function renderPage() {
		const def = PAGES[page];
		const waiting = def.group === 'achievements' && !view;
		const shown = waiting ? 'waiting' : page;

		document.querySelectorAll('#page section').forEach((s) => s.classList.toggle('on', s.dataset.page === shown));
		document.querySelectorAll('.info-box[data-group]').forEach((box) => { box.hidden = box.dataset.group !== def.group; });
		A.$('wm').innerHTML = A.icon(def.icon);

		if (waiting) {
			A.$('plate').classList.add('idle');
			A.$('plate-text').textContent = 'Töltődik…';
			return;
		}

		if (def.chrome) def.chrome();
		def.render();
	}

	function showPage(name) {
		if (!PAGES[name]) return;
		page = name;
		document.querySelectorAll('.nav-btn').forEach((b) => b.classList.toggle('on', b.dataset.page === name));
		A.$('page').scrollTop = 0;
		renderPage();
	}

	// data = { view, tasks, page } from achievements/client/panel.lua
	A.openPanel = function (data) {
		view = data.view ? normalise(data.view) : null;
		leaderboard = null;
		if (A.setTasks) A.setTasks(data.tasks);
		open = true;
		A.$('panel').classList.add('show');
		showPage(PAGES[data.page] ? data.page : page);
	};

	A.hidePanel = function () {
		open = false;
		A.$('panel').classList.remove('show');
	};

	A.closePanel = function () {
		A.hidePanel();
		A.post('close');
	};

	// A live unlock while the panel is open: patch the view instead of refetching it.
	A.onUnlocked = function (data) {
		if (!view) return;
		const def = A.byId[data.id];
		if (!def || view.unlocked[def.id]) return;

		view.unlocked[def.id] = data.at;
		view.points += A.tier(def.tier).points;
		view.earned += Number(data.reward) || 0;
		view.stats.unlocks = (Number(view.stats.unlocks) || 0) + 1;
		view.stats.points = view.points;
		view.global.holders[def.id] = (Number(view.global.holders[def.id]) || 0) + 1;
		if (data.first) {
			view.firsts[def.id] = true;
			view.stats.firsts = countKeys(view.firsts);
			view.global.firsts[def.id] = { name: view.name, at: data.at };
		}

		if (!open) return;
		renderPage();
		const el = document.querySelector(`.ach[data-id="${def.id}"]`);
		if (el) el.classList.add('flash');
	};

	// The achievement pages keep the trophy watermark of the former panel.
	['overview', 'list', 'map', 'leaderboard', 'stats'].forEach((name) => {
		A.registerPage(name, { group: 'achievements', icon: 'trophy', chrome: renderChrome, render: () => RENDERERS[name]() });
	});

	A.bindPanel = function () {
		A.$('btn-close').onclick = A.closePanel;

		document.querySelectorAll('.nav-btn').forEach((btn) => {
			btn.onclick = () => showPage(btn.dataset.page);
		});

		A.$('ov-cats').addEventListener('click', (e) => {
			const row = e.target.closest('[data-cat]');
			if (!row) return;
			filter.category = row.dataset.cat;
			filter.status = 'all';
			showPage('list');
		});

		A.$('l-cats').addEventListener('click', (e) => {
			const chip = e.target.closest('[data-cat]');
			if (!chip) return;
			filter.category = chip.dataset.cat;
			RENDERERS.list();
		});

		A.$('l-status').addEventListener('click', (e) => {
			const btn = e.target.closest('[data-status]');
			if (!btn) return;
			filter.status = btn.dataset.status;
			RENDERERS.list();
		});

		A.$('l-q').addEventListener('input', (e) => {
			filter.q = fold(e.target.value.trim());
			RENDERERS.list();
		});

		A.$('l-sort').addEventListener('change', (e) => {
			filter.sort = e.target.value;
			RENDERERS.list();
		});

		A.$('panel').addEventListener('click', (e) => {
			const route = e.target.closest('[data-route]');
			if (route && open) A.post('waypoint', { id: route.dataset.route });
		});

		const hover = (e, on) => {
			const el = e.target.closest('[data-pin],[data-lm]');
			if (el) focusLandmark(el.dataset.pin || el.dataset.lm, on);
		};
		['m-pins', 'm-list'].forEach((id) => {
			A.$(id).addEventListener('mouseover', (e) => hover(e, true));
			A.$(id).addEventListener('mouseout', (e) => hover(e, false));
		});
	};
})(window.Ach);
