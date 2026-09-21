// Figyeljük a Lua (kliens) felől érkező üzeneteket
window.addEventListener('message', function(event) {
    const item = event.data;

    if (item.type === "open") {
        // Megjelenítjük a fő konténert
        document.getElementById('container').style.display = 'flex';
        // Feltöltjük a listát a kapott adatokkal
        updateBanList(item.bans);
    } 
    else if (item.type === "updateList") {
        // Frissítjük a listát (pl. ha épp most tiltottunk ki valakit)
        updateBanList(item.bans);
    }
});

// Ez a függvény generálja le a tiltott játékosok listáját a bal oldalon
function updateBanList(bans) {
    const listElement = document.getElementById('ban-list');
    listElement.innerHTML = ''; // Előbb kiürítjük

    if (!bans || bans.length === 0) {
        listElement.innerHTML = '<p style="text-align:center; color:gray; font-size:12px; margin-top:20px;">Nincs aktív tiltás.</p>';
        return;
    }

    bans.forEach(ban => {
        const div = document.createElement('div');
        div.className = 'ban-item';
        div.innerHTML = `
            <div>
                <h4 style="margin:0; color:#fff;">${ban.name}</h4>
                <p style="margin:2px 0; font-size:11px; color:#bbb;">
                    <i class="fas fa-clock"></i> Lejár: ${formatTime(ban.untilTime)}
                </p>
                <p style="margin:2px 0; font-size:11px; color:#bbb;">
                    <i class="fas fa-comment"></i> ${ban.reason}
                </p>
                <p style="margin:2px 0; font-size:10px; color:#5dade2;">
                    <i class="fas fa-user-shield"></i> Admin: ${ban.bannedBy}
                </p>
            </div>
            <button class="unban-btn" onclick="unbanPlayer('${ban.identifier}')">
                <i class="fas fa-unlock"></i> Feloldás
            </button>
        `;
        listElement.appendChild(div);
    });
}

// Segédfüggvény: Unix timestamp-ből kiszámolja a hátralévő perceket
function formatTime(until) {
    const now = Math.floor(Date.now() / 1000);
    const diff = until - now;
    if (diff <= 0) return "Lejárt";
    return Math.ceil(diff / 60) + " perc";
}

// Amikor a "Tiltás érvényesítése" gombra kattintasz
document.getElementById('submit-ban').addEventListener('click', () => {
    const targetId = document.getElementById('target-id').value;
    const banTime = document.getElementById('ban-time').value;
    const banReason = document.getElementById('ban-reason').value;

    if (targetId && banTime && banReason) {
        // Küldjük az adatokat a kliensnek (client.lua)
        fetch(`https://${GetParentResourceName()}/submitBan`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                id: targetId,
                time: banTime,
                reason: banReason
            })
        });
        
        // Mezők kiürítése a beküldés után
        document.getElementById('target-id').value = '';
        document.getElementById('ban-time').value = '';
        document.getElementById('ban-reason').value = '';
    } else {
        console.log("Minden mezőt ki kell tölteni!");
    }
});

// Amikor a lista melletti "Feloldás" gombra kattintasz
function unbanPlayer(playerIdentifier) {
    fetch(`https://${GetParentResourceName()}/unban`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ identifier: playerIdentifier })
    });
}

// Bezárás gomb és ESC gomb kezelése
const closePanel = () => {
    document.getElementById('container').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
};

document.getElementById('close-btn').addEventListener('click', closePanel);

window.addEventListener('keydown', (event) => {
    if (event.key === "Escape") {
        closePanel();
    }
});