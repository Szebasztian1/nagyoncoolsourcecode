/* ============================================================
   Crafting table NUI logic.
   Receives `craft:open` from the client, renders the recipe list,
   ingredient state and the craft column, then posts back
   `craft:craft` / `craft:close`. All validation stays server-side.

   Rendering is split so nothing rebuilds needlessly:
     renderList()   -> once per open
     renderDetail() -> once per selection
     updateAmounts()-> on every quantity change (numbers only)
   Rebuilding markup would re-create the <img> tags and make the
   icons flicker on every click / slider move.
   ============================================================ */
(function () {
    "use strict";

    var RES = typeof GetParentResourceName === "function" ? GetParentResourceName() : "esx_job_creator";

    var root = document.getElementById("craft-root");
    if (!root) return;

    var elJob = document.getElementById("craft-job");
    var elCount = document.getElementById("craft-count");
    var elList = document.getElementById("craft-list");
    var elResult = document.getElementById("craft-result");
    var elIngs = document.getElementById("craft-ings");
    var elSide = document.getElementById("craft-side");

    // Where item images live. Change the base if your inventory stores them
    // elsewhere; the extensions are tried in order until one loads.
    var ICON_BASE = "nui://ox_inventory/web/images/";
    var ICON_EXTS = [".webp", ".png"];

    var items = [];
    var sel = -1;
    var amount = 1;

    // items whose image failed for every extension — never requested again
    var badIcons = {};

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

    function clamp(v, lo, hi) {
        return Math.max(lo, Math.min(hi, v));
    }

    function current() {
        return sel >= 0 && sel < items.length ? items[sel] : null;
    }

    /** Two-letter monogram shown until (or instead of) the item image. */
    function monogram(label) {
        var parts = String(label || "?").trim().split(/\s+/);
        var s = parts.length > 1 ? parts[0][0] + parts[1][0] : parts[0].slice(0, 2);
        return esc(s.toUpperCase());
    }

    /** Item icon: inventory image fading in over a monogram fallback. */
    function icoHtml(itemName, label, cls) {
        var key = String(itemName).toLowerCase();
        var html = '<div class="' + (cls || "c-ico") + '" data-item="' + esc(key) + '">' + monogram(label);

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

    /* ---------- recipe list (built once per open) ---------- */

    function renderList() {
        if (!items.length) {
            elList.innerHTML = '<div class="c-empty">Ehhez az asztalhoz nincs recept beállítva.</div>';
            return;
        }

        var html = "";
        for (var i = 0; i < items.length; i++) {
            var it = items[i];
            var tag = it.isWeapon ? '<span class="c-tag">Fegyver</span> ' : "";
            var sub = it.canCraft
                ? tag + "max. <b>" + it.maxCraft + " db</b> &middot; " + it.craftTime + " mp"
                : tag + "<i>Hiányzó alapanyag</i>";

            html += '<div class="c-card' + (i === sel ? " on" : "") + (it.canCraft ? "" : " off") + '" data-i="' + i + '">' +
                icoHtml(it.itemName, it.label) +
                '<div class="c-meta">' +
                '<div class="c-cname">' + esc(it.label) + "</div>" +
                '<div class="c-csub">' + sub + "</div>" +
                "</div></div>";
        }

        elList.innerHTML = html;
        wireIcons(elList);

        var cards = elList.querySelectorAll(".c-card");
        for (var j = 0; j < cards.length; j++) {
            cards[j].addEventListener("click", function () {
                select(parseInt(this.getAttribute("data-i"), 10));
            });
        }
    }

    /** Moves the selection highlight without touching the markup. */
    function markSelected() {
        var cards = elList.querySelectorAll(".c-card");
        for (var i = 0; i < cards.length; i++) {
            cards[i].classList.toggle("on", parseInt(cards[i].getAttribute("data-i"), 10) === sel);
        }
    }

    /* ---------- detail (built once per selection) ---------- */

    function renderDetail() {
        var it = current();

        if (!it) {
            elResult.innerHTML = "";
            elIngs.innerHTML = "";
            elSide.innerHTML = '<div class="c-empty">Válassz receptet.</div>';
            return;
        }

        elResult.innerHTML =
            '<div class="c-result">' +
            icoHtml(it.itemName, it.label, "c-rico") +
            "<div>" +
            '<div class="c-rn">' + esc(it.label) + "</div>" +
            '<div class="c-rs">' +
            '<span><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/></svg> ' +
            it.resultQty + " db / gyártás</span>" +
            '<span><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg> ' +
            it.craftTime + " másodperc</span>" +
            "</div></div></div>";
        wireIcons(elResult);

        var ing = it.ingredients || [];
        if (!ing.length) {
            elIngs.innerHTML = '<div class="c-empty">Nincs megadva hozzávaló.</div>';
        } else {
            var h = "";
            for (var i = 0; i < ing.length; i++) {
                h += '<div class="c-ing" data-need="' + ing[i].need + '" data-have="' + ing[i].have + '">' +
                    icoHtml(ing[i].name, ing[i].label) +
                    '<div class="c-iname">' + esc(ing[i].label) + "</div>" +
                    '<div class="c-barwrap"><div class="c-barfill"></div></div>' +
                    '<div class="c-cnt"></div>' +
                    "</div>";
            }
            elIngs.innerHTML = h;
            wireIcons(elIngs);
        }

        renderSide();
        updateAmounts();
    }

    /** Craft column skeleton — rebuilt per selection, never per quantity change
        (replacing the slider mid-drag would break the drag). */
    function renderSide() {
        var it = current();
        if (!it) return;

        var max = Math.max(it.maxCraft, 0);
        var canCraft = it.canCraft && max > 0;

        elSide.innerHTML =
            '<div class="c-qty">' +
            '<div class="c-ql">Mennyiség</div>' +
            '<div class="c-qrow">' +
            '<div class="c-step" data-step="-1">&minus;</div>' +
            '<div class="c-qnum">' + amount + "</div>" +
            '<div class="c-step" data-step="1">+</div>' +
            "</div>" +
            '<input class="c-range" type="range" min="1" max="' + Math.max(max, 1) + '" value="' + amount + '"' +
            (max > 1 ? "" : " disabled") + ">" +
            "</div>" +

            '<div class="c-sum">' +
            '<div class="c-r"><span>Egy gyártás</span><span>' + it.craftTime + " mp</span></div>" +
            '<div class="c-r"><span>Összes idő</span><span id="craft-total-time"></span></div>' +
            '<div class="c-r total"><span>Kapsz</span><span id="craft-total-qty"></span></div>' +
            "</div>" +

            '<div class="c-hint">Gyártás közben <b>[G]</b> &minus;10 mp (50.000$) &middot; <b>[Backspace]</b> mégse</div>' +

            '<div class="c-grow"></div>' +

            '<div class="c-btn ghost' + (max > 1 ? "" : " disabled") + '" id="craft-max">Max mennyiség</div>' +
            '<div class="c-btn ' + (canCraft ? "green" : "disabled") + '" id="craft-go">' +
            '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M6 18V9l6-4 6 4v9"/></svg>' +
            (canCraft ? "Gyártás indítása" : "Nincs elég alapanyag") +
            "</div>";

        var steps = elSide.querySelectorAll(".c-step");
        for (var i = 0; i < steps.length; i++) {
            steps[i].addEventListener("click", function () {
                setAmount(amount + parseInt(this.getAttribute("data-step"), 10));
            });
        }

        var range = elSide.querySelector(".c-range");
        if (range) range.addEventListener("input", function () { setAmount(parseInt(this.value, 10)); });

        var maxBtn = document.getElementById("craft-max");
        if (maxBtn) maxBtn.addEventListener("click", function () { setAmount(max); });

        var goBtn = document.getElementById("craft-go");
        if (goBtn && canCraft) goBtn.addEventListener("click", craft);
    }

    /** Patches only the numbers that depend on the chosen quantity. */
    function updateAmounts() {
        var it = current();
        if (!it) return;

        var rows = elIngs.querySelectorAll(".c-ing");
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            var have = parseInt(row.getAttribute("data-have"), 10) || 0;
            var need = (parseInt(row.getAttribute("data-need"), 10) || 0) * amount;

            row.classList.toggle("miss", have < need);
            row.querySelector(".c-cnt").textContent = have + " / " + need;
            row.querySelector(".c-barfill").style.width =
                (need > 0 ? clamp((have / need) * 100, 0, 100) : 100) + "%";
        }

        var qnum = elSide.querySelector(".c-qnum");
        if (qnum) qnum.textContent = amount;

        var range = elSide.querySelector(".c-range");
        if (range && String(range.value) !== String(amount)) range.value = amount;

        var time = document.getElementById("craft-total-time");
        if (time) time.textContent = it.craftTime * amount + " mp";

        var qty = document.getElementById("craft-total-qty");
        if (qty) qty.textContent = it.resultQty * amount + " db";
    }

    /* ---------- state ---------- */

    function setAmount(v) {
        var it = current();
        if (!it) return;

        var max = Math.max(it.maxCraft, 1);
        var next = clamp(isNaN(v) ? 1 : v, 1, max);
        if (next === amount) return;

        amount = next;
        updateAmounts();
    }

    function select(i) {
        if (isNaN(i) || i < 0 || i >= items.length || i === sel) return;

        sel = i;
        amount = 1;
        markSelected();
        renderDetail();
    }

    function craft() {
        var it = current();
        if (!it || !it.canCraft) return;

        post("craft:craft", { itemName: it.itemName, amount: amount });
        hide();
    }

    function hide() {
        root.classList.remove("open");
        items = [];
        sel = -1;
        amount = 1;
    }

    function close() {
        post("craft:close", {});
        hide();
    }

    function open(data) {
        items = (data && data.items) || [];
        sel = items.length ? 0 : -1;
        amount = 1;

        elJob.textContent = (data && data.jobLabel) || "";

        var craftable = 0;
        for (var i = 0; i < items.length; i++) if (items[i].canCraft) craftable++;
        elCount.textContent = items.length
            ? items.length + " recept · " + craftable + " gyártható"
            : "Nincs recept";

        renderList();
        renderDetail();
        root.classList.add("open");
    }

    /* ---------- wiring ---------- */

    document.getElementById("craft-close").addEventListener("click", close);

    document.addEventListener("keydown", function (e) {
        if (!root.classList.contains("open")) return;
        if (e.key === "Escape") close();
    });

    window.addEventListener("message", function (event) {
        var d = event.data || {};
        if (d.action === "craft:open") open(d.data);
        else if (d.action === "craft:close") hide();
    });
})();
