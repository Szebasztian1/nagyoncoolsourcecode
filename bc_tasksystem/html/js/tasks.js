/* bc_tasksystem — the task pages of the BC Küldetések panel: daily, weekly and permanent tasks,
   their progress and the reward claim. client/client.lua sends fresh rows on every open. */

(function (A) {
	'use strict';

	// `type` is the taskType the Lua "claim" callback expects.
	const TABS = [
		{ page: 'daily',     type: 'DailyTasks',     loc: 'ui_daily_tasks',     icon: 'sun' },
		{ page: 'weekly',    type: 'WeeklyTasks',    loc: 'ui_weekly_tasks',    icon: 'calendarWeek' },
		{ page: 'permanent', type: 'PermanentTasks', loc: 'ui_permanent_tasks', icon: 'star' },
	];

	// Used until the "data" callback answers, and for any key it leaves out.
	const DEFAULT_LOCALES = {
		ui_menu_name: 'Küldetések',
		ui_daily_tasks: 'Napi küldetések',
		ui_weekly_tasks: 'Heti küldetések',
		ui_permanent_tasks: 'Örökös küldetések',
		ui_reward: 'Jutalom',
	};

	const lists = { daily: [], weekly: [], permanent: [] };
	const pending = {};   // [type:id] = a claim is on its way
	let locales = Object.assign({}, DEFAULT_LOCALES);
	let localesAsked = false;

	const num = (v) => { const n = Number(v); return Number.isFinite(n) ? n : 0; };

	// Dot thousands separators on every digit run of 4+ digits: $50000 -> $50.000, 1 stays 1.
	const groupDigits = (s) => String(s).replace(/\d{4,}/g, (d) => d.replace(/\B(?=(\d{3})+(?!\d))/g, '.'));

	const isClaimable = (t) => !t.claimed && num(t.completed) >= num(t.required);
	const isDone = (t) => !!t.claimed || num(t.completed) >= num(t.required);
	const shownCount = (t) => Math.min(Math.max(num(t.completed), 0), num(t.required));
	const progress = (t) => (num(t.required) > 0 ? shownCount(t) / num(t.required) : 1);

	/*
	 * The reward arrives as one Lua-built string, e.g. "Craft Segítő darab: 1 Pénz: $50000 "
	 * or a custom label like "600 PP + 6.000.000 $". Split it into "label: amount" chips only
	 * when those parts account for the whole string; anything else stays one chip, verbatim.
	 */
	const REWARD_PART = /[^:]+?:\s*\$?[\d.,]+/g;
	function rewardChips(raw) {
		const text = String(raw == null ? '' : raw).trim();
		if (!text) return [];
		const parts = text.match(REWARD_PART);
		if (parts && text.replace(REWARD_PART, '').trim() === '') {
			const chips = parts.map((p) => {
				const i = p.indexOf(':');
				return { k: p.slice(0, i).trim(), v: groupDigits(p.slice(i + 1).trim().replace(/[.,]+$/, '')) };
			});
			if (chips.every((c) => c.k && c.v)) return chips;
		}
		return [{ k: '', v: groupDigits(text) }];
	}

	/*
	 * Lua fills the arrays with pairs(), so the incoming order is random. Claimable first,
	 * then in-progress by progress (highest first), claimed last; ties by name. The order is
	 * fixed when the panel opens, so a row never jumps away from under the cursor on claim.
	 */
	function prepare(list) {
		const arr = Array.isArray(list) ? list.slice() : (list && typeof list === 'object' ? Object.values(list) : []);
		const rank = (t) => (isClaimable(t) ? 0 : t.claimed ? 2 : 1);
		return arr
			.filter((t) => t && typeof t === 'object')
			.sort((a, b) =>
				rank(a) - rank(b) ||
				(rank(a) === 1 ? progress(b) - progress(a) : 0) ||
				String(a.name || '').localeCompare(String(b.name || ''), 'hu'));
	}

	function statsOf(tab) {
		const list = lists[tab.page];
		const done = list.filter(isDone).length;
		return {
			count: list.length,
			done,
			claimable: list.filter(isClaimable).length,
			claimed: list.filter((t) => !!t.claimed).length,
			pct: list.length ? Math.round((done / list.length) * 100) : 0,
		};
	}

	const titleOf = (tab) => locales[tab.loc] || DEFAULT_LOCALES[tab.loc];

	// "Napi küldetések" -> "NAPI <b>KÜLDETÉSEK</b>"
	function headline(title) {
		const upper = String(title).toLocaleUpperCase('hu');
		const space = upper.indexOf(' ');
		return space < 0 ? `<b>${A.esc(upper)}</b>` : `${A.esc(upper.slice(0, space))} <b>${A.esc(upper.slice(space + 1))}</b>`;
	}

	// Chrome ------------------------------------------------------------------------------------

	function renderNav() {
		TABS.forEach((tab) => {
			const s = statsOf(tab);
			A.$(`nav-${tab.page}-t`).textContent = titleOf(tab);
			A.$(`nav-${tab.page}-d`).textContent = `${s.count} küldetés · ${s.done} kész`;
			const badge = A.$(`cnt-${tab.page}`);
			badge.hidden = s.claimable === 0;
			badge.textContent = s.claimable;
			badge.title = `${s.claimable} átvehető jutalom`;
		});
	}

	function renderChrome() {
		const totals = TABS.map(statsOf).reduce((sum, s) => ({
			count: sum.count + s.count, done: sum.done + s.done, claimable: sum.claimable + s.claimable, claimed: sum.claimed + s.claimed,
		}), { count: 0, done: 0, claimable: 0, claimed: 0 });

		A.$('plate').classList.toggle('idle', totals.claimable === 0);
		A.$('plate-text').textContent = totals.claimable > 0 ? `${totals.claimable} átvehető jutalom` : 'Nincs átvehető jutalom';
		A.$('t-total').textContent = totals.count;
		A.$('t-done').textContent = totals.done;
		A.$('t-claimed').textContent = totals.claimed;
		const claimable = A.$('t-claimable');
		claimable.textContent = totals.claimable;
		claimable.className = totals.claimable > 0 ? 'badge ok' : '';
	}

	// Page ----------------------------------------------------------------------------------------

	function rowMarkup(tab, task) {
		const state = task.claimed ? 'got' : (isClaimable(task) ? 'can' : 'run');
		const required = num(task.required);
		const shown = shownCount(task);
		const ratio = progress(task);
		const full = ratio >= 1;
		const busy = !!pending[`${tab.type}:${task.id}`];
		const chips = rewardChips(task.reward);

		let action;
		if (state === 'can') {
			action = `<button type="button" class="btn green" data-claim="${A.esc(task.id)}"${busy ? ' disabled' : ''}><span class="bi">${A.icon('gift')}</span>Átvétel</button>`;
		} else if (state === 'got') {
			action = `<span class="got-pill"><span class="bi">${A.icon('check')}</span>Átvéve</span>`;
		} else {
			action = `<span class="left">Még <b>${groupDigits(Math.max(required - shown, 0))}</b> van hátra</span>`;
		}

		return `<div class="box task is-${state}" data-task="${A.esc(task.id)}">
			<div class="si">${A.icon(state === 'can' ? 'gift' : state === 'got' ? 'circleCheck' : 'target')}</div>
			<div class="tc">
				<div class="tn">${A.esc(task.name)}</div>
				${task.description ? `<div class="tdsc">${A.esc(task.description)}</div>` : ''}
				${chips.length ? `<div class="rw"><span class="rk">${A.esc(locales.ui_reward)}</span>${chips.map((chip) =>
					`<span class="tag${chip.k ? '' : ' raw'}">${chip.k ? `<span class="tk">${A.esc(chip.k)}:</span>` : ''}<b>${A.esc(chip.v)}</b></span>`).join('')}</div>` : ''}
			</div>
			<div class="tp">
				<div class="tph"><span class="tpl">Haladás</span><span class="rv${full ? ' ok' : ''}">${groupDigits(shown)} / ${groupDigits(required)}</span></div>
				<div class="track"><i class="${full ? 'full' : ''}" style="width:${(Math.round(ratio * 1000) / 10)}%"></i></div>
				<div class="act">${action}</div>
			</div>
		</div>`;
	}

	function render(tab) {
		const s = statsOf(tab);
		const list = lists[tab.page];
		document.querySelectorAll('[data-menu-name]').forEach((el) => { el.textContent = locales.ui_menu_name; });
		A.$(`ttl-${tab.page}`).innerHTML = headline(titleOf(tab));

		A.$(`t-${tab.page}`).innerHTML = list.length ? `
			<div class="box sum">
				<div class="st"><b>${s.done}</b> / ${s.count} teljesítve</div>
				<div class="track"><i style="width:${s.pct}%"></i></div>
				<div class="pc">${s.pct}%</div>
			</div>
			<div class="tasks">${list.map((task) => rowMarkup(tab, task)).join('')}</div>`
			: `<div class="box"><div class="empty">${A.icon('inbox')}<div>Ebben a kategóriában most nincs küldetés.</div></div></div>`;
	}

	// The whole row claims too, the button is just the obvious target.
	async function claim(tab, id) {
		const task = lists[tab.page].find((t) => String(t.id) === id);
		if (!task || !isClaimable(task)) return;

		const key = `${tab.type}:${task.id}`;
		if (pending[key]) return;
		pending[key] = true;
		render(tab);

		const result = await A.post('claim', { taskId: task.id, taskType: tab.type });
		delete pending[key];
		if (result && result.success) task.claimed = true;

		renderNav();
		renderChrome();
		render(tab);
	}

	async function loadLocales() {
		localesAsked = true;
		const data = await A.post('data');
		const loc = data && data.locales;
		if (!loc || typeof loc !== 'object') return;

		const merged = Object.assign({}, DEFAULT_LOCALES);
		Object.keys(loc).forEach((k) => {
			if (typeof loc[k] === 'string' && loc[k].trim() !== '') merged[k] = loc[k];
		});
		locales = merged;
		A.$('menu-title').textContent = String(locales.ui_menu_name).toLocaleUpperCase('hu');
		renderNav();
	}

	A.setTasks = function (data) {
		TABS.forEach((tab) => { lists[tab.page] = prepare(data && data[tab.page]); });
		renderNav();
		if (!localesAsked) loadLocales();
	};

	TABS.forEach((tab) => {
		A.registerPage(tab.page, { group: 'tasks', icon: tab.icon, chrome: renderChrome, render: () => render(tab) });

		A.$(`t-${tab.page}`).addEventListener('click', (e) => {
			const row = e.target.closest('[data-task]');
			if (row) claim(tab, row.dataset.task);
		});
	});
})(window.Ach);
