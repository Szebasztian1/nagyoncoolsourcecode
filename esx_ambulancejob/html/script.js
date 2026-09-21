const heartbeat = new Audio("heartbeat.mp3");
heartbeat.loop = true;
heartbeat.volume = 0.05;

const modal     = document.getElementById("call-modal");
const msgInput  = document.getElementById("call-message");
const submitBtn = document.getElementById("modal-submit");
const cancelBtn = document.getElementById("modal-cancel");
const charCount = document.getElementById("char-count");
const textuiBar = document.querySelector(".textui-bar");
const respawnPrompt = document.getElementById("respawn-prompt");

let deathScreenVisible = false;
let modalOpen          = false;
let callPending        = false;   // blocks G/H while a fetch is in-flight
let distressSound      = null;    // single distress sound slot — stops overlap
let canRespawn         = false;   // true once bleedout phase begins (E enabled)
let respawnSent        = false;   // prevents spamming the respawn request
let instantPending     = false;   // blocks K while the PP charge is in-flight
let toastTimer         = null;

const deathToast = document.getElementById("death-toast");

// Rövid üzenet a sáv fölött. A halálképernyőn nincs más visszajelzés, enélkül a
// "nincs elég PP" némán elveszne.
function showToast(text, isError) {
    if (!deathToast) return;

    deathToast.textContent = text;
    deathToast.classList.toggle("error", isError === true);
    deathToast.classList.add("visible");

    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(function () {
        deathToast.classList.remove("visible");
    }, 4000);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function nuiFetch(endpoint, body) {
    return fetch("https://esx_ambulancejob/" + endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body || {}),
    }).then(function (r) { return r.json(); });
}

function playRandomDistress(onEnd) {
    // stop any currently playing distress sound first
    if (distressSound) {
        distressSound.pause();
        distressSound.currentTime = 0;
        distressSound = null;
    }
    const n = Math.floor(Math.random() * 3) + 1;
    distressSound = new Audio(n + ".mp3");
    distressSound.volume = 0.8;
    distressSound.play().catch(function () {});
    if (onEnd) {
        distressSound.addEventListener("ended", onEnd, { once: true });
    }
}

function openModal() {
    modalOpen = true;
    modal.classList.add("visible");
    msgInput.focus();
    nuiFetch("setNuiFocus", { focus: true, cursor: true });
}

function closeModal() {
    modalOpen   = false;
    callPending = false;
    modal.classList.remove("visible");
    msgInput.value = "";
    charCount.textContent = "0 / 200";
    nuiFetch("setNuiFocus", { focus: false, cursor: false });
}

// ── Keyboard: G / H ──────────────────────────────────────────────────────────

function handleDeathScreenKey(key) {
    if (!deathScreenVisible) return;

    key = key.toLowerCase();

    // G — call a live ambulance
    if (key === "g" && !modalOpen && !callPending) {
        callPending = true;
        nuiFetch("checkAmbulance").then(function (res) {
            if (res.available) {
                textuiBar.classList.add("hidden");
                playRandomDistress(function () {
                    openModal();
                });
            } else {
                callPending = false;
            }
        }).catch(function () {
            callPending = false;
        });
    }

    // E — early respawn (only during bleedout phase)
    if (key === "e" && canRespawn && !respawnSent && !modalOpen) {
        respawnSent = true;
        respawnPrompt.textContent = "";
        nuiFetch("respawnEarly");
    }

    // K — instant respawn for Premium Points
    if (key === "k" && !modalOpen && !instantPending && !respawnSent) {
        instantPending = true;
        nuiFetch("instantRevive").then(function (res) {
            instantPending = false;

            if (res && res.ok) {
                respawnSent = true;
                textuiBar.classList.add("hidden");
                showToast(res.msg || "Éledsz...", false);
            } else if (res && res.msg) {
                showToast(res.msg, true);
            }
        }).catch(function () {
            instantPending = false;
        });
    }

    // H — NPC transport
    if (key === "h" && !modalOpen && !callPending) {
        callPending = true;
        nuiFetch("callNPC").then(function (res) {
            if (res.cancall) {
                textuiBar.classList.add("hidden");
                playRandomDistress();
            } else {
                callPending = false;
            }
        }).catch(function () {
            callPending = false;
        });
    }
}

document.addEventListener("keydown", function (e) {
    handleDeathScreenKey(e.key);
});

// ── Modal actions ─────────────────────────────────────────────────────────────

submitBtn.addEventListener("click", function () {
    const message = msgInput.value.trim();
    nuiFetch("submitCallModal", { message: message });
    closeModal();
});

cancelBtn.addEventListener("click", function () {
    nuiFetch("cancelCallModal");
    closeModal();
});

msgInput.addEventListener("input", function () {
    charCount.textContent = msgInput.value.length + " / 200";
});

msgInput.addEventListener("keydown", function (e) {
    if (e.key === "Enter" && e.ctrlKey) {
        submitBtn.click();
    }
});

// ── NUI messages from Lua ─────────────────────────────────────────────────────

window.addEventListener("message", function (event) {
    if (event.data.type === "pressKey") {
        handleDeathScreenKey(event.data.key);
    } else if (event.data.type === "show") {
        deathScreenVisible = event.data.enable;
        document.body.style.display = event.data.enable ? "block" : "none";

        if (deathToast) deathToast.classList.remove("visible");
        instantPending = false;

        if (event.data.enable) {
            callPending = false;
            canRespawn  = false;
            respawnSent = false;
            respawnPrompt.textContent = "";
            textuiBar.classList.remove("hidden");
            heartbeat.currentTime = 0;
            heartbeat.play().catch(function () {});
        } else {
            canRespawn  = false;
            respawnSent = false;
            respawnPrompt.textContent = "";
            heartbeat.pause();
            heartbeat.currentTime = 0;
            if (distressSound) {
                distressSound.pause();
                distressSound = null;
            }
            textuiBar.classList.remove("hidden");
            closeModal();
        }

        document.getElementById("killer").innerHTML = event.data.killer
            ? "Megölt: " + event.data.killer
            : "";

    } else if (event.data.type === "canRespawn") {
        canRespawn  = event.data.enable;
        respawnSent = false;
        respawnPrompt.textContent = event.data.enable ? "[ E ] az újraéledéshez" : "";

    } else if (event.data.type === "respawntime") {
        document.getElementById("respawn").innerHTML = event.data.time;

    } else if (event.data.type === "ambulance") {
        document.getElementById("ambulance").innerHTML =
            "Elérhető mentősők: " + event.data.count;
    }
});
