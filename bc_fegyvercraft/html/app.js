/* ============================================================
   Fegyvercraft NUI logic.
   Receives `open` / `update` from the client, renders the three
   panels (jobs, ingredients, workshop) and posts back `action`
   / `close`. Every action is re-validated server side; the UI
   only decides what to offer.

   Rendering is split so nothing rebuilds needlessly:
     renderList()   -> job list
     renderDetail() -> result + ingredients of the selection
     renderSide()   -> the action column
   ============================================================ */
(function () {
	"use strict";

	var RES = typeof GetParentResourceName === "function" ? GetParentResourceName() : "bc_fegyvercraft";

	var stage = document.getElementById("stage");
	var elWho = document.getElementById("who");
	var elCount = document.getElementById("count");
	var elList = document.getElementById("list");
	var elResult = document.getElementById("result");
	var elIngs = document.getElementById("ings");
	var elIngSub = document.getElementById("ingsub");
	var elSide = document.getElementById("side");
	var elToast = document.getElementById("toast");

	// Where item images live. ox_inventory ships .webp, so that goes first —
	// .png is only a fallback for items that were added by hand.
	var ICON_BASE = "nui://ox_inventory/web/images/";
	var ICON_EXTS = [".webp", ".png"];

	var entries = [];
	var sel = null;   // key of the selected entry
	var pid = "";     // typed player id, kept across re-renders
	var qty = 1;      // how many of the selected pickup stack to collect
	var confirmKey = null;
	var confirmTimer = null;
	var toastTimer = null;

	// items whose image failed for every extension — never requested again
	var badIcons = {};

	var GROUPS = [
		{ kind: "own", title: "Saját fegyverek" },
		{ kind: "help", title: "Segítői megbízások" },
		{ kind: "pickup", title: "Átvételre vár" }
	];

	/* ---------- helpers ---------- */

	function post(name, body) {
		return fetch("https://" + RES + "/" + name, {
			method: "POST",
			headers: { "Content-Type": "application/json; charset=UTF-8" },
			body: JSON.stringify(body || {})
		}).catch(function () { });
	}

	function esc(s) {
		return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
			return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
		});
	}

	// Lua sends an empty table as {}, so length checks need a guard.
	function arr(v) {
		return Array.isArray(v) ? v : [];
	}

	function num(n) {
		return Number(n || 0).toLocaleString("hu-HU");
	}

	/** Millions collapse to "1,45M" so a money row still fits one line. */
	function short(n) {
		n = Number(n || 0);

		if (n < 1000000) return num(n);

		var m = n / 1000000;
		return num(m >= 100 ? Math.round(m) : Math.round(m * 100) / 100) + "M";
	}

	function clamp(v, lo, hi) {
		return Math.max(lo, Math.min(hi, v));
	}

	function keyOf(e) {
		return e.kind === "pickup" ? "pickup:" + e.model : e.kind === "help" ? "help:" + e.hid : "own:" + e.model;
	}

	/** Pickups are grouped per weapon: `stacks` rows hold `amount` guns. */
	function maxQty(e) {
		return e && e.kind === "pickup" ? Math.max(1, e.stacks || 1) : 1;
	}

	/** A row normally holds one gun; only then is the count shown in pieces. */
	function unitOf(e) {
		return e && e.amount === e.stacks ? " db" : " tétel";
	}

	function current() {
		for (var i = 0; i < entries.length; i++) {
			if (keyOf(entries[i]) === sel) return entries[i];
		}
		return null;
	}

	/** How many ingredients the player is short of. */
	function missingCount(e) {
		var items = arr(e.items), n = 0;
		for (var i = 0; i < items.length; i++) {
			if ((items[i].have || 0) < items[i].need) n++;
		}
		return n;
	}

	/* ---------- item icons ---------- */

	/** Two-letter monogram shown until (or instead of) the item image. */
	function monogram(label) {
		var parts = String(label || "?").trim().split(/\s+/);
		var s = parts.length > 1 ? parts[0][0] + parts[1][0] : parts[0].slice(0, 2);
		return esc(s.toUpperCase());
	}

	/** Item icon: inventory image fading in over a monogram fallback. */
	function icoHtml(itemName, label, cls) {
		var key = String(itemName || "").toLowerCase();
		var html = '<div class="' + (cls || "ico") + '" data-item="' + esc(key) + '">' + monogram(label);

		if (!badIcons[key]) {
			html += '<img src="' + esc(ICON_BASE + key + ICON_EXTS[0]) + '" data-ext="0" alt="">';
		}

		return html + "</div>";
	}

	/**
	 * Images start hidden: they fade in only once decoded, and a failed one is
	 * dropped and remembered, so a broken image never flashes over the monogram.
	 */
	function wireIcons(scope) {
		var imgs = scope.querySelectorAll("img");

		for (var i = 0; i < imgs.length; i++) {
			(function (img) {
				var holder = img.parentNode;
				var key = holder ? holder.getAttribute("data-item") : null;

				function ok() { img.classList.add("ok"); }

				function fail() {
					var next = (parseInt(img.getAttribute("data-ext"), 10) || 0) + 1;

					// try the next known extension before giving up
					if (key && next < ICON_EXTS.length) {
						img.setAttribute("data-ext", next);
						img.src = ICON_BASE + key + ICON_EXTS[next];
						return;
					}

					if (key) badIcons[key] = true;
					img.remove();
				}

				// handlers first, so a retry started below is still handled
				img.onload = ok;
				img.onerror = fail;

				if (img.complete) {
					if (img.naturalWidth > 0) ok(); else fail();
				}
			})(imgs[i]);
		}
	}

	/* ---------- job list ---------- */

	function subOf(e) {
		if (e.kind === "pickup") {
			return "<b>" + num(e.amount) + " db</b>" + (e.at ? " &middot; " + esc(e.at) : "");
		}

		var miss = missingCount(e);
		var state = miss ? "<i>" + miss + " alapanyag hiányzik</i>" : "<b>Gyártható</b>";

		return e.kind === "help" ? esc(e.ownerName || "Ismeretlen") + " részére &middot; " + state : state;
	}

	function renderList() {
		if (!entries.length) {
			elList.innerHTML =
				'<div class="empty">' +
				'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">' +
				'<path d="M12 3 20 7.5v9L12 21l-8-4.5v-9z"/><path d="M8 12h8"/></svg>' +
				"<div>Nincs egyedi fegyvered.<br>Fegyvert a <b>PP boltban</b> szerezhetsz, vagy kérd meg egy tulajdonost, hogy vegyen fel segítőnek.</div>" +
				"</div>";
			return;
		}

		var html = "";

		for (var g = 0; g < GROUPS.length; g++) {
			var kind = GROUPS[g].kind;
			var any = false;

			for (var i = 0; i < entries.length; i++) {
				var e = entries[i];
				if (e.kind !== kind) continue;

				if (!any) {
					html += '<div class="group">' + GROUPS[g].title + "</div>";
					any = true;
				}

				var k = keyOf(e);
				var off = e.kind !== "pickup" && missingCount(e) > 0;

				html += '<div class="card' + (k === sel ? " on" : "") + (off ? " off" : "") + '" data-k="' + esc(k) + '">' +
					icoHtml(e.model, e.label) +
					'<div class="meta">' +
					'<div class="cname">' + esc(e.label) + "</div>" +
					'<div class="csub">' + subOf(e) + "</div>" +
					"</div></div>";
			}
		}

		elList.innerHTML = html;
		wireIcons(elList);

		var cards = elList.querySelectorAll(".card");
		for (var c = 0; c < cards.length; c++) {
			cards[c].addEventListener("click", function () {
				select(this.getAttribute("data-k"));
			});
		}
	}

	/* ---------- ingredients ---------- */

	function renderDetail() {
		var e = current();

		if (!e) {
			elIngSub.textContent = "Válassz a bal oldali listából";
			elResult.innerHTML = "";
			elIngs.innerHTML = '<div class="empty">Itt jelennek meg a kijelölt fegyver alkatrészei.</div>';
			return;
		}

		elIngSub.textContent = e.kind === "pickup" ? "Kifizetve — nincs teendőd"
			: e.kind === "help" ? (e.ownerName || "Ismeretlen") + " megrendeléséhez"
				: "A kijelölt fegyver alkatrészei";

		var sub = e.kind === "pickup"
			? "<span>" + iconBox() + " " + num(e.amount) + " db készen áll</span>"
			: "<span>" + iconBox() + " " + num(e.result) + " db / gyártás</span>" +
			'<span><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">' +
			'<path d="M4 7h16M4 12h16M4 17h10"/></svg> ' + arr(e.items).length + " alapanyag</span>";

		elResult.innerHTML =
			'<div class="result">' +
			icoHtml(e.model, e.label, "rico") +
			"<div>" +
			'<div class="rn">' + esc(e.label) + "</div>" +
			'<div class="rs">' + sub + "</div>" +
			"</div></div>";
		wireIcons(elResult);

		if (e.kind === "pickup") {
			elIngs.innerHTML =
				'<div class="empty">' +
				'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">' +
				'<path d="M5 12l5 5L20 7"/></svg>' +
				"<div>Ez a fegyver már elkészült.<br>Az alapanyagokat a segítőd fizette." +
				(maxQty(e) > 1 ? "<br><br>Jobb oldalon állítsd be, <b>hány darabot</b> viszel el egyszerre." : "") +
				"</div></div>";
			return;
		}

		var items = arr(e.items);

		if (!items.length) {
			elIngs.innerHTML = '<div class="empty">Ehhez a fegyverhez nincs alapanyag megadva.</div>';
			return;
		}

		var html = "";
		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			var have = it.have || 0;
			var miss = have < it.need;

			html += '<div class="ing' + (miss ? " miss" : "") + '">' +
				icoHtml(it.name, it.label) +
				'<div class="iname">' + esc(it.label) + "</div>" +
				'<div class="barwrap"><div class="barfill" style="width:' +
				clamp((have / it.need) * 100, 0, 100) + '%"></div></div>' +
				'<div class="cnt" title="' + num(have) + " / " + num(it.need) + '">' +
				short(Math.min(have, it.need)) + " / " + short(it.need) + "</div>" +
				"</div>";
		}

		elIngs.innerHTML = html;
		wireIcons(elIngs);
	}

	/* ---------- action column ---------- */

	function renderSide() {
		var e = current();

		if (!e) {
			elSide.innerHTML = '<div class="empty">Nincs kijelölt munka.</div>';
			return;
		}

		var html = "";

		if (e.kind === "pickup") {
			var max = maxQty(e);
			qty = clamp(qty, 1, max);

			html +=
				'<div class="box">' +
				'<div class="bl">Átvétel</div>' +
				'<div class="row"><span>Fegyver</span><span>' + esc(e.label) + "</span></div>" +
				'<div class="row ok"><span>Készen áll</span><span>' + num(e.amount) + " db</span></div>" +
				'<div class="row"><span>Legrégebbi</span><span>' + esc(e.at || "—") + "</span></div>" +
				"</div>";

			// stepper only makes sense above one waiting gun
			if (max > 1) {
				html +=
					'<div class="qty">' +
					'<div class="qb" data-q="-" title="Kevesebb"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M5 12h14"/></svg></div>' +
					'<input id="qty" type="number" min="1" max="' + max + '" value="' + qty + '">' +
					'<div class="qb" data-q="+" title="Több"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></div>' +
					'<div class="qb wide" data-q="max">Mind</div>' +
					"</div>";
			}

			html +=
				btnHtml("go", "green", "Átvétel &middot; " + num(qty) + unitOf(e), iconBox()) +
				'<div class="grow"></div>' +
				'<div class="hint">A rendszer csak annyit ad át, amennyi <b>elfér</b> a táskádban — a többi itt marad.</div>';

		} else if (e.kind === "help") {
			var ready = missingCount(e) === 0;

			html +=
				'<div class="box">' +
				'<div class="bl">Megbízás</div>' +
				'<div class="row"><span>Megrendelő</span><span>' + esc(e.ownerName || "Ismeretlen") + "</span></div>" +
				'<div class="row ' + (ready ? "ok" : "bad") + '"><span>Alapanyag</span><span>' +
				(ready ? "Megvan" : missingCount(e) + " hiányzik") + "</span></div>" +
				"</div>" +
				btnHtml("go", ready ? "green" : "disabled",
					ready ? "Gyártás a megrendelőnek" : "Nincs elég alapanyag", iconAnvil()) +
				'<div class="grow"></div>' +
				'<div class="hint">Az alapanyagok <b>tőled</b> fogynak. A kész fegyvert a megrendelő veszi át itt, a craftolónál.</div>';

		} else {
			var ok = missingCount(e) === 0;
			var helpers = arr(e.helpers);

			html +=
				'<div class="box">' +
				'<div class="bl">Gyártás</div>' +
				'<div class="row"><span>Kapsz</span><span>' + num(e.result) + " db</span></div>" +
				'<div class="row ' + (ok ? "ok" : "bad") + '"><span>Alapanyag</span><span>' +
				(ok ? "Megvan" : missingCount(e) + " hiányzik") + "</span></div>" +
				"</div>" +
				btnHtml("go", ok ? "green" : "disabled",
					ok ? "Gyártás indítása" : "Nincs elég alapanyag", iconAnvil());

			html += '<div class="box gap"><div class="bl">Segítők</div>';

			if (helpers.length) {
				for (var i = 0; i < helpers.length; i++) {
					html += '<div class="helper">' +
						'<div class="hn">' + esc(helpers[i].name || "Ismeretlen") + "</div>" +
						'<div class="hx" data-hid="' + helpers[i].id + '" title="Eltávolítás">' +
						'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">' +
						'<path d="M18 6 6 18M6 6l12 12"/></svg></div></div>';
				}
			} else {
				html += '<div class="none">Még senki nem gyárthat helyetted.</div>';
			}

			html +=
				'<div class="field"><input id="pid" type="number" min="1" max="1024" placeholder="Játékos ID" value="' +
				esc(pid) + '"></div>' +
				btnHtml("add", "ghost", "Segítő hozzáadása") +
				btnHtml("share", "ghost", "Fegyver átadása") +
				"</div>" +
				'<div class="grow"></div>' +
				'<div class="hint">Az átadás <b>végleges</b>: a fegyver a másik játékoshoz kerül, nálad megszűnik. ' +
				'A segítő viszont a saját alapanyagából gyárt neked — a fegyver marad a tiéd.</div>';
		}

		elSide.innerHTML = html;
		wireSide();
	}

	function iconAnvil() {
		return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
			'<path d="M3 21h18"/><path d="M6 18V9l6-4 6 4v9"/></svg>';
	}

	function iconBox() {
		return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
			'<path d="M12 3 20 7.5v9L12 21l-8-4.5v-9z"/><path d="M12 12 20 7.5M12 12v9M12 12 4 7.5"/></svg>';
	}

	function btnHtml(id, cls, label, icon) {
		return '<div class="btn ' + cls + '" data-btn="' + id + '" tabindex="0">' + (icon || "") + "<span>" + label + "</span></div>";
	}

	/** Clamps the amount, syncs the field and relabels the button — no re-render, the field keeps focus. */
	function setQty(v, keepField) {
		var e = current();
		qty = clamp(Math.floor(Number(v) || 1), 1, maxQty(e));

		var field = document.getElementById("qty");
		if (field && !keepField) field.value = qty;

		var btn = elSide.querySelector('[data-btn="go"]');
		if (!btn) return;

		// a changed amount must be confirmed again
		disarm();
		btn.classList.remove("confirm");
		btn.querySelector("span").textContent = "Átvétel · " + num(qty) + unitOf(e);
	}

	function wireSide() {
		var input = document.getElementById("pid");
		if (input) {
			input.addEventListener("input", function () { pid = this.value; });
		}

		var field = document.getElementById("qty");
		if (field) {
			// keep the raw value while typing, snap it into range once the field is left
			field.addEventListener("input", function () { setQty(this.value, true); });
			field.addEventListener("change", function () { setQty(this.value); });
			field.addEventListener("blur", function () { this.value = qty; });
		}

		var steps = elSide.querySelectorAll("[data-q]");
		for (var s = 0; s < steps.length; s++) {
			steps[s].addEventListener("click", function () {
				var q = this.getAttribute("data-q");
				setQty(q === "max" ? maxQty(current()) : q === "+" ? qty + 1 : qty - 1);
			});
		}

		var btns = elSide.querySelectorAll("[data-btn]");
		for (var i = 0; i < btns.length; i++) {
			btns[i].addEventListener("click", function () { onButton(this.getAttribute("data-btn")); });
			btns[i].addEventListener("keydown", function (ev) {
				if (ev.key === "Enter" || ev.key === " ") {
					ev.preventDefault();
					onButton(this.getAttribute("data-btn"));
				}
			});
		}

		var xs = elSide.querySelectorAll(".hx");
		for (var j = 0; j < xs.length; j++) {
			xs[j].addEventListener("click", function () {
				send("removeHelper", { hid: parseInt(this.getAttribute("data-hid"), 10) });
			});
		}
	}

	/* ---------- actions ---------- */

	function onButton(id) {
		var e = current();
		if (!e) return;

		if (id === "add" || id === "share") {
			var target = parseInt(pid, 10);

			if (!target || target < 1) {
				return toast("Írd be a játékos ID-jét.", false);
			}

			send(id === "add" ? "addHelper" : "share", { model: e.model, target: target });
			return;
		}

		// crafting and pickup both consume something — ask for a second click
		if (!armed(id)) return;

		if (e.kind === "pickup") send("pickup", { model: e.model, count: qty });
		else if (e.kind === "help") send("help", { hid: e.hid });
		else send("craft", { model: e.model });
	}

	/** Two-step confirm on the primary button; reverts after a few seconds. */
	function armed(id) {
		var btn = elSide.querySelector('[data-btn="' + id + '"]');
		if (!btn) return false;

		if (confirmKey === id) {
			disarm();
			return true;
		}

		disarm();
		confirmKey = id;
		btn.classList.add("confirm");
		btn.querySelector("span").textContent = "Biztos? Kattints újra";
		confirmTimer = setTimeout(function () {
			confirmKey = null;
			renderSide();
		}, 4000);

		return false;
	}

	function disarm() {
		if (confirmTimer) clearTimeout(confirmTimer);
		confirmTimer = null;
		confirmKey = null;
	}

	function send(action, body) {
		body = body || {};
		body.action = action;
		post("action", body);
	}

	function toast(msg, ok) {
		if (!msg) return;

		elToast.textContent = msg;
		elToast.classList.toggle("bad", ok === false);
		elToast.classList.add("show");

		if (toastTimer) clearTimeout(toastTimer);
		toastTimer = setTimeout(function () { elToast.classList.remove("show"); }, 3200);
	}

	/* ---------- state ---------- */

	function select(k) {
		if (!k || k === sel) return;

		sel = k;
		disarm();
		resetQty();
		markSelected();
		renderDetail();
		renderSide();
	}

	/** A fresh pickup selection offers everything that is waiting — that is the usual intent. */
	function resetQty() {
		var e = current();
		qty = e && e.kind === "pickup" ? maxQty(e) : 1;
	}

	/** Moves the selection highlight without rebuilding the list. */
	function markSelected() {
		var cards = elList.querySelectorAll(".card");
		for (var i = 0; i < cards.length; i++) {
			cards[i].classList.toggle("on", cards[i].getAttribute("data-k") === sel);
		}
	}

	function summary() {
		var n = { own: 0, help: 0, pickup: 0 };

		for (var i = 0; i < entries.length; i++) {
			var e = entries[i];
			// pickups are grouped per weapon, so the header counts guns, not cards
			n[e.kind] += e.kind === "pickup" ? (e.amount || 0) : 1;
		}

		var parts = [];
		if (n.own) parts.push(n.own + " saját");
		if (n.help) parts.push(n.help + " megbízás");
		if (n.pickup) parts.push(n.pickup + " átvehető");

		return parts.length ? parts.join(" · ") : "Nincs munkád";
	}

	function apply(data) {
		entries = arr(data && data.entries);
		elWho.textContent = (data && data.who) || "";
		elCount.textContent = summary();

		// keep the selection if it still exists, otherwise fall back to the first job
		var found = null;
		for (var i = 0; i < entries.length; i++) {
			if (keyOf(entries[i]) === sel) { found = sel; break; }
		}
		sel = found || (entries.length ? keyOf(entries[0]) : null);

		disarm();
		resetQty();
		renderList();
		renderDetail();
		renderSide();
	}

	function open(data) {
		pid = "";
		sel = null;
		apply(data);
		stage.classList.add("open");
	}

	function hide() {
		stage.classList.remove("open");
		disarm();
		entries = [];
		sel = null;
		pid = "";
		qty = 1;
	}

	function close() {
		post("close", {});
		hide();
	}

	/* ---------- wiring ---------- */

	document.getElementById("close").addEventListener("click", close);

	document.addEventListener("keydown", function (ev) {
		if (!stage.classList.contains("open")) return;
		if (ev.key === "Escape") close();
	});

	window.addEventListener("message", function (ev) {
		var d = ev.data || {};

		if (d.action === "open") {
			open(d.data);
		} else if (d.action === "update") {
			if (stage.classList.contains("open")) {
				if (d.data) apply(d.data);
				toast(d.msg, d.ok);
			}
		} else if (d.action === "close") {
			hide();
		}
	});
})();
