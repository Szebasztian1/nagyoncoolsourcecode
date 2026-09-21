/* VIP EXP sav. A bc_vip szervere kuldi a mar kiszamolt szintadatokat
   ("bc_vip:xpadded_hud" -> client/vipxp.lua -> SendNUIMessage {action:'vipxp'}).
   A sav csak XP-szerzeskor latszik, 6 masodpercig. */
(function () {
	var box = null,
		segs = [],
		hideTimer = null,
		settleTimer = null;

	function build() {
		if (box) return;
		box = document.createElement('div');
		box.id = 'bcvipxp';
		/* Egy soros sav, hogy elferjen legfelul: jelveny, csomag + szint, csik,
		   XP, hatralevo XP, es a most kapott XP. */
		box.innerHTML =
			'<div class="vx-badge"><span></span></div>' +
			'<div class="vx-id"><span class="vx-k"></span><span class="vx-t"></span></div>' +
			'<div class="vx-bar"></div>' +
			'<span class="vx-xp"></span>' +
			'<span class="vx-next"></span>' +
			'<span class="vx-gain"></span>';
		var bar = box.querySelector('.vx-bar');
		for (var i = 0; i < 10; i++) {
			var seg = document.createElement('div');
			seg.className = 'vx-seg';
			seg.innerHTML = '<i></i><b></b>';
			bar.appendChild(seg);
			segs.push(seg);
		}
		document.body.appendChild(box);
	}

	function fmt(n) {
		n = Math.round(Number(n) || 0);
		try {
			return n.toLocaleString('hu-HU');
		} catch (err) {
			return String(n);
		}
	}

	function clamp(v, lo, hi) {
		return v < lo ? lo : v > hi ? hi : v;
	}

	/* p = az uj kitoltottseg, old = a szerzes elotti. A kulonbseg vilagoskek marad,
	   majd ~1 masodperc mulva beall a szokasos kekre. */
	function paint(p, old) {
		for (var i = 0; i < segs.length; i++) {
			var a = clamp((p - i * 10) / 10, 0, 1),
				b = clamp((old - i * 10) / 10, 0, 1);
			segs[i].children[0].style.width = a * 100 + '%';
			segs[i].children[1].style.width = b * 100 + '%';
		}
	}

	function show(d) {
		build();

		var level = Number(d.level) || 0,
			maxLevel = Number(d.maxLevel) || 0,
			xp = Number(d.xp) || 0,
			prevXp = Number(d.prevXp) || 0,
			nextXp = Number(d.nextXp) || 0,
			gained = Number(d.gained) || 0,
			maxed = !!d.maxed,
			up = !!d.leveledUp,
			percent = clamp(Number(d.percent) || (maxed ? 100 : 0), 0, 100);

		box.classList.toggle('up', up);
		box.classList.toggle('max', maxed);
		box.querySelector('.vx-badge span').textContent = maxed ? maxLevel || level : level;
		box.querySelector('.vx-k').textContent = d.label || 'VIP';
		box.querySelector('.vx-t').textContent = up
			? level + '. szint elérve'
			: maxed
			? 'Max szint'
			: level + '. szint';
		box.querySelector('.vx-gain').textContent = up ? 'Jutalom: /vip' : '+' + fmt(gained) + ' XP';
		box.querySelector('.vx-xp').textContent = maxed
			? fmt(xp) + ' XP'
			: fmt(xp) + ' / ' + fmt(nextXp) + ' XP';
		box.querySelector('.vx-next').textContent = maxed
			? 'Minden szint elérve'
			: up
			? 'Jutalom átvehető'
			: level + 1 + '. szintig ' + fmt(Math.max(0, nextXp - xp)) + ' XP';

		var oldPercent = percent;
		if (maxed) {
			oldPercent = 100;
		} else if (nextXp > prevXp) {
			var before = xp - gained;
			oldPercent = before > prevXp ? clamp(((before - prevXp) / (nextXp - prevXp)) * 100, 0, 100) : 0;
		}

		paint(percent, oldPercent);
		clearTimeout(settleTimer);
		settleTimer = setTimeout(function () {
			paint(percent, percent);
		}, 900);

		box.classList.add('show');
		clearTimeout(hideTimer);
		hideTimer = setTimeout(function () {
			box.classList.remove('show');
		}, 6000);
	}

	window.addEventListener('message', function (event) {
		var data = (event && event.data) || {};
		if (data.action !== 'vipxp') return;
		try {
			show(data.data || {});
		} catch (err) {
			/* a HUD tobbi resze ne alljon meg egy hibas payloadtol */
		}
	});
})();
