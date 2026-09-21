const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bc_forgalmi';

const wrap = document.getElementById('wrap');
const stage = document.getElementById('stage');
const doc = document.getElementById('doc');
const showBtn = document.getElementById('showBtn');
const closeBtn = document.getElementById('closeBtn');
const barcodeEl = document.getElementById('barcode');

let open = false;

function post(name, data) {
	return fetch(`https://${RES}/${name}`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json; charset=UTF-8' },
		body: JSON.stringify(data || {}),
	}).catch(() => {});
}

/* --- barcode: deterministic from plate / vin --------------------------- */
function buildBarcode(seedText) {
	barcodeEl.innerHTML = '';

	let h = 2166136261;
	const seed = String(seedText || 'SA-DMV');

	for (let i = 0; i < seed.length; i++) {
		h ^= seed.charCodeAt(i);
		h = Math.imul(h, 16777619) >>> 0;
	}

	let total = 0;
	const max = 182;

	while (total < max) {
		h = (Math.imul(h, 1103515245) + 12345) >>> 0;
		const w = 1 + (h % 3);
		const gap = ((h >>> 8) % 2) + 1;

		const bar = document.createElement('i');
		bar.style.width = `${w}px`;
		barcodeEl.appendChild(bar);

		const space = document.createElement('i');
		space.style.width = `${gap}px`;
		space.style.background = 'transparent';
		barcodeEl.appendChild(space);

		total += w + gap;
	}
}

/* --- fill fields ------------------------------------------------------- */
function render(fields) {
	const data = fields || {};

	document.querySelectorAll('[data-field]').forEach((el) => {
		const raw = data[el.dataset.field];
		const value = raw === undefined || raw === null || raw === '' ? null : String(raw);

		el.textContent = value !== null ? value : '—';
		el.classList.toggle('empty', value === null);
		el.title = value !== null ? value : '';
	});

	buildBarcode(data.rendszam || data.alvazszam || data.okmanyazonosito);
}

/* --- scale to viewport ------------------------------------------------- */
function fit() {
	if (!open) return;

	stage.style.transform = 'scale(1)';

	const h = doc.offsetHeight + 60;
	const w = doc.offsetWidth + 40;
	const scale = Math.max(0.5, Math.min(1.7, Math.min(
		(window.innerHeight * 0.94) / h,
		(window.innerWidth * 0.96) / w
	)));

	stage.style.transform = `scale(${scale})`;
}

function openDoc(fields, readOnly, expired) {
	render(fields);

	doc.classList.toggle('expired', !!expired);
	showBtn.classList.toggle('hidden', !!readOnly);

	wrap.classList.remove('hidden');
	open = true;
	fit();
}

function closeDoc(notify) {
	if (!open) return;

	open = false;
	wrap.classList.add('hidden');

	if (notify) post('close');
}

window.addEventListener('message', (event) => {
	const msg = event.data || {};

	if (msg.action === 'open') {
		openDoc(msg.fields, msg.readOnly, msg.expired);
	} else if (msg.action === 'close') {
		closeDoc(false);
	}
});

document.addEventListener('keydown', (e) => {
	if (!open) return;

	if (e.key === 'Escape' || e.code === 'Escape' || e.key === 'Backspace') {
		e.preventDefault();
		closeDoc(true);
	}
});

closeBtn.addEventListener('click', () => closeDoc(true));
showBtn.addEventListener('click', () => post('show'));

window.addEventListener('resize', fit);
