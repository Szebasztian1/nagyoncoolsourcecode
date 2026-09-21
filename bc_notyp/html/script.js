// A VIP EXP sav (aty_hud) ugyanazt a legfelso helyet hasznalja, de csak
// XP-szerzeskor ~6 masodpercig. Amig kint van, a kliens atkuldi a 'shiftDown'
// uzenetet, es a felhivas a masodik savba csuszik (style.css: .shifted).
let vipShiftTimer = null;

window.addEventListener('message', function(event) {
    if (event.data.action === 'shiftDown') {
        const container = document.getElementById('notification-container');
        if (!container) return;

        container.classList.add('shifted');
        clearTimeout(vipShiftTimer);
        vipShiftTimer = setTimeout(function () {
            container.classList.remove('shifted');
        }, Number(event.data.time) || 6300);
        return;
    }

    if (event.data.action === 'showNotification') {
        const container = document.getElementById('notification-container');
        const notifyDiv = document.createElement('div');
        notifyDiv.classList.add('notify-card');

        let icon = 'fa-shield-halved';
        let color = '#3b82f6';

        const type = event.data.type ? event.data.type.toLowerCase() : 'police';

        const jobs = {
            'cso': { icon: 'fa-building-shield', color: '#4a5568' },
            'gov': { icon: 'fa-landmark', color: '#d4af37' },
            'tact': { icon: 'fa-crosshairs', color: '#ffffff' },
            'snss': { icon: 'fa-eye', color: '#2d3748' },
            'fib': { icon: 'fa-user-secret', color: '#1e3a8a' },
            'nms': { icon: 'fa-truck-medical', color: '#ff3b3b' },
            'ambulance': { icon: 'fa-truck-medical', color: '#ff3b3b' },
            'fta': { icon: 'fa-handcuffs', color: '#2c5282' },
            'fea': { icon: 'fa-bolt', color: '#f6e05e' },
            'us': { icon: 'fa-flag-usa', color: '#3182ce' },
            'lspd': { icon: 'fa-shield-halved', color: '#3b82f6' },
            'ndu': { icon: 'fa-briefcase', color: '#718096' },
            'nda': { icon: 'fa-star', color: '#22d3ee' }
        };

        // Az okokChat a rövidítés-kulcsot küldi (nda, cso, fib...), a bc_factionfun
        // autogov viszont a JOB nevét. Ez a tábla fordítja a job neveket a fenti kulcsokra,
        // hogy az autogovnál is a saját frakció ikonja jelenjen meg az alap pajzs helyett.
        const jobAliases = {
            'police': 'nda',
            'fbi': 'cso',
            'fbiuj': 'fib',
            'uss': 'nms',
            'irs': 'fta',
            'atf': 'fea',
            'navi': 'us',
            'detective': 'lspd',
            'guardarmy': 'ndu',
            'usms': 'tact',
            'servicess': 'snss'
        };

        const key = jobAliases[type] || type;

        if (jobs[key]) {
            icon = jobs[key].icon;
            color = jobs[key].color;
        }

        notifyDiv.style.setProperty('--glow-color', color);

        // Itt az új HTML struktúra a notify-inner-rel
        notifyDiv.innerHTML = `
            <div class="notify-inner">
                <div class="icon-box"><i class="fa-solid ${icon}"></i></div>
                <div class="text-content">
                    <span class="title">${event.data.title}</span>
                    <span class="message">${event.data.message}</span>
                </div>
                <div class="progress-bar" style="background-color: ${color};"></div>
            </div>
        `;

        container.appendChild(notifyDiv);

        const progressBar = notifyDiv.querySelector('.progress-bar');
        setTimeout(() => {
            progressBar.style.transition = `width ${event.data.time}ms linear`;
            progressBar.style.width = '0%';
        }, 50);

        setTimeout(() => {
            notifyDiv.style.animation = 'slideUpExit 0.5s ease-in forwards';
            setTimeout(() => { notifyDiv.remove(); }, 500);
        }, event.data.time);
    }
});