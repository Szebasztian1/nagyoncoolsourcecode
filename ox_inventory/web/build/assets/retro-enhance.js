/*
 * Display enhancements for the custom ox_inventory looks (retro / új design).
 * Only touches the rendered DOM (no React/state logic, no new gameplay features).
 *
 * Drag: while a panel look is active (retro or bc), each inventory panel can be
 * dragged independently by its header bar (.retro-header-content). Offsets are
 * remembered per panel position (0 = left, 1 = right).
 *
 * The screen blur state ('retroState' NUI callback) is reported by the React app
 * instead, since it now follows the per-design "Háttér elmosás" setting.
 */
(function () {
  'use strict';

  /* ---------- shared helpers ---------- */
  function isRetro() {
    if (document.body && document.body.classList.contains('retro-theme')) return true;
    try {
      return localStorage.getItem('inventory_retro') === 'true';
    } catch (e) {
      return false;
    }
  }

  // every look that draws its own draggable title bar
  function isDraggable() {
    return isRetro() || (document.body && document.body.classList.contains('bc-theme'));
  }

  /* ---------- 1) per-panel dragging ---------- */
  var offsets = {}; // panel index -> { x, y }
  var drag = null;

  function getPanels() {
    var mid = document.querySelector('.middleInv');
    if (!mid) return [];
    return Array.prototype.slice.call(mid.querySelectorAll('.inventory-grid-wrapper'));
  }

  function applyAll() {
    var panels = getPanels();
    for (var i = 0; i < panels.length; i++) {
      if (!isDraggable()) {
        if (panels[i].style.transform) panels[i].style.transform = '';
        continue;
      }
      var o = offsets[i];
      if (o && (o.x || o.y)) {
        panels[i].style.transform = 'translate(' + o.x + 'px,' + o.y + 'px)';
      }
    }
  }

  document.addEventListener('mousedown', function (e) {
    if (!isDraggable() || !e.target || !e.target.closest) return;
    if (!e.target.closest('.retro-header-content')) return;
    if (e.target.closest('.retro-action-btn, input, button')) return;
    var panel = e.target.closest('.inventory-grid-wrapper');
    if (!panel) return;
    var idx = getPanels().indexOf(panel);
    if (idx < 0) return;
    var o = offsets[idx] || { x: 0, y: 0 };
    drag = { sx: e.clientX, sy: e.clientY, ox: o.x, oy: o.y, panel: panel, idx: idx };
    e.preventDefault();
  });

  document.addEventListener('mousemove', function (e) {
    if (!drag) return;
    var x = drag.ox + (e.clientX - drag.sx);
    var y = drag.oy + (e.clientY - drag.sy);
    offsets[drag.idx] = { x: x, y: y };
    drag.panel.style.transform = 'translate(' + x + 'px,' + y + 'px)';
  });

  document.addEventListener('mouseup', function () {
    drag = null;
  });

  /* ---------- observe (re)mounts + design switch ---------- */
  var mo = new MutationObserver(function () {
    if (!drag) applyAll();
  });

  function start() {
    if (!document.body) {
      return void requestAnimationFrame(start);
    }
    mo.observe(document.body, { childList: true, subtree: true, attributes: true, attributeFilter: ['class'] });
  }

  start();
})();
