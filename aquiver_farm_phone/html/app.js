/* ===== aquiver_farm_phone — phone app logic ===== */
(function () {
    'use strict';

    const HOST = location.hostname || '';
    const RES = HOST.replace(/^cfx-nui-/, '') || 'aquiver_farm_phone';
    const IN_GAME = HOST.indexOf('cfx-nui-') === 0 || location.protocol === 'nui:' || typeof window.GetParentResourceName === 'function';

    let state = { farms: [], purchasable: [], price: 15000000, current: null };

    /* ---------- ambient / UI sounds (Web Audio) ---------- */
    const Sfx = (function () {
        let ctx = null, muted = false;
        try { muted = localStorage.getItem('farm_muted') === '1'; } catch (e) {}
        function ac() {
            if (!ctx) { try { ctx = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) { return null; } }
            if (ctx && ctx.state === 'suspended') ctx.resume();
            return ctx;
        }
        function notes(seq, type, vol) {
            if (muted) return;
            const c = ac(); if (!c) return;
            const t0 = c.currentTime;
            seq.forEach(n => {
                const o = c.createOscillator(), g = c.createGain();
                o.type = type || 'sine';
                o.frequency.value = n[0];
                const start = t0 + (n[1] || 0), dur = n[2] || 0.08, v = (vol || 0.05);
                g.gain.setValueAtTime(0.0001, start);
                g.gain.exponentialRampToValueAtTime(v, start + 0.012);
                g.gain.exponentialRampToValueAtTime(0.0001, start + dur);
                o.connect(g); g.connect(c.destination);
                o.start(start); o.stop(start + dur + 0.02);
            });
        }
        return {
            tap:     () => notes([[660, 0, 0.05]], 'sine', 0.035),
            open:    () => notes([[523, 0, 0.07], [784, 0.06, 0.09]], 'sine', 0.045),
            back:    () => notes([[523, 0, 0.06], [392, 0.05, 0.08]], 'sine', 0.04),
            gps:     () => notes([[880, 0, 0.06], [1175, 0.05, 0.08]], 'triangle', 0.045),
            success: () => notes([[523, 0, 0.09], [659, 0.09, 0.09], [988, 0.18, 0.16]], 'sine', 0.06),
            error:   () => notes([[220, 0, 0.18], [165, 0.06, 0.2]], 'sawtooth', 0.04),
            isMuted: () => muted,
            toggle:  () => { muted = !muted; try { localStorage.setItem('farm_muted', muted ? '1' : '0'); } catch (e) {} if (!muted) notes([[784, 0, 0.07]], 'sine', 0.05); return muted; }
        };
    })();

    /* ---------- helpers ---------- */
    function fmtMoney(n) { return '$' + (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    function fmtNum(n) { return (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    function fmtDate(unix) {
        if (!unix) return '';
        const d = new Date(Number(unix) * 1000);
        return d.toLocaleDateString('hu-HU') + ' ' + d.toLocaleTimeString('hu-HU', { hour: '2-digit', minute: '2-digit' });
    }
    function esc(s) { return String(s == null ? '' : s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c])); }
    function show(id) {
        document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
        document.getElementById(id).classList.add('active');
    }
    function setTheme(dark) { document.body.className = dark ? 'theme-dark' : 'theme-light'; }

    // colored meter: mode 'good' = high is good (green->red), 'bad' = high is bad (red), 'neutral' = accent
    function meter(label, val, mode) {
        val = Math.max(0, Math.min(100, Math.round(val)));
        let cls = '';
        if (mode === 'good') cls = val >= 60 ? 'green' : val >= 30 ? 'warn' : 'red';
        else if (mode === 'bad') cls = val >= 70 ? 'red' : val >= 40 ? 'warn' : 'green';
        return `<div class="meter"><div class="ml"><span>${label}</span><b>${val}%</b></div>
            <div class="bar"><span class="${cls}" style="width:${val}%"></span></div></div>`;
    }

    async function post(cb, data) {
        if (!IN_GAME) return demo(cb, data);
        try {
            const res = await fetch(`https://${RES}/${cb}`, {
                method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify(data || {})
            });
            return await res.json();
        } catch (e) { return { ok: false, reason: 'error' }; }
    }

    /* ---------- screens ---------- */
    async function loadList() {
        show('screen-loading');
        const r = await post('getFarms', {});
        if (!r || !r.ok) {
            document.getElementById('error-text').textContent =
                (r && r.reason === 'no_user') ? 'Nem sikerült azonosítani a játékost.' : 'Nem sikerült betölteni az adatokat.';
            return show('screen-error');
        }
        setTheme(r.dark !== false);
        state.farms = r.farms || [];
        state.purchasable = r.purchasable || [];
        state.price = r.price || state.price;
        if (state.farms.length === 0 && state.purchasable.length === 0) return show('screen-empty');
        renderList();
        show('screen-list');
    }

    function renderList() {
        const wrap = document.getElementById('list');
        document.getElementById('list-count').textContent = state.farms.length + ' farm';
        wrap.innerHTML = '';

        if (state.farms.length === 0) {
            const note = document.createElement('div');
            note.className = 'list-note';
            note.textContent = 'Még nincs saját farmod.';
            wrap.appendChild(note);
        }

        state.farms.forEach(f => {
            const roleBadge = f.role === 'owner'
                ? `<div class="badge ${f.hasAccess ? 'on' : 'off'}">${f.hasAccess ? 'Aktív' : 'Zárolva'}</div>`
                : `<div class="badge staff">Dolgozó</div>`;
            const div = document.createElement('div');
            div.className = 'fcard';
            div.innerHTML = `
                <div class="row">
                    <div class="ico">🚜</div>
                    <div class="meta">
                        <div class="name">${esc(f.name)}</div>
                        <div class="type">${f.role === 'owner' ? 'Tulajdonos' : 'Dolgozó'}${f.locked ? ' • 🔒 zárva' : ''}</div>
                    </div>
                    ${roleBadge}
                </div>
                <div class="actions">
                    <button class="btn ${f.hasAccess ? 'btn-primary' : ''}" data-open="${esc(f.id)}">
                        ${f.hasAccess ? 'Statisztika' : 'Feloldás ' + fmtMoney(state.price)}
                    </button>
                    <button class="btn gps" data-gps="${esc(f.id)}" title="GPS">📍</button>
                </div>`;
            wrap.appendChild(div);
        });

        if (state.purchasable.length > 0) {
            const title = document.createElement('div');
            title.className = 'list-section-title';
            title.textContent = 'Megvásárolható farmok';
            wrap.appendChild(title);
            state.purchasable.forEach(f => {
                const div = document.createElement('div');
                div.className = 'fcard buyable';
                div.innerHTML = `
                    <div class="row">
                        <div class="ico">🚜</div>
                        <div class="meta">
                            <div class="name">${esc(f.name)}</div>
                            <div class="price-line">${f.price ? 'Ár: <b>' + fmtMoney(f.price) + '</b>' : 'Megvásárolható'}</div>
                        </div>
                        <div class="badge buy">Eladó</div>
                    </div>
                    <div class="actions">
                        <button class="btn" data-gps="${esc(f.id)}">📍 Kijelölés (GPS)</button>
                    </div>`;
                wrap.appendChild(div);
            });
        }

        wrap.querySelectorAll('[data-open]').forEach(b => b.onclick = () => { Sfx.open(); openFarm(b.dataset.open); });
        wrap.querySelectorAll('[data-gps]').forEach(b => b.onclick = () => gps(b.dataset.gps));
    }

    async function openFarm(id) {
        state.current = id;
        show('screen-loading');
        const r = await post('getFarmStats', { id: Number(id) });
        if (!r || !r.ok) return show('screen-error');
        if (r.locked) {
            state.price = r.price || state.price;
            document.getElementById('lock-name').textContent = (state.farms.find(f => String(f.id) === String(id)) || {}).name || 'Farm';
            document.getElementById('lock-price').textContent = fmtMoney(state.price) + ' / hét';
            document.getElementById('lock-msg').textContent = '';
            document.getElementById('lock-buy').disabled = false;
            return show('screen-lock');
        }
        renderStats(r);
        show('screen-stats');
    }

    function renderStats(s) {
        document.getElementById('stats-name').textContent = s.name || 'Farm';
        document.getElementById('stats-access').textContent = s.paidUntil ? ('Hozzáférés eddig: ' + fmtDate(s.paidUntil)) : '';
        const a = s.animals;
        let html = '';

        /* KPIs */
        html += `<div class="kpi-grid">
            <div class="kpi"><div class="label">Állatok</div><div class="val">${a.count}</div></div>
            <div class="kpi"><div class="label">Átlag egészség</div><div class="val ${a.avgHealth>=60?'green':a.avgHealth>=30?'':'red'}">${a.avgHealth}%</div></div>
            <div class="kpi"><div class="label">Figyelmet igényel</div><div class="val ${a.attention>0?'red':'green'}">${a.attention}</div></div>
            <div class="kpi"><div class="label">Állatállomány értéke</div><div class="val">${fmtMoney(a.totalValue)}</div></div>
            <div class="kpi"><div class="label">Tárolt termék értéke</div><div class="val green">${fmtMoney(s.storage.value)}</div></div>
            <div class="kpi"><div class="label">Ajtó</div><div class="val">${s.doorLocked ? '🔒 Zárva' : '🔓 Nyitva'}</div></div>
        </div>`;

        /* type summary */
        if (a.byType && a.byType.length > 0) {
            html += `<div class="section"><h3>🐾 Állomány</h3><div class="chips">`;
            a.byType.forEach(t => { html += `<div class="chip">${t.emoji} ${esc(t.label)} <span class="c">${t.count}</span></div>`; });
            html += `</div></div>`;
        }

        /* animals */
        html += `<div class="section"><h3>📋 Állatok <span class="pill">${a.count} db</span></h3>`;
        if (a.list.length === 0) html += `<div class="muted small">Nincs állat.</div>`;
        a.list.forEach(an => {
            html += `<div class="animal">
                <div class="ahead">
                    <span class="aemoji">${an.emoji}</span>
                    <div class="aname">${esc(an.label)}<div class="aprice">Becsült érték: ${fmtMoney(an.sellPrice)}</div></div>
                    <span class="rarity r${an.rarity}">${esc(an.rarityLabel)}</span>
                </div>
                <div class="meters">
                    ${meter('Egészség', an.health, 'good')}
                    ${meter('Minőség', an.quality, 'good')}
                    ${meter('Feldolgozás', an.gather, 'good')}
                    ${meter('Igény', an.requirements, 'bad')}
                    ${meter('Kor', an.age, 'neutral')}
                </div>
                ${an.harvestReady ? '<span class="tag-ready">Betakarítható ✓</span>' : ''}
                ${an.needsCare ? '<span class="tag-care">Gondozás kell ⚠️</span>' : ''}
            </div>`;
        });
        html += `</div>`;

        /* food troughs */
        html += `<div class="section"><h3>🥣 Etetők <span class="pill">${s.troughs.length} db</span></h3>`;
        if (s.troughs.length === 0) html += `<div class="muted small">Nincs etető.</div>`;
        s.troughs.forEach((t, i) => {
            html += `<div class="line-item"><div class="li-name">Etető ${i+1} — ${esc(t.content)}</div>
                <div class="li-val">${t.empty ? '⚠️ üres' : fmtNum(t.count)}</div></div>`;
        });
        html += `</div>`;

        /* water */
        if (s.water.length > 0) {
            const totalW = s.water.reduce((x,y)=>x+y,0);
            html += `<div class="section"><h3>💧 Itatók <span class="pill">összesen ${fmtNum(totalW)}</span></h3>`;
            s.water.forEach((w, i) => {
                html += `<div class="line-item"><div class="li-name">Itató ${i+1}</div>
                    <div class="li-val">${w <= 0 ? '⚠️ üres' : fmtNum(w)}</div></div>`;
            });
            html += `</div>`;
        }

        /* tiles cleanliness */
        if (s.tiles.count > 0) {
            html += `<div class="section"><h3>🧹 Alom / tisztaság <span class="pill">${s.tiles.dirty} koszos / ${s.tiles.count}</span></h3>`;
            html += meter('Átlagos koszosság', s.tiles.avgDirtiness, 'bad');
            html += `</div>`;
        }

        /* storage */
        if (s.storage.list.length > 0) {
            html += `<div class="section"><h3>📦 Tároló (termékek)</h3>`;
            s.storage.list.forEach(it => {
                html += `<div class="line-item"><div class="li-name">${esc(it.label)}</div>
                    <div class="li-val">${fmtNum(it.count)}${it.max?' / '+it.max:''} • ${fmtMoney(it.value)}</div></div>`;
            });
            html += `</div>`;
        }

        /* warehouse */
        if (s.warehouse.length > 0) {
            html += `<div class="section"><h3>🏬 Raktár (takarmány)</h3>`;
            s.warehouse.forEach(it => {
                html += `<div class="line-item"><div class="li-name">${esc(it.label)}</div><div class="li-val">${fmtNum(it.count)} db</div></div>`;
            });
            html += `</div>`;
        }

        /* compost + staff */
        html += `<div class="kpi-grid">
            <div class="kpi"><div class="label">Komposzt</div><div class="val">${fmtNum(s.compost)}</div></div>
            <div class="kpi"><div class="label">Dolgozók</div><div class="val">${s.staff.length}</div></div>
        </div>`;

        if (s.staff.length > 0) {
            html += `<div class="section"><h3>👷 Dolgozók</h3>`;
            s.staff.forEach(p => {
                html += `<div class="line-item"><div class="li-name">${esc(p.name)}</div>
                    <div class="li-val">${p.perms.length ? esc(p.perms.join(', ')) : '—'}</div></div>`;
            });
            html += `</div>`;
        }

        const body = document.getElementById('stats-body');
        body.innerHTML = html;
        body.scrollTop = 0;
    }

    async function buy() {
        const btn = document.getElementById('lock-buy');
        const msg = document.getElementById('lock-msg');
        btn.disabled = true; msg.textContent = 'Fizetés…';
        const r = await post('buyAccess', { id: Number(state.current) });
        if (r && r.ok) {
            Sfx.success(); msg.textContent = 'Sikeres fizetés!'; openFarm(state.current);
        } else {
            Sfx.error(); btn.disabled = false;
            const reasons = { no_money: 'Nincs elég pénzed.', already_active: 'A hozzáférés már aktív.', cooldown: 'Várj egy kicsit.', not_allowed: 'Nincs jogosultságod ehhez a farmhoz.' };
            msg.textContent = (r && reasons[r.reason]) || 'A fizetés sikertelen.';
        }
    }

    async function gps(id) {
        Sfx.gps();
        const r = await post('setGps', { id: Number(id) });
        flash(r && r.ok ? 'GPS beállítva 📍' : 'GPS nem elérhető');
    }
    function gpsCurrent() { if (state.current) gps(state.current); }

    let flashT;
    function flash(text) {
        let el = document.getElementById('flash');
        if (!el) {
            el = document.createElement('div');
            el.id = 'flash';
            el.style.cssText = 'position:fixed;left:50%;bottom:26px;transform:translateX(-50%);background:var(--card);color:var(--text);padding:10px 18px;border-radius:999px;font-size:13px;border:1px solid var(--line);z-index:50;box-shadow:0 6px 18px rgba(0,0,0,.3)';
            document.body.appendChild(el);
        }
        el.textContent = text; el.style.opacity = '1';
        clearTimeout(flashT);
        flashT = setTimeout(() => { el.style.opacity = '0'; el.style.transition = 'opacity .4s'; }, 1600);
    }

    function back() { Sfx.back(); loadList(); }
    function toggleMute() { updateMuteBtn(Sfx.toggle()); }
    function updateMuteBtn(m) { const b = document.getElementById('mute-btn'); if (b) { b.textContent = m ? '🔇' : '🔊'; b.title = m ? 'Hangok be' : 'Hangok ki'; } }

    window.addEventListener('message', (ev) => {
        const e = ev.data || {};
        if (e.customevent === 'open' || e.action === 'open' || e.type === 'farm_app_open') loadList();
    });

    /* ---------- demo data (browser preview only) ---------- */
    function demo(cb, data) {
        if (cb === 'getFarms') {
            return Promise.resolve({ ok: true, dark: true, price: 15000000,
                farms: [
                    { id: 1, name: 'Kovács Tanya', role: 'owner', locked: false, hasAccess: true, paidUntil: Math.floor(Date.now()/1000)+400000 },
                    { id: 2, name: 'Zöldmező Farm', role: 'owner', locked: true, hasAccess: false, paidUntil: 0 },
                    { id: 3, name: 'Nagy Béla tanyája', role: 'staff', locked: false, hasAccess: false, paidUntil: 0 },
                ],
                purchasable: [ { id: 7, name: 'Tanya #7', price: 4500000 }, { id: 9, name: 'Tanya #9', price: 7800000 } ] });
        }
        if (cb === 'getFarmStats') {
            if (Number(data.id) !== 1) return Promise.resolve({ ok: true, locked: true, price: 15000000, paidUntil: 0 });
            return Promise.resolve(demoStats());
        }
        if (cb === 'buyAccess') return Promise.resolve({ ok: true, paidUntil: Math.floor(Date.now()/1000)+604800 });
        if (cb === 'setGps') return Promise.resolve({ ok: true });
        return Promise.resolve({ ok: false });
    }
    function demoStats() {
        return { ok: true, locked: false, id: 1, name: 'Kovács Tanya', role: 'owner', doorLocked: false,
            animals: { count: 5, avgHealth: 64, attention: 1, totalValue: 9450000,
                byType: [ {label:'Tehén',emoji:'🐄',count:2},{label:'Csirke',emoji:'🐔',count:2},{label:'Szarvasmarha',emoji:'🐂',count:1} ],
                list: [
                    { label:'Tehén', emoji:'🐄', health:92, quality:88, age:40, requirements:18, gather:100, rarity:4, rarityLabel:'Mítoszi', sellPrice:3200000, harvestReady:true, needsCare:false },
                    { label:'Csirke', emoji:'🐔', health:70, quality:65, age:55, requirements:50, gather:80, rarity:3, rarityLabel:'Legendás', sellPrice:520000, harvestReady:false, needsCare:false },
                    { label:'Szarvasmarha', emoji:'🐂', health:48, quality:42, age:60, requirements:70, gather:30, rarity:2, rarityLabel:'Ritka', sellPrice:980000, harvestReady:false, needsCare:false },
                    { label:'Tehén', emoji:'🐄', health:22, quality:30, age:80, requirements:88, gather:10, rarity:1, rarityLabel:'Közönséges', sellPrice:1100000, harvestReady:false, needsCare:true },
                    { label:'Csirke', emoji:'🐔', health:60, quality:55, age:35, requirements:40, gather:0, rarity:3, rarityLabel:'Legendás', sellPrice:410000, harvestReady:false, needsCare:false },
                ] },
            troughs: [ {content:'Szarvasmarha takarmány',count:45,empty:false}, {content:'Üres',count:0,empty:true} ],
            water: [ 80, 0, 60 ],
            tiles: { count: 12, avgDirtiness: 35, dirty: 3 },
            storage: { list: [ {label:'Tej',count:42,value:4830000,max:100},{label:'Tojás',count:18,value:1350000,max:100} ], value: 6180000 },
            warehouse: [ {label:'Szarvasmarha takarmány',count:120},{label:'Csirketáp',count:60} ],
            compost: 24, staff: [ {name:'Nagy Béla', perms:['Állatok kezelése','Tároló kezelése']} ],
            paidUntil: Math.floor(Date.now()/1000)+400000 };
    }

    window.App = { loadList, back, openFarm, buy, gps, gpsCurrent, toggleMute };
    updateMuteBtn(Sfx.isMuted());
    loadList();
})();

/* ESC-fix: kattintás után a gomb ne maradjon fókuszban/"kijelölve" — a fókuszált
   gomb elnyeli az elsö ESC-et, ezért nem zár be egyböl. Kattintás után + ESC-re
   levesszük a fókuszt; az ESC-et NEM nyeljük el, hogy a RoadPhone egyböl bezárjon. */
(function () {
  document.addEventListener('pointerup', function (e) {
    var b = e.target && e.target.closest && e.target.closest('button,[role="button"],.btn,.tab');
    if (b) setTimeout(function () { try { b.blur(); } catch (_) {} }, 0);
  }, true);
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      var a = document.activeElement;
      if (a && a !== document.body && typeof a.blur === 'function') { try { a.blur(); } catch (_) {} }
    }
  }, true);
})();
