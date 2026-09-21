/* bc_express — BC Express futár app (RoadPhone custom app) */
(function () {
    'use strict';
    var HOST = location.hostname || '';
    var RES = HOST.replace(/^cfx-nui-/, '') || 'bc_express';
    var IN_GAME = HOST.indexOf('cfx-nui-') === 0 || location.protocol === 'nui:' || typeof window.GetParentResourceName === 'function';

    var pollTimer = null;
    var currentTab = 'work';

    function fmtMoney(n) { return '$' + (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    function fmtNum(n) { return (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    // játékos-vezérelt szövegek (pl. karakternév) innerHTML-be fűzés előtt escape-elve (XSS ellen)
    function esc(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    function show(id) {
        var els = document.querySelectorAll('.screen');
        for (var i = 0; i < els.length; i++) els[i].classList.remove('active');
        var el = document.getElementById(id);
        if (el) el.classList.add('active');
        var tb = document.getElementById('tabbar');
        if (tb) tb.style.display = (id === 'screen-loading' || id === 'screen-error') ? 'none' : 'flex';
    }

    async function post(cb, body) {
        if (!IN_GAME) return demo(cb);
        try {
            var res = await fetch('https://' + RES + '/' + cb, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify(body || {})
            });
            return await res.json();
        } catch (e) { return { ok: false }; }
    }

    function levelCard(lv, tier, next) {
        var pct = lv.isMax ? 100 : (lv.xpForNext > 0 ? Math.min(100, Math.round((lv.xpInLevel / lv.xpForNext) * 100)) : 0);
        var xpTxt = lv.isMax ? 'MAX szint' : (fmtNum(lv.xpInLevel) + ' / ' + fmtNum(lv.xpForNext) + ' EXP');

        var nextHtml = '';
        if (next) {
            var moreMoney = Math.round((next.payMult / tier.payMult - 1) * 100);
            var bits = [];
            bits.push(next.addresses + ' cím/kör');
            if (moreMoney > 0) bits.push('+' + moreMoney + '% pénz');
            if (next.fragileChance > tier.fragileChance) bits.push('törékeny (értékes) csomag');
            var needTxt = (next.deliveriesToNext > 0)
                ? 'még <b>' + next.deliveriesToNext + ' leadás</b> (' + fmtNum(next.xpToNext) + ' EXP)'
                : '<b>most léphetsz</b>';
            nextHtml = '<div class="next">Következő rang: <b>' + next.label + '</b> (' + next.minLevel + '. szint) — ' + needTxt + '<br>' + bits.join(' · ') + '</div>';
        } else {
            nextHtml = '<div class="next">Elérted a legmagasabb rangot.</div>';
        }

        return '' +
            '<div class="row"><div class="lvl"><b>' + lv.level + '.</b> szint</div><div class="tier">' + tier.label + ' · ' + tier.addresses + ' cím/kör</div></div>' +
            '<div class="xp-bar"><div class="xp-fill" style="width:' + pct + '%"></div></div>' +
            '<div class="xp-txt">' + xpTxt + '</div>' +
            nextHtml;
    }

    function statsCards(s) {
        return '' +
            '<div class="stat-card"><div class="k">Leadott cím</div><div class="v">' + fmtNum(s.deliveries) + '</div></div>' +
            '<div class="stat-card"><div class="k">Törékeny leadva</div><div class="v">' + fmtNum(s.fragile) + '</div></div>' +
            '<div class="stat-card full"><div class="k">Összes kereset</div><div class="v gold">' + fmtMoney(s.money) + '</div></div>';
    }

    function renderNoJob(r) {
        document.getElementById('level-card').innerHTML = levelCard(r.level, r.tier, r.nextTier);
        document.getElementById('stats-nojob').innerHTML = statsCards(r.stats || {});
        show('screen-nojob');
    }

    function renderJob(r) {
        var job = r.job;
        var done = job.delivered || 0;
        var size = job.size || job.addresses.length;
        var pct = size > 0 ? Math.round((done / size) * 100) : 0;

        document.getElementById('size-badge').textContent = size + ' cím';
        document.getElementById('progress-label').textContent = done + ' / ' + size + ' cím';
        document.getElementById('pending-pay').textContent = fmtMoney(job.pending);
        document.getElementById('bar-fill').style.width = pct + '%';

        document.getElementById('fragile-banner').style.display = job.hasFragile ? 'flex' : 'none';

        var ded = document.getElementById('deduction');
        if (job.deduction > 0) {
            ded.style.display = 'block';
            ded.textContent = 'Törékeny-levonás eddig: -' + fmtMoney(job.deduction);
        } else {
            ded.style.display = 'none';
        }

        var current = job.current;
        var returning = job.state === 'returning';

        var rows = job.addresses.map(function (a, i) {
            var n = i + 1;
            var isActive = !returning && (n === current) && !a.done;
            var cls = 'addr' + (a.done ? ' done' : (isActive ? ' active' : ''));
            var status = a.done ? 'Kézbesítve' : (isActive ? 'Aktív cél — koppints a navigációhoz' : 'Függőben');
            var tag = a.fragile ? '<span class="frag-tag">TÖRÉKENY</span>' : '';
            var click = isActive ? ' onclick="App.nav(' + a.x + ',' + a.y + ')"' : '';
            return '' +
                '<div class="' + cls + '"' + click + '>' +
                '  <div class="num">' + n + '</div>' +
                '  <div class="info"><div class="t">Cím #' + n + tag + '</div><div class="s">' + status + '</div></div>' +
                '  <div class="reward">' + fmtMoney(a.reward) + '</div>' +
                '</div>';
        }).join('');
        document.getElementById('addr-list').innerHTML = rows;

        document.getElementById('job-note').textContent = returning
            ? 'Minden csomag kézbesítve! Vidd vissza a kocsit a depóba a fizetségedért.'
            : 'Hajts a kijelölt címhez, vedd ki a dobozt a kocsi hátuljából, és tedd az automatába.';

        show('screen-job');
    }

    async function load() {
        var r = await post('bcx:getState');
        if (!r || !r.ok) {
            document.getElementById('error-text').textContent = 'Nem sikerült lekérni az állapotot.';
            return show('screen-error');
        }
        if (r.active && r.job) renderJob(r); else renderNoJob(r);
    }

    /* ---------------- CÉG (csak nézet) ---------------- */
    function renderCompany(r) {
        var m = r.manager || {}, o = r.ops || {}, cfg = o.cfg || {};
        var body = document.getElementById('company-body');
        var html = '';

        var company = (o.company != null ? o.company : m.company) || 0;
        html += '<div class="co-cash"><div class="k">Cégkassza</div><div class="v">' + fmtMoney(company) + '</div></div>';

        // sofőrök + eddig termelt
        var mine = m.mine || [];
        var totalDrv = mine.reduce(function (a, d) { return a + (d.pending || 0); }, 0);
        html += '<div class="co-title">Sofőrök (' + mine.length + ') — eddig termelt: ' + fmtMoney(totalDrv) + '</div>';
        html += mine.length ? mine.map(function (d) {
            return '<div class="co-row"><div class="nm">' + d.name + '<div class="s">ár/km: ' + fmtMoney(d.price_per_km) + ' • EXP: ' + fmtNum(d.exp_earned || 0) + '</div></div><div class="val gold">' + fmtMoney(d.pending) + '</div></div>';
        }).join('') : '<div class="muted small">Még nincs sofőröd.</div>';

        // törékeny-engedély
        if (o.permit) {
            html += '<div class="co-title">Törékeny-engedély</div>';
            html += '<div class="co-row"><div class="nm">Engedély szint</div><div class="val">' + (o.permit.level || 0) + ' / ' + (o.permit.max || 0) + '</div></div>';
        }

        // telepenkénti szortírozó vonal
        var depots = o.depots || [];
        if (depots.length) {
            depots.forEach(function (d) {
                html += '<div class="co-title">' + d.label + '</div>';
                html += '<div class="co-grid">' +
                    '<div class="co-card"><div class="k">Gépek</div><div class="v">' + d.machines.length + '/' + d.caps.machine + '</div></div>' +
                    '<div class="co-card"><div class="k">Munkások</div><div class="v">' + d.workers + '/' + d.caps.worker + '</div></div>' +
                    '<div class="co-card"><div class="k">Kapcsolatok</div><div class="v">' + d.connections.length + '/' + d.caps.connection + '</div></div>' +
                    '</div>';
                d.machines.forEach(function (mc) {
                    var p = Math.max(0, Math.min(100, mc.condition));
                    var broken = mc.condition < (cfg.breakBelow != null ? cfg.breakBelow : 20);
                    var cls = 'co-fill' + (broken ? ' low' : (mc.condition >= 70 ? ' good' : ''));
                    html += '<div class="co-bar-row"><span class="lbl">Gép #' + mc.id + (broken ? ' (leállt)' : '') + '</span>' +
                        '<div class="co-bar"><div class="' + cls + '" style="width:' + p + '%"></div></div><span class="pct">' + mc.condition + '%</span></div>';
                });
                html += '<div class="co-row"><div class="nm">Eddig termelt (szalag)</div><div class="val gold">' + fmtMoney(d.earned) + '</div></div>';
                html += '<div class="co-row"><div class="nm">Becsült bevétel / ciklus</div><div class="val">' + fmtMoney(d.estIncome) + '</div></div>';
            });
        } else {
            html += '<div class="muted small">Nincs feloldott telep — a depóban tudsz feloldani.</div>';
        }

        html += '<div class="muted small co-foot">Ez csak nézet — vásárolni, javítani és felvenni a depó paneljén tudsz.</div>';
        body.innerHTML = html;
        show('screen-company');
    }

    async function loadCompany() {
        var r = await post('bcx:getCompany');
        if (!r || !r.ok) {
            document.getElementById('error-text').textContent = 'Nem sikerült lekérni a céges adatokat.';
            return show('screen-error');
        }
        renderCompany(r);
    }

    /* ---------------- MUNKAHELY (csak nézet — ahol alkalmazott vagy) ---------------- */
    function renderEmployment(r) {
        var body = document.getElementById('employment-body');
        var emps = (r && r.employers) || [];
        var cfg = (r && r.cfg) || {};
        if (!emps.length) {
            body.innerHTML = '<div class="info-box"><div class="t">Nincs munkahelyed</div>' +
                '<div class="muted">Jelenleg egyetlen cégtulaj sem vett fel. Ha valaki felvesz, itt látod, és a depón karbantarthatod a gépeit.</div></div>';
            return show('screen-employment');
        }
        function bar(pct, low) {
            var p = Math.max(0, Math.min(100, pct));
            var cls = 'co-fill' + (pct < (low || 30) ? ' low' : (pct >= 70 ? ' good' : ''));
            return '<div class="co-bar"><div class="' + cls + '" style="width:' + p + '%"></div></div>';
        }
        var html = '<div class="co-cash"><div class="k">Felvehető béred (összes)</div><div class="v">' + fmtMoney(r.pending || 0) + '</div></div>';
        html += '<div class="muted small">Legfeljebb ' + (r.maxEmployers || 3) + ' cégnél lehetsz alkalmazott. A bér offline is gyűlik — a depón tudod felvenni a bankodba.</div>';
        emps.forEach(function (o) {
            html += '<div class="co-title">' + esc(o.name) + '</div>';
            html += '<div class="co-row"><div class="nm">Béred</div><div class="val gold">' + fmtMoney(o.wage) + ' / ciklus</div></div>';
            html += '<div class="co-row"><div class="nm">Felhalmozva</div><div class="val gold">' + fmtMoney(o.pending || 0) + '</div></div>';

            html += '<div class="co-title">Gépek (' + (o.machines || []).length + ')</div>';
            (o.machines || []).forEach(function (mc) {
                var broken = mc.condition_pct < (cfg.breakBelow != null ? cfg.breakBelow : 20);
                html += '<div class="co-bar-row"><span class="lbl">Gép #' + mc.id + ' (telep ' + mc.depot + ')' + (broken ? ' (leállt)' : '') + '</span>' +
                    bar(mc.condition_pct, cfg.breakBelow) + '<span class="pct">' + mc.condition_pct + '%</span></div>';
            });
            if (!(o.machines || []).length) html += '<div class="muted small">Nincs gép.</div>';

            html += '<div class="co-title">Kapcsolatok (' + (o.connections || []).length + ')</div>';
            (o.connections || []).forEach(function (c) {
                html += '<div class="co-bar-row"><span class="lbl">Kapcsolat #' + c.id + ' (telep ' + c.depot + ')</span>' +
                    bar(c.relationship, 30) + '<span class="pct">' + c.relationship + '%</span></div>';
            });
            if (!(o.connections || []).length) html += '<div class="muted small">Nincs kapcsolat.</div>';
        });
        html += '<div class="muted small co-foot">Ez csak nézet — javítani és ápolni a depó paneljén tudsz.</div>';
        body.innerHTML = html;
        show('screen-employment');
    }

    async function loadEmployment() {
        var r = await post('bcx:getEmployment');
        if (!r || !r.ok) {
            document.getElementById('error-text').textContent = 'Nem sikerült lekérni a munkahely adatait.';
            return show('screen-error');
        }
        renderEmployment(r);
    }

    function tab(name) {
        currentTab = name;
        var tabs = document.querySelectorAll('#tabbar .tab');
        for (var i = 0; i < tabs.length; i++) tabs[i].classList.toggle('active', tabs[i].getAttribute('data-tab') === name);
        if (name === 'company') loadCompany();
        else if (name === 'employment') loadEmployment();
        else load();
    }

    function nav(x, y) { post('bcx:waypoint', { x: x, y: y }); }

    function startPoll() {
        if (pollTimer) return;
        pollTimer = setInterval(function () {
            if (document.visibilityState !== 'visible') return;
            if (currentTab === 'company') loadCompany();
            else if (currentTab === 'employment') loadEmployment();
            else load();
        }, 5000);
    }

    /* böngészős demó */
    function demo(cb) {
        if (cb === 'bcx:getState') {
            return Promise.resolve({
                ok: true, hasPhone: true, active: true,
                stats: { deliveries: 23, money: 487500, fragile: 4 },
                level: { level: 5, totalXp: 47000, isMax: false, xpInLevel: 12000, xpForNext: 30000 },
                tier: { index: 2, label: 'Futár', addresses: 5, payMult: 1.10, fragileChance: 15 },
                nextTier: { label: 'Tapasztalt', minLevel: 6, addresses: 7, payMult: 1.25, fragileChance: 25, xpToNext: 43000, deliveriesToNext: 43 },
                job: {
                    size: 5, delivered: 1, current: 2, state: 'driving', pending: 71087, hasFragile: true, deduction: 4000,
                    addresses: [
                        { x: 451.1, y: -794.4, z: 26.3, reward: 71087, fragile: false, done: true },
                        { x: -8.5, y: -1079.6, z: 25.6, reward: 55480, fragile: true, done: false },
                        { x: -302.4, y: -927.4, z: 30.0, reward: 72564, fragile: false, done: false },
                        { x: -402.1, y: -128.1, z: 37.5, reward: 13222, fragile: false, done: false },
                        { x: 1210.8, y: -3196.6, z: 5.0, reward: 52666, fragile: false, done: false }
                    ]
                }
            });
        }
        if (cb === 'bcx:getCompany') {
            return Promise.resolve({
                ok: true,
                manager: {
                    ok: true, company: 250000,
                    mine: [
                        { name: 'Pedro Aquino', price_per_km: 1150, pending: 184000, exp_earned: 320 },
                        { name: 'Kirk Cook', price_per_km: 980, pending: 52500, exp_earned: 95 }
                    ]
                },
                ops: {
                    ok: true, company: 250000,
                    permit: { level: 1, max: 1 },
                    cfg: { breakBelow: 20 },
                    depots: [
                        { level: 1, label: 'Belvárosi Telep', estIncome: 62800, earned: 940000,
                          caps: { machine: 2, worker: 3, connection: 1 }, workers: 2,
                          machines: [ { id: 1, condition: 76 }, { id: 2, condition: 14 } ],
                          connections: [ { id: 1, relationship: 40 } ] }
                    ]
                }
            });
        }
        if (cb === 'bcx:getEmployment') {
            return Promise.resolve({
                ok: true, pending: 32000, maxEmployers: 3,
                cfg: { repairPerPct: 1500, nurturePerPct: 1000, breakBelow: 20 },
                employers: [
                    { name: 'Carlos Vega', wage: 8000, pending: 32000,
                      machines: [ { id: 3, depot: 1, condition_pct: 18 }, { id: 4, depot: 1, condition_pct: 64 } ],
                      connections: [ { id: 2, depot: 1, relationship: 35 } ] }
                ]
            });
        }
        return Promise.resolve({ ok: true });
    }

    /* gomb-hangok (Web Audio, nincs hozzá fájl) + a fókusz-csapda elkerülése, hogy a telefon ESC-re záruljon */
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
        var b = e.target.closest && e.target.closest('button');
        if (b && b !== lastHover) { lastHover = b; blip(620, 0.04, 0.02); } else if (!b) lastHover = null;
    });
    // mousedown: ne kapjon fókuszt a gomb (különben a telefon iframe elnyeli az ESC-et)
    document.addEventListener('mousedown', function (e) {
        if (e.target.closest && e.target.closest('button')) e.preventDefault();
    });
    document.addEventListener('click', function (e) {
        var b = e.target.closest && e.target.closest('button');
        if (b) { blip(420, 0.08, 0.05); if (b.blur) b.blur(); }
    });

    window.App = { load: load, nav: nav, tab: tab, loadCompany: loadCompany, loadEmployment: loadEmployment };
    startPoll();
    load();
})();
