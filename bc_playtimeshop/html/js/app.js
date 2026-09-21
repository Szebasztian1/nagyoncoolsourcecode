/* BlackCity | Játékidő shop */

const RESOURCE = "bc_playtimeshop";
const PER_PAGE = 12;
const FALLBACK_IMAGE = "./images/box.png";

const state = {
    coin: 0,
    categories: [],
    byCategory: {},
    lang: {},
    activeCategory: null,
    page: 1,
    remaining: 0,
    pending: null, // item awaiting purchase confirmation
};

let countdownTimer = null;
let toastTimer = null;

const $ = (id) => document.getElementById(id);

// An empty Lua table arrives as `{}`, not `[]` — guard before iterating anything from Lua.
const asArray = (value) => (Array.isArray(value) ? value : []);

async function post(name, data) {
    try {
        const res = await fetch(`https://${RESOURCE}/${name}`, {
            method: "POST",
            headers: { "Content-Type": "application/json; charset=UTF-8" },
            body: JSON.stringify(data || {}),
        });
        return await res.json();
    } catch (e) {
        return null;
    }
}

/* ---------- helpers ---------- */

function text(el, value) {
    if (el) el.textContent = value == null ? "" : String(value);
}

// Items may point at an image that was never shipped — never show a broken icon.
function setImage(el, src) {
    el.onerror = () => {
        el.onerror = null;
        el.src = FALLBACK_IMAGE;
    };
    el.src = src || FALLBACK_IMAGE;
}

function formatTime(seconds) {
    const s = Math.max(0, Math.floor(seconds));
    const h = String(Math.floor(s / 3600)).padStart(2, "0");
    const m = String(Math.floor((s % 3600) / 60)).padStart(2, "0");
    const sec = String(s % 60).padStart(2, "0");
    return `${h}:${m}:${sec}`;
}

function showToast(message, kind) {
    const el = $("toast");
    text(el, message);
    el.className = "toast show" + (kind ? " " + kind : "");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
        el.className = "toast" + (kind ? " " + kind : "");
    }, 3000);
}

function openOverlay(id) {
    $(id).classList.add("open");
}

function closeOverlay(id) {
    $(id).classList.remove("open");
}

function anyOverlayOpen() {
    return document.querySelector(".overlay.open") !== null;
}

function setCoin(value) {
    state.coin = value;
    text($("coinBalance"), value);
    text($("coinBalance2"), value);
}

/* ---------- rendering ---------- */

function renderCategories() {
    const list = $("navList");
    list.replaceChildren();

    state.categories.forEach((cat) => {
        const items = state.byCategory[cat.category] || [];

        const btn = document.createElement("div");
        btn.className = "nav-btn";
        btn.dataset.category = cat.category;

        const ico = document.createElement("div");
        ico.className = "ico";
        const i = document.createElement("i");
        i.className = cat.icon || "fa-solid fa-box";
        ico.appendChild(i);

        const lbl = document.createElement("div");
        lbl.className = "lbl";
        const t = document.createElement("div");
        t.className = "t";
        t.textContent = cat.label || cat.category;
        const d = document.createElement("div");
        d.className = "d";
        d.textContent = `${items.length} termék`;
        lbl.append(t, d);

        btn.append(ico, lbl);
        btn.addEventListener("click", () => selectCategory(cat.category));
        list.appendChild(btn);
    });
}

function selectCategory(category) {
    state.activeCategory = category;
    state.page = 1;

    document.querySelectorAll(".nav-btn").forEach((btn) => {
        btn.classList.toggle("on", btn.dataset.category === category);
    });

    renderItems();
}

function renderItems() {
    const grid = $("itemGrid");
    grid.replaceChildren();

    const items = state.byCategory[state.activeCategory] || [];
    const totalPages = Math.max(1, Math.ceil(items.length / PER_PAGE));
    if (state.page > totalPages) state.page = totalPages;

    text($("currentPage"), state.page);
    text($("totalPage"), totalPages);
    $("btnPrev").classList.toggle("disabled", state.page <= 1);
    $("btnNext").classList.toggle("disabled", state.page >= totalPages);

    if (items.length === 0) {
        const empty = document.createElement("div");
        empty.className = "empty";
        empty.textContent = state.lang.emptyCategory || "Nincs termék.";
        grid.appendChild(empty);
        return;
    }

    const start = (state.page - 1) * PER_PAGE;
    items.slice(start, start + PER_PAGE).forEach((item) => {
        grid.appendChild(buildItemCard(item));
    });
}

function buildItemCard(item) {
    const card = document.createElement("div");
    card.className = "item-card";

    const top = document.createElement("div");
    top.className = "ic-top";
    const name = document.createElement("div");
    name.className = "ic-name";
    name.textContent = item.label;
    const count = document.createElement("div");
    count.className = "ic-count";
    count.textContent = `${item.count}x`;
    top.append(name, count);

    const img = document.createElement("img");
    img.className = "ic-img";
    img.alt = "";
    setImage(img, item.image);

    const foot = document.createElement("div");
    foot.className = "ic-foot";

    const price = document.createElement("div");
    price.className = "ic-price";
    const coinImg = document.createElement("img");
    coinImg.className = "coin-ico sm";
    coinImg.src = "./images/coin.png";
    const priceVal = document.createElement("span");
    priceVal.textContent = item.price;
    price.append(coinImg, priceVal);

    const buy = document.createElement("div");
    buy.className = "ic-buy";
    buy.textContent = state.lang.buy || "Vásárlás";
    buy.addEventListener("click", () => askConfirm(item));

    foot.append(price, buy);
    card.append(top, img, foot);
    return card;
}

function renderTopPlayers(players) {
    const list = $("topList");
    list.replaceChildren();

    asArray(players).forEach((player, index) => {
        const row = document.createElement("div");
        row.className = "top-row" + (index === 0 ? " first" : "");

        const rank = document.createElement("div");
        rank.className = "rank";
        rank.textContent = index + 1;

        const name = document.createElement("div");
        name.className = "tname";
        name.textContent = player.firstName || "—";

        const coin = document.createElement("div");
        coin.className = "tcoin";
        const coinImg = document.createElement("img");
        coinImg.className = "coin-ico sm";
        coinImg.src = "./images/coin.png";
        const coinVal = document.createElement("span");
        coinVal.textContent = player.coin;
        coin.append(coinImg, coinVal);

        row.append(rank, name, coin);
        list.appendChild(row);
    });
}

/* ---------- purchase flow ---------- */

function askConfirm(item) {
    state.pending = item;
    text($("confirmName"), item.label);
    text($("confirmCount"), `${item.count}x`);
    text($("confirmPrice"), item.price);
    setImage($("confirmImg"), item.image);
    openOverlay("confirmOverlay");
}

async function confirmPurchase() {
    const item = state.pending;
    if (!item) return;

    if (state.coin < item.price) {
        closeOverlay("confirmOverlay");
        showToast(state.lang.youDntHvEngMoney || "Nincs elég érméd!", "err");
        return;
    }

    const ok = await post("buyItem", { itemInfo: { id: item.id } });
    closeOverlay("confirmOverlay");

    if (ok === "full") {
        showToast(state.lang.inventoryFull || "Nincs elég hely a táskádban!", "err");
        return;
    }
    if (ok !== true) {
        showToast(state.lang.youDntHvEngMoney || "Nincs elég érméd!", "err");
        return;
    }

    setCoin(state.coin - item.price);
    text($("successName"), item.label);
    setImage($("successImg"), item.image);
    openOverlay("successOverlay");
    setTimeout(() => closeOverlay("successOverlay"), 1800);
}

/* ---------- open / close ---------- */

function startCountdown() {
    clearInterval(countdownTimer);
    text($("countdown"), formatTime(state.remaining));
    countdownTimer = setInterval(() => {
        state.remaining = Math.max(0, state.remaining - 1);
        text($("countdown"), formatTime(state.remaining));
    }, 1000);
}

function closeUi() {
    clearInterval(countdownTimer);
    $("stage").classList.remove("open");
    ["confirmOverlay", "successOverlay"].forEach(closeOverlay);
    post("closeMenu");
}

function applyTranslations(lang) {
    state.lang = lang || {};
    const map = {
        brandName: "brand",
        brandTitle: "title",
        coinUnit: "coin",
        lblPlayer: "player",
        shopEyebrow: "shopEyebrow",
        shopTitle: "shopTitle",
        lblPrev: "previousPage",
        lblNext: "nextPage",
        lblNextReward: "nextReward",
        lblReward: "reward",
        topEyebrow: "topEyebrow",
        topTitle: "topTitle",
        confirmTitle: "confirmTitle",
        successTitle: "purchased",
        btnCancel: "cancel",
        btnConfirm: "buy",
    };

    Object.entries(map).forEach(([id, key]) => {
        if (state.lang[key]) text($(id), state.lang[key]);
    });
}

function openUi(data) {
    state.categories = asArray(data.categories);
    state.remaining = data.remaining || 0;
    state.page = 1;

    // Group items by category once, instead of scanning the full list per render.
    state.byCategory = {};
    state.categories.forEach((cat) => (state.byCategory[cat.category] = []));
    asArray(data.items).forEach((item) => {
        if (!state.byCategory[item.category]) state.byCategory[item.category] = [];
        state.byCategory[item.category].push(item);
    });

    setCoin(data.coin || 0);
    text($("playerName"), data.firstname || "—");
    text($("rewardAmount"), data.coinReward || 0);
    const avatar = $("avatar");
    avatar.onerror = () => {
        avatar.onerror = null;
        avatar.src = "./images/pp.png";
    };
    avatar.src = data.avatar || "./images/pp.png";

    renderTopPlayers(data.topPlayers);
    renderCategories();
    selectCategory(state.categories[0] && state.categories[0].category);
    startCountdown();

    $("stage").classList.add("open");
}

/* ---------- events ---------- */

window.addEventListener("message", (event) => {
    const data = event.data || {};
    if (data.type === "openui") {
        // Carries its own translations: the startup message may have arrived before we were ready.
        if (data.translate) applyTranslations(data.translate);
        openUi(data);
    } else if (data.type === "translate") {
        applyTranslations(data.translate);
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;
    if (anyOverlayOpen()) {
        ["confirmOverlay", "successOverlay"].forEach(closeOverlay);
        return;
    }
    closeUi();
});

document.addEventListener("DOMContentLoaded", () => {
    $("btnClose").addEventListener("click", closeUi);
    $("btnCancel").addEventListener("click", () => closeOverlay("confirmOverlay"));
    $("btnConfirm").addEventListener("click", confirmPurchase);

    $("btnPrev").addEventListener("click", () => {
        if (state.page <= 1) return;
        state.page -= 1;
        renderItems();
    });

    $("btnNext").addEventListener("click", () => {
        state.page += 1;
        renderItems();
    });
});
