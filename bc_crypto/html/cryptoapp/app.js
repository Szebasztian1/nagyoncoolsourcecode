/* ===== bc_crypto — RoadPhone crypto guide (read-only) ===== */
(function () {
    'use strict';

    const HOST = location.hostname || '';
    const RES = HOST.replace(/^cfx-nui-/, '') || 'bc_crypto';
    const IN_GAME = HOST.indexOf('cfx-nui-') === 0 || location.protocol === 'nui:' || typeof window.GetParentResourceName === 'function';

    /* ---------- helpers ---------- */
    function fmtMoney(n) { return '$' + (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    function fmtNum(n) { return (Math.round(Number(n) || 0)).toLocaleString('hu-HU'); }
    function fmtCoin(n) {
        n = Number(n) || 0;
        if (n === 0) return '0';
        if (n < 0.0001) return n.toExponential(2);
        return n.toLocaleString('hu-HU', { maximumFractionDigits: 6 });
    }
    function esc(s) { return String(s == null ? '' : s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c])); }
    function show(id) {
        document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
        document.getElementById(id).classList.add('active');
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
    async function init() {
        show('screen-loading');
        const r = await post('cryptoGetData', {});
        if (!r || !r.ok) return show('screen-error');
        if (!r.unlocked) {
            document.getElementById('lock-price').textContent = fmtMoney(r.price);
            document.getElementById('lock-msg').textContent = '';
            return show('screen-lock');
        }
        renderGuide(r.guide, r.containers);
        show('screen-guide');
    }

    async function buy() {
        const btn = document.getElementById('lock-buy');
        const msg = document.getElementById('lock-msg');
        btn.disabled = true; msg.textContent = 'Feldolgozás…';
        const r = await post('cryptoBuyAccess', {});
        btn.disabled = false;
        if (r && r.ok) {
            renderGuide(r.guide, r.containers);
            return show('screen-guide');
        }
        const reasons = {
            no_money: 'Nincs elég pénzed a bankszámládon.',
            already: 'Már fel van oldva.',
            cooldown: 'Túl gyors voltál, próbáld újra.',
        };
        msg.textContent = reasons[r && r.reason] || 'Nem sikerült a feloldás.';
        if (r && r.reason === 'already') { init(); }
    }

    function durColor(v) { return v > 50 ? '#34c759' : v > 20 ? '#ffb84d' : '#ff453a'; }

    function renderContainers(list) {
        if (!list || !list.length) {
            return '<div class="section-title">Konténereim</div>'
                + '<div class="card"><div class="muted small">Még nincs saját crypto bányászatod. Vedd meg az NPC-nél.</div></div>';
        }
        let html = '<div class="section-title">Konténereim (' + list.length + ')</div>';
        list.forEach(c => {
            const bal = (c.balance || []).map(b =>
                `<div class="bal-row"><span>${esc(b.name)} <span class="muted small">${esc(b.symbol)}</span></span>`
                + `<span><b>${fmtCoin(b.amount)}</b>${b.usd != null ? ' · <span class="accent">' + fmtMoney(b.usd) + '</span>' : ''}</span></div>`
            ).join('') || '<div class="bal-row"><span class="muted small">Nincs egyenleg.</span></div>';

            const pcs = (c.pcs || []).map(p => {
                const dur = Math.max(0, Math.min(100, Math.round(p.durability || 0)));
                const gpus = (p.gpus || []).map(g => `<span class="tag">${esc(g.name)} · ${Math.round(g.durability)}%</span>`).join('')
                    || '<span class="tag muted">nincs GPU</span>';
                const coolers = (p.coolers || []).map(x => `<span class="tag">${esc(x.name)} · ${Math.round(x.durability)}%</span>`).join('')
                    || '<span class="tag muted">nincs hűtés</span>';
                const mining = p.running
                    ? `<span class="badge on">⛏ ${esc(p.running)}</span>`
                    : `<span class="badge off">Kikapcsolva</span>`;
                return `<div class="pc">
                    <div class="pc-top">
                        <div class="pc-name">Gép #${p.slot}</div>
                        ${mining}
                        <div class="item-right"><div class="item-val accent">${fmtNum(p.hashrate)} H/s</div></div>
                    </div>
                    <div class="bar"><span style="width:${dur}%;background:${durColor(dur)}"></span></div>
                    <div class="bar-label"><span>Tartósság</span><span>${dur}%</span></div>
                    <div class="tags">${gpus}</div>
                    <div class="tags">${coolers}</div>
                </div>`;
            }).join('') || '<div class="muted small" style="margin-top:6px">Nincs bányászgép a konténerben.</div>';

            html += `<div class="cont-card">
                <div class="cont-head">
                    <span class="dot" style="background:var(--accent)"></span>
                    <div class="cont-title">${esc(c.label)} <span class="muted small">#${c.id}</span></div>
                    ${c.security ? `<span class="badge sec">🛡 ${esc(c.security)}</span>` : ''}
                </div>
                <div class="bal">${bal}</div>
                ${pcs}
            </div>`;
        });
        return html;
    }

    function renderGuide(g, containers) {
        g = g || {};
        const body = document.getElementById('guide-body');
        const e = g.earnings || {};
        const tickSec = g.tick || 60;

        let earnHtml = '<span class="muted">A kereset-becslés jelenleg nem elérhető (árak frissülnek).</span>';
        if (e.perHour != null) {
            earnHtml = `Fullos setup: <b>${e.gpuCount}× ${esc(e.gpuName)}</b> (${fmtNum(e.hashrate)} hashrate) `
                + `a(z) <b>${esc(e.cryptoName)}</b> bányászásával kb. <b>${fmtMoney(e.perHour)} / óra</b>, `
                + `azaz ~<b>${fmtMoney(e.perDay)} / nap</b> (folyamatos működés mellett, kopás előtt).`;
        }

        const hero = `
            <div class="hero">
                <div class="hero-label">Bányászat ára (NPC · PP)</div>
                <div class="hero-price">${fmtNum(g.shopPrice)} PP</div>
                <div class="hero-sub">Az ár ${fmtNum(g.shopMin)}–${fmtNum(g.shopMax)} PP között mozog, ~2 óránként változik.</div>
                <div class="hero-earn">${earnHtml}</div>
            </div>`;

        // cryptos
        const cryptos = (g.cryptos || []).map(c => `
            <div class="row">
                <span class="dot" style="background:${esc(c.color || '#888')}"></span>
                <div>
                    <div class="item-name">${esc(c.name)} <span class="muted small">${esc(c.symbol)}</span></div>
                    <div class="item-sub">Hozam: ${fmtCoin((c.reward || 0) * 1000)} ${esc(c.symbol)} / 1000 hashrate / tick</div>
                </div>
                <div class="item-right">
                    <div class="item-val accent">${c.usd != null ? '$' + fmtNum(c.usd) : '—'}</div>
                    <div class="item-sub">/ ${esc(c.symbol)}</div>
                </div>
            </div>`).join('');

        // computers
        const computers = (g.computers || []).map(c => `
            <div class="card">
                <div class="item-name">${esc(c.name)}</div>
                <div class="stat-grid">
                    <div class="stat"><div class="k">GPU helyek</div><div class="v">${c.gpuSlots}</div></div>
                    <div class="stat"><div class="k">Hűtő helyek</div><div class="v">${c.coolerSlots}</div></div>
                </div>
                <div class="tags"><span class="tag">GPU: ${(c.acceptedGpus || []).map(esc).join(', ')}</span></div>
                <div class="tags"><span class="tag">Hűtő: ${(c.acceptedCoolers || []).map(esc).join(', ')}</span></div>
            </div>`).join('');

        // gpus
        const gpus = (g.gpus || []).map(x => `
            <div class="row">
                <div>
                    <div class="item-name">${esc(x.name)}</div>
                    <div class="item-sub">Hőtermelés: +${x.heat}</div>
                </div>
                <div class="item-right">
                    <div class="item-val accent">${fmtNum(x.hashrate)} H/s</div>
                    <div class="item-sub">${fmtMoney(x.price)}</div>
                </div>
            </div>`).join('');

        // coolers
        const coolers = (g.coolers || []).map(x => `
            <div class="row">
                <div class="item-name">${esc(x.name)}</div>
                <div class="item-right">
                    <div class="item-val accent">-${x.cooling} hő</div>
                    <div class="item-sub">${fmtMoney(x.price)}</div>
                </div>
            </div>`).join('');

        const howto = `
            <div class="card howto">
                <ol>
                    <li>Vedd meg a <b>bányászatod (CP)</b> az NPC-nél <b>PP</b>-ért, majd rakd le a kijelölt zónában.</li>
                    <li>Szerezz egy <b>bányászgépet</b>, és tedd bele a konténered egyik helyére.</li>
                    <li>Rakj a gépbe <b>videokártyákat (GPU)</b> a hashrate növeléséhez — több hashrate = több crypto.</li>
                    <li>A GPU-k <b>hőt</b> termelnek; tegyél be <b>hűtéseket</b>, különben gyorsabban kopik minden.</li>
                    <li>Válaszd ki, melyik <b>cryptot</b> bányássza a gép, és indítsd el.</li>
                    <li>A bányászott cryptot a konténerben tudod <b>eladni</b> az aktuális árfolyamon.</li>
                    <li>A gépek, GPU-k és hűtések <b>elhasználódnak</b> (tartósság), idővel cserélni kell őket.</li>
                </ol>
            </div>`;

        body.innerHTML =
            hero +
            renderContainers(containers) +
            '<div class="section-title">Bányászható cryptok</div><div class="card">' + (cryptos || '<div class="muted small">Nincs adat.</div>') + '</div>' +
            '<div class="section-title">Bányászgépek</div>' + (computers || '') +
            '<div class="section-title">Videokártyák (GPU)</div><div class="card">' + (gpus || '') + '</div>' +
            '<div class="section-title">Hűtések</div><div class="card">' + (coolers || '') + '</div>' +
            '<div class="section-title">Hogyan működik?</div>' + howto;
    }

    /* ---------- demo (browser preview only) ---------- */
    function demo(cb) {
        if (cb === 'cryptoGetData') {
            return Promise.resolve({ ok: true, unlocked: false, price: 10000000 });
        }
        if (cb === 'cryptoBuyAccess') {
            return Promise.resolve({ ok: true, guide: demoGuide(), containers: demoContainers() });
        }
        return Promise.resolve({ ok: false });
    }
    function demoContainers() {
        return [{
            id: 4, label: 'Crypto Bányászat', security: 'Basic Security System',
            balance: [{ name: 'Ethereum', symbol: 'ETH', amount: 12.34567, usd: 37654 }, { name: 'Bitcoin', symbol: 'BTC', amount: 0.0421, usd: 2568 }],
            pcs: [
                { slot: 1, name: 'Hobby Mining Computer', durability: 82, hashrate: 3000, running: 'Ethereum',
                  gpus: [{ name: 'Közepes GPU', durability: 74 }, { name: 'Közepes GPU', durability: 91 }, { name: 'Kis GPU', durability: 63 }],
                  coolers: [{ name: 'Közepes hűtés', durability: 88 }, { name: 'Kis hűtés', durability: 45 }] },
                { slot: 2, name: 'Hobby Mining Computer', durability: 16, hashrate: 0, running: null,
                  gpus: [{ name: 'Kis GPU', durability: 9 }], coolers: [] },
            ],
        }];
    }
    function demoGuide() {
        return {
            tick: 60, shopPrice: 9200, shopMin: 7000, shopMax: 10000,
            earnings: { hashrate: 3000, gpuCount: 3, gpuName: 'Közepes GPU', cryptoName: 'Ethereum', symbol: 'ETH', perHour: 184000, perDay: 4416000 },
            cryptos: [
                { name: 'Bitcoin', symbol: 'BTC', color: '#F7931A', reward: 0.0000068666, usd: 61000 },
                { name: 'Ethereum', symbol: 'ETH', color: '#3C3C3D', reward: 0.000406666, usd: 3050 },
            ],
            computers: [{ name: 'Hobby Mining Computer', gpuSlots: 3, coolerSlots: 2, acceptedGpus: ['Kis GPU', 'Közepes GPU'], acceptedCoolers: ['Kis hűtés', 'Közepes hűtés'], price: 1500000 }],
            gpus: [
                { name: 'Kis GPU', hashrate: 700, heat: 1.15, price: 300000 },
                { name: 'Közepes GPU', hashrate: 1000, heat: 1.3, price: 360000 },
            ],
            coolers: [
                { name: 'Kis hűtés', cooling: 1.08, price: 165000 },
                { name: 'Közepes hűtés', cooling: 1.15, price: 200000 },
            ],
        };
    }

    window.App = { init, buy };
    init();
})();

/* ESC-fix: blur focused buttons so RoadPhone closes on the first ESC press. */
(function () {
    document.addEventListener('pointerup', function (e) {
        var b = e.target && e.target.closest && e.target.closest('button,[role="button"],.btn');
        if (b) setTimeout(function () { try { b.blur(); } catch (_) {} }, 0);
    }, true);
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            var a = document.activeElement;
            if (a && a !== document.body && typeof a.blur === 'function') { try { a.blur(); } catch (_) {} }
        }
    }, true);
})();
