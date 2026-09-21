// variables
let display = false;
let option = 0;
let count = 0;

// Variables from client
let IMAGES_PATH = null;
let PRICES_SEPARATOR = ",";

// Employees Permissions
let selfPermissions = {};

// Filters
let currentFilterId = null;
let currentFilterLabel = null;
let ALL_FILTERS = [];

// Opened shop data
let currentShopId = null;
let currentShopType = null;
let selectedItemDiv = null;

// Current shop label
let shopTitle = null; 

// item list for later purposes
let ITEMS = [];

/* ── Bolti kedvezmény ─────────────────────────────────────────────────────
   A boltra épp érvényes kedvezmény ennek a játékosnak. Az értéket kizárólag a
   szerver adja (discounts/sv_discounts.lua) — itt csak megjelenítjük, az árat
   soha nem küldjük vissza. */
let SHOP_DISCOUNT = 0;              // százalék, 0 = nincs kedvezmény
let SHOP_DISCOUNT_EXPIRES = 0;      // unix idő, 0 = nem jár le
let CAN_MANAGE_DISCOUNTS = false;   // a bolt tulajdonosa vagyok-e
let MAX_DISCOUNT_PERCENT = 20;

// Kedvezményes egységár. Darabonként, lefelé kerekítve — pontosan ugyanígy
// számol a szerver, így a kártyán látott ár és a levont összeg mindig egyezik.
function discountedUnitPrice(price) {
    if(SHOP_DISCOUNT <= 0 || isNaN(price)) return price;

    return Math.floor(price * (100 - SHOP_DISCOUNT) / 100);
}

// Csak a vásárlói nézetben, és csak azon a tételen, amit a bolt elad.
function isDiscountActive() {
    return SHOP_DISCOUNT > 0 && currentShopType == "playersShop";
}

// Bolt megnyitásakor: jár-e kedvezmény, illetve kezelhetem-e a boltét.
async function loadShopDiscount(shopId) {
    SHOP_DISCOUNT = 0;
    SHOP_DISCOUNT_EXPIRES = 0;
    CAN_MANAGE_DISCOUNTS = false;

    const info = await $.post(`https://${resName}/bcDiscountInfo`, JSON.stringify({shopId: shopId}));

    if(info) {
        SHOP_DISCOUNT = parseInt(info.percent) || 0;
        SHOP_DISCOUNT_EXPIRES = parseInt(info.expiresAt) || 0;
        CAN_MANAGE_DISCOUNTS = info.canManage === true;
        MAX_DISCOUNT_PERCENT = parseInt(info.maxPercent) || MAX_DISCOUNT_PERCENT;
    }
}

/* ── Bolti kirakat (hirdetés) ─────────────────────────────────────────────
   A tulajdonos által megadott kép és bemutatkozó szöveg. A szerver ellenőrzi
   (storefront/sv_storefront.lua), de innentől játékostól származó szövegről
   van szó: kizárólag escape-elve kerülhet a HTML-be. */
let SHOP_STOREFRONT = null;
let CAN_MANAGE_STOREFRONT = false;

function escapeHtml(text) {
    return String(text == null ? "" : text)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

// A kép nem jött be (halott link, lassú tárhely): a doboz maradjon meg, csak
// ikon kerüljön a helyére — a CEF a törött képet 0x0-ra húzza össze.
function storefrontImgFallback(img) {
    img.onerror = null;

    const box = img.closest(".sf-photo, .thumb");
    if(box) box.classList.add("empty");

    // A szerkesztőben mondjuk is meg, hogy a link nem tölthető be — enélkül a
    // tulaj csak egy üres dobozt lát, és nem tudja, mit rontott el.
    $("#sf-image-warn").show();
}

// Kap-e szélesebb panelt a bolt? Csak akkor, ha van mit mutatni: kép vagy
// bemutatkozó. A hely/kedvezmény/ID a szűk sávban is elfér.
function hasStorefrontContent() {
    const sf = SHOP_STOREFRONT;
    if(!sf) return false;

    return !!(sf.imageUrl || sf.description);
}

async function loadShopStorefront(shopId) {
    SHOP_STOREFRONT = null;
    CAN_MANAGE_STOREFRONT = false;

    const data = await $.post(`https://${resName}/bcStorefrontGet`, JSON.stringify({shopId: shopId}));

    if(!data) return;

    CAN_MANAGE_STOREFRONT = data.canManage === true;
    SHOP_STOREFRONT = data;
}

/* A bal sáv bolt-kártyája. A bolt NEVE szándékosan nincs benne: azt a fejléc
   írja ki, itt csak megismétlődne. Mindig kirajzoljuk, mert a hely, a
   kedvezmény és a bolt azonosítója akkor is érdekes, ha a tulaj nem állított
   be kirakatot. */
function storefrontCard() {
    if(currentShopType != "playersShop" && !hasStorefrontContent()) return "";

    const sf = SHOP_STOREFRONT || {};
    const badges = [];

    if(SHOP_DISCOUNT > 0) {
        badges.push(`<span class="sf-badge acc">${getLocalizedText("menu:bc_discount")}: -${SHOP_DISCOUNT}%</span>`);

        badges.push(`<span class="sf-badge">${SHOP_DISCOUNT_EXPIRES > 0
            ? `${getLocalizedText("menu:bc_expires")}: ${discountDate(SHOP_DISCOUNT_EXPIRES)}`
            : getLocalizedText("menu:bc_permanent_access")}</span>`);
    }

    if(currentShopId != null) {
        badges.push(`<span class="sf-badge">ID: ${escapeHtml(currentShopId)}</span>`);
    }

    (sf.tags || []).forEach(function(tag) {
        badges.push(`<span class="sf-badge">${escapeHtml(tag)}</span>`);
    });

    const rows = [
        sf.hours ? `<div class="info-row"><span>${getLocalizedText("menu:bc_sf_hours")}</span><span>${escapeHtml(sf.hours)}</span></div>` : "",
        sf.phone ? `<div class="info-row"><span>${getLocalizedText("menu:bc_sf_phone")}</span><span>${escapeHtml(sf.phone)}</span></div>` : "",
    ].join("");

    return `
    <div class="sf-card">
        ${sf.imageUrl ? `
        <div class="sf-photo">
            <img src="${escapeHtml(sf.imageUrl)}" alt="" referrerpolicy="no-referrer" onerror="storefrontImgFallback(this)">
            <i class="bi bi-shop ph"></i>
        </div>` : ""}

        <div class="sf-body">
            ${SHOP_LOCATION ? `<div class="sf-loc"><i class="bi bi-geo-alt-fill"></i> ${escapeHtml(SHOP_LOCATION)}</div>` : ""}
            ${badges.length ? `<div class="sf-badges">${badges.join("")}</div>` : ""}
            ${sf.ownerName ? `<div class="sf-owner"><i class="bi bi-person-badge"></i> ${escapeHtml(sf.ownerName)}</div>` : ""}
            ${sf.description ? `<div class="sf-desc bc-scroll">${escapeHtml(sf.description)}</div>` : ""}
            ${rows ? `<div class="sf-rows">${rows}</div>` : ""}
        </div>
    </div>`;
}



/* ── Szavatosság ──────────────────────────────────────────────────────────
   Tárgynév -> hány százalékos az az adag, amit a következő vevő kapna ebben a
   boltban. Csak a romlandó tárgyak kerülnek bele; aminek nincs szavatossága,
   az nem is szerepel, és nem kap jelvényt. */
let SHOP_QUALITY = {};

// Az admin boltok és a játékos boltok külön számozásból jönnek, így a 12-es
// admin bolt és a 12-es játékos bolt ugyanaz a szám. A készletben negatívval
// különítjük el az adminokat, hogy ne keveredjen a kettő.
function shopLifeKey(shopId) {
    const id = parseInt(shopId);

    if(isNaN(id)) return 0;

    return String(currentShopType || "").startsWith("adminShop") ? -id : id;
}

async function loadShopQuality(shopId) {
    // a szerver ebből is megtudja, melyik boltnál járunk — a berakott romlandó
    // áru ennek a boltnak a készletébe kerül
    //
    // $.each, nem .map: a script hol tömbként, hol objektumként adja vissza a
    // tételeket (lásd a dolgozó-listát is). Tömbön a .map elszállt, és a hiba
    // némán megette az egész jelvény-frissítést.
    const names = [];

    $.each(ITEMS || {}, function(_, item) {
        if(item && typeof item.name === "string") names.push(item.name);
    });

    const data = await $.post(`https://${resName}/bcShopQuality`, JSON.stringify({shopId: shopLifeKey(shopId), items: names}));

    // Csak akkor írjuk felül, ha tényleg kaptunk adatot. A fékezett vagy
    // elveszett válasz korábban kitörölte a már kirajzolt jelvényeket.
    if(data && data.quality) SHOP_QUALITY = data.quality;
}

// A jelvények utólagos kitöltése. Nem rajzolunk újra, csak a meglévő helyekre
// írunk — így a menü soha nem vár a válaszra.
function applyQualityBadges() {
    $(".items-list .item-element").each(function() {
        const percent = SHOP_QUALITY[ $(this).data("itemName") ];
        const badge = $(this).find(".life-badge");

        if(percent === undefined || percent === null) {
            badge.hide();
            return;
        }

        const level = percent >= 67 ? "good" : (percent >= 34 ? "mid" : "low");

        badge.removeClass("good mid low").addClass(level)
            .html(`<i class="bi bi-hourglass-split"></i> ${percent}%`)
            .show();
    });
}

// A bolt helye (kerület + utca). A kliens a játékos pozíciójából olvassa ki —
// a menü megnyitásakor a játékos a boltnál áll.
let SHOP_LOCATION = "";

async function loadShopLocation() {
    SHOP_LOCATION = "";

    const place = await $.post(`https://${resName}/bcShopLocation`, JSON.stringify({}));

    if(!place) return;

    SHOP_LOCATION = [place.zone, place.street].filter(function(part) {
        return part && String(part).trim() !== "";
    }).join(", ");
}

// Bolt megnyitásakor a kiegészítők adata egyszerre kérdeződik le.
async function loadShopExtras(shopId) {
    // A minőséget szándékosan NEM kérjük itt: a refreshItemsInUI úgyis lekéri,
    // méghozzá a végleges tétellistával. Két egymás utáni kérésből a másodikat
    // a fékezés eldobta, és a válasza kitörölte a jelvényeket.
    SHOP_QUALITY = {};

    await Promise.all([ loadShopDiscount(shopId), loadShopStorefront(shopId), loadShopLocation() ]);
}

/* A menü SOHA nem várhat a kiegészítőkre. Ezek szerver-körbefordulások, és ha
   egy is elakad (alt-tab, akadó szerver, elveszett esemény), a régi megoldás
   ott ült a válaszra, és a bolt egyszerűen nem nyílt meg — kívülről ez úgy
   nézett ki, mintha beragadt volna a panel.

   Innentől: ha a kiegészítők 1,5 mp alatt megjönnek, egyszer rajzolunk; ha
   nem, előbb megnyitjuk a boltot kedvezmény/kirakat nélkül, és amint
   megérkeznek, frissítünk. */
function openWithExtras(shopId, render) {
    // ehhez a megnyitáshoz tartozunk; ha közben bezárták a menüt vagy másik
    // boltot nyitottak, ez már nem egyezik, és nem rajzolunk semmit
    const session = shopSession;

    const isStillOurs = function() {
        return session === shopSession && currentShopId == shopId;
    };

    let opened = false;

    const openOnce = function() {
        if(opened || !isStillOurs()) return;

        opened = true;
        render();
    };

    const slowTimer = setTimeout(openOnce, 1500);

    loadShopExtras(shopId).then(function() {
        clearTimeout(slowTimer);

        if(!isStillOurs()) return;

        if(opened) {
            render();   // már nyitva volt, most jött meg az adat
        } else {
            openOnce();
        }
    });
}

/* Minden bolt-megnyitás kap egy sorszámot, és a bezárás lépteti. A késleltetett
   rajzolás (openWithExtras) ebből tudja, hogy még az ő megnyitásáról van-e szó
   — enélkül egy közben bezárt menü magától visszaugrott a képernyőre. */
let shopSession = 0;

// display ui
function show(bool) {
    if (bool) {
        $(".main-container").show();
    } else {
        shopSession++;

        $(".main-container").hide();
        $.post(`https://${GetParentResourceName()}/close`);
    }
    display = bool;
}

async function refreshItemsInUI() {
    switch(currentShopType) {
        case "playersShop":
            ITEMS = await retrieveObjectsOnSaleFromShop(currentShopId);
            break;
        case "playerInventory":
            ITEMS = await retrievePlayerSellableObjects(currentShopId);
            break;
        case "playersShopObjectsOnSaleSettings":
            ITEMS = await retrieveObjectsOnSaleFromShop(currentShopId);
            break;
        case "playersShopObjectsFromStorage":
            ITEMS = await retrieveObjectsFromStorage(currentShopId);
            break;
    }

    // A kezelő nézetekben (eladó tárgyak, raktár) is friss minőséget mutatunk.
    // Nem várunk rá: ha megjön, csak a jelvényeket írjuk át.
    if(currentShopId != null) {
        // a hiba ne tudjon némán elnyelni egy frissítést, mint legutóbb
        loadShopQuality(currentShopId).then(applyQualityBadges).catch(function(err) {
            console.log("[shops_creator] minőség-lekérdezés hiba: " + err);
        });
    }

    showMainShop();
}

function togglePlayerInventoryOptions(state) {
    $("#deposit-storage").toggle(state);
    $("#add-sale").toggle(state);
    $("#add-buy-list").toggle(state);
}

function toggleOnSaleItemsOptions(state) {
    $("#remove-from-sale").toggle(state);
    $("#add-stocks").toggle(state);
    $("#update-price").toggle(state);
}

function toggleToBuyItemsOptions(state) {
    $("#remove-from-to-buy-list").toggle(state);
    $("#update-quantity").toggle(state);
    $("#update-price").toggle(state);
}

function toggleStorageOptions(state) {
    $("#withdraw-from-storage").toggle(state);
    $("#add-sale").toggle(state);
}

function toggleSellAllButton(state) {
    $("#sell-all-btn").toggle(state);
}

function hideAllExtraOptionsFromShopUI() {
    togglePlayerInventoryOptions(false);
    toggleOnSaleItemsOptions(false);
    toggleToBuyItemsOptions(false);
    toggleStorageOptions(false);
    toggleSellAllButton(false);
}

// sidebar action button (BC nav-btn)
function navButton(id, icon, label) {
    return `<a id="${id}" class="nav-btn clickable"><span class="ico"><i class="bi ${icon}"></i></span><span class="t">${label}</span></a>`;
}

// display main player shop
function showMainShop() {
    const options = [
        hasPermission("depositStoredObjects") && navButton("deposit-storage", "bi-box-arrow-in-down", getLocalizedText("menu:deposit_in_storage")),
        hasPermission("addObjectToSale") && navButton("add-sale", "bi-tag", getLocalizedText("menu:add_on_sale")),
        hasPermission("addObjectToBuyList") && navButton("add-buy-list", "bi-cart-plus", getLocalizedText("menu:add_on_to_buy_list")),

        hasPermission("updateObjectPrice") && navButton("update-price", "bi-currency-exchange", getLocalizedText("menu:update_price")),
        hasPermission("removeObjectFromSale") && navButton("remove-from-sale", "bi-x-circle", getLocalizedText("menu:remove_from_sale")),
        hasPermission("addObjectStocks") && navButton("add-stocks", "bi-plus-square", getLocalizedText("menu:add_stocks")),
        hasPermission("removeObjectFromToBuyList") && navButton("remove-from-to-buy-list", "bi-cart-dash", getLocalizedText("menu:remove_from_to_buy_list")),
        hasPermission("updateObjectQuantity") && navButton("update-quantity", "bi-123", getLocalizedText("menu:update_wanted_quantity")),

        hasPermission("withdrawStoredObjects") && navButton("withdraw-from-storage", "bi-box-arrow-up", getLocalizedText("menu:withdraw_from_storage")),
    ].filter(Boolean);

    $(".main-container").html(`
    <div class="shop-page ${hasStorefrontContent() ? "has-sf" : ""}">
        <div class="bar">
            <div class="brand">
                <div class="logo"><i class="bi bi-shop"></i></div>
                <div class="name">
                    <!-- A bolt neve szándékosan nincs itt: a fejléc csak a menüt
                         nevezi meg, a boltot az NPC névtáblája és a bal oldali
                         kártya azonosítja. -->
                    <span class="shop-title">${getLocalizedText("menu:bc_brand")}</span>
                </div>
            </div>
            <div class="bar-right">
                <a class="bc-btn ghost filter-btn clickable"><i class="bi bi-funnel"></i><p>${getLocalizedText("menu:filter")}</p></a>
                <a class="bc-close exit-btn clickable" title="${getLocalizedText("menu:exit")}"><i class="bi bi-x-lg"></i></a>
            </div>
        </div>

        <div class="body">
            <div class="side ${options.length ? "" : "no-options"}">
                ${storefrontCard()}

                <div class="options-menu">${options.join("")}</div>

                <div class="side-fill"></div>

                <div class="info-box">
                    <div class="ih">${getLocalizedText("menu:bc_cart_details")}</div>
                    <div class="info-row"><span>${getLocalizedText("menu:label")}</span><span id="sel-name">—</span></div>
                    <div class="info-row" id="sel-price-row"><span>${getLocalizedText("menu:price")}</span><span id="sel-price">—</span></div>
                    <div class="info-row"><span>${getLocalizedText("menu:stock")}</span><span id="sel-stock">—</span></div>
                    <div class="info-row"><span>${getLocalizedText("menu:bc_quantity")}</span><span id="sel-qty">—</span></div>
                    <div class="info-row disc" id="sel-disc-row" style="display:none"><span>${getLocalizedText("menu:bc_discount")}</span><span id="sel-disc">—</span></div>
                    <div class="info-row" id="sel-total-row"><span>${getLocalizedText("menu:total")}</span><span class="bc-badge" id="sel-total">—</span></div>
                </div>
            </div>

            <div class="main">
                <div class="wm"><i class="bi bi-shop"></i></div>
                <ul class="items-list page"></ul>
                <div class="foot">
                    <input type="number" min="1" id="amount-input" placeholder="${getLocalizedText("menu:amount")}" required>
                    <div class="bc-btn green clickable" id="main-action-btn"><p>${getLocalizedText("menu:purchase")}</p></div>
                    <div class="bc-btn blue clickable" id="sell-all-btn" style="display:none"><p>${getLocalizedText("menu:sell_all")}</p></div>
                </div>
            </div>
        </div>
    </div>
    <div class="filter-page" style="display:none"></div>
    `);

    // filter button click
    $(".filter-btn").click(function () {
        showFilter(true);
        $(".filter-element").click(function () {
            $(".filter-element").removeClass("on");
            $(this).addClass("on");
            currentFilterId = $(this).data('filterId');
            currentFilterLabel = $(this).data('filterLabel');
        });
    });

    if(currentFilterId != null) {
        $(".filter-btn").addClass("active").find("p").text(currentFilterLabel);
    }

    // keep the selection box in sync with the typed amount
    $("#amount-input").on("input", updateSelectionBox);

    // shop exit button
    $(".exit-btn").click(function () {
        if(currentShopType == "playersShop" || currentShopType == "adminShop-sell" || currentShopType == "adminShop-buy") {
            show(false);
        } else {
            showShopSettings();
        }
    });

    // option clicked
    $(".options-menu a").click(function () {
        option = $(this).attr("id");
        $(".options-menu a").removeClass("selected-btn");
        $(this).addClass("selected-btn");
        
        const showAmountInput = option != "update-price" && option != "remove-from-to-buy-list";

        switch(currentShopType) {
            case "playersShopObjectsOnSaleSettings": {
                $("#amount-input").toggle(showAmountInput).prop("required", showAmountInput);
                break;
            }

            default: {
                $("#amount-input").show().prop("required", showAmountInput);
                break;
            }
        }

    });

    switch(currentShopType) {
        case "adminShop-buy": {
            $("#main-action-btn p").text(getLocalizedText("menu:purchase"));
            hideAllExtraOptionsFromShopUI();
            break;
        }

        case "adminShop-sell": {
            $("#main-action-btn p").text(getLocalizedText("menu:sell"));

            hideAllExtraOptionsFromShopUI();
            toggleSellAllButton(true);

            break;
        }

        case "playersShop": {
            hideAllExtraOptionsFromShopUI();
            break;
        }
        case "playerInventory": {
            $("#main-action-btn p").text(getLocalizedText("menu:confirm"));

            hideAllExtraOptionsFromShopUI();
            togglePlayerInventoryOptions(true);

            break;
        }

        case "playersShopObjectsOnSaleSettings": {
            $("#main-action-btn p").text(getLocalizedText("menu:confirm"));

            hideAllExtraOptionsFromShopUI();
            toggleOnSaleItemsOptions(true);

            break;
        }

        case "playersShopObjectsFromStorage": {
            $("#main-action-btn p").text(getLocalizedText("menu:confirm"));

            hideAllExtraOptionsFromShopUI();
            toggleStorageOptions(true);

            break;
        }
    }

    $("#sell-all-btn").click(async function () {
        if(!selectedItemDiv) return;

        const itemId = selectedItemDiv.data("itemId");

        switch(currentShopType) {
            case "adminShop-sell": {
                $.post(`https://${resName}/sellItemsInBulkToAdminShop`, JSON.stringify({shopId: currentShopId, itemId: itemId}), null);
                resetSelectedItem();
                break;
            }

            case "playersShop": {
                $.post(`https://${resName}/sellItemsInBulkToPlayerShop`, JSON.stringify({shopId: currentShopId, itemId: itemId}), async function(success) {
                    if (success)
                        refreshItemsInUI()
                });

                resetSelectedItem();
                break;
            }
        }
    });

    // shop submit button
    $("#main-action-btn").click(async function () {
        if(!selectedItemDiv) return;
        
        if( $("#amount-input").prop("required") ) {
            count = parseInt( $("#amount-input").val() );
            if(isNaN(count)) return;
        } else {
            count = 0;
        }

        // Used in most shop types
        const itemId = selectedItemDiv.data("itemId");

        switch(currentShopType) {
            case "adminShop-buy": {
                $.post(`https://${resName}/buyItemFromAdminShop`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), null);
                resetSelectedItem();
                break;
            }

            case "adminShop-sell": {
                $.post(`https://${resName}/sellItemToAdminShop`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), null);
                resetSelectedItem();
                break;
            }

            case "playersShop": {
                const method = selectedItemDiv.data("method");

                if(method == "buy") {
                    // Kedvezmény: előbb bejegyeztetjük a szerverrel, hogy ez a
                    // vásárlás kedvezményes — a levonáskor onnan derül ki.
                    // Ha ez bármiért nem sikerül, a teljes árat fizeti.
                    if(isDiscountActive()) {
                        await $.post(`https://${resName}/bcDiscountPrepare`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}));
                    }

                    $.post(`https://${resName}/buyItemFromPlayersShop`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), async function(success) {
                        if (success)
                            refreshItemsInUI()
                    });
                } else if(method == "sell") {
                    $.post(`https://${resName}/sellItemToPlayersShop`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), function(success) {
                        if (success)
                            refreshItemsInUI()
                    });
                }

                break;
            }

            case "playerInventory": {
                const itemName = selectedItemDiv.data("itemName");
                const itemType = selectedItemDiv.data("itemType");

                switch(option) {
                    case "deposit-storage": {
				        $.post(`https://${resName}/depositObjectInStorage`, JSON.stringify({shopId: currentShopId, name: itemName, type: itemType, quantity: count}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });

                        break;
                    }

                    case "add-sale": {
                        const price = await showInput(getLocalizedText("menu:choose_price"), getLocalizedText("menu:price_for_each_object"), true)
                        if(price == null) return;

                        $.post(`https://${resName}/addItemToSale`, JSON.stringify({shopId: currentShopId, name: itemName, type: itemType, quantity: count, price: price}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });

                        break;
                    }

                    case "add-buy-list": {
                        const price = await showInput(getLocalizedText("menu:choose_price"), getLocalizedText("menu:price_to_buy_each_object"), true)
                        if(price == null) return;

                        $.post(`https://${resName}/addItemToBuyList`, JSON.stringify({shopId: currentShopId, name: itemName, type: itemType, quantity: count, price: price}), function(successful) {
                            if(successful) 
                                refreshItemsInUI();
                        });

                        break;
                    }
                }

                break;
            }

            case "playersShopObjectsOnSaleSettings": {
                switch(option) {
                    case "remove-from-sale": {
                        $.post(`https://${resName}/removeItemFromSale`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });

                        break;
                    }

                    case "add-stocks": {
                        $.post(`https://${resName}/addObjectStocks`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });
                        
                        break;
                    }

                    case "update-price": {
                        const price = await showInput(getLocalizedText("menu:choose_price"), getLocalizedText("menu:price_for_each_object"), true)
                        if(price == null) return;

                        $.post(`https://${resName}/updateObjectPrice`, JSON.stringify({shopId: currentShopId, itemId: itemId, price: price}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });

                        break;
                    }

                    case "remove-from-to-buy-list": {
                        $.post(`https://${resName}/removeItemFromToBuyList`, JSON.stringify({shopId: currentShopId, itemId: itemId}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });

                        break;
                    }

                    case "update-quantity": {
                        $.post(`https://${resName}/updateObjectQuantity`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });

                        break;
                    }
                }

                break;
            }

            case "playersShopObjectsFromStorage": {
                switch(option) {
                    case "withdraw-from-storage": {
                        $.post(`https://${resName}/withdrawObjectFromStorage`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });
                        break;
                    }

                    case "add-sale": {
                        const price = await showInput(getLocalizedText("menu:choose_price"), getLocalizedText("menu:price_for_each_object"), true)
                        if(price == null) return;

                        $.post(`https://${resName}/storageToSale`, JSON.stringify({shopId: currentShopId, itemId: itemId, quantity: count, price: price}), function(successful) {
                            if(successful)
                                refreshItemsInUI();
                        });
                    }
                }
                        
                break;
            }
        }

        selectedItemDiv = null;
    });

    // append all items
    loadItems(ITEMS);
    show(true);
}

function isItemNameInFilterId(itemName) {
    if(currentFilterId == null) return true; // no filter selected

    itemName = itemName.toLowerCase();

    let filterData = ALL_FILTERS[currentFilterId];
    if(!filterData) return false;

    let filterItems = filterData.items;
    if(!filterItems) return false;

    return filterItems[itemName];
}

// display filter page (player shop)
function showFilter(bool) {
    if (bool) {
        currentFilterId = null;
        $(".filter-btn").removeClass("active").find("p").text(getLocalizedText("menu:filter"));

        let filtersDivs = "";

        ALL_FILTERS.forEach((filterData, index) => {
            filtersDivs += `<li class="filter-element" data-filter-id="${index}" data-filter-label="${filterData.label}"><p>${filterData.label}</p></li>`
        });

        // show filter page
        $(".filter-page").show();
        $(".filter-page").html(`
        <div class="filter-modal">
            <div class="bar">
                <div class="brand">
                    <div class="logo"><i class="bi bi-funnel"></i></div>
                    <div class="name">
                        <span class="k">${getLocalizedText("menu:bc_brand")}</span>
                        <span class="shop-title">${getLocalizedText("menu:filter")}</span>
                    </div>
                </div>
            </div>

            <p class="filter-description">${getLocalizedText("menu:choose_your_filter")}</p>
            <ul class='filter-options page'>
                ${filtersDivs}
            </ul>

            <div class="filter-buttons foot">
                <a class="bc-btn ghost cancel-btn clickable"><p>${getLocalizedText("menu:cancel")}</p></a>
                <a class="bc-btn blue submit-btn clickable"><p>${getLocalizedText("menu:submit")}</p></a>
            </div>
        </div>
        `);

        // filter submit button
        $('.filter-page .filter-buttons .submit-btn').click(function () {
            // Filter applied
            showFilter(false);
            refreshItemsInUI();
        });

        // filter cancel button
        $('.filter-page .filter-buttons .cancel-btn').click(function () {
            currentFilterId = null;
            showFilter(false);
            refreshItemsInUI();
        });

    } else {
        $(".filter-page").hide();
    }

}

// shared shell for every settings-style page: header, sidebar list, main column
function settingsShell(title, icon, rightOptions) {
    return `
    <div class="shop-settings">
        <div class="bar">
            <div class="brand">
                <div class="logo"><i class="bi ${icon}"></i></div>
                <div class="name">
                    <span class="k">${getLocalizedText("menu:bc_brand")}</span>
                    <div class="titlebox"><h2>${title}</h2></div>
                </div>
            </div>
        </div>

        <div class="body">
            <ul class="left-settings"></ul>

            <div class="main">
                <div class="wm"><i class="bi ${icon}"></i></div>
                <ul class="right-options">${rightOptions}</ul>
            </div>
        </div>
    </div>
    `;
}

function cancelOption() {
    return `
    <div class="seperator"></div>
    <a class="bc-btn ghost clickable" id="cancelBtn"><p>${getLocalizedText("menu:cancel")}</p></a>`;
}

// A bolt kezelő menüjének bal oldali listája. Külön függvény, mert a
// kedvezmény-oldal is ugyanezt a listát rakja ki, hogy onnan is lehessen
// navigálni.
function shopSettingsEntries() {
    let settings = [
        {
            elementId: "playerInventory",
            elementTitle: getLocalizedText("menu:your_inventory")
        },
        {
            elementId: "itemSale",
            elementTitle: getLocalizedText("menu:objects_on_sale")
        },
        {
            elementId: "shopStorage",
            elementTitle: getLocalizedText("menu:shop_storage")
        }
    ];

    if(hasPermission("canToggleShopStatus"))
        settings.push({
            elementId: "toggleStatus",
            elementTitle: getLocalizedText("menu:toggle_shop_status")
        });

    if(hasPermission("manager")) {
        settings.push({
            elementId: "updateLabel",
            elementTitle: getLocalizedText("menu:update_shop_label")
        });

        settings.push({
            elementId: "employees",
            elementTitle: getLocalizedText("menu:employees_management")
        });
    }

    // Kedvezmények és kirakat: kizárólag a bolt tulajdonosának. A szerver a
    // menüpont nélkül is elutasít minden mást, ez csak a felület.
    if(CAN_MANAGE_DISCOUNTS) {
        settings.push({
            elementId: "bcDiscounts",
            elementTitle: getLocalizedText("menu:bc_discounts")
        });
    }

    if(CAN_MANAGE_STOREFRONT) {
        settings.push({
            elementId: "bcStorefront",
            elementTitle: getLocalizedText("menu:bc_sf_edit")
        });
    }

    if(hasPermission("sellShop")) {
        settings.push({
            elementId: "sellShop",
            elementTitle: getLocalizedText("menu:sell_shop")
        });
    }

    return settings;
}

// display shop setting page
function showShopSettings() {
    $(".main-container").html( settingsShell(getLocalizedText("menu:shop_settings"), "bi-sliders", `
        <li class="option-element stored-money">
            <div class="sm-head">
                <p class="stored-money-title">${getLocalizedText("menu:stored_money")}</p>
                <div class="money-icon"><i class="bi bi-cash-stack"></i></div>
            </div>
            <h2 class="stored-money-amount" id="storedMoney">${CURRENCY_SYMBOL}<span>???</span></h2>
        </li>
        <li class="option-element clickable" id="withdraw-btn"><i class="bi bi-box-arrow-up"></i><p>${getLocalizedText("menu:permissions:withdraw_money")}</p></li>
        <li class="option-element clickable" id="deposit-btn"><i class="bi bi-box-arrow-in-down"></i><p>${getLocalizedText("menu:permissions:deposit_money")}</p></li>
        ${cancelOption()}
    `) );

    $.post(`https://${resName}/getShopMoney`, JSON.stringify({shopId: currentShopId}), function(shopMoney) {
        $(".stored-money-amount span").text(formatNum(shopMoney));
    });

    let settings = shopSettingsEntries();

    if( !hasPermission("depositMoney") ) {
        $("#deposit-btn").hide();
    }

    if(!hasPermission("withdrawMoney") ) {
        $("#withdraw-btn").hide();
    }

    updateSettingList(settings, "settings");
    show(true);
}

/* ── Kedvezmények kezelése (csak a bolt tulajdonosa) ──────────────────────
   A jogosultságot a szerver dönti el, ez az oldal csak a felület. Minden
   művelet után a szerver újraellenőrzi, hogy tényleg a tulaj kérte. */

function discountDate(timestamp) {
    if(!timestamp) return "";

    const d = new Date(timestamp * 1000);
    const pad = (n) => String(n).padStart(2, "0");

    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

function renderDiscountList(list) {
    const container = $(".main-container .disc-list");

    container.empty();

    if(!list || !list.length) {
        container.append(`<div class="disc-empty">${getLocalizedText("menu:bc_no_discounts")}</div>`);
        $("#disc-count").text( getLocalizedText("menu:bc_active_discounts").replace("%s", 0) );
        return;
    }

    $("#disc-count").text( getLocalizedText("menu:bc_active_discounts").replace("%s", list.length) );

    $.each(list, function(k, v) {
        const expiry = v.expiresAt > 0
            ? `${v.expired ? getLocalizedText("menu:bc_expired") : getLocalizedText("menu:bc_expires")}: ${discountDate(v.expiresAt)}`
            : getLocalizedText("menu:bc_no_expiry");

        container.append(`
        <div class="disc-row ${v.expired ? "expired" : ""}" data-identifier="${escapeHtml(v.identifier)}">
            <div class="av"><i class="bi bi-person-fill"></i></div>
            <div class="who">
                <b>${escapeHtml(v.label)}</b>
                <span>${getLocalizedText("menu:bc_granted_by")}: ${escapeHtml(v.grantedBy)} · ${discountDate(v.grantedAt)} · ${expiry}</span>
            </div>
            <span class="pct">-${v.percent}%</span>
            <a class="revoke clickable"><i class="bi bi-x-circle"></i> ${getLocalizedText("menu:bc_revoke")}</a>
        </div>`);
    });

    $(".main-container .disc-row .revoke").click(async function() {
        const identifier = $(this).closest(".disc-row").data("identifier");

        const response = await $.post(`https://${resName}/bcDiscountRevoke`, JSON.stringify({shopId: currentShopId, identifier: identifier}));

        if(response && response.ok) {
            showDiscountsManagement();
        } else {
            swal(getLocalizedText("menu:error"), getLocalizedText("menu:bc_err_not_owner"), "error");
        }
    });
}

async function showDiscountsManagement() {
    $(".main-container").html( settingsShell(getLocalizedText("menu:bc_discounts"), "bi-percent", `
        <li class="disc-add">
            <div class="disc-field narrow">
                <span class="disc-label">${getLocalizedText("menu:bc_player_id")}</span>
                <input type="number" min="1" class="inputField" id="disc-player-id">
            </div>
            <div class="disc-field narrow">
                <span class="disc-label">${getLocalizedText("menu:bc_percent")}</span>
                <input type="number" min="1" max="${MAX_DISCOUNT_PERCENT}" class="inputField" id="disc-percent">
            </div>
            <div class="disc-field">
                <span class="disc-label">${getLocalizedText("menu:bc_expiry_days")}</span>
                <input type="number" min="0" value="0" class="inputField" id="disc-days">
            </div>
            <a class="bc-btn green clickable" id="disc-add-btn"><i class="bi bi-plus-lg"></i><p>${getLocalizedText("menu:bc_add")}</p></a>
        </li>

        <li class="disc-hint">${getLocalizedText("menu:bc_discount_hint").replace("%s", MAX_DISCOUNT_PERCENT)}</li>

        <li class="disc-label" id="disc-count">${getLocalizedText("menu:bc_active_discounts").replace("%s", "…")}</li>

        <li class="disc-list"></li>

        <div class="seperator"></div>
        <li class="sf-actions">
            <a class="bc-btn ghost clickable" id="disc-revoke-all"><i class="bi bi-trash3"></i><p>${getLocalizedText("menu:bc_revoke_all")}</p></a>
            <div class="grow"></div>
            <a class="bc-btn ghost clickable" id="disc-back"><p>${getLocalizedText("menu:cancel")}</p></a>
        </li>
    `) );

    $(".main-container .shop-settings").addClass("disc-page");

    updateSettingList(shopSettingsEntries(), "settings");
    $(`.main-container .left-settings #bcDiscounts`).addClass("selected");

    show(true);

    const response = await $.post(`https://${resName}/bcDiscountList`, JSON.stringify({shopId: currentShopId}));

    if(!response || !response.allowed) {
        // a három ok más-más teendőt jelent, ne mossuk össze őket
        const key = !response ? "menu:bc_err_no_response"
            : response.reason == "busy" ? "menu:bc_err_busy"
            : "menu:bc_err_not_owner";

        swal(getLocalizedText("menu:error"), getLocalizedText(key), "error");
        showShopSettings();
        return;
    }

    MAX_DISCOUNT_PERCENT = parseInt(response.maxPercent) || MAX_DISCOUNT_PERCENT;
    renderDiscountList(response.list);

    $("#disc-add-btn").click(async function() {
        const playerId = parseInt( $("#disc-player-id").val() );
        const days = parseInt( $("#disc-days").val() ) || 0;

        // a szerver úgyis levágja, de itt is látszódjon, hogy mi ment el
        let percent = parseInt( $("#disc-percent").val() );

        if(isNaN(playerId) || isNaN(percent)) return;

        percent = Math.min(percent, MAX_DISCOUNT_PERCENT);
        $("#disc-percent").val(percent);

        const result = await $.post(`https://${resName}/bcDiscountAdd`, JSON.stringify({
            shopId: currentShopId, playerId: playerId, percent: percent, days: days
        }));

        if(result && result.ok) {
            showDiscountsManagement();
            return;
        }

        const reasons = {
            offline: "menu:bc_err_offline",
            not_owner: "menu:bc_err_not_owner",
            invalid_percent: "menu:bc_err_percent",
            self: "menu:bc_err_self",
            busy: "menu:bc_err_busy",
        };

        const key = !result ? "menu:bc_err_no_response" : (reasons[result.reason] || "menu:bc_err_offline");

        swal(getLocalizedText("menu:error"), getLocalizedText(key), "error");
    });

    $("#disc-revoke-all").click(async function() {
        const confirmed = await showConfirm(getLocalizedText("menu:confirm"), getLocalizedText("menu:bc_confirm_revoke_all"), true);

        if(!confirmed) return;

        await $.post(`https://${resName}/bcDiscountRevokeAll`, JSON.stringify({shopId: currentShopId}));

        showDiscountsManagement();
    });

    $("#disc-back").click(function() {
        showShopSettings();
    });
}

/* ── Kirakat szerkesztése (csak a bolt tulajdonosa) ───────────────────────
   A mezőket a szerver ellenőrzi újra mentéskor; ez az oldal csak a felület. */

function updateStorefrontPreview() {
    const url = $("#sf-image").val().trim();
    const thumb = $(".main-container .sf-preview .thumb");

    thumb.removeClass("empty").empty();
    $("#sf-image-warn").hide();

    if(!url) {
        thumb.addClass("empty").append(`<i class="bi bi-shop ph"></i>`);
        return;
    }

    thumb.append(`<img src="${escapeHtml(url)}" alt="" referrerpolicy="no-referrer" onerror="storefrontImgFallback(this)">`);
    thumb.append(`<i class="bi bi-shop ph"></i>`);
}

async function showStorefrontManagement() {
    const sf = SHOP_STOREFRONT || {};
    const maxLength = 600;

    $(".main-container").html( settingsShell(getLocalizedText("menu:bc_sf_edit"), "bi-images", `
        <li class="sf-preview">
            <div class="thumb empty"><i class="bi bi-shop ph"></i></div>
            <div class="meta">
                <span class="sf-label">${getLocalizedText("menu:bc_sf_preview")}</span>
                <span class="sf-name">${escapeHtml(sf.shopLabel || shopTitle || "")}</span>
                ${sf.ownerName ? `<span class="sf-owner"><i class="bi bi-person-badge"></i> ${escapeHtml(sf.ownerName)}</span>` : ""}
                <span class="sf-hint">${getLocalizedText("menu:bc_sf_preview_hint")}</span>
            </div>
        </li>

        <li class="sf-field">
            <span class="sf-label">${getLocalizedText("menu:bc_sf_image")}</span>
            <input type="text" class="inputField" id="sf-image" value="${escapeHtml(sf.imageUrl || "")}" placeholder="https://i.imgur.com/...">
            <span class="sf-hint">${getLocalizedText("menu:bc_sf_image_hint")}</span>
            <span class="sf-warn" id="sf-image-warn" style="display:none"><i class="bi bi-exclamation-triangle-fill"></i> ${getLocalizedText("menu:bc_sf_image_failed")}</span>
        </li>

        <li class="sf-field">
            <span class="sf-label">${getLocalizedText("menu:bc_sf_description")}</span>
            <textarea class="inputField bc-scroll" id="sf-description" maxlength="${maxLength}">${escapeHtml(sf.description || "")}</textarea>
            <span class="sf-counter" id="sf-counter">0 / ${maxLength}</span>
        </li>

        <li class="sf-field">
            <span class="sf-label">${getLocalizedText("menu:bc_sf_tags")}</span>
            <input type="text" class="inputField" id="sf-tags" value="${escapeHtml((sf.tags || []).join(", "))}">
        </li>

        <li class="sf-row2">
            <div class="sf-field">
                <span class="sf-label">${getLocalizedText("menu:bc_sf_hours")}</span>
                <input type="text" class="inputField" id="sf-hours" value="${escapeHtml(sf.hours || "")}">
            </div>
            <div class="sf-field">
                <span class="sf-label">${getLocalizedText("menu:bc_sf_phone")}</span>
                <input type="text" class="inputField" id="sf-phone" value="${escapeHtml(sf.phone || "")}">
            </div>
        </li>

        <div class="seperator"></div>
        <li class="sf-actions">
            <a class="bc-btn ghost clickable" id="sf-clear"><i class="bi bi-trash3"></i><p>${getLocalizedText("menu:bc_sf_clear")}</p></a>
            <div class="grow"></div>
            <a class="bc-btn ghost clickable" id="sf-back"><p>${getLocalizedText("menu:cancel")}</p></a>
            <a class="bc-btn green clickable" id="sf-save"><p>${getLocalizedText("menu:bc_sf_save")}</p></a>
        </li>
    `) );

    $(".main-container .shop-settings").addClass("sf-page");

    updateSettingList(shopSettingsEntries(), "settings");
    $(`.main-container .left-settings #bcStorefront`).addClass("selected");

    show(true);

    updateStorefrontPreview();

    const counter = function() {
        $("#sf-counter").text(`${$("#sf-description").val().length} / ${maxLength}`);
    };

    counter();

    $("#sf-description").on("input", counter);

    // Gépelés közben is frissüljön az előnézet, de ne indítsunk képletöltést
    // minden leütésre — enélkül a tulaj csak mentés után látná, hogy jó-e a link.
    let previewTimer = null;

    $("#sf-image").on("input", function() {
        clearTimeout(previewTimer);
        previewTimer = setTimeout(updateStorefrontPreview, 600);
    });

    $("#sf-image").on("change blur", updateStorefrontPreview);

    $("#sf-save").click(async function() {
        const result = await $.post(`https://${resName}/bcStorefrontSave`, JSON.stringify({
            shopId: currentShopId,
            imageUrl: $("#sf-image").val(),
            description: $("#sf-description").val(),
            tags: $("#sf-tags").val(),
            hours: $("#sf-hours").val(),
            phone: $("#sf-phone").val(),
        }));

        if(result && result.ok) {
            await loadShopStorefront(currentShopId);
            showShopSettings();
            return;
        }

        const reasons = {
            not_https: "menu:bc_sf_err_https",
            bad_host: "menu:bc_sf_err_host",
            bad_url: "menu:bc_sf_err_url",
            too_long: "menu:bc_sf_err_url",
            not_owner: "menu:bc_err_not_owner",
            busy: "menu:bc_err_busy",
        };

        const key = !result ? "menu:bc_err_no_response" : (reasons[result.reason] || "menu:bc_sf_err_url");

        swal(getLocalizedText("menu:error"), getLocalizedText(key), "error");
    });

    $("#sf-clear").click(async function() {
        const confirmed = await showConfirm(getLocalizedText("menu:confirm"), getLocalizedText("menu:bc_sf_confirm_clear"), true);

        if(!confirmed) return;

        await $.post(`https://${resName}/bcStorefrontClear`, JSON.stringify({shopId: currentShopId}));
        await loadShopStorefront(currentShopId);

        showShopSettings();
    });

    $("#sf-back").click(function() {
        showShopSettings();
    });
}

async function showEmployeesManagement() {
    $(".main-container").html( settingsShell(getLocalizedText("menu:employees_management"), "bi-people-fill", `
        <li class="option-element stored-money">
            <div class="sm-head">
                <p class="stored-money-title">${getLocalizedText("menu:employees")}</p>
                <div class="money-icon people"><i class="bi bi-people-fill"></i></div>
            </div>
            <h2 class="stored-money-amount count" id="storedMoney"><span>${getLocalizedText("menu:members")}</span></h2>
        </li>
        <li class="option-element clickable" id="fireBtn"><i class="bi bi-person-dash"></i><p>${getLocalizedText("menu:fire")}</p></li>
        <li class="option-element clickable" id="managePermissionsBtn"><i class="bi bi-shield-lock"></i><p>${getLocalizedText("menu:manage_permissions")}</p></li>
        ${cancelOption()}
    `) );

    const rawEmployees = await $.post(`https://${resName}/getEmployees`, JSON.stringify({shopId: currentShopId}));
    
    const elaboratedEmployees = Object.values(rawEmployees).map(employeData => {
        return {
            elementId: employeData.identifier,
            elementTitle: employeData.name,
            data: employeData.permissions
        }
    })

    $("#storedMoney span").text(elaboratedEmployees.length + " " + getLocalizedText("menu:members"));

    updateSettingList(elaboratedEmployees, "manageEmployees");
    show(true);
}

async function showEmployeesOptions() {
    $(".main-container").html( settingsShell(getLocalizedText("menu:employees_management"), "bi-people-fill", cancelOption()) );

    updateSettingList([
        {
            elementId: "hireEmployee",
            elementTitle: getLocalizedText("menu:hire_employee")
        },
        {
            elementId: "manageEmployees",
            elementTitle: getLocalizedText("menu:manage_employees")
        },
    ], "employeesOptions");
    
    show(true);
}

async function showClosePlayersToHire() {
    const closePlayers = await $.post(`https://${resName}/getClosePlayers`, JSON.stringify({}));

    $(".main-container").html( settingsShell(getLocalizedText("menu:hire_employee"), "bi-person-plus", cancelOption()) );

    let settingsList = [];

    if(closePlayers && closePlayers.length > 0) {
        closePlayers.forEach(playerData => {
            settingsList.push({
                elementId: "player-id-" + playerData.id,
                elementTitle: `${getLocalizedText("menu:hire")} ${playerData.name}`,
            });
        });
    } else {
        settingsList.push({
            elementId: "no-players",
            elementTitle: getLocalizedText("menu:no_players_nearby"),
        });
    }

    updateSettingList(settingsList, "hireEmployee");
    show(true);
}

// shared shell for the small input / confirm dialogs
function dialogShell(inputTitle, inputDescription, icon, inputField) {
    return `
    <div class="inputMenu">
        <div class="bar">
            <div class="brand">
                <div class="logo"><i class="bi ${icon}"></i></div>
                <div class="name">
                    <span class="k">${getLocalizedText("menu:bc_brand")}</span>
                    <h2 class="inputMenuTitle">${inputTitle}</h2>
                </div>
            </div>
        </div>

        <div class="ibody">
            <p class="inputMenuDesc">${inputDescription}</p>

            <div class="buttons">
                ${inputField ? `<input type="text" class="inputField" placeholder="${getLocalizedText("menu:value")}">` : ""}
                <div class="brow">
                    <a class="bc-btn ghost cancel-btn clickable" id="cancel"><p>${getLocalizedText("menu:cancel")}</p></a>
                    <a class="bc-btn green submit-btn clickable" id="submit"><p>${getLocalizedText("menu:submit")}</p></a>
                </div>
            </div>
        </div>
    </div>
    `;
}

// display input menu
async function showInput(inputTitle, inputDescription, closeAfterSubmit) {
    return new Promise((resolve, reject) => {
        $(".main-container").html( dialogShell(inputTitle, inputDescription, "bi-pencil-square", true) );

        $(".inputField").focus().on("keyup", function (e) {
            if(e.key == "Enter") $("#submit").click();
        });

        $(".inputMenu .buttons a").click(function () {
            switch ($(this).attr('id')) {
                case 'cancel': {
                    resolve();
                    break;
                }
                case 'submit': {
                    let val = $(`.inputMenu .buttons input`).val();
                    resolve(val)
                    break;
                }
            }

            if (closeAfterSubmit) {
                $(".main-container").hide();
                showShopSettings();
            }
        });
    });
}

// display confirm/cancel
async function showConfirm(inputTitle, inputDescription, closeAfterSubmit) {
    return new Promise((resolve, reject) => {
        $(".main-container").html( dialogShell(inputTitle, inputDescription, "bi-question-circle", false) );

        $(".inputMenu .buttons a").click(function () {
            switch ($(this).attr('id')) {
                case 'cancel': {
                    resolve(false);
                    break;
                }
                case 'submit': {
                    resolve(true)
                    break;
                }
            }

            if (closeAfterSubmit) {
                show(false);
            }
        });
    });
}

// display buy shop
function showDialogToBuyShop(shopPrice, shopId, shopLabel, shopDesc, shopResell) {
    $(".main-container").html(`
    <div class="buy-shop">
        <div class="bar">
            <div class="brand">
                <div class="logo"><i class="bi bi-shop"></i></div>
                <div class="name">
                    <span class="k">${getLocalizedText("menu:buy_shop")}</span>
                    <span class="shop-title">${shopLabel}</span>
                </div>
            </div>
            <div class="bar-right">
                <div class="plate"><span class="dot"></span><span>${CURRENCY_SYMBOL}${formatNum(shopPrice)}</span></div>
                <a class="bc-close cancel-btn clickable"><i class="bi bi-x-lg"></i></a>
            </div>
        </div>

        <div class="body">
            <div class="preview-image">
                <img src="./assets/png/shop-preview.png" class="shop-image">
                <div class="adress-text">
                    <p class="shop-id">#${shopId}</p>
                    <h2>${shopLabel}</h2>
                </div>
            </div>

            <div class="right-side">
                <div class="info-box">
                    <div class="ih">${getLocalizedText("menu:description")}</div>
                    <p class="info-text">${shopDesc}</p>
                </div>

                <div class="info-box">
                    <div class="ih">${getLocalizedText("menu:generic")}</div>
                    <div class="info-row"><span>${getLocalizedText("menu:id")}</span><span>${shopId}</span></div>
                    <div class="info-row"><span>${getLocalizedText("menu:price")}</span><span>${CURRENCY_SYMBOL}${formatNum(shopPrice)}</span></div>
                    <div class="info-row"><span>${getLocalizedText("menu:resell")}</span><span class="bc-badge">${shopResell}</span></div>
                </div>

                <div class="buttons">
                    <a class="bc-btn green purchase-btn clickable"><p>${getLocalizedText("menu:purchase")}</p></a>
                    <a class="bc-btn ghost cancel-btn clickable"><p>${getLocalizedText("menu:cancel")}</p></a>
                </div>
            </div>
        </div>
    </div>
    `);
    $(".buy-shop .purchase-btn").click(function () {
        $.post(`https://${resName}/buyPlayersShop`, JSON.stringify({shopId: shopId}));

        show(false);
    });
    $(".buy-shop .cancel-btn").click(function () {

        show(false);
    });
    show(true);
}

function resetSelectedItem() {
    $(".item-element").removeClass("on");
    selectedItemDiv = null;
    updateSelectionBox();
}

// keep the sidebar info box in sync with the selected item and the typed amount
function updateSelectionBox() {
    if(!$(".info-box").length) return;

    if(!selectedItemDiv) {
        $("#sel-name, #sel-price, #sel-stock, #sel-qty, #sel-total").text("—");
        $("#sel-disc-row").hide();
        return;
    }

    const price = parseFloat( selectedItemDiv.data("price") );
    const amount = parseInt( $("#amount-input").val() );

    // kedvezmény csak arra, amit a bolt elad
    const hasDiscount = isDiscountActive() && selectedItemDiv.data("method") == "buy" && !isNaN(price);
    const unitPay = hasDiscount ? discountedUnitPrice(price) : price;

    $("#sel-name").text( selectedItemDiv.find(".item-name").text() );
    $("#sel-stock").text( selectedItemDiv.find(".item-count").text() );
    $("#sel-qty").text( isNaN(amount) ? "—" : formatNum(amount) );
    $("#sel-price").text( isNaN(price) ? "—" : CURRENCY_SYMBOL + formatNum(price) );
    $("#sel-total").text( (isNaN(price) || isNaN(amount)) ? "—" : CURRENCY_SYMBOL + formatNum(unitPay * amount) );

    $("#sel-disc-row").toggle(hasDiscount);

    if(hasDiscount) {
        const saved = (price - unitPay) * (isNaN(amount) ? 1 : amount);

        $("#sel-disc").text(`-${SHOP_DISCOUNT}% (-${CURRENCY_SYMBOL}${formatNum(saved)})`);

        if(!isNaN(amount)) {
            $("#main-action-btn p").text(`${getLocalizedText("menu:purchase")} — ${CURRENCY_SYMBOL}${formatNum(unitPay * amount)}`);
        }
    }
}

// Inventory images differ per resource: png first (see integrations/cl_integrations.lua),
// then webp, then the bundled placeholder. If none resolve we drop the <img> and show an
// icon instead — CEF collapses a broken image to 0x0, which pulls the whole card apart.
function itemImgFallback(img) {
    const step = Number(img.dataset.step || 0) + 1;
    img.dataset.step = step;

    switch(step) {
        case 1: {
            img.src = `${IMAGES_PATH}/${$(img).closest(".item-element").data("itemName")}.webp`;
            break;
        }

        case 2: {
            img.src = "./images/undefined.png";
            break;
        }

        default: {
            img.onerror = null;
            img.style.display = "none";
            img.parentNode.classList.add("empty");
        }
    }
}

// append item function
function loadItems(items) {
    $.each(items, function (k, v) {
        if(!v) return; // skip if item is null
        if(!isItemNameInFilterId(v.name)) return; // skip if item is not in filter (if filter is active)

        let quantity = v.quantity || v.count || "∞";

        if(quantity == -1) {
            quantity = getLocalizedText("menu:out_of_stock")
        }

        // Készlethiánynál nincs mit ígérni: a szavatosság-jelvény ilyenkor
        // kimarad, különben a tartalék-értéket írnánk ki olyasmire, amiből
        // egy darab sincs.
        const inStock = v.quantity != -1;

        // kedvezmény: áthúzott alapár + a ténylegesen fizetendő egységár
        const unitPay = (isDiscountActive() && v.method == "buy") ? discountedUnitPrice(v.price) : v.price;
        const isDiscounted = unitPay < v.price;

        const priceHtml = isDiscounted
            ? `<span class="item-price old">${CURRENCY_SYMBOL}${formatNum(v.price)}</span><span class="item-price">${CURRENCY_SYMBOL}${formatNum(unitPay)}</span>`
            : `<span class="item-price">${CURRENCY_SYMBOL}${formatNum(v.price)}</span>`;

        let itemDiv = $(`
        <li class="item-element clickable" data-item-id="${v.id}" data-price="${v.price}" data-method="${v.method}" data-item-name="${v.name}" data-item-type="${v.type}">
            <div class="inner-item">
                ${isDiscounted ? `<span class="disc-badge">-${SHOP_DISCOUNT}%</span>` : ""}
                <p class="item-count">${quantity}</p>
                <div class="item-thumb">
                    <img src="${IMAGES_PATH}/${v.name}.png" class="item-img" alt="" onerror="itemImgFallback(this)">
                    <i class="bi bi-box-seam"></i>
                </div>
                <p class="item-info"><span class="item-name">${v.label}</span><br>${priceHtml}${inStock ? `<span class="life-badge" style="display:none"></span>` : ""}</p>
            </div>
        </li>
        `)

        // stripe tells apart what the shop sells from what it buys
        if(v.method == "sell") {
            itemDiv.addClass("m-sell");
        } else if(v.method == "buy") {
            itemDiv.addClass("m-buy");
        }

        $(".items-list").append(itemDiv);
    });

    // item clicked
    $(".items-list .item-element").click(function () {
        resetSelectedItem();
        selectedItemDiv = $(this);

        switch(currentShopType) {
            case "playersShop": {
                const method = $(this).data('method');

                if(method == "buy") {
                    $("#main-action-btn p").text(getLocalizedText("menu:purchase"));
                    toggleSellAllButton(false);
                } else if(method == "sell") {
                    $("#main-action-btn p").text(getLocalizedText("menu:sell"));
                    toggleSellAllButton(true);
                }

                break;
            }

            case "playersShopObjectsOnSaleSettings": {
                const method = $(this).data('method');

                if(method == "sell") { // player has to sell to shop
                    toggleToBuyItemsOptions(true);
                    toggleOnSaleItemsOptions(false);
                } else if(method == "buy") { // player has to buy from shop
                    toggleToBuyItemsOptions(false);
                    toggleOnSaleItemsOptions(true);
                }

                break;
            }
        }

        $(this).addClass("on");
        updateSelectionBox();
    });

    applyQualityBadges();

    const hasToShowPrice = currentShopType != "playerInventory" && currentShopType != "playersShopObjectsFromStorage";

    $(".items-list").find(".item-price").toggle(hasToShowPrice);
    $("#sel-price-row, #sel-total-row").toggle(hasToShowPrice);
}

function setupSettingsClickEvents() {
    $(".shop-settings ul [id]").click(async function () {
        switch ($(this).attr('id')) {
            case 'toggleStatus': {
                $.post(`https://${resName}/toggleShopStatus`, JSON.stringify({shopId: currentShopId}));
                break;
            }
            case 'playerInventory': {
                currentShopType = "playerInventory";
                            
                shopTitle = getLocalizedText("menu:your_inventory")

                refreshItemsInUI();

                break;
            }
            case 'itemSale': {
                currentShopType = "playersShopObjectsOnSaleSettings";

                shopTitle = getLocalizedText("menu:objects_on_sale")

                refreshItemsInUI();

                break;
            }
            case 'shopStorage': {
                currentShopType = "playersShopObjectsFromStorage";

                shopTitle = getLocalizedText("menu:shop_storage")

                refreshItemsInUI();

                break;
            }
            case 'updateLabel': {
                const newShopLabel = await showInput(getLocalizedText("menu:update_shop_label"), getLocalizedText("menu:enter_new_shop_label"), true);

                if(newShopLabel) {
                    $.post(`https://${resName}/updateShopLabel`, JSON.stringify({shopId: currentShopId, label: newShopLabel}));
                }

                break;
            }

            case 'employees': {
                showEmployeesOptions();
                break;
            }

            case 'bcDiscounts': {
                showDiscountsManagement();
                break;
            }

            case 'bcStorefront': {
                showStorefrontManagement();
                break;
            }
            
            case 'sellShop': {

                const confirm = await showConfirm(getLocalizedText("menu:confirm"), getLocalizedText("menu:are_you_sure_to_sell_the_shop"), true)

                if(confirm) {
                    $.post(`https://${resName}/sellShop`, JSON.stringify({shopId: currentShopId}));
                    show(false);
                }

                break;
            }

            case 'cancelBtn': {
                show(false);
                break;
            }

            case 'withdraw-btn': {
                const amount = await showInput(getLocalizedText("menu:amount"), getLocalizedText("menu:enter_amount_to_withdraw"), true);
                if(amount != null) {
                    await $.post(`https://${resName}/withdrawMoney`, JSON.stringify({shopId: currentShopId, amount: amount}));
                }

                showShopSettings();

                break;
            }
            case 'deposit-btn': {
                const amount = await showInput(getLocalizedText("menu:amount"), getLocalizedText("menu:enter_amount_to_deposit"), true);

                if(amount != null) {
                    await $.post(`https://${resName}/depositMoney`, JSON.stringify({shopId: currentShopId, amount: amount}));
                };
                
                showShopSettings();

                break;
            }
        }
    });
}

function setupEmployeesOptionsClickEvents() {
    $(".shop-settings ul [id]").click(async function () {
        switch ($(this).attr('id')) {
            case 'hireEmployee': {
                showClosePlayersToHire();
                break;
            }

            case "manageEmployees": {
                showEmployeesManagement();
                break;
            }
            
            case 'cancelBtn': {
                showShopSettings();
                break;
            }
        }
    });
}

function setupClosePlayersToHireClickEvents() {
    $(".shop-settings ul [id]").click(async function () {
        switch ($(this).attr('id')) {
            case 'cancelBtn': {
                showEmployeesOptions();
                break;
            }

            default: {
                const elementId = $(this).attr('id');
                const playerId = parseInt( elementId.replace("player-id-", "") );

                if(playerId) {
                    $.post(`https://${resName}/hirePlayerId`, JSON.stringify({shopId: currentShopId, playerId: playerId}), function(successful) {
                        if(successful) {
                            showEmployeesOptions();
                        }
                    });
                }

                break;
            }
        }
    });
}

function setupEmployeesManagementClickEvents() {
    $(".shop-settings ul .clickable").click(async function () {
        switch ($(this).attr('id')) {
            case 'cancelBtn': {
                showEmployeesOptions();
                break;
            }

            case "fireBtn": {
                // Get the selected employee
                const selectedEmployeeDiv = $(".left-settings .setting-element.selected");
                const identifier = selectedEmployeeDiv.attr('id');

                if(identifier) {
                    const successful = await $.post(`https://${resName}/fireEmployee`, JSON.stringify({shopId: currentShopId, identifier: identifier}));

					if(successful)
						showEmployeesManagement();
                }

                break;
            }

            case "managePermissionsBtn": {
                // Get the selected employee
                const selectedEmployeeDiv = $(".left-settings .setting-element.selected");
                const playerName = selectedEmployeeDiv.find("p").text();
                const identifier = selectedEmployeeDiv.attr('id');
                const permissions = selectedEmployeeDiv.data("data");

                if(identifier) {
                    showPermissionPage(identifier, playerName, permissions);
                }

                break;
            }
        }
    });

    $(".shop-settings ul .setting-element").click(function () {
        $(".shop-settings ul .setting-element").removeClass("selected");
        $(this).addClass("selected");
    });
}

// update shop settings / employee list
function updateSettingList(settings, method) {
    $(".main-container .shop-settings .left-settings").empty();
    $.each(settings, function (k, v) {
        let div = $(`<li class="setting-element clickable" id="${v.elementId}"><p>${v.elementTitle}</p></li>`);
        div.data("data", v.data);
        $(".main-container .shop-settings .left-settings").append(div);

    });

    switch(method) {
        case "settings": {
            setupSettingsClickEvents();
            break;
        }

        case "employeesOptions": {
            setupEmployeesOptionsClickEvents();
            break;
        }

        case "hireEmployee": {
            setupClosePlayersToHireClickEvents();
            break;
        }

        case "manageEmployees": {
            setupEmployeesManagementClickEvents();
            break;
        }
    }
};

/*
███████ ███    ███ ██████  ██       ██████  ██    ██ ███████ ███████ ███████     ██████  ███████ ██████  ███    ███ ███████
██      ████  ████ ██   ██ ██      ██    ██  ██  ██  ██      ██      ██          ██   ██ ██      ██   ██ ████  ████ ██     
█████   ██ ████ ██ ██████  ██      ██    ██   ████   █████   █████   ███████     ██████  █████   ██████  ██ ████ ██ ███████
██      ██  ██  ██ ██      ██      ██    ██    ██    ██      ██           ██     ██      ██      ██   ██ ██  ██  ██      ██
███████ ██      ██ ██      ███████  ██████     ██    ███████ ███████ ███████     ██      ███████ ██   ██ ██      ██ ███████
*/

function showPermissionPage(identifier, userName, permissionList) {
    $('.main-container').html(`
    <div class='shop-permissions'>
        <div class="bar">
            <div class="brand">
                <div class="logo"><i class="bi bi-shield-lock"></i></div>
                <div class="name">
                    <span class="k">${getLocalizedText("menu:manage_permissions")}</span>
                    <span class="shop-title">${userName}</span>
                </div>
            </div>
        </div>

        <ul class='permissions-list page'></ul>

        <div class="foot">
            <a class="bc-btn ghost clickable" id="perm-cancel"><p>${getLocalizedText("menu:cancel")}</p></a>
            <div class='bc-btn green submit-btn clickable'><p>${getLocalizedText("menu:submit")}</p></div>
        </div>
    </div>
    `);

    $("#perm-cancel").click(() => showEmployeesManagement());

    const ALL_PERMISSIONS = [
        {
            permissionId: "manager",
            permissionText: getLocalizedText("menu:permissions:manager"),
        },
    
        {
            permissionId: "addObjectToSale",
            permissionText: getLocalizedText("menu:permissions:add_object_to_sale"),
        },
        
        {
            permissionId: "removeObjectFromSale",
            permissionText: getLocalizedText("menu:permissions:remove_object_from_sale"),
        },
        
        {
            permissionId: "updateObjectPrice",
            permissionText: getLocalizedText("menu:permissions:update_object_price"),
        },
        
        {
            permissionId: "addObjectStocks",
            permissionText: getLocalizedText("menu:permissions:add_object_stocks"),
        },
        
        {
            permissionId: "addObjectToBuyList",
            permissionText: getLocalizedText("menu:permissions:add_object_to_buy_list"),
        },
        
        {
            permissionId: "updateObjectQuantity",
            permissionText: getLocalizedText("menu:permissions:update_object_quantity"),
        },
        
        {
            permissionId: "removeObjectFromToBuyList",
            permissionText: getLocalizedText("menu:permissions:remove_object_from_to_buy_list"),
        },
        
        {
            permissionId: "depositMoney",
            permissionText: getLocalizedText("menu:permissions:deposit_money"),
        },
        
        {
            permissionId: "withdrawMoney",
            permissionText: getLocalizedText("menu:permissions:withdraw_money"),
        },
        
        {
            permissionId: "withdrawStoredObjects",
            permissionText: getLocalizedText("menu:permissions:withdraw_stored_objects"),
        },
        
        {
            permissionId: "depositStoredObjects",
            permissionText: getLocalizedText("menu:permissions:deposit_stored_objects"),
        },
        
        {
            permissionId: "canToggleShopStatus",
            permissionText: getLocalizedText("menu:permissions:can_toggle_shop_status"),
        },
        
        {
            permissionId: "toggleDoors",
            permissionText: getLocalizedText("menu:permissions:toggle_doors"),
        },
    ];

    $.each(ALL_PERMISSIONS, function (k, v) {
        const hasPermission = permissionList[v.permissionId] || false;

        $('.permissions-list').append(`
        <li class='permission-element' id='${v.permissionId}'>
            <p class='permission-text'>${v.permissionText}</p>
            <div class='switch' id='${hasPermission}'>
                <a class='switch-off'></a>
                <div class='seperator'></div>
                <a class='switch-on'></a>
            </div>
        </li>
        `);
        $(`#${v.permissionId} .switch`).click(function () {
            let currentState = $(this).attr('id');
            if (currentState === 'false') {
                currentState = true;
            } else if (currentState === 'true') {
                currentState = false;
            }
            $(this).attr('id', currentState);
        });
    });
    $(".main-container .shop-permissions .submit-btn").click(function () {
        let permissions = {};

        $.each(ALL_PERMISSIONS, function (k, v) {
            let currentState = $(`#${v.permissionId} .switch`).attr('id');
            if (currentState === 'false') {
                currentState = false;
            } else if (currentState === 'true') {
                currentState = true;
            }
            permissions[v.permissionId] = currentState;
        });

        $.post(`https://${resName}/updateIdentifierPermissions`, JSON.stringify({shopId: currentShopId, identifier: identifier, permissions: permissions}), function(successful) {
            if(successful)
                showEmployeesManagement();
        });
    });
}

function hasPermission(permissionName) {
	let permissions = selfPermissions;

	if(!permissions) return;

	return permissions["manager"] || permissions[permissionName] || false;
}

// format numbers (1000 -> 1,000)
function formatNum(num) {
    if(typeof num !== 'number') return num;
    return Math.floor(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, PRICES_SEPARATOR);
}

window.addEventListener('message', (event) => {
	let data = event.data;
	let action = data.action;

	switch(action) {
		case "showDialogToBuyShop": {
			showDialogToBuyShop(
                data.shopPrice,
                data.shopId,
                data.shopLabel,
                getLocalizedText("menu:become_the_owner_of_this_shop"),
                `${data.resellPercentage}% ( ${CURRENCY_SYMBOL}${Math.floor( data.shopPrice * data.resellPercentage / 100 )} )`)
			break;
		}

        case "openAdminShop": {
            ITEMS = data.itemsData;
            currentShopType = `adminShop-${data.type}`
            currentShopId = data.shopId
            
            shopTitle = data.shopLabel

			showMainShop();

			break;
		}

        case "openPlayersShop": {
            ITEMS = data.objectsInShop;
            currentShopType = `playersShop`
            currentShopId = data.shopId

            shopTitle = data.label

            openWithExtras(data.shopId, refreshItemsInUI);

            break;
        }

        case "openPlayersShopManagement": {
            currentShopId = data.shopId

            selfPermissions = data.permissions;

            openWithExtras(data.shopId, showShopSettings);

			break;
		}

        // adtak vagy visszavontak egy kedvezményt, miközben nyitva a bolt
        case "bcDiscountChanged": {
            if(currentShopType == "playersShop" && currentShopId == data.shopId) {
                loadShopDiscount(data.shopId).then(refreshItemsInUI);
            }

            break;
        }

        case "loadFilters": {
            ALL_FILTERS = data.filters;
            break;
        }

        case "loadImagesPath": {
            IMAGES_PATH = data.imagesPath;
            break;
        }

        case "loadPricesSeparator": {
            PRICES_SEPARATOR = data.symbol;
            break;
        }
    }
});

// Closes menu when clicking ESC
$(document).on('keyup', function(e) {
	if (e.key == "Escape") {
		if( $(".main-container").is(":visible") ) {
			show(false);
		}
	}
});