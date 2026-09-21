/* ============================================================
   Fegyvercraft (jogosultsagi) NUI logic.
   Receives `open` / `update` from the client, renders the three
   panels (weapons, ingredients, crafting) and posts back `craft`
   / `close`. Every craft is re-validated server side; the UI only
   decides what to offer.

   Rendering is split so nothing rebuilds needlessly:
     renderList()   -> item list of the open tab
     renderDetail() -> result + ingredients of the selection
     renderSide()   -> the action column
     refreshQty()   -> only the numbers that follow the stepper
   ============================================================ */
(function () {
	"use strict";

	var RES = typeof GetParentResourceName === "function" ? GetParentResourceName() : "bc_fegyvercraft_wl";

	var stage = document.getElementById("stage");
	var elWho = document.getElementById("who");
	var elPTitle = document.getElementById("ptitle");
	var elCount = document.getElementById("count");
	var elTabs = document.getElementById("tabs");
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
	var cats = [];    // the tabs that have at least one craftable item
	var cat = null;   // id of the open tab
	var sel = null;   // model of the selected item
	var qty = 1;      // how many the craft asks for
	var maxCraft = 1; // Config.MaxCraftAmount, arrives with every payload
	var confirmed = false;
	var confirmTimer = null;
	var toastTimer = null;

	// items whose image failed for every extension — never requested again
	var badIcons = {};

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

	function current() {
		for (var i = 0; i < entries.length; i++) {
			if (entries[i].model === sel) return entries[i];
		}
		return null;
	}

	/** The entries of the open tab, in the order the server sent them. */
	function visible() {
		var out = [];

		for (var i = 0; i < entries.length; i++) {
			if (!cat || entries[i].category === cat) out.push(entries[i]);
		}

		return out;
	}

	function catLabel() {
		for (var i = 0; i < cats.length; i++) {
			if (cats[i].id === cat) return cats[i].label;
		}
		return "Kínálat";
	}

	/** How many ingredients the player is short of for `n` crafts. */
	function missingFor(e, n) {
		var items = arr(e.items), miss = 0;

		for (var i = 0; i < items.length; i++) {
			if ((items[i].have || 0) < items[i].need * n) miss++;
		}

		return miss;
	}

	/** How many full crafts the materials allow, capped by Config.MaxCraftAmount. */
	function affordable(e) {
		if (!e) return 0;

		var items = arr(e.items);
		if (!items.length) return maxCraft;

		var least = maxCraft;

		for (var i = 0; i < items.length; i++) {
			var n = Math.floor((items[i].have || 0) / items[i].need);
			if (n < least) least = n;
		}

		return Math.max(0, least);
	}

	function maxQty(e) {
		return Math.max(1, Math.min(maxCraft, affordable(e)));
	}

	function canCraft(e) {
		return !!e && affordable(e) >= qty;
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

	/* ---------- category tabs ---------- */

	/** Header line of the list panel — follows the open tab. */
	function renderHead() {
		elPTitle.textContent = cats.length ? catLabel() : "Kínálat";
		elCount.textContent = summary();
	}

	function renderTabs() {
		// a single tab carries no information, the panel title already names it
		if (cats.length < 2) {
			elTabs.innerHTML = "";
			elTabs.style.display = "none";
			return;
		}

		elTabs.style.display = "";

		var html = "";

		for (var i = 0; i < cats.length; i++) {
			var c = cats[i];
			var n = 0;

			for (var j = 0; j < entries.length; j++) {
				if (entries[j].category === c.id) n++;
			}

			html += '<div class="tab' + (c.id === cat ? " on" : "") + '" data-c="' + esc(c.id) + '">' +
				esc(c.label) + '<span class="tn">' + n + "</span></div>";
		}

		elTabs.innerHTML = html;

		var tabs = elTabs.querySelectorAll(".tab");
		for (var t = 0; t < tabs.length; t++) {
			tabs[t].addEventListener("click", function () {
				setCat(this.getAttribute("data-c"));
			});
		}
	}

	/** Switching tabs starts on the first item of the new one. */
	function setCat(id) {
		if (!id || id === cat) return;

		cat = id;
		qty = 1;
		disarm();

		var list = visible();
		sel = list.length ? list[0].model : null;

		renderHead();
		renderTabs();
		renderList();
		renderDetail();
		renderSide();
	}

	/* ---------- item list ---------- */

	function renderList() {
		var list = visible();

		if (!list.length) {
			elList.innerHTML =
				'<div class="empty">' +
				'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">' +
				'<path d="M12 3 20 7.5v9L12 21l-8-4.5v-9z"/><path d="M8 12h8"/></svg>' +
				(entries.length
					? "<div>Ebben a kategóriában nincs <b>gyártható</b> tétel.</div>"
					: "<div>Nincs <b>jogosultságod</b> egyetlen tételhez sem.</div>") +
				"</div>";
			return;
		}

		var html = "";

		for (var i = 0; i < list.length; i++) {
			var e = list[i];
			var can = affordable(e) > 0;

			html += '<div class="card' + (e.model === sel ? " on" : "") + (can ? "" : " off") +
				'" data-k="' + esc(e.model) + '">' +
				icoHtml(e.model, e.label) +
				'<div class="meta">' +
				'<div class="cname">' + esc(e.label) + "</div>" +
				'<div class="csub">' +
				(can ? "<b>Gyártható</b>" : "<i>" + missingFor(e, 1) + " alapanyag hiányzik</i>") +
				"</div></div></div>";
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
			elIngs.innerHTML = '<div class="empty">Itt jelennek meg a kijelölt tétel alapanyagai.</div>';
			return;
		}

		elIngSub.textContent = "A kijelölt tétel alapanyagai";

		elResult.innerHTML =
			'<div class="result">' +
			icoHtml(e.model, e.label, "rico") +
			"<div>" +
			'<div class="rn">' + esc(e.label) + "</div>" +
			'<div class="rs">' +
			"<span>" + iconBox() + " " +
			(qty > 1 ? num(e.result * qty) + " db (&times;" + qty + ")" : num(e.result) + " db / gyártás") +
			"</span>" +
			'<span><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">' +
			'<path d="M4 7h16M4 12h16M4 17h10"/></svg> ' + arr(e.items).length + " alapanyag</span>" +
			"</div></div></div>";
		wireIcons(elResult);

		var items = arr(e.items);

		if (!items.length) {
			elIngs.innerHTML = '<div class="empty">Ehhez a tételhez nincs alapanyag megadva.</div>';
			return;
		}

		var html = "";
		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			var have = it.have || 0;
			var need = it.need * qty; // the whole recipe scales with the amount
			var miss = have < need;

			html += '<div class="ing' + (miss ? " miss" : "") + '">' +
				icoHtml(it.name, it.label) +
				'<div class="iname">' + esc(it.label) + "</div>" +
				'<div class="barwrap"><div class="barfill" style="width:' +
				clamp((have / need) * 100, 0, 100) + '%"></div></div>' +
				'<div class="cnt" title="' + num(have) + " / " + num(need) + '">' +
				short(Math.min(have, need)) + " / " + short(need) + "</div>" +
				"</div>";
		}

		elIngs.innerHTML = html;
		wireIcons(elIngs);
	}

	/* ---------- action column ---------- */

	function matText(e) {
		return canCraft(e) ? "Megvan" : missingFor(e, qty) + " hiányzik";
	}

	function goLabel(e) {
		if (!canCraft(e)) return "Nincs elég alapanyag";
		return "Gyártás &middot; " + num(qty * (e.result || 1)) + " db";
	}

	function renderSide() {
		var e = current();

		if (!e) {
			elSide.innerHTML = '<div class="empty">Nincs kijelölt tétel.</div>';
			return;
		}

		var max = maxQty(e);
		qty = clamp(qty, 1, max);

		var html =
			'<div class="box">' +
			'<div class="bl">Gyártás</div>' +
			'<div class="row"><span>Tétel</span><span>' + esc(e.label) + "</span></div>" +
			'<div class="row"><span>Kapsz</span><span id="qres">' + num(e.result * qty) + " db</span></div>" +
			'<div class="row ' + (canCraft(e) ? "ok" : "bad") + '" id="qmat"><span>Alapanyag</span><span>' +
			matText(e) + "</span></div>" +
			"</div>";

		// stepper only makes sense when more than one is possible
		if (max > 1) {
			html += '<div class="qty">' +
				'<div class="qb" data-q="-" title="Kevesebb"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M5 12h14"/></svg></div>' +
				'<input id="qty" type="number" min="1" max="' + max + '" value="' + qty + '">' +
				'<div class="qb" data-q="+" title="Több"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></div>' +
				'<div class="qb wide" data-q="max">Mind</div>' +
				"</div>";
		}

		html +=
			btnHtml(canCraft(e) ? "green" : "disabled", goLabel(e)) +
			'<div class="grow"></div>' +
			'<div class="hint">Az alapanyagok <b>tőled</b> fogynak, a kész tétel a táskádba kerül. ' +
			'Annyiszor gyárthatsz, ahányszor akarsz.</div>';

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

	function btnHtml(cls, label) {
		return '<div class="btn ' + cls + '" data-btn="go" tabindex="0">' + iconAnvil() + "<span>" + label + "</span></div>";
	}

	/** Only the numbers that follow the stepper — no re-render, the field keeps focus. */
	function refreshQty() {
		var e = current();
		if (!e) return;

		renderDetail(); // the ingredient list scales with the amount

		var res = document.getElementById("qres");
		if (res) res.textContent = num(e.result * qty) + " db";

		var mat = document.getElementById("qmat");
		if (mat) {
			mat.className = "row " + (canCraft(e) ? "ok" : "bad");
			mat.querySelector("span:last-child").textContent = matText(e);
		}

		disarm(); // a changed amount must be confirmed again

		var btn = elSide.querySelector('[data-btn="go"]');
		if (!btn) return;

		btn.className = "btn " + (canCraft(e) ? "green" : "disabled");
		btn.querySelector("span").innerHTML = goLabel(e);
	}

	function setQty(v, keepField) {
		qty = clamp(Math.floor(Number(v) || 1), 1, maxQty(current()));

		var field = document.getElementById("qty");
		if (field && !keepField) field.value = qty;

		refreshQty();
	}

	function wireSide() {
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

		var btn = elSide.querySelector('[data-btn="go"]');
		if (btn) {
			btn.addEventListener("click", onCraft);
			btn.addEventListener("keydown", function (ev) {
				if (ev.key === "Enter" || ev.key === " ") {
					ev.preventDefault();
					onCraft();
				}
			});
		}
	}

	/* ---------- actions ---------- */

	function onCraft() {
		var e = current();
		if (!e) return;

		if (!canCraft(e)) return toast("Nincs elég alapanyagod ennyihez.", false);

		// crafting consumes materials — ask for a second click
		if (!armed()) return;

		post("craft", { model: e.model, count: qty });
	}

	/** Two-step confirm on the craft button; reverts after a few seconds. */
	function armed() {
		var btn = elSide.querySelector('[data-btn="go"]');
		if (!btn) return false;

		if (confirmed) {
			disarm();
			return true;
		}

		confirmed = true;
		btn.classList.add("confirm");
		btn.querySelector("span").textContent = "Biztos? Kattints újra";
		confirmTimer = setTimeout(function () {
			confirmed = false;
			renderSide();
		}, 4000);

		return false;
	}

	function disarm() {
		if (confirmTimer) clearTimeout(confirmTimer);
		confirmTimer = null;
		confirmed = false;
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

	function select(model) {
		if (!model || model === sel) return;

		sel = model;
		qty = 1;
		disarm();
		markSelected();
		renderDetail();
		renderSide();
	}

	/** Moves the selection highlight without rebuilding the list. */
	function markSelected() {
		var cards = elList.querySelectorAll(".card");
		for (var i = 0; i < cards.length; i++) {
			cards[i].classList.toggle("on", cards[i].getAttribute("data-k") === sel);
		}
	}

	function summary() {
		if (!entries.length) return "Nincs jogosultságod";
		return visible().length + " gyártható tétel";
	}

	function apply(data) {
		entries = arr(data && data.entries);
		cats = arr(data && data.categories);
		maxCraft = Math.max(1, Number(data && data.maxCraft) || 1);

		elWho.textContent = (data && data.who) || "";

		// keep the open tab if it still exists, otherwise fall back to the first one
		var keptCat = null;
		for (var c = 0; c < cats.length; c++) {
			if (cats[c].id === cat) { keptCat = cat; break; }
		}
		cat = keptCat || (cats.length ? cats[0].id : null);

		// keep the selection if it is still in the open tab, otherwise its first item
		var list = visible();
		var found = null;
		for (var i = 0; i < list.length; i++) {
			if (list[i].model === sel) { found = sel; break; }
		}
		sel = found || (list.length ? list[0].model : null);

		disarm();
		qty = 1;
		renderHead();
		renderTabs();
		renderList();
		renderDetail();
		renderSide();
	}

	function open(data) {
		sel = null;
		cat = null; // always opens on the first tab
		apply(data);
		stage.classList.add("open");
	}

	function hide() {
		stage.classList.remove("open");
		disarm();
		entries = [];
		cats = [];
		cat = null;
		sel = null;
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
