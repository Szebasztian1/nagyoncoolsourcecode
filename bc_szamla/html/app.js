let selectedPlayerId = null;
let incomingInvoice = null;
let canIssueGlobal = false;

const app = document.getElementById('app');
const mainMenuPanel = document.getElementById('mainMenuPanel');
const createPanel = document.getElementById('createPanel');
const incomingPanel = document.getElementById('incomingPanel');
const listPanel = document.getElementById('listPanel');
const trackedPanel = document.getElementById('trackedPanel');

const mainMenuButtons = document.getElementById('mainMenuButtons');
const nearbyPlayersEl = document.getElementById('nearbyPlayers');
const selectedPlayerEl = document.getElementById('selectedPlayer');
const incomingSummaryEl = document.getElementById('incomingSummary');
const invoiceListEl = document.getElementById('invoiceList');
const trackedListEl = document.getElementById('trackedList');

function post(name, data = {}) {
  return fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  });
}

function applyTheme(theme) {
  if (!theme) return;
  const root = document.documentElement;
  Object.entries(theme).forEach(([key, value]) => {
    root.style.setProperty(`--${key}`, value);
  });
}

function openApp() {
  app.classList.remove('hidden');
}

function hideAll() {
  mainMenuPanel.classList.add('hidden');
  createPanel.classList.add('hidden');
  incomingPanel.classList.add('hidden');
  listPanel.classList.add('hidden');
  trackedPanel.classList.add('hidden');
}

function closeApp() {
  app.classList.add('hidden');
  hideAll();
}

function closeUI() {
  post('close');
}

function openMainMenu() {
  post('openMainMenu');
}

function formatDate(value) {
  if (!value) return '-';

  if (typeof value === 'number' || /^\d+$/.test(String(value))) {
    let timestamp = Number(value);
    if (timestamp > 9999999999) timestamp = Math.floor(timestamp / 1000);
    const d = new Date(timestamp * 1000);
    if (!isNaN(d.getTime())) return d.toLocaleString('hu-HU');
  }

  const parsed = new Date(value);
  if (!isNaN(parsed.getTime())) return parsed.toLocaleString('hu-HU');

  return '-';
}

function formatRemaining(dueAt) {
  if (!dueAt) return 'Nincs határidő';

  const due = new Date(dueAt);
  if (isNaN(due.getTime())) return 'Nincs határidő';

  const now = new Date();
  const diff = due.getTime() - now.getTime();

  if (diff <= 0) return 'Lejárt';

  const totalMinutes = Math.floor(diff / 60000);
  const days = Math.floor(totalMinutes / 1440);
  const hours = Math.floor((totalMinutes % 1440) / 60);
  const minutes = totalMinutes % 60;

  if (days > 0) return `${days} nap ${hours} óra`;
  if (hours > 0) return `${hours} óra ${minutes} perc`;
  return `${minutes} perc`;
}

function renderMainMenu(canIssue) {
  mainMenuButtons.innerHTML = '';

  const buttons = [];

  if (canIssue) {
    buttons.push({
      label: 'Számla kiállítás',
      sub: 'Új számla kiállítása',
      action: 'openCreateMenu'
    });
    buttons.push({
      label: 'Tartozások',
      sub: 'Ki nem fizetett tartozások',
      action: 'openTrackedMenu'
    });
  }

  buttons.push({
    label: 'Számláim',
    sub: 'Saját számlák megtekintése',
    action: 'openMyInvoicesMenu'
  });

  buttons.forEach((btn) => {
    const el = document.createElement('button');
    el.className = 'menu-card';
    el.innerHTML = `
      <div class="menu-title">${btn.label}</div>
      <div class="menu-sub">${btn.sub}</div>
    `;
    el.onclick = () => post(btn.action);
    mainMenuButtons.appendChild(el);
  });
}

function renderPlayers(players) {
  nearbyPlayersEl.innerHTML = '';

  if (!players || !players.length) {
    nearbyPlayersEl.innerHTML = `
      <div class="item">
        <div class="item-title">Nincs a közelben játékos.</div>
      </div>
    `;
    return;
  }

  players.forEach((player) => {
    const displayName = player.name && player.name !== ''
      ? `${player.name} (${player.id})`
      : `ID: ${player.id}`;

    const el = document.createElement('div');
    el.className = 'item clickable';
    el.dataset.id = String(player.id);
    el.innerHTML = `
      <div class="item-title">${displayName}</div>
      <div class="item-meta">Távolság: ${player.distance}m</div>
    `;

    el.onclick = () => {
      document.querySelectorAll('#nearbyPlayers .item').forEach((node) => node.classList.remove('active'));
      el.classList.add('active');
      selectedPlayerId = player.id;
      selectedPlayerEl.value = displayName;
    };

    nearbyPlayersEl.appendChild(el);
  });
}

function refreshNearby() {
  post('refreshNearby')
    .then((res) => res.json())
    .then((players) => renderPlayers(players));
}

function createInvoice() {
  const reason = document.getElementById('reason').value.trim();
  const amount = Number(document.getElementById('amount').value);

  if (!selectedPlayerId || !reason || !amount || amount < 1) return;

  post('createInvoice', {
    targetId: selectedPlayerId,
    reason,
    amount
  });
}

function respondInvoice(accepted) {
  if (!incomingInvoice) return;
  post('respondInvoice', {
    id: incomingInvoice.id,
    accepted
  });
}

function payInvoice(id) {
  post('payInvoice', { id });
}

function deleteInvoice(id) {
  post('deleteInvoice', { id });
}

function statusLabel(status) {
  if (status === 'pending_accept') return ['Elfogadásra vár', 'pending'];
  if (status === 'accepted' || status === 'active') return ['Fizetésre vár', 'accepted'];
  if (status === 'paid') return ['Kifizetve', 'paid'];
  if (status === 'rejected') return ['Elutasítva', 'rejected'];
  return [status, 'pending'];
}

function renderInvoices(invoices) {
  invoiceListEl.innerHTML = '';

  if (!invoices || !invoices.length) {
    invoiceListEl.innerHTML = `
      <div class="item">
        <div class="item-title">Nincs tárolt számlád.</div>
      </div>
    `;
    return;
  }

  invoices.forEach((inv) => {
    const [label, klass] = statusLabel(inv.status);
    const autoText = Number(inv.auto_collected) === 1 ? '<br>Státusz: Rendszer által fizetve.' : '';

    let actions = '';

    if (inv.status === 'accepted' || inv.status === 'active') {
      actions = `<div class="actions"><button class="btn primary" onclick="payInvoice(${inv.id})">Befizetem</button></div>`;
    }

    if (inv.status === 'rejected') {
      actions = `<div class="actions"><button class="btn danger" onclick="deleteInvoice(${inv.id})">Törlés</button></div>`;
    }

    const el = document.createElement('div');
    el.className = 'item';
    el.innerHTML = `
      <div class="item-title">#${inv.id} • ${inv.reason}</div>
      <div class="item-meta">
        Kiállító: ${inv.issuer_name} (${inv.issuer_job})<br>
        Összeg: $${inv.amount}<br>
        Létrehozva: ${formatDate(inv.created_at)}<br>
        Határidő: ${formatDate(inv.due_at)}${autoText}
      </div>
      <div class="badge ${klass}">${label}</div>
      ${actions}
    `;
    invoiceListEl.appendChild(el);
  });
}

function renderTrackedInvoices(rows) {
  trackedListEl.innerHTML = '';

  if (!rows || !rows.length) {
    trackedListEl.innerHTML = `
      <div class="item">
        <div class="item-title">Nincs aktív tartozás.</div>
      </div>
    `;
    return;
  }

  rows.forEach((row) => {
    const remaining = formatRemaining(row.due_at);
    const el = document.createElement('div');
    el.className = 'item';
    el.innerHTML = `
      <div class="item-title">${row.target_name}</div>
      <div class="item-meta">
        Számla: ${row.reason}<br>
        Tartozás: $${row.amount}<br>
        Határidő: ${formatDate(row.due_at)}<br>
        Hátralévő idő: ${remaining}
      </div>
      <div class="badge accepted">Aktív</div>
    `;
    trackedListEl.appendChild(el);
  });
}

window.addEventListener('message', (event) => {
  const data = event.data || {};
  applyTheme(data.theme);

  if (data.action === 'closeAll') {
    closeApp();
    return;
  }

  if (data.action === 'openMainMenu') {
    openApp();
    hideAll();
    canIssueGlobal = data.canIssue === true;
    renderMainMenu(canIssueGlobal);
    mainMenuPanel.classList.remove('hidden');
    return;
  }

  if (data.action === 'openCreate') {
    openApp();
    hideAll();
    createPanel.classList.remove('hidden');
    selectedPlayerId = null;
    selectedPlayerEl.value = '';
    document.getElementById('reason').value = '';
    document.getElementById('amount').value = '';
    renderPlayers(data.players || []);
    return;
  }

  if (data.action === 'updateNearbyPlayers') {
    const currentSelected = selectedPlayerId;
    renderPlayers(data.players || []);

    if (currentSelected) {
      const found = (data.players || []).find((p) => Number(p.id) === Number(currentSelected));
      if (found) {
        selectedPlayerEl.value = `${found.name} (${found.id})`;
        const selectedNode = document.querySelector(`#nearbyPlayers .item[data-id="${found.id}"]`);
        if (selectedNode) selectedNode.classList.add('active');
      }
    }
    return;
  }

  if (data.action === 'openIncoming') {
    openApp();
    hideAll();
    incomingPanel.classList.remove('hidden');
    incomingInvoice = data.invoice;
    incomingSummaryEl.innerHTML = `
      <div class="summary-box"><strong>Kiállító:</strong> ${data.invoice.issuerName}</div>
      <div class="summary-box"><strong>Frakció:</strong> ${data.invoice.issuerJob}</div>
      <div class="summary-box"><strong>Megnevezés:</strong> ${data.invoice.reason}</div>
      <div class="summary-box"><strong>Összeg:</strong> $${data.invoice.amount}</div>
    `;
    return;
  }

  if (data.action === 'openInvoices') {
    openApp();
    hideAll();
    canIssueGlobal = data.canIssue === true;
    listPanel.classList.remove('hidden');
    renderInvoices(data.invoices || []);
    return;
  }

  if (data.action === 'openTrackedInvoices') {
    openApp();
    hideAll();
    trackedPanel.classList.remove('hidden');
    renderTrackedInvoices(data.tracked || []);
  }
});

document.addEventListener('keyup', (event) => {
  if (event.key === 'Escape') closeUI();
});