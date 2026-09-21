/* bc_tasksystem — NUI core: helpers, the catalog, number formatting,
   the message router and the bootstrap handshake. */

window.Ach = window.Ach || {};

(function (A) {
	'use strict';

	const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'bc_tasksystem';
	const nf = new Intl.NumberFormat('hu-HU');
	const nf1 = new Intl.NumberFormat('hu-HU', { maximumFractionDigits: 1 });
	const nf2 = new Intl.NumberFormat('hu-HU', { maximumFractionDigits: 2 });

	A.$ = (id) => document.getElementById(id);

	A.esc = function (value) {
		if (value === null || value === undefined) return '';
		return String(value)
			.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
			.replace(/"/g, '&quot;').replace(/'/g, '&#39;');
	};

	A.num = (n) => nf.format(Math.round(Number(n) || 0));
	A.num1 = (n) => nf1.format(Number(n) || 0);

	A.post = async function (name, data) {
		try {
			const res = await fetch(`https://${RES}/${name}`, {
				method: 'POST',
				headers: { 'Content-Type': 'application/json; charset=UTF-8' },
				body: JSON.stringify(data || {}),
			});
			return await res.json().catch(() => null);
		} catch (e) {
			return null;
		}
	};

	// Catalog ------------------------------------------------------------------

	A.catalog = null;
	A.byId = {};
	A.categoryById = {};
	A.landmarkById = {};

	// Lua sends empty tables as {} and arrays as lists; normalise the few that matter.
	const list = (value) => Array.isArray(value) ? value : Object.values(value || {});

	A.setCatalog = function (catalog) {
		catalog.achievements = list(catalog.achievements);
		catalog.categories = list(catalog.categories);
		catalog.landmarks = list(catalog.landmarks);
		catalog.statGroups = list(catalog.statGroups).map((g) => ({ ...g, stats: list(g.stats) }));

		A.catalog = catalog;
		A.byId = {};
		A.categoryById = {};
		A.landmarkById = {};
		catalog.achievements.forEach((def, index) => { def.order = index; A.byId[def.id] = def; });
		catalog.categories.forEach((cat) => { A.categoryById[cat.id] = cat; });
		catalog.landmarks.forEach((lm) => { A.landmarkById[lm.id] = lm; });

		A.$('toasts').className = 'toasts ' + ((catalog.toast && catalog.toast.position) || 'top-center');
		if (A.loadSound) A.loadSound(catalog.toast && catalog.toast.sound);
	};

	A.tier = (id) => (A.catalog && A.catalog.tiers[id]) || { label: id, points: 0, rank: 0 };

	// Formatting ----------------------------------------------------------------

	const FORMAT = {
		distance: (m) => m < 1000 ? `${A.num(m)} m` : `${m < 100000 ? A.num1(m / 1000) : A.num(m / 1000)} km`,
		time: (s) => s < 3600 ? `${A.num(s / 60)} perc` : `${s < 360000 ? A.num1(s / 3600) : A.num(s / 3600)} óra`,
		speed: (v) => `${A.num(v)} km/h`,
		depth: (v) => `${A.num1(v)} m`,
		money: (v) => `$${A.num(v)}`,
		days: (v) => `${A.num(v)} nap`,
		count: (v) => A.num(v),
	};

	A.formatStat = function (key, value) {
		const def = A.catalog.stats[key] || {};
		return (FORMAT[def.format] || FORMAT.count)(Number(value) || 0);
	};

	// Past a million the bank ladder reads in the goal's unit: "0,75 / 1 M $", "1,4 / 2 Mrd $".
	// The value is rounded down, so a rung never looks complete before it is.
	function moneyProgress(value, goal) {
		const unit = goal >= 1e9 ? [1e9, 'Mrd'] : goal >= 1e6 ? [1e6, 'M'] : null;
		if (!unit) return `$${A.num(value)} / $${A.num(goal)}`;
		return `${nf2.format(Math.floor((value / unit[0]) * 100) / 100)} / ${nf2.format(goal / unit[0])} ${unit[1]} $`;
	}

	// "3,2 / 10 km" — both sides in the goal's unit.
	A.progressText = function (key, value, goal) {
		const def = A.catalog.stats[key] || {};
		const v = Math.min(Number(value) || 0, goal);

		switch (def.format) {
			case 'distance':
				return goal >= 1000 ? `${A.num1(v / 1000)} / ${A.num1(goal / 1000)} km` : `${A.num(v)} / ${A.num(goal)} m`;
			case 'time':
				return `${A.num1(v / 3600)} / ${A.num1(goal / 3600)} óra`;
			case 'speed':
				return `${A.num(v)} / ${A.num(goal)} km/h`;
			case 'depth':
				return `${A.num1(v)} / ${A.num(goal)} m`;
			case 'money':
				return moneyProgress(v, goal);
			case 'days':
				return `${A.num(v)} / ${A.num(goal)} nap`;
			default:
				return `${A.num(v)} / ${A.num(goal)}`;
		}
	};

	A.date = function (unix) {
		const d = new Date((Number(unix) || 0) * 1000);
		const pad = (n) => String(n).padStart(2, '0');
		return `${d.getFullYear()}. ${pad(d.getMonth() + 1)}. ${pad(d.getDate())}.`;
	};

	A.time = function (unix) {
		const d = new Date((Number(unix) || 0) * 1000);
		return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
	};

	// Icons in static markup: data-icon replaces, data-icon-before prepends.
	A.hydrateIcons = function (root) {
		root.querySelectorAll('[data-icon]').forEach((el) => {
			el.innerHTML = A.icon(el.dataset.icon);
			el.removeAttribute('data-icon');
		});
		root.querySelectorAll('[data-icon-before]').forEach((el) => {
			el.insertAdjacentHTML('afterbegin', A.icon(el.dataset.iconBefore));
			el.removeAttribute('data-icon-before');
		});
	};

	// Router ---------------------------------------------------------------------

	// Messages that arrive between the client's answer to `ready` and the catalog landing here wait,
	// then run in order.
	const early = [];

	function dispatch(msg) {
		const route = {
			toast:    () => A.showToast(msg.data || {}),
			notice:   () => A.onNotice(msg.data || {}),
			noticeband: () => A.onNoticeBand(msg.data || {}),
			open:     () => A.openPanel(msg.data || {}),
			close:    () => A.hidePanel(),
			unlocked: () => A.onUnlocked(msg.data || {}),
		}[msg.action];

		if (!route) return;
		try {
			route();
		} catch (err) {
			console.error('[bc_tasksystem] ' + msg.action + ': ' + err.message);
		}
	}

	window.addEventListener('message', (ev) => {
		const msg = ev.data || {};
		// 'noticeband' is a 6-second positioning hint: replaying it later from the
		// queue would move the probe at the wrong moment, so it never waits.
		if (!A.catalog && msg.action !== 'close' && msg.action !== 'noticeband') {
			if (early.length < 50) early.push(msg);
			return;
		}
		dispatch(msg);
	});

	document.addEventListener('keydown', (e) => {
		if (e.key === 'Escape' && A.isPanelOpen && A.isPanelOpen()) A.closePanel();
	});

	// Bootstrap --------------------------------------------------------------------

	const wait = (ms) => new Promise((r) => setTimeout(r, ms));

	async function handshake() {
		for (let attempt = 0; attempt < 60 && !A.catalog; attempt++) {
			// A request sent before the client registered the callback may never answer.
			const catalog = await Promise.race([A.post('ready'), wait(2500).then(() => null)]);
			if (catalog && catalog.achievements) {
				A.setCatalog(catalog);
				if (typeof A.bindPanel === 'function') A.bindPanel();
				early.splice(0).forEach(dispatch);
				return;
			}
			await wait(1000);
		}
	}

	function boot() {
		A.hydrateIcons(document);
		handshake();
	}

	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', () => setTimeout(boot, 0));
	} else {
		setTimeout(boot, 0);
	}
})(window.Ach);
