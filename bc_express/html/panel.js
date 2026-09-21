/* bc_express — depot career/management panel (the resource's own NUI ui_page). BC design system. */
(function () {
    'use strict';
    var RES = (typeof GetParentResourceName === 'function' && GetParentResourceName()) || 'bc_express';
    var IN_GAME = typeof GetParentResourceName === 'function';

    function fmtMoney(n) { return '$' + (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    function fmtNum(n) { return (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    // player-controlled strings (e.g. character names) are escaped before innerHTML (XSS)
    function esc(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    /* ---------------- icons (inline Tabler outline — no CDN) ---------------- */
    var ICONS = {
        truck: '<circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/><path d="M5 17H3V6a1 1 0 0 1 1-1h9v12m-4 0h6m4 0h2v-6h-8m0-5h5l3 5"/>',
        career: '<path d="M3 17l6-6l4 4l8-8"/><path d="M14 7h7v7"/>',
        depots: '<path d="M3 21v-13l9-4l9 4v13"/><path d="M13 13h4v8h-10v-6h6"/><path d="M13 21v-9a1 1 0 0 0-1-1h-2a1 1 0 0 0-1 1v3"/>',
        drivers: '<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/><path d="M21 21v-2a4 4 0 0 0-3-3.85"/>',
        ops: '<circle cx="6" cy="10" r="2"/><path d="M6 4v4M6 12v8"/><circle cx="12" cy="16" r="2"/><path d="M12 4v10M12 18v2"/><circle cx="18" cy="7" r="2"/><path d="M18 4v1M18 9v11"/>',
        employees: '<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4"/><path d="M16 19h6M19 16v6"/>',
        employment: '<rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M3 13a20 20 0 0 0 18 0"/><path d="M12 12v.01"/>',
        sell: '<circle cx="7.5" cy="7.5" r="1"/><path d="M3 6v5.17a2 2 0 0 0 .59 1.42l7.7 7.71a2.41 2.41 0 0 0 3.42 0l5.59-5.59a2.41 2.41 0 0 0 0-3.42l-7.71-7.7A2 2 0 0 0 11.17 3H6a3 3 0 0 0-3 3z"/>',
        help: '<circle cx="12" cy="12" r="9"/><path d="M12 17v.01"/><path d="M12 13.5a1.5 1.5 0 0 1 1-1.5a2.6 2.6 0 1 0-3-4"/>',
        close: '<path d="M18 6L6 18M6 6l12 12"/>'
    };
    function ico(name) {
        return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ' +
            'stroke-linecap="round" stroke-linejoin="round">' + ICONS[name] + '</svg>';
    }

    /* ---------------- navigation ---------------- */
    var PAGES = [
        { id: 'career',     icon: 'career',     t: 'Karrier',       d: 'Szint, rang, ranglétra',   hint: 'A leadások EXP-et adnak — magasabb rang, több cím és nagyobb pénzszorzó.' },
        { id: 'depots',     icon: 'depots',     t: 'Telepek',       d: 'Feloldás és kapacitás',    hint: 'A telepeket sorban kell feloldani; mindegyik jobb sofőröket és nagyobb kapacitást ad.' },
        { id: 'drivers',    icon: 'drivers',    t: 'Sofőrök',       d: 'Passzív bevétel, kassza',  hint: 'A sofőrök bére és felvételi díja a cégkasszából megy, a bevételük oda folyik be.' },
        { id: 'ops',        icon: 'ops',        t: 'Üzemeltetés',   d: 'Gépek, munkások, engedély', hint: 'Egy gép csak akkor termel, ha van mellé munkás. A gépek és kapcsolatok idővel romlanak.' },
        { id: 'employees',  icon: 'employees',  t: 'Alkalmazottak', d: 'Valódi játékosok',         hint: 'Az alkalmazott karbantartja a cégedet, de a pénzedhez nem fér hozzá.' },
        { id: 'employment', icon: 'employment', t: 'Munkahelyem',   d: 'Ahol alkalmazott vagy',    hint: 'A béred offline is gyűlik — itt bármikor felveheted a bankodba.' },
        { id: 'sell',       icon: 'sell',       t: 'Cég eladása',   d: 'Eladás vagy átadás',       hint: 'Az eladás és az átadás is végleges — a céges adataid nullázódnak.' },
        { id: 'help',       icon: 'help',       t: 'Útmutató',      d: 'Hogyan működik',           hint: 'Kérdésed van? Itt minden rendszert végigveszünk.' }
    ];
    var currentPage = 'career';

    function buildNav() {
        document.getElementById('brand-logo').innerHTML = ico('truck');
        document.getElementById('btn-close').innerHTML = ico('close');
        document.getElementById('nav').innerHTML = PAGES.map(function (p) {
            return '<button class="nav-btn" data-page="' + p.id + '">' +
                '<div class="ico">' + ico(p.icon) + '</div>' +
                '<div class="lbl"><div class="t">' + p.t + '</div><div class="d">' + p.d + '</div></div>' +
                '</button>';
        }).join('');
    }

    function setPage(id) {
        currentPage = id;
        var pgs = document.querySelectorAll('.pg');
        for (var i = 0; i < pgs.length; i++) pgs[i].classList.toggle('on', pgs[i].getAttribute('data-page') === id);
        var navs = document.querySelectorAll('.nav-btn');
        for (var j = 0; j < navs.length; j++) navs[j].classList.toggle('on', navs[j].getAttribute('data-page') === id);

        var p = PAGES.filter(function (x) { return x.id === id; })[0] || PAGES[0];
        document.getElementById('wm').innerHTML = ico(p.icon);
        document.getElementById('foot-hint').textContent = p.hint;
        document.getElementById('page').scrollTop = 0;
    }

    /* ---------------- shell ---------------- */
    function openOverlay() { document.getElementById('overlay').classList.add('open'); }

    function close() {
        document.getElementById('overlay').classList.remove('open');
        if (IN_GAME) fetch('https://' + RES + '/bcx:closePanel', { method: 'POST', body: '{}' }).catch(function () {});
    }

    var toastTimer = null;
    function showToast(t) {
        if (!t || !t.msg) return;
        var el = document.getElementById('toast');
        el.textContent = t.msg;
        el.className = 'toast show ' + (t.ok ? 'ok' : 'err');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { el.className = 'toast ' + (t.ok ? 'ok' : 'err'); }, 3600);
    }

    /* ---------------- career ---------------- */
    function renderCareer(d) {
        var lv = d.level, tier = d.tier, tiers = d.tiers || [];
        var pct = lv.isMax ? 100 : (lv.xpForNext > 0 ? Math.min(100, Math.round((lv.xpInLevel / lv.xpForNext) * 100)) : 0);

        document.getElementById('p-level').textContent = lv.level;
        document.getElementById('p-tier').textContent = tier.label;
        document.getElementById('p-xpfill').style.width = pct + '%';
        var xpTxt = lv.isMax ? 'MAX szint' : (fmtNum(lv.xpInLevel) + ' / ' + fmtNum(lv.xpForNext) + ' EXP');
        if (!lv.isMax && d.nextTier && d.nextTier.deliveriesToNext > 0) {
            xpTxt += ' · ' + d.nextTier.label + '-ig még ' + d.nextTier.deliveriesToNext + ' leadás';
        }
        document.getElementById('p-xptxt').textContent = xpTxt;

        var s = d.stats || {};
        document.getElementById('p-totals').innerHTML = '' +
            '<div class="tcard"><div class="k">Leadott cím</div><div class="v">' + fmtNum(s.deliveries) + '</div></div>' +
            '<div class="tcard"><div class="k">Törékeny leadva</div><div class="v">' + fmtNum(s.fragile) + '</div></div>' +
            '<div class="tcard full"><div class="k">Összes kereset</div><div class="v cash">' + fmtMoney(s.money) + '</div></div>';

        var head = '<div class="tier-row head"><div></div><div>Rang</div><div>Cím/kör</div><div>Pénz</div><div>Törékeny</div></div>';
        var rows = tiers.map(function (t, i) {
            var current = (i + 1) === tier.index;
            var locked = lv.level < t.minLevel;
            var moneyTxt = t.payMult <= 1.0 ? 'alap' : ('+' + Math.round((t.payMult - 1) * 100) + '%');
            var frag = t.fragileChance > 0
                ? '<span class="frag yes">Igen (' + t.fragileChance + '%)</span>'
                : '<span class="frag no">Nem</span>';
            var badge = current ? '<span class="badge">Jelenlegi</span>' : '';
            return '<div class="tier-row' + (current ? ' current' : '') + (locked ? ' locked' : '') + '">' +
                '<div class="lv">' + t.minLevel + '</div>' +
                '<div class="nm">' + t.label + badge + '</div>' +
                '<div>' + t.addresses + ' cím</div>' +
                '<div>' + moneyTxt + '</div>' +
                '<div>' + frag + '</div>' +
                '</div>';
        }).join('');
        document.getElementById('p-tiers').innerHTML = head + rows;

        var bonus = d.fragileBonus || 1.6;
        document.getElementById('p-hint').innerHTML =
            'A <b>törékeny</b> csomag <b>×' + bonus + '</b> pénzt fizet, de óvatosan kell szállítani — ha túl gyorsan hajtasz, sérül és levonják az értékét. ' +
            'Minél magasabb a szinted, annál <b>több címet</b> kapsz, <b>nagyobb a pénzszorzód</b>, és <b>nagyobb eséllyel</b> kapsz értékes törékeny csomagot.';
    }

    /* ---------------- sidebar summary + header plate ---------------- */
    function renderSummary(data) {
        var st = data && data.state, m = data && data.manager;
        document.getElementById('i-level').textContent = (st && st.ok && st.level) ? st.level.level : 0;
        document.getElementById('i-tier').textContent = (st && st.ok && st.tier) ? st.tier.label : '—';
        document.getElementById('i-deliv').textContent = (m && m.ok) ? fmtNum(m.deliveries) : '0';
        var cash = (m && m.ok) ? fmtMoney(m.company) : '—';
        document.getElementById('i-company').textContent = cash;
        document.getElementById('bar-company').textContent = cash;
    }

    /* ---------------- management ---------------- */
    function avatar(img) {
        return img
            ? '<img class="drv-img" src="' + img + '" onerror="this.classList.add(\'ph\')">'
            : '<div class="drv-img ph"></div>';
    }

    /* DEPOTS — progressive unlock (1 -> 2 -> 3) */
    function renderDepots(m) {
        var el = document.getElementById('p-depots');
        var depots = (m && m.depots) || [];
        var deliveries = (m && m.deliveries) || 0;

        if (!m || !m.ok || !depots.length) {
            el.innerHTML = '<div class="mgr-empty">A telepek jelenleg nem elérhetők.</div>';
            return;
        }

        el.innerHTML = depots.map(function (d) {
            var cls = 'depot-card' + (d.unlocked ? ' open' : (d.isNext ? '' : ' locked'));
            var info = '<div class="nm">' + d.label +
                '<div class="k">Sofőr ár/km a telep szintje szerint • kapacitás: ' + d.capacity + '</div></div>';

            var right;
            if (d.unlocked) {
                right = '<div class="v ok">Feloldva</div>' +
                    '<div class="depot-tag">' + d.used + '/' + d.capacity + ' sofőr</div>';
            } else if (d.isNext) {
                var enough = deliveries >= d.reqDeliveries;
                var ppTxt = d.reqPP > 0 ? '<div class="k">PP: ' + fmtNum(d.reqPP) + '</div>' : '';
                var prog = '<div class="k">Fuvar: ' + fmtNum(deliveries) + ' / ' + fmtNum(d.reqDeliveries) + '</div>' + ppTxt;
                var priceTxt = fmtMoney(d.unlockPrice) + (d.reqPP > 0 ? ' + ' + fmtNum(d.reqPP) + ' PP' : '');
                right = '<div class="v">' + prog + '</div>' +
                    '<button class="btn btn-primary" data-act="unlockDepot" data-id="' + d.level + '"' + (enough ? '' : ' disabled') + '>' +
                    'Feloldás — ' + priceTxt + '</button>';
            } else {
                right = '<div class="v"><div class="k">Előbb az előző telep</div></div>' +
                    '<div class="depot-tag">' + fmtMoney(d.unlockPrice) + ' • ' + fmtNum(d.reqDeliveries) + ' fuvar' +
                    (d.reqPP > 0 ? ' • ' + fmtNum(d.reqPP) + ' PP' : '') + '</div>';
            }

            return '<div class="' + cls + '">' + avatar(d.img) + info + right + '</div>';
        }).join('');
    }

    /* DRIVERS — treasury box + one box per unlocked depot */
    function renderManager(m) {
        var el = document.getElementById('p-manager');
        if (!m || !m.ok) { el.innerHTML = '<div class="box"><div class="mgr-empty">A menedzsment jelenleg nem elérhető.</div></div>'; return; }

        var depots = m.depots || [];
        var mine = m.mine || [];
        var avail = m.available || [];
        var wageTxt = fmtMoney(m.wageMin) + '–' + fmtMoney(m.wageMax);

        function mineRow(d) {
            return '<div class="drv-row">' +
                avatar(d.img) +
                '<div class="nm">' + esc(d.name) + '<div class="k">ár/km: ' + fmtMoney(d.price_per_km) + ' • eddig termelt: ' + fmtMoney(d.pending) + ' • EXP: ' + fmtNum(d.exp_earned || 0) + '</div></div>' +
                '<div class="v ok">dolgozik</div>' +
                '<button class="btn btn-danger" data-act="fire" data-id="' + d.id + '">Elbocsát</button>' +
                '</div>';
        }
        function candRow(d, canHire) {
            return '<div class="drv-row cand">' +
                avatar(d.img) +
                '<div class="nm">' + esc(d.name) + '<div class="k">ár/km: ' + fmtMoney(d.price_per_km) + '</div></div>' +
                '<div class="v">' + fmtMoney(d.hire_cost) + '</div>' +
                '<button class="btn btn-primary" data-act="hire" data-id="' + d.id + '"' + (canHire ? '' : ' disabled') + '>Felvesz</button>' +
                '</div>';
        }

        var treasury = '<div class="box">' +
            '<div class="mgr-top">' +
            '  <div class="pending">Cégkassza <b>' + fmtMoney(m.company) + '</b></div>' +
            '</div>' +
            '<div class="mgr-money">' +
            '  <input id="mgr-amount" type="number" min="1" placeholder="Összeg ($)" />' +
            '  <button class="btn btn-primary" data-act="deposit">Befizetés</button>' +
            '  <button class="btn btn-ghost" data-act="withdraw">Kivét</button>' +
            '</div>' +
            '<div class="mgr-note">A sofőrök bére a kasszából megy (~' + wageTxt + '/sofőr/ciklus), a bevételük ide folyik be. A felvételi díj is a kasszából. Jobb telep = jobb (több ár/km-ű) sofőr.</div>' +
            '</div>';

        var unlocked = depots.filter(function (d) { return d.unlocked; });
        var depotsHtml;
        if (!unlocked.length) {
            depotsHtml = '<div class="box"><div class="mgr-empty">Oldd fel az első telepet a „Telepek" fülön, hogy sofőröket alkalmazhass.</div></div>';
        } else {
            depotsHtml = unlocked.map(function (dep) {
                var myHere = mine.filter(function (d) { return d.depot === dep.level; });
                var availHere = avail.filter(function (d) { return d.depot === dep.level; });
                var canHire = myHere.length < dep.capacity;

                var myHtml = myHere.length ? myHere.map(mineRow).join('')
                    : '<div class="mgr-empty">Még nincs ide alkalmazott sofőröd.</div>';
                var availHtml = availHere.length ? availHere.map(function (d) { return candRow(d, canHire); }).join('')
                    : '<div class="mgr-empty">Jelenleg nincs ehhez a telephez jelölt — várj, amíg új jelentkezik.</div>';

                return '<div class="box">' +
                    '<div class="bh"><div class="bt">' + dep.label + '</div>' +
                    '<div class="bs">' + myHere.length + ' / ' + dep.capacity + ' sofőr</div></div>' +
                    myHtml +
                    '<div class="mgr-subline">Elérhető jelöltek ide</div>' +
                    availHtml +
                    '</div>';
            }).join('');
        }

        el.innerHTML = treasury + depotsHtml;
    }

    /* OPERATIONS — permit + per-depot machines / workers / connections */
    function opsBar(pct) {
        var p = Math.max(0, Math.min(100, pct));
        var cls = 'fill' + (p < 30 ? ' low' : (p >= 70 ? ' good' : ''));
        return '<div class="ops-bar"><div class="' + cls + '" style="width:' + p + '%"></div></div>';
    }

    function renderOps(ops) {
        var el = document.getElementById('p-ops');
        if (!ops || !ops.ok) { el.innerHTML = '<div class="box"><div class="mgr-empty">A telephely üzemeltetés jelenleg nem elérhető.</div></div>'; return; }
        var cfg = ops.cfg || {};
        var html = '';

        // fragile permit
        var p = ops.permit || {};
        html += '<div class="box"><div class="bh"><div class="bt">Törékeny-engedély</div>' +
            '<div class="bs">Szint ' + (p.level || 0) + ' / ' + (p.max || 0) + '</div></div>';
        html += '<div class="ops-card"><div class="nm">Engedély' +
            '<div class="k">Magasabb engedély = nagyobb esély ÉS érték a törékenyre a saját köreidben (a max szintet a telep-szinted adja).</div></div>';
        if (p.next && (p.level || 0) < (p.max || 0)) {
            html += '<div class="v"><div class="k">+' + p.next.fragileChanceAdd + '% esély • +' + p.next.valueMultAdd + '× érték</div></div>' +
                '<button class="btn btn-primary" data-act="buyPermit">' + p.next.label + ' — ' + fmtMoney(p.next.price) + '</button>';
        } else if (!p.next) {
            html += '<div class="v ok">Maxon</div>';
        } else {
            html += '<div class="v"><div class="k">Oldj fel egy újabb telepet a nagyobb engedélyhez</div></div>';
        }
        html += '</div></div>';

        var depots = ops.depots || [];
        if (!depots.length) {
            html += '<div class="box"><div class="mgr-empty">Oldd fel az első telepet, hogy gépeket, munkásokat és kapcsolatokat vehess.</div></div>';
            el.innerHTML = html;
            return;
        }

        depots.forEach(function (d) {
            html += '<div class="box"><div class="bh"><div class="bt">' + d.label + '</div>' +
                '<div class="bs">Becsült szalag-bevétel: ' + fmtMoney(d.estIncome) + '/ciklus</div></div>';

            // sorting machines
            html += '<div class="ops-sub">Szortírozó gépek (' + d.machines.length + '/' + d.caps.machine + ')</div>';
            d.machines.forEach(function (m) {
                var broken = m.condition < cfg.breakBelow;
                var repair = (100 - m.condition) * cfg.repairPerPct;
                html += '<div class="ops-card"><div class="nm">Gép #' + m.id + (broken ? ' <span class="broken">leállt</span>' : '') +
                    '<div class="k">Kondíció: ' + m.condition + '%</div>' + opsBar(m.condition) + '</div><div class="v"></div>' +
                    (m.condition < 100
                        ? '<button class="btn btn-ghost" data-act="repairMachine" data-id="' + m.id + '">Javít — ' + fmtMoney(repair) + '</button>'
                        : '<div class="depot-tag">rendben</div>') + '</div>';
            });
            if (d.machines.length < d.caps.machine) {
                html += '<div class="ops-card cand"><div class="nm">Új szortírozó gép<div class="k">' + fmtMoney(cfg.incomePerCycle) + '/ciklus, ha van mellé munkás</div></div><div class="v"></div>' +
                    '<button class="btn btn-primary" data-act="buyMachine" data-id="' + d.level + '">Vesz — ' + fmtMoney(cfg.machineBuy) + '</button></div>';
            }

            // workers
            html += '<div class="ops-sub">Munkások (' + d.workers + '/' + d.caps.worker + ') — bér: ' + fmtMoney(cfg.workerWage) + '/fő/ciklus</div>';
            html += '<div class="ops-card"><div class="nm">Szalag-munkások<div class="k">Egy gép csak egy munkással termel</div></div>' +
                '<div class="v">' + d.workers + ' fő</div><div class="ops-actions">' +
                '<button class="btn btn-ghost" data-act="fireWorker" data-id="' + d.level + '"' + (d.workers <= 0 ? ' disabled' : '') + '>−</button>' +
                '<button class="btn btn-primary" data-act="hireWorker" data-id="' + d.level + '"' + (d.workers >= d.caps.worker ? ' disabled' : '') + '>Felvesz — ' + fmtMoney(cfg.workerHire) + '</button>' +
                '</div></div>';

            // connections
            html += '<div class="ops-sub">Kapcsolatok (' + d.connections.length + '/' + d.caps.connection + ') — teli kapcsolat: +' + cfg.perConnectionBonusPct + '% bevétel</div>';
            d.connections.forEach(function (c) {
                var nurture = (100 - c.relationship) * cfg.nurturePerPct;
                html += '<div class="ops-card"><div class="nm">Kapcsolat #' + c.id +
                    '<div class="k">Szint: ' + c.relationship + '%</div>' + opsBar(c.relationship) + '</div><div class="v"></div>' +
                    (c.relationship < 100
                        ? '<button class="btn btn-ghost" data-act="nurtureConnection" data-id="' + c.id + '">Ápol — ' + fmtMoney(nurture) + '</button>'
                        : '<div class="depot-tag">rendben</div>') + '</div>';
            });
            if (d.connections.length < d.caps.connection) {
                html += '<div class="ops-card cand"><div class="nm">Új kapcsolat<div class="k">+' + cfg.perConnectionBonusPct + '% a vonal-bevételre (teli szinten)</div></div><div class="v"></div>' +
                    '<button class="btn btn-primary" data-act="formConnection" data-id="' + d.level + '">Köt — ' + fmtMoney(cfg.connectionForm) + '</button></div>';
            }

            html += '</div>';
        });

        el.innerHTML = html;
    }

    /* EMPLOYEES (owner side) */
    function renderEmployees(m) {
        var el = document.getElementById('p-employees');
        if (!m || !m.ok) { el.innerHTML = '<div class="box"><div class="mgr-empty">Az alkalmazottak jelenleg nem elérhetők.</div></div>'; return; }
        var emps = m.employees || [];
        var canHire = (m.depots || []).some(function (d) { return d.unlocked; });

        var rows = emps.length ? emps.map(function (e) {
            var dot = '<span class="emp-dot ' + (e.online ? 'on' : 'off') + '"></span>';
            return '<div class="drv-row">' +
                '<div class="emp-av">' + (e.emp_name ? esc(e.emp_name.charAt(0).toUpperCase()) : '?') + '</div>' +
                '<div class="nm">' + dot + esc(e.emp_name || 'Alkalmazott') +
                '<div class="k">' + (e.online ? 'online' : 'offline') + ' • bér: ' + fmtMoney(e.wage) + '/ciklus • fel nem vett: ' + fmtMoney(e.pending || 0) + '</div></div>' +
                '<div class="v"></div>' +
                '<button class="btn btn-danger" data-act="fireEmployee" data-id="' + e.id + '">Kirúg</button>' +
                '</div>';
        }).join('') : '<div class="mgr-empty">Még nincs alkalmazottad. Állj egy játékos mellé, és vedd fel.</div>';

        el.innerHTML = '<div class="box">' +
            '<div class="bh"><div class="bt">Alkalmazottak</div><div class="bs">' + emps.length + ' / ' + m.empMax + ' fő</div></div>' +
            rows +
            '<div class="mgr-note">Az alkalmazott a telefonján látja, hogy nálad dolgozik, a depón pedig karbantarthatja a gépeidet és kapcsolataidat (a kasszádból fizetve). A pénzedhez nem fér hozzá. Bér: ' + fmtMoney(m.empWage) + '/fő/ciklus, max ' + m.empMax + ' fő.</div>' +
            '<div class="emp-hire"><button class="btn btn-primary" data-act="hireEmployee"' + (canHire ? '' : ' disabled') + '>Közeli játékos felvétele</button></div>' +
            '</div>';
    }

    /* MY EMPLOYMENT (employee side) — maintains the owner's machines/connections */
    function renderEmployment(emp) {
        var el = document.getElementById('p-employment');
        if (!emp || !emp.ok || !(emp.employers || []).length) {
            el.innerHTML = '<div class="box"><div class="mgr-empty">Jelenleg nem vagy alkalmazott sehol. Ha egy cégtulaj felvesz, itt karbantarthatod a gépeit és kapcsolatait.</div></div>';
            return;
        }
        var cfg = emp.cfg || {};
        var pending = emp.pending || 0;

        var head = '<div class="box">' +
            '<div class="mgr-top">' +
            '<div class="pending">Felvehető béred <b>' + fmtMoney(pending) + '</b></div>' +
            '<button class="btn btn-primary" data-act="collectWage"' + (pending > 0 ? '' : ' disabled') + '>Fizetés felvétele</button>' +
            '</div>' +
            '<div class="mgr-note">Legfeljebb ' + (emp.maxEmployers || 3) + ' cégnél lehetsz alkalmazott. A béred offline is gyűlik — itt bármikor felveheted a bankodba.</div>' +
            '</div>';

        el.innerHTML = head + emp.employers.map(function (o) {
            var html = '<div class="box"><div class="bh"><div class="bt">' + esc(o.name) + '</div>' +
                '<div class="bs">Béred: ' + fmtMoney(o.wage) + '/ciklus • felhalmozva: ' + fmtMoney(o.pending || 0) + '</div></div>';

            html += '<div class="ops-sub">Szortírozó gépek</div>';
            html += (o.machines || []).length ? o.machines.map(function (m) {
                var broken = m.condition_pct < (cfg.breakBelow != null ? cfg.breakBelow : 20);
                var repair = (100 - m.condition_pct) * cfg.repairPerPct;
                return '<div class="ops-card"><div class="nm">Gép #' + m.id + ' <span class="depot-tag">telep ' + m.depot + '</span>' + (broken ? ' <span class="broken">leállt</span>' : '') +
                    '<div class="k">Kondíció: ' + m.condition_pct + '%</div>' + opsBar(m.condition_pct) + '</div><div class="v"></div>' +
                    (m.condition_pct < 100
                        ? '<button class="btn btn-ghost" data-act="empRepair" data-id="' + m.id + '">Javít — ' + fmtMoney(repair) + '</button>'
                        : '<div class="depot-tag">rendben</div>') + '</div>';
            }).join('') : '<div class="mgr-empty">Nincs gép.</div>';

            html += '<div class="ops-sub">Kapcsolatok</div>';
            html += (o.connections || []).length ? o.connections.map(function (c) {
                var nurture = (100 - c.relationship) * cfg.nurturePerPct;
                return '<div class="ops-card"><div class="nm">Kapcsolat #' + c.id + ' <span class="depot-tag">telep ' + c.depot + '</span>' +
                    '<div class="k">Szint: ' + c.relationship + '%</div>' + opsBar(c.relationship) + '</div><div class="v"></div>' +
                    (c.relationship < 100
                        ? '<button class="btn btn-ghost" data-act="empNurture" data-id="' + c.id + '">Ápol — ' + fmtMoney(nurture) + '</button>'
                        : '<div class="depot-tag">rendben</div>') + '</div>';
            }).join('') : '<div class="mgr-empty">Nincs kapcsolat.</div>';
            return html + '</div>';
        }).join('');
    }

    /* SELL / TRANSFER — two-step confirmation */
    var sellArmed = false;
    var transferArmed = false;
    var lastManager = null;
    function renderSell(m) {
        var el = document.getElementById('p-sell');
        if (!m || !m.ok || !m.sell) { el.innerHTML = ''; return; }
        var s = m.sell;
        if (!s.canSell) {
            el.innerHTML = '<div class="box"><div class="mgr-empty">Még nincs eladható vagy átadható céged — oldj fel legalább egy telepet.</div></div>';
            sellArmed = false; transferArmed = false; return;
        }

        var sellHtml = sellArmed
            ? '<div class="box sell-card armed"><div class="nm">Biztosan eladod a céget?' +
              '<div class="k">Minden telep, gép, kapcsolat, munkás, sofőr és alkalmazott véglegesen megszűnik. A bankodra kb. <b>' + fmtMoney(s.value) + '</b> kerül.</div></div>' +
              '<div class="ops-actions"><button class="btn btn-ghost" data-act="sellCancel">Mégse</button>' +
              '<button class="btn btn-danger" data-act="sellConfirm">Végleges eladás</button></div></div>'
            : '<div class="box sell-card"><div class="nm">Cég eladása' +
              '<div class="k">Visszakapod a teljes cégkasszát és a befektetett eszközök egy részét. Becsült ár most: <b>' + fmtMoney(s.value) + '</b>.</div></div>' +
              '<button class="btn btn-danger" data-act="sellArm">Eladás…</button></div>';

        var transferHtml = transferArmed
            ? '<div class="box sell-card armed"><div class="nm">Eladási ajánlatot küldesz a melletted álló játékosnak?' +
              '<div class="k">Ha <b>elfogadja</b>, a teljes cég (telepek, eszközök, alkalmazottak, cégkassza) ÉS a ranglétrád (szinted) is az ő nevére kerül, és a megadott ár a bankjából a tiédbe kerül. Ha neki már van saját cége vagy magasabb szintje, az az elfogadással <b>véglegesen törlődik</b> (felülíródik). Te ezzel <b>MINDENT elveszítesz</b> — telep, kassza, fuvarszám, szint is nulláról indul.</div>' +
              '<input id="transfer-price" type="number" min="0" placeholder="Ár ($, üresen hagyva = ingyen)" /></div>' +
              '<div class="ops-actions"><button class="btn btn-ghost" data-act="transferCancel">Mégse</button>' +
              '<button class="btn btn-danger" data-act="transferConfirm">Ajánlat küldése</button></div></div>'
            : '<div class="box sell-card"><div class="nm">Cég eladása játékosnak' +
              '<div class="k">A teljes céget és a ranglétrádat pénzért (vagy ingyen) felajánlhatod a melletted álló játékosnak. El kell fogadnia; a sajátja felülíródik és törlődik, te pedig teljesen nulláról (telep és szint nélkül) kezded újra.</div></div>' +
              '<button class="btn btn-ghost" data-act="transferArm">Eladás…</button></div>';

        el.innerHTML = sellHtml + transferHtml;
    }

    /* ---------------- delegated button handlers (survive innerHTML swaps) ---------------- */
    function delegate(containerId) {
        document.getElementById(containerId).addEventListener('click', function (e) {
            var b = e.target.closest && e.target.closest('button[data-act]');
            if (!b || b.disabled) return;
            var idAttr = b.getAttribute('data-id');
            act(b.getAttribute('data-act'), idAttr != null ? parseInt(idAttr, 10) : undefined);
        });
    }
    delegate('p-ops');
    delegate('p-depots');
    delegate('p-employees');
    delegate('p-employment');

    // treasury: deposit/withdraw need the amount from the input
    document.getElementById('p-manager').addEventListener('click', function (e) {
        var b = e.target.closest && e.target.closest('button[data-act]');
        if (!b || b.disabled) return;
        var action = b.getAttribute('data-act');
        var idAttr = b.getAttribute('data-id');
        var amount;
        if (action === 'deposit' || action === 'withdraw') {
            var inp = document.getElementById('mgr-amount');
            amount = inp ? parseInt(inp.value, 10) : 0;
        }
        act(action, idAttr != null ? parseInt(idAttr, 10) : undefined, amount);
    });

    // sell: arm/cancel is local state only, confirm hits the server
    document.getElementById('p-sell').addEventListener('click', function (e) {
        var b = e.target.closest && e.target.closest('button[data-act]');
        if (!b || b.disabled) return;
        var a = b.getAttribute('data-act');
        if (a === 'sellArm') { sellArmed = true; transferArmed = false; renderSell(lastManager); }
        else if (a === 'sellCancel') { sellArmed = false; renderSell(lastManager); }
        else if (a === 'sellConfirm') { sellArmed = false; act('sellCompany'); }
        else if (a === 'transferArm') { transferArmed = true; sellArmed = false; renderSell(lastManager); }
        else if (a === 'transferCancel') { transferArmed = false; renderSell(lastManager); }
        else if (a === 'transferConfirm') {
            transferArmed = false;
            var priceInp = document.getElementById('transfer-price');
            var price = priceInp ? (parseInt(priceInp.value, 10) || 0) : 0;
            act('transferCompany', undefined, price);
        }
    });

    document.getElementById('nav').addEventListener('click', function (e) {
        var b = e.target.closest && e.target.closest('.nav-btn');
        if (b) setPage(b.getAttribute('data-page'));
    });
    document.getElementById('btn-close').addEventListener('click', close);
    document.getElementById('btn-close2').addEventListener('click', close);

    /* ---------------- render / server round-trip ---------------- */
    function renderAll(data, toast) {
        if (data && data.state && data.state.ok) renderCareer(data.state);
        lastManager = data && data.manager;
        renderSummary(data);
        renderDepots(data && data.manager);
        renderManager(data && data.manager);
        renderOps(data && data.ops);
        renderEmployees(data && data.manager);
        renderEmployment(data && data.employment);
        renderSell(data && data.manager);
        openOverlay();
        showToast(toast);
    }

    function need(res) { return res.need ? (' (' + fmtMoney(res.need) + ' kell)') : ''; }

    function toastFor(action, res) {
        if (!res) return { ok: false, msg: 'A szerver nem válaszolt. Próbáld újra.' };
        var r = res.reason;

        if (action === 'unlockDepot') {
            if (res.ok) return { ok: true, msg: 'Telep feloldva!' };
            if (r === 'no_money') return { ok: false, msg: 'Nincs elég pénz a bankszámládon a feloldáshoz' + need(res) + '.' };
            if (r === 'need_deliveries') return { ok: false, msg: 'Még nincs elég leadott fuvarod ehhez a telephez (' + fmtNum(res.have) + '/' + fmtNum(res.need) + ').' };
            if (r === 'need_pp') return { ok: false, msg: 'Ehhez a telephez ' + fmtNum(res.need) + ' PP is kell (most ' + fmtNum(res.have) + ').' };
            if (r === 'order') return { ok: false, msg: 'Előbb az előző telepet kell feloldanod.' };
            return { ok: false, msg: 'A feloldás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'hire') {
            if (res.ok) return { ok: true, msg: 'Felvetted: ' + res.name + ' (díj: ' + fmtMoney(res.cost) + ')' };
            if (r === 'locked') return { ok: false, msg: 'Ehhez a sofőrhöz előbb fel kell oldanod a megfelelő telepet.' };
            if (r === 'max') return { ok: false, msg: 'Ez a telep megtelt — nincs több szabad sofőr-hely.' };
            if (r === 'taken') return { ok: false, msg: 'Ezt a sofőrt már elvitték — válassz másikat.' };
            if (r === 'no_company_money') return { ok: false, msg: 'Nincs elég pénz a cégkasszában a felvételhez' + need(res) + '. Tölts fel!' };
            if (r === 'invalid') return { ok: false, msg: 'Érvénytelen kérés — frissítsd a panelt és próbáld újra.' };
            return { ok: false, msg: 'A felvétel nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'deposit') {
            if (res.ok) return { ok: true, msg: 'Befizetve a kasszába: ' + fmtMoney(res.amount) };
            if (r === 'no_money') return { ok: false, msg: 'Nincs ennyi pénz a bankszámládon' + need(res) + '.' };
            if (r === 'bad_amount') return { ok: false, msg: 'Adj meg egy érvényes összeget.' };
            return { ok: false, msg: 'A befizetés nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'withdraw') {
            if (res.ok) return { ok: true, msg: 'Kivéve a kasszából: ' + fmtMoney(res.amount) };
            if (r === 'no_company_money') return { ok: false, msg: 'Nincs ennyi pénz a cégkasszában' + need(res) + '.' };
            if (r === 'bad_amount') return { ok: false, msg: 'Adj meg egy érvényes összeget.' };
            return { ok: false, msg: 'A kivét nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'fire') {
            if (res.ok) return { ok: true, msg: 'Sofőr elbocsátva.' };
            return { ok: false, msg: 'Az elbocsátás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        // depot operations
        var noCompany = 'Nincs elég pénz a cégkasszában' + need(res) + '. Tölts fel!';
        if (action === 'buyMachine') {
            if (res.ok) return { ok: true, msg: 'Új szortírozó gép beszerezve (' + fmtMoney(res.cost) + ').' };
            if (r === 'max') return { ok: false, msg: 'Ezen a telepen elérted a max gépszámot.' };
            if (r === 'locked') return { ok: false, msg: 'Előbb oldd fel ezt a telepet.' };
            if (r === 'no_company_money') return { ok: false, msg: noCompany };
            return { ok: false, msg: 'A gép vétele nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'repairMachine') {
            if (res.ok) return { ok: true, msg: 'Gép megjavítva (' + fmtMoney(res.cost) + ').' };
            if (r === 'full') return { ok: false, msg: 'Ez a gép már 100%-on van.' };
            if (r === 'no_company_money') return { ok: false, msg: noCompany };
            return { ok: false, msg: 'A javítás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'hireWorker') {
            if (res.ok) return { ok: true, msg: 'Munkás felvéve (' + fmtMoney(res.cost) + ').' };
            if (r === 'max') return { ok: false, msg: 'Ezen a telepen elérted a max munkásszámot.' };
            if (r === 'locked') return { ok: false, msg: 'Előbb oldd fel ezt a telepet.' };
            if (r === 'no_company_money') return { ok: false, msg: noCompany };
            return { ok: false, msg: 'A felvétel nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'fireWorker') {
            if (res.ok) return { ok: true, msg: 'Munkás elbocsátva.' };
            if (r === 'none') return { ok: false, msg: 'Nincs elbocsátható munkás ezen a telepen.' };
            return { ok: false, msg: 'Az elbocsátás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'formConnection') {
            if (res.ok) return { ok: true, msg: 'Új kapcsolat kötve (' + fmtMoney(res.cost) + ').' };
            if (r === 'max') return { ok: false, msg: 'Ezen a telepen elérted a max kapcsolatszámot.' };
            if (r === 'locked') return { ok: false, msg: 'Előbb oldd fel ezt a telepet.' };
            if (r === 'no_company_money') return { ok: false, msg: noCompany };
            return { ok: false, msg: 'A kapcsolat kötése nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'nurtureConnection') {
            if (res.ok) return { ok: true, msg: 'Kapcsolat ápolva (' + fmtMoney(res.cost) + ').' };
            if (r === 'full') return { ok: false, msg: 'Ez a kapcsolat már 100%-on van.' };
            if (r === 'no_company_money') return { ok: false, msg: noCompany };
            return { ok: false, msg: 'Az ápolás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'buyPermit') {
            if (res.ok) return { ok: true, msg: 'Megvetted a(z) ' + res.label + ' törékeny-engedélyt!' };
            if (r === 'maxed') return { ok: false, msg: 'Már a legmagasabb engedélyed van.' };
            if (r === 'depot_cap') return { ok: false, msg: 'Ehhez az engedély-szinthez előbb fel kell oldanod a megfelelő telepet.' };
            if (r === 'no_money') return { ok: false, msg: 'Nincs elég pénz a bankszámládon' + need(res) + '.' };
            if (r === 'need_pp') return { ok: false, msg: 'Nincs elég PP-d ehhez (' + fmtNum(res.have) + '/' + fmtNum(res.need) + ').' };
            return { ok: false, msg: 'Az engedély vétele nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'sellCompany') {
            if (res.ok) return { ok: true, msg: 'Eladtad a céged ' + fmtMoney(res.total) + '-ért!' };
            if (r === 'nothing') return { ok: false, msg: 'Nincs eladható céged.' };
            if (r === 'busy') return { ok: false, msg: 'Az eladás már folyamatban van — várj egy pillanatot.' };
            return { ok: false, msg: 'Az eladás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'transferCompany') {
            if (res.ok) return { ok: true, msg: 'Ajánlat elküldve ' + res.name + ' részére — el kell fogadnia.' };
            if (r === 'no_target') return { ok: false, msg: 'Nincs a közelben játékos, akinek eladhatnád.' };
            if (r === 'too_far') return { ok: false, msg: 'A játékos túl messze van — állj közelebb.' };
            if (r === 'nothing') return { ok: false, msg: 'Nincs eladható céged.' };
            return { ok: false, msg: 'Az eladás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'hireEmployee') {
            if (res.ok) return { ok: true, msg: res.name + ' felvéve alkalmazottnak (' + fmtMoney(res.wage) + '/ciklus).' };
            if (r === 'no_target') return { ok: false, msg: 'Nincs a közelben felvehető játékos.' };
            if (r === 'too_far') return { ok: false, msg: 'A játékos túl messze van — állj közelebb.' };
            if (r === 'no_company') return { ok: false, msg: 'Előbb oldj fel egy telepet, hogy alkalmazhass.' };
            if (r === 'max') return { ok: false, msg: 'Elérted a max alkalmazottszámot.' };
            if (r === 'already') return { ok: false, msg: 'Ez a játékos már nálad dolgozik.' };
            if (r === 'target_full') return { ok: false, msg: 'Ez a játékos már 3 cégnél dolgozik — nem vehető fel.' };
            return { ok: false, msg: 'A felvétel nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'collectWage') {
            if (res.ok) return { ok: true, msg: 'Felvetted a béredet: ' + fmtMoney(res.amount) + '.' };
            if (r === 'nothing') return { ok: false, msg: 'Jelenleg nincs felvehető béred.' };
            return { ok: false, msg: 'A bér felvétele nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'fireEmployee') {
            if (res.ok) return { ok: true, msg: 'Alkalmazott kirúgva.' };
            return { ok: false, msg: 'A kirúgás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'empRepair') {
            if (res.ok) return { ok: true, msg: 'Megjavítottad a gépet (' + fmtMoney(res.cost) + ' a munkaadó kasszájából).' };
            if (r === 'full') return { ok: false, msg: 'Ez a gép már 100%-on van.' };
            if (r === 'no_company_money') return { ok: false, msg: 'A munkaadó cégkasszája nem fedezi a javítást' + need(res) + '.' };
            if (r === 'not_employee') return { ok: false, msg: 'Már nem vagy itt alkalmazott.' };
            return { ok: false, msg: 'A javítás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        if (action === 'empNurture') {
            if (res.ok) return { ok: true, msg: 'Ápoltad a kapcsolatot (' + fmtMoney(res.cost) + ' a munkaadó kasszájából).' };
            if (r === 'full') return { ok: false, msg: 'Ez a kapcsolat már 100%-on van.' };
            if (r === 'no_company_money') return { ok: false, msg: 'A munkaadó cégkasszája nem fedezi az ápolást' + need(res) + '.' };
            if (r === 'not_employee') return { ok: false, msg: 'Már nem vagy itt alkalmazott.' };
            return { ok: false, msg: 'Az ápolás nem sikerült (' + (r || 'ismeretlen') + ').' };
        }
        return { ok: !!res.ok, msg: '' };
    }

    async function act(action, id, amount) {
        if (!IN_GAME) return;
        try {
            var r = await fetch('https://' + RES + '/bcx:managerAction', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ action: action, id: id, amount: amount })
            });
            var j = await r.json();
            renderAll(j.data, toastFor(action, j.result));   // keeps the current page selected
        } catch (e) {}
    }

    window.addEventListener('message', function (e) {
        var d = e.data;
        if (!d) return;
        if (d.action === 'openPanel') { setPage('career'); renderAll(d.data || {}, null); }
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') close();
    });

    /* button sounds (Web Audio, no asset) + never leave a sticky focus on a button */
    var actx;
    function blip(freq, dur, vol) {
        try {
            actx = actx || new (window.AudioContext || window.webkitAudioContext)();
            if (actx.state === 'suspended') actx.resume();
            var o = actx.createOscillator(), g = actx.createGain();
            o.type = 'sine'; o.frequency.value = freq;
            g.gain.setValueAtTime(0.0001, actx.currentTime);
            g.gain.linearRampToValueAtTime(vol, actx.currentTime + 0.005);
            g.gain.exponentialRampToValueAtTime(0.0001, actx.currentTime + dur);
            o.connect(g); g.connect(actx.destination);
            o.start(); o.stop(actx.currentTime + dur);
        } catch (e) {}
    }
    var lastHover = null;
    document.addEventListener('mouseover', function (e) {
        var b = e.target.closest && e.target.closest('button, .close');
        if (b && b !== lastHover) { lastHover = b; blip(620, 0.04, 0.02); } else if (!b) lastHover = null;
    });
    document.addEventListener('mousedown', function (e) {
        if (e.target.closest && e.target.closest('button')) e.preventDefault();   // don't trap focus on the button
    });
    document.addEventListener('click', function (e) {
        var b = e.target.closest && e.target.closest('button, .close');
        if (b) { blip(420, 0.08, 0.05); if (b.blur) b.blur(); }
    });

    buildNav();
    setPage('career');

    window.Panel = { close: close, act: act, page: setPage };

    /* browser preview */
    if (!IN_GAME) {
        renderAll({
            state: {
                ok: true, fragileBonus: 1.6,
                stats: { deliveries: 142, money: 3875400, fragile: 18 },
                level: { level: 6, isMax: false, xpInLevel: 9000, xpForNext: 38000 },
                tier: { index: 3, label: 'Tapasztalt' },
                nextTier: { label: 'Profi', minLevel: 9, addresses: 9, payMult: 1.45, fragileChance: 35, xpToNext: 96000, deliveriesToNext: 96 },
                tiers: [
                    { label: 'Gyakornok', minLevel: 0, addresses: 3, payMult: 1.0, fragileChance: 0 },
                    { label: 'Futár', minLevel: 3, addresses: 5, payMult: 1.1, fragileChance: 15 },
                    { label: 'Tapasztalt', minLevel: 6, addresses: 7, payMult: 1.25, fragileChance: 25 },
                    { label: 'Profi', minLevel: 9, addresses: 9, payMult: 1.45, fragileChance: 35 },
                    { label: 'Mester', minLevel: 12, addresses: 11, payMult: 1.7, fragileChance: 45 },
                    { label: 'Elit', minLevel: 15, addresses: 14, payMult: 2.0, fragileChance: 60 }
                ]
            },
            manager: {
                ok: true, payoutEvery: 30, wageMin: 3000, wageMax: 7000, company: 250000, deliveries: 320,
                depots: [
                    { level: 1, label: 'Belvárosi Telep', img: 'https://bootdey.com/img/Content/avatar/avatar1.png', unlockPrice: 2000000, reqDeliveries: 50, capacity: 3, unlocked: true, isNext: false, used: 2 },
                    { level: 2, label: 'Kikötői Telep', img: 'https://bootdey.com/img/Content/avatar/avatar2.png', unlockPrice: 8000000, reqDeliveries: 250, capacity: 4, unlocked: false, isNext: true, used: 0 },
                    { level: 3, label: 'Reptéri Telep', img: 'https://bootdey.com/img/Content/avatar/avatar3.png', unlockPrice: 30000000, reqDeliveries: 750, reqPP: 5000, capacity: 5, unlocked: false, isNext: false, used: 0 }
                ],
                mine: [
                    { id: 1, name: 'Pedro Aquino', img: 'https://bootdey.com/img/Content/avatar/avatar1.png', depot: 1, price_per_km: 1150, pending: 184000, exp_earned: 320 },
                    { id: 2, name: 'Kirk Cook', img: 'https://bootdey.com/img/Content/avatar/avatar2.png', depot: 1, price_per_km: 980, pending: 52500, exp_earned: 95 }
                ],
                available: [
                    { id: 5, name: 'Wells Wyatt', img: 'https://bootdey.com/img/Content/avatar/avatar3.png', depot: 1, hire_cost: 58000, price_per_km: 1200 },
                    { id: 6, name: 'Goff Raymond', img: 'https://bootdey.com/img/Content/avatar/avatar4.png', depot: 2, hire_cost: 120000, price_per_km: 1920 }
                ],
                employees: [
                    { id: 1, emp_name: 'John Mason', wage: 8000, online: true, pending: 24000 },
                    { id: 2, emp_name: 'Eva Doyle', wage: 8000, online: false, pending: 8000 }
                ],
                empWage: 8000, empMax: 5,
                sell: { value: 4120000, minDepots: 1, canSell: true }
            },
            employment: {
                ok: true, pending: 32000, maxEmployers: 3,
                cfg: { repairPerPct: 1500, nurturePerPct: 1000, breakBelow: 20 },
                employers: [
                    { name: 'Carlos Vega', wage: 8000, pending: 32000,
                      machines: [ { id: 3, depot: 1, condition_pct: 18 }, { id: 4, depot: 1, condition_pct: 64 } ],
                      connections: [ { id: 2, depot: 1, relationship: 35 } ] }
                ]
            },
            ops: {
                ok: true, company: 250000,
                permit: { level: 0, max: 1, next: { level: 1, label: 'Alap', price: 1000000, fragileChanceAdd: 10, valueMultAdd: 0.3 } },
                cfg: { machineBuy: 250000, repairPerPct: 1500, breakBelow: 20, incomePerCycle: 40000,
                       workerHire: 50000, workerWage: 6000, connectionForm: 300000, nurturePerPct: 1000, perConnectionBonusPct: 20, payoutEvery: 30 },
                depots: [
                    { level: 1, label: 'Belvárosi Telep', estIncome: 62800, caps: { machine: 2, worker: 3, connection: 1 },
                      machines: [ { id: 1, condition: 76 }, { id: 2, condition: 14 } ],
                      workers: 2,
                      connections: [ { id: 1, relationship: 40 } ] }
                ]
            }
        }, null);
        // preview only: #<page> opens that nav page straight away
        if (location.hash) setPage(location.hash.slice(1));
    }
})();
