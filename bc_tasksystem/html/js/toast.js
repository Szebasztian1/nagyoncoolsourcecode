/* bc_tasksystem — unlock popups. At most three on screen, the rest wait
   their turn. Nothing animates once the stack is empty, and the audio context
   sleeps between two sounds. */

(function (A) {
	'use strict';

	const MAX_VISIBLE = 3;
	const BURST_WINDOW = 150;   // ms; the window a burst of popups is collected in
	const MERGE_FROM = 3;       // cards of one stat in that window: one or two stay separate,
	                            // three or more would flood the screen, so those share a card
	const queue = [];
	let visible = 0;
	let burst = null;           // popups of the current window, not queued yet

	function ringSvg() {
		return '<svg class="ring" viewBox="0 0 40 40"><circle class="track" cx="20" cy="20" r="18.5"/>'
			+ '<circle class="fill" cx="20" cy="20" r="18.5" pathLength="100"/></svg>';
	}

	// A merged card names the highest goal and counts the rest: "19 teljesítmény feloldva".
	function unlockMarkup(def, item) {
		const first = item.firsts > 0;
		let eyebrow = first ? 'Szerver-első teljesítmény!' : 'Teljesítmény feloldva';
		if (item.count > 1) {
			eyebrow = first ? `${item.count} teljesítmény · ${item.firsts} szerver-első` : `${item.count} teljesítmény feloldva`;
		}

		return {
			cls: `t-${def.tier}${first ? ' is-first' : ''}`,
			html: `
				<div class="ic">${ringSvg()}<div class="core">${A.icon('trophy')}</div>${first ? `<div class="badge">${A.icon('crown')}</div>` : ''}</div>
				<div class="tx">
					<div class="k">${eyebrow}</div>
					<div class="t">${A.esc(def.title)}</div>
					<div class="d">${A.esc(def.desc)}</div>
				</div>
				<div class="pts-col"><div class="pts">+${A.num(item.points)} pont</div>${item.reward > 0 ? `<div class="pts cash">+${A.num(item.reward)} $</div>` : ''}</div>
				<div class="sheen"></div>`,
		};
	}

	// Another player's server first (crown) or legendary unlock (trophy in the tier colour).
	function newsMarkup(def, item) {
		const tier = A.tier(def.tier);
		const more = item.count > 1 ? ` és még ${item.count - 1}` : '';
		return {
			cls: item.first ? 't-legend' : `t-${def.tier}`,
			html: `
				<div class="ic">${ringSvg()}<div class="core">${A.icon(item.first ? 'crown' : 'trophy')}</div></div>
				<div class="tx">
					<div class="k">${item.first ? `Szerver-első · ${A.esc(tier.label)}` : `${A.esc(tier.label)} teljesítmény`}</div>
					<div class="t">${A.esc(item.name || 'Valaki')}</div>
					<div class="d">${item.first ? 'elsőként teljesítette' : 'feloldotta'}: ${A.esc(def.title)}${more}</div>
				</div>
				<div class="sheen"></div>`,
		};
	}

	function render(item) {
		const def = A.byId[item.id];
		if (!def) return false;

		const view = item.kind === 'news' ? newsMarkup(def, item) : unlockMarkup(def, item);
		const el = document.createElement('div');
		el.className = 'toast ' + view.cls;
		el.innerHTML = view.html;
		A.$('toasts').appendChild(el);
		visible++;
		if (item.kind === 'unlock') playSound();

		const duration = (A.catalog.toast && A.catalog.toast.duration) || 6500;
		setTimeout(() => {
			el.classList.add('out');
			setTimeout(() => {
				el.remove();
				visible--;
				pump();
			}, 380);
		}, duration);
		return true;
	}

	function pump() {
		while (visible < MAX_VISIBLE && queue.length) {
			render(queue.shift());
		}
	}

	// A flood of one stat at once (a deposit that crosses several rungs of the bank ladder, the
	// first login after install) makes one card: the highest goal, the count, the summed points.
	function burstKey(item, def) {
		if (!def.stat) return null;
		return item.kind === 'news' ? `news:${item.name}:${def.stat}` : `unlock:${def.stat}`;
	}

	function absorb(into, item, def) {
		into.count += item.count;
		into.points += item.points;
		into.reward += item.reward;
		into.firsts += item.firsts;
		if (def.goal > A.byId[into.id].goal) {
			into.id = item.id;
			into.first = item.first;
		}
	}

	function flushBurst() {
		const items = burst;
		burst = null;

		// How many cards of each stat the window holds. Below MERGE_FROM every unlock keeps its
		// own card; from there up the group shares one, or the screen would fill with them.
		const sizes = {};
		items.forEach((item) => {
			if (item.key) sizes[item.key] = (sizes[item.key] || 0) + 1;
		});

		const merged = {};
		items.forEach((item) => {
			if (item.key && sizes[item.key] >= MERGE_FROM) {
				const into = merged[item.key];
				if (into) return absorb(into, item, A.byId[item.id]);
				merged[item.key] = item;
			}

			// Someone else's unlock is news, not a reward: it never pushes the queue past ten.
			if (item.kind === 'news' && queue.length >= 10) return;
			queue.push(item);
		});

		pump();
	}

	A.showToast = function (data) {
		const def = A.byId[data.id];
		if (!def) return;

		const first = data.first === true;
		const item = {
			kind: data.kind === 'news' ? 'news' : 'unlock',
			id: def.id,
			name: data.name,
			first,
			count: 1,
			points: A.tier(def.tier).points,
			reward: Number(data.reward) || 0,   // dollars the server pays for it (0: grant, paid before, news)
			firsts: first ? 1 : 0,
		};
		item.key = burstKey(item, def);

		// A card of the same stat that is still queued takes the newcomer in -- only the queue is
		// searched, because inside the current window the flush decides: two unlocks arriving
		// together stay two cards, stacked under each other.
		const waiting = item.key && queue.find((other) => other.key === item.key);
		if (waiting) {
			absorb(waiting, item, def);
			return;
		}

		if (!burst) {
			burst = [];
			setTimeout(flushBurst, BURST_WINDOW);
		}
		burst.push(item);
	};

	// Sound -------------------------------------------------------------------------------------
	// Read into memory once: the NUI file scheme answers no range requests, and a media element
	// whose stream stalls goes silent without any event. Web Audio plays the decoded buffer.

	const SOUND_GAP = 1200;   // ms; popups appearing together play one sound
	let sound = null;
	let lastSoundAt = -Infinity;

	A.loadSound = function (config) {
		if (sound || !config || !config.file) return;

		const volume = Number(config.volume);
		const xhr = new XMLHttpRequest();
		xhr.open('GET', config.file);
		xhr.responseType = 'arraybuffer';
		xhr.onload = () => {
			// The NUI scheme answers a missing file with an empty body, not with a 404.
			if (!xhr.response || !xhr.response.byteLength) {
				console.warn(`[bc_tasksystem] sound file not found: ${config.file}`);
				return;
			}

			const ctx = new AudioContext();
			ctx.decodeAudioData(xhr.response)
				.then((buffer) => {
					sound = { ctx, buffer, volume: Number.isFinite(volume) ? Math.min(Math.max(volume, 0), 1) : 1 };
					return ctx.suspend();
				})
				.catch(() => {
					console.warn(`[bc_tasksystem] sound file could not be decoded: ${config.file}`);
					ctx.close();
				});
		};
		xhr.send();
	};

	function playSound() {
		if (!sound || !sound.volume) return;

		const now = performance.now();
		if (now - lastSoundAt < SOUND_GAP) return;
		lastSoundAt = now;

		const { ctx, buffer, volume } = sound;
		const source = ctx.createBufferSource();
		const gain = ctx.createGain();
		source.buffer = buffer;
		gain.gain.value = volume;
		source.connect(gain);
		gain.connect(ctx.destination);
		// Sleep again unless a newer sound started meanwhile.
		source.onended = () => {
			if (performance.now() - lastSoundAt >= buffer.duration * 1000) ctx.suspend();
		};
		ctx.resume().then(() => source.start());
	}

	// Notice ------------------------------------------------------------------------------------
	// A bc_notyp notice is up in the top-centre slot. Its card is rebuilt unseen in #notice-probe,
	// and the popups stand below the measured bottom edge until the card has slid away.

	const NOTICE_EXIT = 500;   // ms bc_notyp's exit animation runs after the notice time
	const NOTICE_GAP = 12;     // px between the notice and the first popup
	let notice = null;

	function placeBelowNotice() {
		const box = A.$('toasts');
		if (!notice) {
			box.style.removeProperty('--below-notice');
			return;
		}

		const probe = A.$('notice-probe');
		probe.querySelector('.title').textContent = notice.title;
		probe.querySelector('.message').textContent = notice.message;
		const bottom = probe.querySelector('.card').getBoundingClientRect().bottom;
		box.style.setProperty('--below-notice', Math.ceil(bottom + NOTICE_GAP) + 'px');
	}

	// The aty_hud VIP EXP bar borrows the very top band for ~6 s on an XP gain;
	// bc_notyp slides its notice down to the second band for that time, so the
	// probe has to move with it or the popups would sit too high.
	let bandTimer = null;

	A.onNoticeBand = function (data) {
		const probe = A.$('notice-probe');
		if (!probe) return;

		probe.classList.add('shifted');
		clearTimeout(bandTimer);
		bandTimer = setTimeout(() => {
			probe.classList.remove('shifted');
			placeBelowNotice();
		}, Number(data && data.time) || 6300);

		placeBelowNotice();
	};

	A.onNotice = function (data) {
		if (notice) clearTimeout(notice.timer);

		notice = { title: String(data.title || ''), message: String(data.message || '') };
		placeBelowNotice();
		// A font face still on its way would change the line breaks; measure again once it is in.
		document.fonts.ready.then(placeBelowNotice);

		const current = notice;
		current.timer = setTimeout(() => {
			if (notice !== current) return;
			notice = null;
			placeBelowNotice();
		}, (Number(data.duration) || 0) + NOTICE_EXIT);
	};
})(window.Ach);
