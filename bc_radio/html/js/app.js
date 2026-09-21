/* bc_radio - NUI app (Vue 3 global build) */
(function () {
  const { createApp } = Vue;

  // FiveM serves the page from https://cfx-nui-<resource>/ ; anywhere else
  // (e.g. a browser preview) we run in mock mode with no callbacks.
  const IN_GAME = location.hostname.indexOf('cfx-nui-') === 0;
  const RES = IN_GAME ? location.hostname.replace('cfx-nui-', '') : 'bc_radio';

  async function post(name, data) {
    if (!IN_GAME) return {};
    try {
      const r = await fetch(`https://${RES}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
      });
      return await r.json().catch(() => ({}));
    } catch (e) {
      return {};
    }
  }

  // Preview-only sample data (mirrors config.lua) so the panel is visible in a browser.
  const MOCK = {
    action: 'open', current: 'retro', volume: 55, xsound: true,
    stations: [
      { id: 'kossuth', name: 'Kossuth Rádió', genre: 'Közszolgálati', icon: 'fa-microphone-lines' },
      { id: 'petofi', name: 'Petőfi Rádió', genre: 'Pop / fiatalos', icon: 'fa-music' },
      { id: 'bartok', name: 'Bartók Rádió', genre: 'Klasszikus', icon: 'fa-masks-theater' },
      { id: 'danko', name: 'Dankó Rádió', genre: 'Magyar nóta', icon: 'fa-guitar' },
      { id: 'retro', name: 'Retro Rádió', genre: 'Retro slágerek', icon: 'fa-record-vinyl' },
      { id: 'radio1', name: 'Rádió 1', genre: 'Mai slágerek', icon: 'fa-1' },
      { id: 'rockfm', name: 'Rock FM 103.9', genre: 'Rock', icon: 'fa-bolt' },
      { id: 'basefm', name: 'Base FM', genre: 'Dance / house', icon: 'fa-compact-disc' },
      { id: 'slager', name: 'Sláger FM', genre: 'Sláger', icon: 'fa-star' },
      { id: 'danubius', name: 'Danubius Rádió', genre: 'Felnőtt pop', icon: 'fa-water' },
      { id: 'jazzy', name: 'Jazzy Rádió', genre: 'Jazz / soul', icon: 'fa-headphones' },
      { id: 'klub', name: 'Klubrádió', genre: 'Közéleti', icon: 'fa-comments' },
      { id: 'poptari', name: 'Poptarisznya', genre: 'Magyar retro', icon: 'fa-guitar' },
      { id: 'dancewave', name: 'Dance Wave!', genre: 'EDM', icon: 'fa-fire' },
    ],
  };

  createApp({
    data() {
      return {
        visible: false, stations: [], current: false, volume: 50, xsound: true,
        openKey: 'q',
        // The panel opens while the key is still held; ignore that key until it
        // has been released once, or the auto-repeat would close it instantly.
        keyArmed: false,
      };
    },
    computed: {
      currentStation() {
        return this.stations.find((s) => s.id === this.current) || null;
      },
    },
    methods: {
      // Map a config icon name to an inline-SVG symbol id (fallback: radio).
      iconId(name) {
        const map = {
          'fa-microphone-lines': 'mic', 'fa-music': 'music', 'fa-masks-theater': 'music',
          'fa-guitar': 'guitar', 'fa-record-vinyl': 'vinyl', 'fa-compact-disc': 'vinyl',
          'fa-1': 'vinyl', 'fa-bolt': 'bolt', 'fa-star': 'star', 'fa-water': 'wave',
          'fa-headphones': 'headphones', 'fa-comments': 'chat', 'fa-fire': 'fire',
        };
        return map[name] || 'radio';
      },
      open(p) {
        this.stations = p.stations || [];
        this.current = p.current || false;
        this.volume = typeof p.volume === 'number' ? p.volume : 50;
        this.xsound = p.xsound !== false;
        this.openKey = p.key || 'q';
        this.keyArmed = false; // the open key may still be held right now
        // Fallback in case the key-up never reaches us (focus handover), so the
        // panel is always closable with the key. Auto-repeat is filtered
        // separately, so arming early cannot close a still-held key.
        clearTimeout(this._armTimer);
        this._armTimer = setTimeout(() => { this.keyArmed = true; }, 1500);
        this.visible = true;
      },
      close() {
        if (!this.visible) return;
        this.visible = false;
        post('close');
      },
      select(id) {
        this.current = id;
        post('select', { id });
      },
      stop() {
        if (!this.current) return;
        this.current = false;
        post('stop');
      },
      // Throttled live volume: send immediately, then at most every 120 ms while
      // dragging, with a trailing send for the final value.
      onVolume() {
        if (this._volTimer) { this._volPending = true; return; }
        post('volume', { value: this.volume });
        this._volTimer = setTimeout(() => {
          this._volTimer = null;
          if (this._volPending) { this._volPending = false; this.onVolume(); }
        }, 120);
      },
    },
    mounted() {
      window.addEventListener('message', (e) => {
        const d = e.data || {};
        if (d.action === 'open') this.open(d);
        else if (d.action === 'close') this.visible = false;
        else if (d.action === 'current') this.current = d.current || false;
      });
      const isOpenKey = (e) =>
        this.openKey && e.key && e.key.toLowerCase() === this.openKey.toLowerCase();

      window.addEventListener('keydown', (e) => {
        if (!this.visible) return;
        if (e.key === 'Escape') { this.close(); return; }
        // Auto-repeat from a key still held down from opening never closes.
        if (e.repeat) return;
        // The open key closes too, but only once it has been released after the
        // press that opened the panel.
        if (isOpenKey(e) && this.keyArmed) this.close();
      });

      window.addEventListener('keyup', (e) => {
        if (isOpenKey(e)) this.keyArmed = true;
      });
      if (!IN_GAME) this.open(MOCK); // browser preview
    },
  }).mount('#app');
})();
