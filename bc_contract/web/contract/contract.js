/* bc_contract — papír szerződés-panel (gépjármű-átruházás).
 *
 * A React adminpanel mellett, ugyanabban a NUI-oldalban fut, attól függetlenül:
 *   be:  { action: 'bcc:open', data: { mode: 'seller' | 'buyer', doc: {...} } }
 *        { action: 'bcc:close' }
 *   ki:  POST bccSubmit  seller: { reason, bank, pp, exchange: [plate], signature }
 *                        buyer:  { accepted: true, signature }
 *        POST bccCancel  {}
 * A Lua oldal (client/main.lua) mindkét callback után maga zárja a panelt és veszi le a fókuszt.
 */
(function () {
	'use strict';

	var RES = typeof window.GetParentResourceName === 'function' ? window.GetParentResourceName() : 'bc_contract';
	var BASE = document.currentScript && document.currentScript.src ? document.currentScript.src.replace(/[^\/]*$/, '') : '';

	var SIG_W = 600;
	var SIG_H = 160;
	var MAX_BANK = 10000000000;

	var MONTHS = ['január', 'február', 'március', 'április', 'május', 'június', 'július', 'augusztus', 'szeptember', 'október', 'november', 'december'];

	// ------------------------------------------------------------ helpers

	function esc(s) {
		return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
			return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
		});
	}

	function num(n) {
		var s = String(Math.max(0, Math.floor(Number(n) || 0)));
		return s.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
	}

	function toInt(v) {
		var digits = String(v == null ? '' : v).replace(/\D/g, '');
		return digits ? Number(digits) : 0;
	}

	function pad2(n) { return n < 10 ? '0' + n : String(n); }

	function longDate(d) { return d.getFullYear() + '. ' + MONTHS[d.getMonth()] + ' ' + d.getDate() + '.'; }
	function shortDate(d) { return d.getFullYear() + '. ' + pad2(d.getMonth() + 1) + '. ' + pad2(d.getDate()) + '.'; }

	function post(name, body) {
		return fetch('https://' + RES + '/' + name, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json; charset=UTF-8' },
			body: JSON.stringify(body || {})
		}).catch(function () { /* NUI callback nem válaszolt — a Lua oldal zár */ });
	}

	// ------------------------------------------------------------ artwork

	var CREST =
		'<svg viewBox="0 0 48 56" aria-hidden="true">' +
		'<path d="M24 2 44 9v17c0 14-9 23-20 28C13 49 4 40 4 26V9z" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linejoin="round"/>' +
		'<path d="M24 7.5 39 13v13c0 10.6-6.8 18-15 22-8.2-4-15-11.4-15-22V13z" fill="none" stroke="currentColor" stroke-width="1"/>' +
		'<text x="24" y="33" text-anchor="middle" font-family="Georgia,\'Times New Roman\',serif" font-size="15" font-weight="700" fill="currentColor">BC</text>' +
		'</svg>';

	var SEAL =
		'<svg viewBox="0 0 120 120" aria-hidden="true">' +
		'<defs><path id="bccSealArc" d="M60 60m-45 0a45 45 0 1 1 90 0a45 45 0 1 1-90 0"/></defs>' +
		'<circle cx="60" cy="60" r="57" fill="none" stroke="currentColor" stroke-width="3"/>' +
		'<circle cx="60" cy="60" r="52" fill="none" stroke="currentColor" stroke-width="1"/>' +
		'<circle cx="60" cy="60" r="33" fill="none" stroke="currentColor" stroke-width="1.2"/>' +
		'<text font-family="\'Courier New\',monospace" font-size="10" font-weight="700" letter-spacing="1.6" fill="currentColor">' +
		'<textPath href="#bccSealArc">BC VÁROSA • JÁRMŰNYILVÁNTARTÁS •</textPath></text>' +
		'<text x="60" y="61" text-anchor="middle" font-family="Georgia,\'Times New Roman\',serif" font-size="21" font-weight="700" fill="currentColor">BC</text>' +
		'<text x="60" y="76" text-anchor="middle" font-family="\'Courier New\',monospace" font-size="7.4" font-weight="700" letter-spacing="1.2" fill="currentColor">HITELES</text>' +
		'</svg>';

	// ------------------------------------------------------------ signature geometry

	function smoothPath(stroke) {
		if (!stroke.length) return '';
		var d = 'M' + stroke[0][0] + ' ' + stroke[0][1];
		if (stroke.length === 1) return d + 'l.1 .1';
		for (var i = 1; i < stroke.length - 1; i++) {
			var mx = (stroke[i][0] + stroke[i + 1][0]) / 2;
			var my = (stroke[i][1] + stroke[i + 1][1]) / 2;
			d += 'Q' + stroke[i][0] + ' ' + stroke[i][1] + ' ' + mx + ' ' + my;
		}
		var z = stroke[stroke.length - 1];
		return d + 'L' + z[0] + ' ' + z[1];
	}

	function traceStroke(ctx, stroke) {
		if (!stroke.length) return;
		ctx.beginPath();
		ctx.moveTo(stroke[0][0], stroke[0][1]);
		if (stroke.length === 1) ctx.lineTo(stroke[0][0] + 0.1, stroke[0][1] + 0.1);
		for (var i = 1; i < stroke.length - 1; i++) {
			ctx.quadraticCurveTo(stroke[i][0], stroke[i][1], (stroke[i][0] + stroke[i + 1][0]) / 2, (stroke[i][1] + stroke[i + 1][1]) / 2);
		}
		if (stroke.length > 1) {
			var z = stroke[stroke.length - 1];
			ctx.lineTo(z[0], z[1]);
		}
		ctx.stroke();
	}

	/** A szerverről jövő aláírás (a másik fél rajza) — csak számokat enged át. */
	function signatureSvg(strokes) {
		if (!Array.isArray(strokes) || !strokes.length) return '';
		var paths = '';
		for (var i = 0; i < strokes.length && i < 16; i++) {
			var s = strokes[i];
			if (!Array.isArray(s)) continue;
			var clean = [];
			for (var j = 0; j < s.length && j < 300; j++) {
				var p = s[j];
				if (!Array.isArray(p)) continue;
				var x = Number(p[0]), y = Number(p[1]);
				if (isFinite(x) && isFinite(y)) clean.push([Math.round(x), Math.round(y)]);
			}
			if (clean.length) paths += '<path d="' + smoothPath(clean) + '"/>';
		}
		if (!paths) return '';
		return '<svg viewBox="0 0 ' + SIG_W + ' ' + SIG_H + '" preserveAspectRatio="none" aria-hidden="true">' +
			'<g fill="none" stroke="#1c3d78" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">' + paths + '</g></svg>';
	}

	function SignaturePad(host, onChange) {
		var canvas = host.querySelector('canvas');
		var ctx = canvas.getContext('2d');
		var strokes = [];
		var current = null;
		var pointer = null;

		function draw() {
			ctx.setTransform(1, 0, 0, 1, 0, 0);
			ctx.clearRect(0, 0, canvas.width, canvas.height);
			ctx.setTransform(canvas.width / SIG_W, 0, 0, canvas.height / SIG_H, 0, 0);
			ctx.lineCap = 'round';
			ctx.lineJoin = 'round';
			ctx.strokeStyle = '#1c3d78';
			ctx.lineWidth = 3;
			for (var i = 0; i < strokes.length; i++) traceStroke(ctx, strokes[i]);
		}

		function fit() {
			var r = host.getBoundingClientRect();
			var dpr = window.devicePixelRatio || 1;
			canvas.width = Math.max(1, Math.round(r.width * dpr));
			canvas.height = Math.max(1, Math.round(r.height * dpr));
			draw();
		}

		function at(e) {
			var r = canvas.getBoundingClientRect();
			return [
				Math.max(0, Math.min(SIG_W, (e.clientX - r.left) / r.width * SIG_W)),
				Math.max(0, Math.min(SIG_H, (e.clientY - r.top) / r.height * SIG_H))
			];
		}

		canvas.addEventListener('pointerdown', function (e) {
			if (e.button !== 0) return;
			e.preventDefault();
			pointer = e.pointerId;
			try { canvas.setPointerCapture(pointer); } catch (err) { /* szintetikus esemény */ }
			current = [at(e)];
			strokes.push(current);
			host.classList.add('inked');
			host.classList.remove('bad');
			draw();
			onChange();
		});

		canvas.addEventListener('pointermove', function (e) {
			if (!current || e.pointerId !== pointer) return;
			var p = at(e);
			var last = current[current.length - 1];
			if (Math.abs(p[0] - last[0]) + Math.abs(p[1] - last[1]) < 2) return;
			current.push(p);
			draw();
		});

		function end() {
			if (!current) return;
			current = null;
			pointer = null;
			onChange();
		}
		canvas.addEventListener('pointerup', end);
		canvas.addEventListener('pointercancel', end);
		canvas.addEventListener('lostpointercapture', end);

		return {
			fit: fit,
			clear: function () {
				strokes = [];
				host.classList.remove('inked');
				draw();
				onChange();
			},
			/** Elég "tinta" ahhoz, hogy aláírásnak számítson (egy pötty vagy egy vonás nem az). */
			isSigned: function () {
				var length = 0, points = 0;
				for (var i = 0; i < strokes.length; i++) {
					var s = strokes[i];
					points += s.length;
					for (var j = 1; j < s.length; j++) length += Math.hypot(s[j][0] - s[j - 1][0], s[j][1] - s[j - 1][1]);
				}
				return length >= 140 && points >= 12;
			},
			/** Egész koordináták, ritkítva, max. 16 vonás / 600 pont — a szerver is ezt a keretet ellenőrzi. */
			exportStrokes: function () {
				var out = [], total = 0;
				for (var i = 0; i < strokes.length && out.length < 16 && total < 600; i++) {
					var s = strokes[i], kept = [];
					for (var j = 0; j < s.length && total < 600; j++) {
						var x = Math.round(s[j][0]), y = Math.round(s[j][1]);
						var prev = kept[kept.length - 1];
						if (prev && Math.abs(prev[0] - x) + Math.abs(prev[1] - y) < 4 && j !== s.length - 1) continue;
						kept.push([x, y]);
						total++;
					}
					if (kept.length > 1) out.push(kept);
				}
				return out;
			}
		};
	}

	// ------------------------------------------------------------ document parts

	function header(doc, stampText) {
		var now = new Date();
		var ref = 'JNY-' + pad2(now.getMonth() + 1) + pad2(now.getDate()) + '/' + String(doc.plate || '').replace(/\s+/g, '');
		return '' +
			'<div class="bcc-stamp" id="bcc-stamp">' + esc(stampText) + '</div>' +
			'<div class="bcc-head">' +
				'<div class="bcc-issuer">' +
					'<div class="bcc-crest">' + CREST + '</div>' +
					'<div><div class="bcc-city">BC Városa</div>' +
					'<div class="bcc-office">Járműnyilvántartó Hivatal</div></div>' +
				'</div>' +
				'<div class="bcc-meta">' +
					'<div><span>Nyomtatvány:</span> <b>JNY-07</b></div>' +
					'<div><span>Azonosító:</span> <b>' + esc(ref) + '</b></div>' +
					'<div><span>Kelt:</span> <b>' + esc(shortDate(now)) + '</b></div>' +
				'</div>' +
			'</div>' +
			'<h1 class="bcc-title">GÉPJÁRMŰ-ÁTRUHÁZÁSI SZERZŐDÉS</h1>' +
			'<div class="bcc-title-sub">a BC Városa által előírt, kötelezően megkötendő formanyomtatvány</div>';
	}

	function section(n, title) {
		return '<div class="bcc-sec"><span class="n">' + n + '.</span><span>' + esc(title) + '</span></div>';
	}

	function subjectTable(doc) {
		return '' +
			'<table class="bcc-table"><tbody>' +
				'<tr><th>Rendszám</th><td class="strong">' + esc(doc.plate) + '</td><th>Típus</th><td>' + esc(doc.model || '—') + '</td></tr>' +
				'<tr><th>Eladó</th><td>' + esc(doc.sellerName) + '</td><th>Vevő</th><td>' + esc(doc.buyerName) + '</td></tr>' +
			'</tbody></table>';
	}

	function rules(mode) {
		var items = mode === 'seller'
			? [
				'Az Eladó kijelenti, hogy a jármű a kizárólagos tulajdonában áll, per-, teher- és igénymentes, nem frakciós és nem bérelt jármű.',
				'A Vevő a jármű állapotát megismerte, azt a szerződés aláírásakor fennálló állapotában veszi át.',
				'A felek tudomásul veszik, hogy az átruházást a BC Városa adminisztrátorai felülvizsgálhatják; valótlan adatok megadása vagy jogosulatlan átruházás szankciót von maga után.',
				'A szerződés a Vevő aláírásával jön létre: az ellenérték ekkor kerül levonásra, a tulajdonjog a nyilvántartásba vétellel száll át.'
			]
			: [
				'A Vevő kijelenti, hogy a jármű állapotát megismerte, és azt a jelen állapotában veszi át.',
				'A Vevő tudomásul veszi, hogy aláírásával a fenti ellenérték azonnal levonásra kerül; cserejármű esetén annak tulajdonjoga az Eladóra száll.',
				'A felek tudomásul veszik, hogy az átruházást a BC Városa adminisztrátorai felülvizsgálhatják; valótlan adatok megadása vagy jogosulatlan átruházás szankciót von maga után.',
				'BC Városa rendelete értelmében gépjármű tulajdonjoga kizárólag e szerződés megkötésével ruházható át; aláírás nélküli megállapodás érvénytelen.'
			];
		return '<ol class="bcc-rules">' + items.map(function (t) { return '<li>' + esc(t) + '</li>'; }).join('') + '</ol>';
	}

	function livePad() {
		return '<div class="bcc-pad live" id="bcc-pad"><canvas></canvas>' +
			'<span class="ph">Írd alá itt, az egérrel</span>' +
			'<button type="button" class="clr" id="bcc-clear">Törlés</button></div>';
	}

	function signatures(doc, mode) {
		var seller = mode === 'seller'
			? livePad()
			: '<div class="bcc-pad signed">' + (signatureSvg(doc.signature) || '<span class="script">' + esc(doc.sellerName) + '</span>') + '</div>';
		var buyer = mode === 'buyer'
			? livePad()
			: '<div class="bcc-pad waiting"><span class="ph">a Vevő aláírására vár</span></div>';
		return '' +
			'<div class="bcc-dated">Kelt: Los Santos, <b>' + esc(longDate(new Date())) + '</b></div>' +
			'<div class="bcc-signs">' +
				'<div class="bcc-sign">' + seller + '<div class="nm">' + esc(doc.sellerName) + '</div><div class="lb">Eladó (átruházó) aláírása</div></div>' +
				'<div class="bcc-seal">' + SEAL + '</div>' +
				'<div class="bcc-sign">' + buyer + '<div class="nm">' + esc(doc.buyerName) + '</div><div class="lb">Vevő (átvevő) aláírása</div></div>' +
			'</div>';
	}

	function actionBar(cancelLabel, cancelClass, okLabel) {
		return '' +
			'<div class="bcc-actions">' +
				'<button type="button" class="bcc-btn ghost ' + cancelClass + '" id="bcc-cancel">' + esc(cancelLabel) + '</button>' +
				'<button type="button" class="bcc-btn ok" id="bcc-ok">' +
					'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.83 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"/></svg>' +
					esc(okLabel) +
				'</button>' +
			'</div>';
	}

	function sellerDocument(doc) {
		var ex = Array.isArray(doc.exchange) ? doc.exchange : [];
		var exchange = '';
		if (ex.length) {
			exchange = '<div class="bcc-subhead">A Vevő által cserébe adott járművek <span>(nem kötelező)</span></div><div class="bcc-checks" id="bcc-checks">' +
				ex.map(function (v) {
					var dist = v.dist != null ? ' · ' + String(v.dist).replace('.', ',') + ' m' : '';
					return '<label class="bcc-check"><input type="checkbox" data-plate="' + esc(v.plate) + '"><span class="bx"></span>' +
						'<span class="t"><b>' + esc(v.plate) + '</b> ' + esc(v.model || '') + esc(dist) + '</span>' +
						(v.hardHandling ? '<span class="bcc-warn">ERŐS HANDLING</span>' : '') + '</label>';
				}).join('') + '</div>';
		}

		return header(doc, 'KITÖLTÉSRE VÁR') +
			'<p class="bcc-text">Amely létrejött egyrészről <b>' + esc(doc.sellerName) + '</b> mint átruházó (a továbbiakban: <b>Eladó</b>), ' +
			'másrészről <b>' + esc(doc.buyerName) + '</b> mint átvevő (a továbbiakban: <b>Vevő</b>) között, az alulírott napon, az alábbi feltételekkel. ' +
			'BC Városa rendelete értelmében gépjármű tulajdonjoga kizárólag e szerződéssel, mindkét fél aláírásával ruházható át — szerződés nélkül a jármű a nyilvántartásban nem írható át.</p>' +

			section(1, 'A szerződés tárgya') + subjectTable(doc) +

			section(2, 'Az átruházás indoka') +
			'<div class="bcc-field" id="bcc-f-reason"><input id="bcc-reason" type="text" maxlength="200" autocomplete="off" spellcheck="false" placeholder="pl. Eladás, ' + esc(doc.plate) + ', sima"></div>' +
			'<div class="bcc-hint">Írd le az átadás indokát, a rendszámot, és hogy az autó <b>egyedi</b>, <b>limitált</b> vagy <b>sima</b> — ebből győződik meg az adminisztrátor arról, hogy az átadás jogos.</div>' +

			section(3, 'Ellenérték') +
			'<div class="bcc-money">' +
				'<div class="bcc-field" id="bcc-f-bank"><label for="bcc-bank">Vételár, bankból:</label><input id="bcc-bank" type="text" inputmode="numeric" autocomplete="off" placeholder="0"><span class="u">$</span></div>' +
				'<div class="bcc-field" id="bcc-f-pp"><label for="bcc-pp">Vételár, PP-ben:</label><input id="bcc-pp" type="text" inputmode="numeric" autocomplete="off" placeholder="0"><span class="u">PP</span></div>' +
			'</div>' +
			'<div class="bcc-hint">A banki összeget a Vevő bankszámlájáról vonjuk le. <b>Figyelem:</b> a PP összegből 5% adó kerül levonásra. Hagyd üresen, amelyik formában nem fizet.</div>' +
			exchange +

			section(4, 'Nyilatkozatok') + rules('seller') +

			'<div class="bcc-error" id="bcc-error"></div>' +
			signatures(doc, 'seller') +
			'<div class="bcc-note">Az Eladó aláírása után a szerződés a Vevőhöz kerül aláírásra. A tulajdonjog a Vevő aláírásával és a nyilvántartásba vétellel száll át.</div>' +
			actionBar('Mégse', '', 'Aláírom és átküldöm a Vevőnek');
	}

	function buyerDocument(doc) {
		var ex = Array.isArray(doc.exchange) ? doc.exchange : [];
		var bank = Math.max(0, Number(doc.bank) || 0);
		var pp = Math.max(0, Number(doc.pp) || 0);
		var hard = ex.some(function (v) { return v && v.hardHandling; });

		var parts = [];
		if (bank > 0) parts.push(num(bank) + ' $');
		if (pp > 0) parts.push(num(pp) + ' PP');
		var total = parts.length ? parts.join(' + ') : (ex.length ? 'csak cserejármű' : 'ingyenes');

		var exchangeRow = ex.length
			? '<tr><th>Cserébe adod</th><td colspan="3">' + ex.map(function (v) {
				return '<div class="bcc-exrow"><b>' + esc(v.plate) + '</b> ' + esc(v.model || '') + (v.hardHandling ? '<span class="bcc-warn">ERŐS HANDLING</span>' : '') + '</div>';
			}).join('') + '</td></tr>'
			: '';

		return header(doc, 'ALÁÍRÁSRA VÁR') +
			'<div class="bcc-lead"><b>' + esc(doc.sellerName) + '</b> a jelen szerződéssel átruházza rád, <b>' + esc(doc.buyerName) + '</b>, a(z) ' +
			'<span class="bcc-plate">' + esc(doc.plate) + '</span> rendszámú <b>' + esc(doc.model || 'gépjármű') + '</b> gépjárművet.</div>' +
			'<p class="bcc-text">A szerződés BC Városa rendelete szerint kötelezően megkötendő: a jármű tulajdonjoga kizárólag akkor írható át a nevedre, ' +
			'ha a szerződést aláírod. Aláírás előtt ellenőrizd a jármű adatait és az ellenértéket — az aláírással a lent rögzített feltételeket elfogadod.</p>' +

			section(1, 'A szerződés tárgya') + subjectTable(doc) +

			section(2, 'Az átruházás indoka') +
			'<div class="bcc-written">' + esc(doc.reason || '—') + '</div>' +

			section(3, 'Ellenérték') +
			'<table class="bcc-table"><tbody>' +
				'<tr><th>Fizetendő, bankból</th><td class="' + (bank > 0 ? 'strong' : 'dim') + '">' + (bank > 0 ? esc(num(bank)) + ' $' : '—') + '</td>' +
				'<th>Fizetendő, PP-ben</th><td class="' + (pp > 0 ? 'strong' : 'dim') + '">' + (pp > 0 ? esc(num(pp)) + ' PP' : '—') + '</td></tr>' +
				exchangeRow +
				'<tr class="total"><th>Összesen</th><td colspan="3">' + esc(total) + '</td></tr>' +
			'</tbody></table>' +
			(hard ? '<div class="bcc-decl"><b>ERŐS HANDLING</b> jármű szerepel a cserében — a szerződés adminisztrátori jóváhagyásra szorul, az átírás csak a jóváhagyás után történik meg.</div>' : '') +

			section(4, 'Nyilatkozatok') + rules('buyer') +

			'<div class="bcc-error" id="bcc-error"></div>' +
			signatures(doc, 'buyer') +
			'<div class="bcc-note">Az ellenérték az aláírás pillanatában kerül levonásra. Ha nem értesz egyet a feltételekkel, utasítsd el a szerződést.</div>' +
			actionBar('Elutasítom', 'decline', 'Aláírom és megkötöm a szerződést');
	}

	// ------------------------------------------------------------ controller

	var root = null;
	var state = null;

	function $(id) { return document.getElementById(id); }

	function mount() {
		if (root) return;
		var css = document.createElement('link');
		css.rel = 'stylesheet';
		css.href = BASE + 'contract.css';
		document.head.appendChild(css);

		var font = document.createElement('link');
		font.rel = 'stylesheet';
		font.href = 'https://fonts.googleapis.com/css2?family=Titillium+Web:wght@600;700&display=swap';
		document.head.appendChild(font);

		root = document.createElement('div');
		root.className = 'bcc-view';
		root.hidden = true;
		root.addEventListener('change', function (e) {
			if (state && e.target && e.target.matches && e.target.matches('.bcc-check input')) setError('');
		});
		document.body.appendChild(root);
	}

	function setError(message, fieldId) {
		var box = $('bcc-error');
		if (box) box.textContent = message || '';
		var nodes = root.querySelectorAll('.bad');
		for (var i = 0; i < nodes.length; i++) nodes[i].classList.remove('bad');
		if (!fieldId) return;
		var field = $(fieldId);
		if (!field) return;
		field.classList.add('bad');
		field.classList.remove('bcc-shake');
		void field.offsetWidth;
		field.classList.add('bcc-shake');
		field.scrollIntoView({ block: 'center', behavior: 'smooth' });
	}

	function finish(payload) {
		if (!state || state.sending) return;
		state.sending = true;
		var stamp = $('bcc-stamp');
		if (stamp) {
			stamp.textContent = 'ALÁÍRVA';
			stamp.classList.add('done');
		}
		$('bcc-ok').disabled = true;
		$('bcc-cancel').disabled = true;
		post('bccSubmit', payload);
	}

	function cancel() {
		if (!state || state.sending) return;
		state.sending = true;
		post('bccCancel', {});
		close();
	}

	function bindSeller(pad) {
		var reason = $('bcc-reason');
		var bank = $('bcc-bank');
		var pp = $('bcc-pp');

		function money(input) {
			input.addEventListener('input', function () {
				var digits = input.value.replace(/\D/g, '').replace(/^0+(?=\d)/, '').slice(0, 11);
				input.value = digits ? num(digits) : '';
				setError('');
			});
		}
		money(bank);
		money(pp);
		reason.addEventListener('input', function () { setError(''); });

		$('bcc-ok').addEventListener('click', function () {
			var text = reason.value.trim();
			if (text.length < 4) {
				reason.focus();
				return setError('Az átruházás indokát kötelező kitölteni (legalább 4 karakter).', 'bcc-f-reason');
			}
			var bankValue = toInt(bank.value);
			var ppValue = toInt(pp.value);
			if (bankValue > MAX_BANK) return setError('A banki vételár legfeljebb 10.000.000.000 $ lehet.', 'bcc-f-bank');

			var plates = [];
			var boxes = root.querySelectorAll('.bcc-check input:checked');
			for (var i = 0; i < boxes.length; i++) plates.push(boxes[i].getAttribute('data-plate'));

			if (bankValue <= 0 && ppValue <= 0 && plates.length === 0) {
				return setError('Adj meg legalább egy összeget ($ vagy PP) vagy cserejárművet!', 'bcc-f-bank');
			}
			if (!pad.isSigned()) return setError('A szerződést alá kell írnod, mielőtt átküldöd a Vevőnek.', 'bcc-pad');

			finish({ reason: text, bank: bankValue, pp: ppValue, exchange: plates, signature: pad.exportStrokes() });
		});

		setTimeout(function () { reason.focus(); }, 80);
	}

	function bindBuyer(pad) {
		$('bcc-ok').addEventListener('click', function () {
			if (!pad.isSigned()) return setError('A szerződés megkötéséhez alá kell írnod.', 'bcc-pad');
			finish({ accepted: true, signature: pad.exportStrokes() });
		});
	}

	function open(data) {
		mount();
		var mode = data && data.mode === 'buyer' ? 'buyer' : 'seller';
		var doc = (data && data.doc) || {};

		state = { mode: mode, sending: false };
		root.innerHTML = '<div class="bcc-paper" role="dialog" aria-modal="true">' + (mode === 'buyer' ? buyerDocument(doc) : sellerDocument(doc)) + '</div>';
		root.hidden = false;

		var pad = SignaturePad($('bcc-pad'), function () { setError(''); });
		state.pad = pad;
		$('bcc-clear').addEventListener('click', function () { pad.clear(); });
		$('bcc-cancel').addEventListener('click', cancel);

		var paper = root.firstChild;
		paper.addEventListener('animationend', function () { pad.fit(); });
		requestAnimationFrame(function () { pad.fit(); });

		if (mode === 'seller') bindSeller(pad); else bindBuyer(pad);
	}

	function close() {
		state = null;
		if (!root) return;
		root.hidden = true;
		root.innerHTML = '';
	}

	window.addEventListener('message', function (e) {
		var msg = e.data;
		if (!msg || typeof msg !== 'object') return;
		if (msg.action === 'bcc:open') open(msg.data);
		else if (msg.action === 'bcc:close') close();
	});

	// Nyitott szerződésnél az ESC a szerződést utasítja el, és NEM jut el a React panel
	// kilépés-figyelőjéhez (az a closePanel callbackkel levenné a fókuszt a papír alól).
	function swallowEscape(e) {
		if (!state || (e.key !== 'Escape' && e.code !== 'Escape')) return;
		e.preventDefault();
		e.stopImmediatePropagation();
		if (e.type === 'keyup') cancel();
	}
	window.addEventListener('keydown', swallowEscape, true);
	window.addEventListener('keyup', swallowEscape, true);

	window.addEventListener('resize', function () { if (state && state.pad) state.pad.fit(); });

	if (document.body) mount();
	else document.addEventListener('DOMContentLoaded', mount);
})();
