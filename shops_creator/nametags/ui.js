/* Shop name plate editor — panel logic.
   Injects its own markup so index.html only carries a <link> and a <script>.
   Listens for the `shopnames:*` message actions; shops_creator's two message
   handlers switch on `action` and ignore anything they do not know. */

(function () {
    'use strict';

    const RES = 'shops_creator';

    let colors = {};      // key -> { label, rgb }
    let order = [];       // colour keys in swatch order
    let maxLength = 24;
    let plateIndex = null;
    let selected = null;
    let open = false;
    let mode = 'edit';    // 'edit' or 'buy'

    const el = {};

    function rgb(key) {
        const c = colors[key];
        return c ? `rgb(${c.rgb[0]}, ${c.rgb[1]}, ${c.rgb[2]})` : '#ffffff';
    }

    // The plate is drawn by a game native, which has no glyph for ő/ű.
    function toNativeText(text) {
        return text.replace(/ő/g, 'ö').replace(/Ő/g, 'Ö')
            .replace(/ű/g, 'ü').replace(/Ű/g, 'Ü')
            .replace(/~/g, '');
    }

    function build() {
        const root = document.createElement('div');
        root.id = 'shopnames';
        root.innerHTML = `
            <div class="sn-modal">
                <div class="sn-bar">
                    <div class="sn-logo"><i class="bi bi-shop-window"></i></div>
                    <div class="sn-name">BOLT <b>NÉVTÁBLA</b></div>
                    <button type="button" class="sn-close" data-sn="close" title="Bezárás">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>

                <div class="sn-body">
                    <div class="sn-wm"><i class="bi bi-signpost-2"></i></div>

                    <div class="sn-page" data-sn="page-buy">
                        <div class="sn-head">
                            <div class="sn-k">Egyszeri díj</div>
                            <div class="sn-ttl">Névtábla <b>feloldása</b></div>
                        </div>

                        <div class="sn-box">
                            <div class="sn-note">
                                Ezzel a bolt NPC-je fölé saját feliratot tehetsz, és később
                                bármikor átírhatod. A feloldás ehhez az egy bolthoz szól — ha
                                a bolt gazdát cserél, a felirat eltűnik és az új tulajdonosnak
                                újra meg kell vennie.
                            </div>
                        </div>

                        <button type="button" class="sn-buy" data-sn="buy-money">
                            <div class="sn-buy-ico"><i class="bi bi-cash-stack"></i></div>
                            <div class="sn-buy-txt">
                                <div class="sn-buy-t" data-sn="price-money">—</div>
                                <div class="sn-buy-d">Készpénzből, ha nincs elég, a bankról</div>
                            </div>
                            <i class="bi bi-chevron-right sn-buy-go"></i>
                        </button>

                        <button type="button" class="sn-buy" data-sn="buy-pp">
                            <div class="sn-buy-ico"><i class="bi bi-gem"></i></div>
                            <div class="sn-buy-txt">
                                <div class="sn-buy-t" data-sn="price-pp">—</div>
                                <div class="sn-buy-d">Fizetés prémium pontból</div>
                            </div>
                            <i class="bi bi-chevron-right sn-buy-go"></i>
                        </button>
                    </div>

                    <div class="sn-page" data-sn="page-edit">
                        <div class="sn-head">
                            <div class="sn-k">NPC felirat</div>
                            <div class="sn-ttl">Bolt <b>neve</b></div>
                        </div>

                        <div class="sn-box">
                            <div class="sn-bh">
                                <div class="sn-bt">Felirat</div>
                                <div class="sn-bs" data-sn="counter">0 / 24</div>
                            </div>
                            <input class="sn-input" data-sn="input" type="text" spellcheck="false"
                                   placeholder="pl. Delta Bolt">
                            <div class="sn-hint">Üresen hagyva a bolt eredeti nevét kapja vissza.</div>
                        </div>

                        <div class="sn-box">
                            <div class="sn-bh">
                                <div class="sn-bt">Szín</div>
                                <div class="sn-bs" data-sn="colorname">fehér</div>
                            </div>
                            <div class="sn-swatches" data-sn="swatches"></div>
                        </div>

                        <div class="sn-box">
                            <div class="sn-bh"><div class="sn-bt">Előnézet</div></div>
                            <div class="sn-preview" data-sn="preview"><span></span></div>
                        </div>
                    </div>

                    <div class="sn-foot" data-sn="foot-edit">
                        <button type="button" class="sn-btn danger" data-sn="clear">
                            <i class="bi bi-trash3"></i> Törlés
                        </button>
                        <button type="button" class="sn-btn ghost right" data-sn="close">Mégse</button>
                        <button type="button" class="sn-btn green" data-sn="save">
                            <i class="bi bi-check-lg"></i> Mentés
                        </button>
                    </div>

                    <div class="sn-foot" data-sn="foot-buy">
                        <button type="button" class="sn-btn ghost right" data-sn="close">Mégse</button>
                    </div>
                </div>
            </div>`;

        document.body.appendChild(root);

        el.root = root;
        el.input = root.querySelector('[data-sn="input"]');
        el.counter = root.querySelector('[data-sn="counter"]');
        el.swatches = root.querySelector('[data-sn="swatches"]');
        el.colorName = root.querySelector('[data-sn="colorname"]');
        el.preview = root.querySelector('[data-sn="preview"]');
        el.previewText = el.preview.querySelector('span');
        el.save = root.querySelector('[data-sn="save"]');
        el.pageEdit = root.querySelector('[data-sn="page-edit"]');
        el.pageBuy = root.querySelector('[data-sn="page-buy"]');
        el.footEdit = root.querySelector('[data-sn="foot-edit"]');
        el.footBuy = root.querySelector('[data-sn="foot-buy"]');
        el.buyMoney = root.querySelector('[data-sn="buy-money"]');
        el.buyPP = root.querySelector('[data-sn="buy-pp"]');
        el.priceMoney = root.querySelector('[data-sn="price-money"]');
        el.pricePP = root.querySelector('[data-sn="price-pp"]');

        el.buyMoney.addEventListener('click', () => unlock('money'));
        el.buyPP.addEventListener('click', () => unlock('pp'));

        root.querySelectorAll('[data-sn="close"]').forEach(b => b.addEventListener('click', close));
        root.querySelector('[data-sn="clear"]').addEventListener('click', () => {
            el.input.value = '';
            refresh();
            submit();
        });
        el.save.addEventListener('click', submit);

        el.input.addEventListener('input', refresh);
        el.input.addEventListener('keydown', ev => {
            if (ev.key === 'Enter') submit();
            else if (ev.key === 'Escape') close();
        });

        document.addEventListener('keydown', ev => {
            if (open && ev.key === 'Escape') close();
        });
    }

    function buildSwatches() {
        el.swatches.innerHTML = '';

        order.forEach(key => {
            const sw = document.createElement('button');
            sw.type = 'button';
            sw.className = 'sn-sw';
            sw.style.background = rgb(key);
            sw.title = colors[key] ? colors[key].label : key;
            sw.addEventListener('click', () => {
                selected = key;
                refresh();
            });
            el.swatches.appendChild(sw);
            sw.dataset.key = key;
        });
    }

    // One place that redraws every derived bit of the panel: counter, swatch
    // selection, colour name, preview and the save button state.
    function refresh() {
        const text = toNativeText(el.input.value);
        if (text !== el.input.value) el.input.value = text;

        const length = [...text].length;
        el.counter.textContent = `${length} / ${maxLength}`;
        el.counter.classList.toggle('over', length > maxLength);
        el.save.disabled = length > maxLength;

        el.swatches.querySelectorAll('.sn-sw').forEach(sw => {
            sw.classList.toggle('on', sw.dataset.key === selected);
        });

        el.colorName.textContent = colors[selected] ? colors[selected].label : selected;

        const trimmed = text.trim();
        el.preview.classList.toggle('empty', trimmed === '');
        el.previewText.textContent = trimmed === '' ? 'Nincs felirat — az eredeti név marad' : trimmed;
        el.previewText.style.color = trimmed === '' ? '' : rgb(selected);
    }

    // Sending the panel to a mode it is already in must not wipe what the player
    // typed, so the editor fields are only reset when the panel actually opens.
    function show(data) {
        const reopening = open && mode === data.mode && plateIndex === data.index;

        colors = data.colors || {};
        order = data.order || Object.keys(colors);
        maxLength = data.maxLength || 24;
        plateIndex = data.index;
        mode = data.mode === 'buy' ? 'buy' : 'edit';

        const p = data.price || {};
        el.priceMoney.textContent = `${p.money || '?'} ${p.currency || ''}`.trim();
        el.buyPP.style.display = p.pp ? '' : 'none';
        if (p.pp) el.pricePP.textContent = `${p.pp} PP`;

        el.pageBuy.style.display = mode === 'buy' ? '' : 'none';
        el.footBuy.style.display = mode === 'buy' ? '' : 'none';
        el.pageEdit.style.display = mode === 'edit' ? '' : 'none';
        el.footEdit.style.display = mode === 'edit' ? '' : 'none';

        if (!reopening) {
            selected = colors[data.color] ? data.color : order[0];
            buildSwatches();
            el.input.value = data.name || '';
            el.input.maxLength = maxLength;
        }
        refresh();

        open = true;
        el.root.classList.add('open');

        if (mode === 'edit') {
            el.input.focus();
            el.input.select();
        }
    }

    function unlock(method) {
        if (!open || mode !== 'buy') return;

        el.buyMoney.disabled = true;
        el.buyPP.disabled = true;

        post('shopnames:unlock', { index: plateIndex, method: method });

        // The server answers by pushing the panel into edit mode; if it refuses
        // (not enough money) nothing arrives, so let them try the other option.
        setTimeout(() => {
            el.buyMoney.disabled = false;
            el.buyPP.disabled = false;
        }, 1200);
    }

    function post(name, payload) {
        fetch(`https://${RES}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(payload),
        });
    }

    function close() {
        if (!open) return;
        open = false;
        el.root.classList.remove('open');
        post('shopnames:close', {});
    }

    function submit() {
        if (!open || mode !== 'edit' || el.save.disabled) return;
        open = false;
        el.root.classList.remove('open');

        post('shopnames:save', {
            index: plateIndex,
            name: el.input.value.trim(),
            color: selected,
        });
    }

    window.addEventListener('message', event => {
        const data = event.data;
        if (!data) return;

        if (data.action === 'shopnames:open') show(data);
        else if (data.action === 'shopnames:close') close();
    });

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', build);
    } else {
        build();
    }
})();
