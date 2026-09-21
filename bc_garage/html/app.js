const FILTERS = [
    { key: 'all',    icon: 'ic-list',   title: 'Összes',    desc: 'Minden jármű' },
    { key: 'fav',    icon: 'ic-star',   title: 'Kedvencek', desc: 'Csillagozott' },
    { key: 'stored', icon: 'ic-garage', title: 'Garázsban', desc: 'Kivehető' },
    { key: 'out',    icon: 'ic-road',   title: 'Kint',      desc: 'Nem tárolt' }
];

Vue.createApp({
    data() {
        return {
            open: false,
            label: 'Garázs',
            cars: [],
            selectedPlate: null,
            search: '',
            filter: 'all',
            filters: FILTERS,
            config: { maxFuel: 100 }
        };
    },

    computed: {
        selected() {
            if (!this.selectedPlate) return null;
            return this.cars.find(c => c.plate === this.selectedPlate) || null;
        },

        counts() {
            return {
                all: this.cars.length,
                fav: this.cars.filter(c => c.fav).length,
                stored: this.cars.filter(c => c.stored).length,
                out: this.cars.filter(c => !c.stored).length
            };
        },

        filteredList() {
            const q = this.search.trim().toLowerCase();

            return this.cars.filter(car => {
                if (this.filter === 'fav' && !car.fav) return false;
                if (this.filter === 'stored' && !car.stored) return false;
                if (this.filter === 'out' && car.stored) return false;
                if (!q) return true;

                return (car.label || '').toLowerCase().includes(q)
                    || (car.plate || '').toLowerCase().includes(q);
            });
        },

        // Tuning rows for the detail panel; pips = null → no level meter.
        mods() {
            const car = this.selected;
            if (!car) return [];

            return [
                { key: 'engine', icon: 'ic-bolt', title: 'Motor',
                  value: this.modText(car.modEngine), pips: this.modPips(car.modEngine) },
                { key: 'brakes', icon: 'ic-disc', title: 'Fékek',
                  value: this.modText(car.modBrakes), pips: this.modPips(car.modBrakes) },
                { key: 'trans',  icon: 'ic-gear', title: 'Váltó',
                  value: this.modText(car.modTransmission), pips: this.modPips(car.modTransmission) },
                { key: 'turbo',  icon: 'ic-wind', title: 'Turbó',
                  value: car.modTurbo ? 'Van' : 'Nincs', pips: null }
            ];
        }
    },

    methods: {
        /* ---------- NUI bridge ---------- */
        onMessage(event) {
            const data = event.data;
            if (data.type !== 'show') return;

            this.open = !!data.enable;
            this.selectedPlate = null;
            this.search = '';
            this.filter = 'all';

            if (!this.open) return;

            this.label = data.label || 'Garázs';

            // Favourites first, then alphabetical by name.
            const cars = (data.cars || []).slice().sort((a, b) => {
                if (!!a.fav !== !!b.fav) return a.fav ? -1 : 1;
                return String(a.label).localeCompare(String(b.label), 'hu');
            });
            this.cars = cars;
        },

        onKey(event) {
            if (this.open && event.key === 'Escape') this.close();
        },

        post(name) {
            fetch(`https://${GetParentResourceName()}/${name}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ plate: this.selectedPlate })
            });
        },

        /* ---------- formatting ---------- */
        // The Lua side prefixes favourites with a star and appends "(rarity)".
        cleanLabel(car) {
            return String(car.label || '')
                .replace(/^\s*⭐\s*/, '')
                .replace(/\s*\([^)]*\)\s*$/, '')
                .trim() || (car.model || '?');
        },

        rarity(car) {
            const match = String(car.label || '').match(/\(([^)]+)\)\s*$/);
            return match ? match[1] : null;
        },

        clamp(value) {
            return Math.max(0, Math.min(100, Math.floor(value)));
        },

        fuelPct(car) {
            if (car.fuelLevel === -1) return 0;
            return this.clamp((car.fuelLevel / this.config.maxFuel) * 100);
        },

        fuelText(car) {
            return car.fuelLevel === -1 ? '?' : this.fuelPct(car) + '%';
        },

        fuelClass(car) {
            return this.fuelPct(car) < 20 ? 'r' : 'b';
        },

        healthPct(car) {
            const engine = Math.max(car.engineHealth || 0, 0);
            const total = (car.bodyHealth || 0) + engine + (car.tankHealth || 0);
            return this.clamp((total / 3 / 1000) * 100);
        },

        healthClass(car) {
            const health = this.healthPct(car);
            if (health >= 70) return 'g';
            if (health >= 35) return 'w';
            return 'r';
        },

        modText(level) {
            return level > 0 ? level + '. szint' : 'Gyári';
        },

        modPips(level) {
            return Math.max(0, Math.min(3, level || 0));
        },

        /* ---------- actions ---------- */
        selectCar(car) {
            this.selectedPlate = this.selectedPlate === car.plate ? null : car.plate;
        },

        close() {
            this.selectedPlate = null;
            this.open = false;
            fetch(`https://${GetParentResourceName()}/exit`, { method: 'POST', body: '{}' });
        },

        takeout()        { this.post('takeout'); },
        takeoutimpound() { this.post('takeoutimpound'); },
        rename()         { this.post('namecar'); },
        fav()            { this.post('fav'); },
        taxmenu()        { this.post('taxmenu'); },
        deletecar()      { this.post('delcar'); }
    },

    mounted() {
        window.addEventListener('message', this.onMessage);
        window.addEventListener('keydown', this.onKey);
    }
}).mount('#stage');
