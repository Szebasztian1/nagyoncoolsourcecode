/*
 * Személyre szabás a pp-shop NUI-hoz.
 *
 * Nem nyúl a Vue apphoz: a shop saját BC tokenjeit (--acc, --bg-*, --radius) írja
 * felül a <html> inline stílusán, a saját panelje pedig a <body>-ra kerül fix
 * pozícióban (így nem lesz belőle flex-elem a modal mellett).
 * A beállítások a játékos gépén, localStorage-ban élnek.
 */
(function () {
  'use strict';

  var KEY = 'ppshop_ui';
  var POS_KEY = 'ppshop_ui_button';

  var FONTS = {
    titillium: { label: 'Titillium Web', stack: "'Titillium Web', 'Segoe UI', system-ui, sans-serif" },
    montserrat: { label: 'Montserrat', stack: "'Montserrat', sans-serif" },
    roboto: { label: 'Roboto', stack: "'Roboto', 'Segoe UI', sans-serif" },
    rajdhani: { label: 'Rajdhani', stack: "'Rajdhani', 'Segoe UI', sans-serif" },
  };

  var PRESETS = ['#2f80ed', '#3b5bdb', '#4a73b8', '#4cdb28', '#e0a80d', '#db2828', '#9b51e0', '#12b5b0'];

  var DEFAULTS = {
    accent: '#2f80ed',
    scale: 100, // %
    alpha: 100, // panel átlátszatlanság, %
    radius: 6, // px
    dim: 0, // háttér sötétítés, %
    font: 'titillium',
    animations: true,
  };

  var LIMITS = {
    scale: [70, 150],
    alpha: [20, 100],
    radius: [0, 16],
    dim: [0, 95],
  };

  // a shop felületeinek alapszínei – ezekre kerül rá az átlátszóság
  var SURFACES = { '--bg-modal': [31, 31, 31], '--bg-bar': [36, 36, 36], '--bg-box': [46, 46, 46] };

  var settings = load();
  var fontsLinked = false;

  function clamp(value, key) {
    var limit = LIMITS[key];
    if (!limit || isNaN(value)) return value;
    return Math.min(limit[1], Math.max(limit[0], Math.round(value)));
  }

  function load() {
    var out = {};
    for (var key in DEFAULTS) out[key] = DEFAULTS[key];

    try {
      var saved = JSON.parse(localStorage.getItem(KEY) || '{}');
      for (var name in out) {
        var value = saved[name];
        if (value === undefined || value === null) continue;
        if (typeof value !== typeof out[name]) continue;
        out[name] = typeof value === 'number' ? clamp(value, name) : value;
      }
    } catch (e) {
      /* sérült mentés – marad az alapérték */
    }

    return out;
  }

  function save() {
    try {
      localStorage.setItem(KEY, JSON.stringify(settings));
    } catch (e) {}
  }

  function hexToRgb(hex) {
    var m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(String(hex).trim());
    if (!m) return [47, 128, 237];
    return [parseInt(m[1], 16), parseInt(m[2], 16), parseInt(m[3], 16)];
  }

  /** A választott betűtípus csak akkor töltődik le, ha tényleg kell. */
  function ensureFont(key) {
    if (key === 'titillium' || fontsLinked) return;
    fontsLinked = true;
    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href =
      'https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&family=Roboto:wght@400;500;700&family=Rajdhani:wght@500;600;700&display=swap';
    document.head.appendChild(link);
  }

  function apply() {
    var root = document.documentElement;
    var rgb = hexToRgb(settings.accent);
    var list = rgb[0] + ', ' + rgb[1] + ', ' + rgb[2];

    root.style.setProperty('--acc', settings.accent);
    root.style.setProperty('--acc-lt', 'rgb(' + rgb.map(function (c) { return Math.round(c + (255 - c) * 0.45); }).join(', ') + ')');
    root.style.setProperty('--acc-tint', 'rgba(' + list + ', 0.16)');
    root.style.setProperty('--acc-tint-h', 'rgba(' + list + ', 0.28)');
    root.style.setProperty('--acc-bd', 'rgba(' + list + ', 0.55)');
    root.style.setProperty('--radius', settings.radius + 'px');
    root.style.setProperty('--ppui-scale', settings.scale / 100);
    root.style.setProperty('--ppui-dim', settings.dim / 100);

    var alpha = settings.alpha / 100;
    for (var token in SURFACES) {
      var base = SURFACES[token];
      root.style.setProperty(token, 'rgba(' + base[0] + ', ' + base[1] + ', ' + base[2] + ', ' + alpha + ')');
    }

    ensureFont(settings.font);
    root.style.setProperty('--ppui-font', (FONTS[settings.font] || FONTS.titillium).stack);
    root.classList.toggle('ppui-noanim', !settings.animations);
  }

  /* ------------------------------------------------------------------ UI */

  var els = {};

  function icon(paths) {
    return '<svg viewBox="0 0 24 24">' + paths + '</svg>';
  }

  function sliderRow(key, label, suffix) {
    return (
      '<div class="ppui-row">' +
      '<div class="ppui-row-head"><span class="ppui-label">' +
      label +
      '</span><span class="ppui-value" data-out="' +
      key +
      '"></span></div>' +
      '<input type="range" data-key="' +
      key +
      '" min="' +
      LIMITS[key][0] +
      '" max="' +
      LIMITS[key][1] +
      '" step="1">' +
      '</div>'
    );
  }

  function toggleRow(key, label, desc) {
    return (
      '<div class="ppui-toggle-row"><div class="ppui-toggle-text"><span class="ppui-label">' +
      label +
      '</span><span class="ppui-desc">' +
      desc +
      '</span></div>' +
      '<button class="ppui-switch" type="button" data-toggle="' +
      key +
      '"><i></i></button></div>'
    );
  }

  function build() {
    var dim = document.createElement('div');
    dim.className = 'ppui-dim';
    document.body.insertBefore(dim, document.body.firstChild);

    var open = document.createElement('button');
    open.className = 'ppui-open';
    open.type = 'button';
    open.title = 'Húzd a mozgatáshoz · dupla katt: alaphelyzet';
    open.innerHTML =
      icon('<circle cx="12" cy="12" r="3"/><path d="M12 3v2M12 19v2M5.6 5.6l1.4 1.4M17 17l1.4 1.4M3 12h2M19 12h2M5.6 18.4L7 17M17 7l1.4-1.4"/>') +
      '<span>Személyre szabás</span>';
    document.body.appendChild(open);

    var overlay = document.createElement('div');
    overlay.className = 'ppui-overlay';
    overlay.hidden = true;
    overlay.innerHTML =
      '<div class="ppui-modal">' +
      '<div class="ppui-bar">' +
      '<div class="ppui-logo">' +
      icon('<circle cx="13.5" cy="6.5" r=".5"/><circle cx="17.5" cy="10.5" r=".5"/><circle cx="8.5" cy="7.5" r=".5"/><circle cx="6.5" cy="12.5" r=".5"/><path d="M12 2a10 10 0 100 20 2 2 0 001.7-3 2 2 0 011.7-3H19a3 3 0 003-3 10 10 0 00-10-11z"/>') +
      '</div>' +
      '<div class="ppui-title"><div class="ppui-eyebrow">Prémium bolt megjelenés</div>' +
      '<div class="ppui-name">Személyre <b>szabás</b></div></div>' +
      '<button class="ppui-close" type="button" data-act="close">&times;</button>' +
      '</div>' +
      '<div class="ppui-page">' +
      '<div class="ppui-box"><div class="ppui-box-head"><span class="ppui-box-title">Szín</span>' +
      '<span class="ppui-box-sub">Kiemelő szín</span></div><div class="ppui-swatches" data-swatches></div></div>' +
      '<div class="ppui-box"><div class="ppui-box-head"><span class="ppui-box-title">Méret</span>' +
      '<span class="ppui-box-sub">Az egész panel</span></div>' +
      sliderRow('scale', 'Panel mérete') +
      '</div>' +
      '<div class="ppui-box"><div class="ppui-box-head"><span class="ppui-box-title">Felület</span>' +
      '<span class="ppui-box-sub">Átlátszóság és forma</span></div>' +
      sliderRow('alpha', 'Panel átlátszatlanság') +
      sliderRow('radius', 'Sarok lekerekítés') +
      sliderRow('dim', 'Háttér sötétítés') +
      '</div>' +
      '<div class="ppui-box"><div class="ppui-box-head"><span class="ppui-box-title">Kiegészítők</span>' +
      '<span class="ppui-box-sub">Betű és mozgás</span></div>' +
      '<div class="ppui-row"><div class="ppui-row-head"><span class="ppui-label">Betűtípus</span></div>' +
      '<select data-font></select></div>' +
      toggleRow('animations', 'Animációk', 'Áttűnések és hover mozgás') +
      '</div>' +
      '</div>' +
      '<div class="ppui-foot">' +
      '<button class="ppui-btn ghost" type="button" data-act="reset">Alaphelyzet</button>' +
      '<button class="ppui-btn blue" type="button" data-act="close">Kész</button>' +
      '</div></div>';
    document.body.appendChild(overlay);

    els.open = open;
    els.overlay = overlay;

    var swatches = overlay.querySelector('[data-swatches]');
    PRESETS.forEach(function (color) {
      var swatch = document.createElement('button');
      swatch.type = 'button';
      swatch.className = 'ppui-swatch';
      swatch.dataset.color = color;
      swatch.style.backgroundColor = color;
      swatches.appendChild(swatch);
    });

    var custom = document.createElement('label');
    custom.className = 'ppui-custom';
    custom.innerHTML = '<input type="color" data-picker><span>Egyedi</span>';
    swatches.appendChild(custom);

    var select = overlay.querySelector('[data-font]');
    Object.keys(FONTS).forEach(function (key) {
      var option = document.createElement('option');
      option.value = key;
      option.textContent = FONTS[key].label;
      select.appendChild(option);
    });

    bind();
    sync();
  }

  function sync() {
    var overlay = els.overlay;

    Object.keys(LIMITS).forEach(function (key) {
      var input = overlay.querySelector('[data-key="' + key + '"]');
      var out = overlay.querySelector('[data-out="' + key + '"]');
      if (!input) return;
      input.value = settings[key];
      out.textContent = settings[key] + (key === 'radius' ? 'px' : '%');
    });

    overlay.querySelectorAll('.ppui-swatch').forEach(function (swatch) {
      swatch.classList.toggle('on', swatch.dataset.color === String(settings.accent).toLowerCase());
    });

    overlay.querySelector('[data-picker]').value = settings.accent;
    overlay.querySelector('[data-font]').value = settings.font;
    overlay.querySelector('[data-toggle="animations"]').classList.toggle('on', settings.animations);
  }

  function set(key, value) {
    settings[key] = typeof DEFAULTS[key] === 'number' ? clamp(value, key) : value;
    apply();
    save();
    sync();
  }

  function bind() {
    var overlay = els.overlay;

    els.open.addEventListener('click', function () {
      if (!els.open.dataset.dragged) overlay.hidden = false;
      delete els.open.dataset.dragged;
    });

    overlay.addEventListener('mousedown', function (event) {
      if (event.target === overlay) overlay.hidden = true;
    });

    overlay.addEventListener('click', function (event) {
      var act = event.target.closest('[data-act]');
      if (act) {
        if (act.dataset.act === 'close') overlay.hidden = true;
        if (act.dataset.act === 'reset') {
          for (var key in DEFAULTS) settings[key] = DEFAULTS[key];
          apply();
          save();
          sync();
        }
        return;
      }

      var swatch = event.target.closest('.ppui-swatch');
      if (swatch) set('accent', swatch.dataset.color);

      var toggle = event.target.closest('[data-toggle]');
      if (toggle) set(toggle.dataset.toggle, !settings[toggle.dataset.toggle]);
    });

    overlay.addEventListener('input', function (event) {
      var target = event.target;
      if (target.dataset.key) set(target.dataset.key, Number(target.value));
      else if (target.hasAttribute('data-picker')) set('accent', target.value);
      else if (target.hasAttribute('data-font')) set('font', target.value);
    });

    // ESC a saját panelt zárja, a shopot ne (a shop is figyeli a 27-est)
    document.addEventListener(
      'keyup',
      function (event) {
        if (event.which === 27 && !overlay.hidden) {
          overlay.hidden = true;
          event.stopImmediatePropagation();
        }
      },
      true
    );

    dragButton();
  }

  /** A gomb bárhová húzható; a hely mentődik és a képernyőn belül marad. */
  function dragButton() {
    var button = els.open;
    var pos = { x: 0, y: 0 };

    try {
      var saved = JSON.parse(localStorage.getItem(POS_KEY) || '{}');
      if (typeof saved.x === 'number' && typeof saved.y === 'number') pos = saved;
    } catch (e) {}

    var place = function () {
      button.style.transform = 'translate(' + pos.x + 'px, ' + pos.y + 'px)';
    };

    var keepInside = function () {
      var rect = button.getBoundingClientRect();
      var baseLeft = rect.left - pos.x;
      var baseTop = rect.top - pos.y;
      var minX = 8 - baseLeft;
      var maxX = window.innerWidth - 8 - rect.width - baseLeft;
      var minY = 8 - baseTop;
      var maxY = window.innerHeight - 8 - rect.height - baseTop;
      pos.x = Math.min(Math.max(pos.x, minX), Math.max(minX, maxX));
      pos.y = Math.min(Math.max(pos.y, minY), Math.max(minY, maxY));
      place();
    };

    place();

    var drag = null;

    button.addEventListener('mousedown', function (event) {
      drag = { x: event.clientX, y: event.clientY, ox: pos.x, oy: pos.y, moved: false };
      event.preventDefault();
    });

    document.addEventListener('mousemove', function (event) {
      if (!drag) return;
      var dx = event.clientX - drag.x;
      var dy = event.clientY - drag.y;
      if (!drag.moved && Math.abs(dx) + Math.abs(dy) < 4) return; // apró rezdülés még kattintás
      drag.moved = true;
      pos.x = drag.ox + dx;
      pos.y = drag.oy + dy;
      place();
    });

    document.addEventListener('mouseup', function () {
      if (!drag) return;
      if (drag.moved) {
        button.dataset.dragged = '1';
        keepInside();
        try {
          localStorage.setItem(POS_KEY, JSON.stringify(pos));
        } catch (e) {}
      }
      drag = null;
    });

    button.addEventListener('dblclick', function () {
      pos = { x: 0, y: 0 };
      place();
      try {
        localStorage.removeItem(POS_KEY);
      } catch (e) {}
    });

    window.addEventListener('resize', keepInside);
  }

  function start() {
    if (!document.body) return void requestAnimationFrame(start);
    apply();
    build();
  }

  start();
})();
