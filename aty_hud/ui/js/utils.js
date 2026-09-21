const hexToRgba = (hex, alpha) => {
	const r = parseInt(hex.slice(1, 3), 16);
	const g = parseInt(hex.slice(3, 5), 16);
	const b = parseInt(hex.slice(5, 7), 16);
	return `rgba(${r},${g},${b},${alpha})`;
};

const convertValue = (value, oldMin, oldMax, newMin, newMax) => {
	const oldRange = oldMax - oldMin;
	const newRange = newMax - newMin;
	const newValue = ((value - oldMin) * newRange) / oldRange + newMin;
	return newValue;
};

// A csikos (bar) HUD tipusok kitoltese. Vizszintes csiknal a szelesseget,
// allo csiknal a magassagot allitja - mind az ot bar-status blokkban egyszerre,
// abbol ugyis csak a kivalasztott lathato.
function setBarStat(stat, value) {
	let v = parseFloat(value);
	if (isNaN(v)) v = 0;
	if (v < 0) v = 0;
	if (v > 100) v = 100;

	$(`.bar-status .${stat}-stat .bar-h > i`).css("width", v + "%");
	$(`.bar-status .${stat}-stat .bar-v > i`).css("height", v + "%");
}

function animateValue(obj, start, end, duration) {
	let startTimestamp = null;
	const step = (timestamp) => {
		if (!startTimestamp) startTimestamp = timestamp;
		const progress = Math.min((timestamp - startTimestamp) / duration, 1);
		//obj.innerHTML = Intl.NumberFormat("de-DE").format(Math.floor(progress * (end - start) + start));
		obj.innerHTML = Math.floor(progress * (end - start) + start);
		if (progress < 1) {
			window.requestAnimationFrame(step);
		}
	};
	window.requestAnimationFrame(step);
}

function animateValue2(obj, start, end, duration) {
	let startTimestamp = null;
	const step = (timestamp) => {
		if (!startTimestamp) startTimestamp = timestamp;
		const progress = Math.min((timestamp - startTimestamp) / duration, 1);
		obj.innerHTML = Intl.NumberFormat("de-DE").format(Math.floor(progress * (end - start) + start));
		//obj.innerHTML = Math.floor(progress * (end - start) + start);
		if (progress < 1) {
			window.requestAnimationFrame(step);
		}
	};
	window.requestAnimationFrame(step);
}

function resetSettings() {
	settings = defaultSettings;
	loadSetting();
}

function setPositions() {
	var editablePositions = localStorage.getItem("aty_hud:editablePositions");

	if (editablePositions) {
		editablePositions = JSON.parse(editablePositions);

		for (const className in editablePositions) {
			const entry = editablePositions[className];
			// Skip legacy left-based entries (old format)
			if (entry.right === undefined) continue;

			// Only restore positions for elements that are actually draggable.
			$(`.${className}`).filter(".editable").css({
				position: "absolute",
				top: `${entry.top}px`,
				left: "auto",
				bottom: "auto",
				right: `${entry.right}px`,
			});
		}
	}
}

// Default right-to-left packing of the top-right info tiles, starting next to
// the logo. Each tile is anchored by its RIGHT edge (CSS align-items: flex-end
// + width: max-content), so a wide value grows leftwards and never shifts the
// others. Tiles the user has manually dragged are left untouched. Runs once on
// first load (and on reset) — there is no per-frame repositioning, so the
// layout can't drift or scramble between sessions.
function layoutInfoTiles(attempt, hiddenAttempt) {
	attempt = attempt || 0;
	hiddenAttempt = hiddenAttempt || 0;

	var pack = function () {
		var done = false;

		var apply = function () {
			if (done) return;
			done = true;

			// The HUD can be hidden when this runs: body starts at display:none
			// and the "toggle" message hides it again for the pause menu /
			// hideHud / cinematic mode. Every tile would then measure 0 and
			// report ":visible == false", so we would place nothing, still
			// reveal the tiles at their unpositioned default and leave all six
			// stacked on each other for the rest of the session. Wait for the
			// HUD to come back instead. hiddenAttempt is counted separately so
			// a long pause-menu stay can't eat the zero-width retries below.
			if (!$("main").is(":visible")) {
				if (hiddenAttempt < 100) {
					setTimeout(function () {
						layoutInfoTiles(attempt, hiddenAttempt + 1);
					}, 100);
				}
				// Past the cap the "toggle" handler re-runs us as soon as the
				// HUD is shown again, so giving up here loses nothing.
				return;
			}

			var saved = JSON.parse(localStorage.getItem("aty_hud:editablePositions") || "{}");
			var gap = 10;
			var $logo = $(".pi-logo");
			// Match the logo's CSS anchor (right: 10px) as the starting edge.
			var logoRight = 10;
			// Reserve the logo's width; fall back to ~4vw (its CSS max-width) if
			// the image hasn't reported a size yet, so tiles never overlap it.
			var logoW = $logo.is(":visible") ? $logo.outerWidth(true) || window.innerWidth * 0.04 : 0;
			var currentRight = logoRight + logoW + gap;

			// Order is right -> left (closest to the logo first).
			var items = [".pi-ping", ".pi-players", ".pi-id", ".pi-money", ".pi-bank", ".pi-job"];

			// If a visible, non-dragged tile still measures 0 wide, the font or
			// its icon hasn't rendered yet. Packing now would drop that tile at
			// the default position and it would stay there, so flag it and retry.
			var pending = false;

			items.forEach(function (sel) {
				var cls = sel.slice(1);
				var $el = $(sel);
				if (!$el.is(":visible")) return;
				// Respect a user-dragged tile: keep its spot and don't reserve a slot.
				if (saved[cls] && saved[cls].right !== undefined) return;
				var w = $el.outerWidth(true);
				if (!w) {
					pending = true;
					return;
				}
				$el.css({ position: "absolute", top: "", left: "auto", right: currentRight + "px" });
				currentRight += w + gap;
			});

			// Layout not settled: retry shortly (up to ~2s) without revealing
			// the tiles, so nothing flashes in the wrong spot. The cap is a
			// fail-safe — never leave the tiles invisible for good.
			if (pending && attempt < 20) {
				setTimeout(function () {
					layoutInfoTiles(attempt + 1, hiddenAttempt);
				}, 100);
				return;
			}

			// Only a clean pass counts as done. If a tile still measured 0 we
			// reveal everything anyway (never leave the info row blank), but
			// keep the flag down so the next "toggle" gets another go.
			if (!pending) infoTilesPacked = true;

			$(".pi-item").css("opacity", "1");
		};

		// Two frames so the browser has applied the latest layout before we measure.
		requestAnimationFrame(function () {
			requestAnimationFrame(apply);
		});
		// rAF is suspended while the page is hidden (alt-tab, minimised game) and
		// its callbacks only fire once it comes back, which would strand the tiles
		// at opacity 0. Timers keep running, so take whichever fires first.
		setTimeout(apply, 250);
	};

	// On the first pass wait for webfonts so text widths are correct; on later
	// calls (reset / toggle) the promise is already resolved and runs at once.
	if (attempt === 0 && document.fonts && document.fonts.ready) {
		document.fonts.ready.then(pack);
	} else {
		pack();
	}
}

function saveSettings() {
	localStorage.setItem("aty_hud:settings", JSON.stringify(settings));
}

// Where the round map's ring belongs. The box is not ours to decide: the ring has to sit on the
// game's radar, and only the client knows where that ended up - the widescreen offset it is
// placed with is missing from this stylesheet, which is exactly why the ring and the map drifted
// apart on anything wider than 16:9. ApplyMapLayout() in client/utils.lua sends the box, we only
// paint it. Null means nothing arrived yet, and the stylesheet's own 16:9 numbers stand in.
let mapGeometry = null;

function applyMapGeometry(data) {
	mapGeometry = data && data.shape === "circle" ? data : null;
	renderMapGeometry();
}

function renderMapGeometry() {
	const wrapper = $(".map-wrapper");
	const ring = $(".map-circle-outline");

	if (!mapGeometry || !wrapper.hasClass("map-circle")) {
		ring.css({ left: "", bottom: "", width: "", height: "" });
		wrapper.css({ left: "", bottom: "", width: "" });
		return;
	}

	ring.css({
		left: mapGeometry.left + "vw",
		bottom: mapGeometry.bottom + "vh",
		width: mapGeometry.width + "vh",
		height: mapGeometry.height + "vh",
	});

	// The address and time row rides on top of the ring, so it follows it everywhere.
	wrapper.css({
		left: mapGeometry.left + "vw",
		bottom: mapGeometry.bottom + mapGeometry.height + 0.55 + "vh",
		width: mapGeometry.width + "vh",
	});
}

function loadSetting() {
	// Migrate legacy speedoType value that has no matching radio button
	if (settings.speedoType === "circle") {
		settings.speedoType = "rpm-circle";
	}

	$.post(`https://${GetParentResourceName()}/setAlwaysMapOn`, JSON.stringify(settings.showMap));
	$.post(`https://${GetParentResourceName()}/cinematicMode`, JSON.stringify(settings.showCinematic));
	$.post(`https://${GetParentResourceName()}/setSpeedUnit`, JSON.stringify(settings.speetUnit));
	$.post(`https://${GetParentResourceName()}/setMapShape`, JSON.stringify(settings.mapShape));

	$(".speed-type").text(settings.speetUnit.toUpperCase());

	for (const setting in settings) {
		if (settings[setting] == true) {
			$(`.setting input[name="${setting}"][data-status="${true}"][type="radio"]`).prop("checked", true);
		} else if (settings[setting] == false) {
			$(`.setting input[name="${setting}"][data-status="${false}"][type="radio"]`).prop("checked", true);
		}

		if (setting == "hudType") {
			$(`.setting input[name="${setting}"][data-status="${settings[setting]}"][type="radio"]`).prop("checked", true);
		}
		if (setting == "scaleSpeedo") {
			let scale = parseInt(settings[setting]);
			$(".speedo-wrapper").css("scale", `${scale / 100}`);
			$(`.setting input[name="${setting}"]`).val(settings[setting]);
		}
		if (setting == "speetUnit") {
			$(`.setting input[name="${setting}"][data-status="${settings[setting]}"][type="radio"]`).prop("checked", true);
		}
		if (setting == "mapShape") {
			$(`.setting input[name="${setting}"][data-status="${settings[setting]}"][type="radio"]`).prop("checked", true);
		}
		if (setting == "speedoType") {
			$(`.setting input[name="${setting}"][data-status="${settings[setting]}"][type="radio"]`).prop("checked", true);
		}
		if (setting == "showCinematic") {
			if (settings[setting]) {
				$("main").hide();
			} else {
				$("main").show();
			}
		}
	}

	for (const stat in settings.hudColors) {
		$(`.${stat}-stat .top stop`).attr("stop-color", settings.hudColors[stat]);
		$(`.${stat}-stat .top-1 stop`).attr("stop-color", settings.hudColors[stat]);
		$(`.${stat}-stat .top-2 stop`).attr("stop-color", settings.hudColors[stat]);
		$(`.${stat}-stat .bottom stop`).attr("stop-color", settings.hudColors[stat]);
		$(`.${stat}-stat .bottom-1 stop`).attr("stop-color", settings.hudColors[stat]);
		$(`.${stat}-stat .bottom-2 stop`).attr("stop-color", settings.hudColors[stat]);
		$(`.${stat}-stat .top path`).attr("fill", settings.hudColors[stat]);
		$(`.${stat}-stat .top-1 path`).attr("fill", settings.hudColors[stat]);
		$(`.${stat}-stat .top-2 path`).attr("fill", settings.hudColors[stat]);
		$(`.${stat}-stat .bottom path`).attr("fill", settings.hudColors[stat]);
		$(`.${stat}-stat .bottom-1 path`).attr("fill", settings.hudColors[stat]);
		$(`.${stat}-stat .bottom-2 path`).attr("fill", settings.hudColors[stat]);
		$(`.${stat}-stat .circle-img stop`).attr("stop-color", settings.hudColors[stat]);
		$(`.${stat}-stat .top`).css("stroke", settings.hudColors[stat]);
		$(`.${stat}-stat .square-stat path`).attr("fill", settings.hudColors[stat]);
		$(`.${stat}-stat circle.top`).attr("stroke", settings.hudColors[stat]);
		$(`.triangle-status .${stat}-stat .progress-poly`).attr("stroke", settings.hudColors[stat]);
		$(`.hex-status .${stat}-stat .progress-poly`).attr("stroke", settings.hudColors[stat]);
		$(`.triangle-status .${stat}-stat .bg-shape polygon`).attr("stroke", hexToRgba(settings.hudColors[stat], 0.3));
		$(`.hex-status .${stat}-stat .bg-shape polygon`).attr("stroke", hexToRgba(settings.hudColors[stat], 0.3));

		$(`.circle-status .${stat}-stat .icon path`).attr("fill", settings.hudColors[stat]);
		$(`.circle-status-settings .${stat}-stat .icon path`).attr("fill", settings.hudColors[stat]);
		$(`.corner-stats-type-one .${stat}-stat .icon path`).attr("fill", settings.hudColors[stat]);
		$(`.corner-stats-type-two .${stat}-stat .icon path`).attr("fill", settings.hudColors[stat]);
		$(`.triangle-status .${stat}-stat .icon path`).attr("fill", settings.hudColors[stat]);
		$(`.hex-status .${stat}-stat .icon path`).attr("fill", settings.hudColors[stat]);
		$(`.circle-v2-status .${stat}-stat .icon path`).attr("fill", settings.hudColors[stat]);
		$(`.circle-v2-status .${stat}-stat .circle-svg-v2 circle.top`).css("stroke", settings.hudColors[stat]);
		$(`.circle-v2-status .${stat}-stat`).css("--glow-color", settings.hudColors[stat]);
		$(`.bar-status .${stat}-stat`).css("--bar-color", settings.hudColors[stat]);
	}

	// A hudType ertekehez tartozo statusz-blokk. Ismeretlen ertek eseten
	// - a regi viselkedessel egyezoen - a negyzetes tipusra esunk vissza.
	const hudTypeWrappers = {
		circle: ".circle-status",
		"circle-v2": ".circle-v2-status",
		"corner-1": ".corner-stats-type-one",
		"corner-2": ".corner-stats-type-two",
		triangle: ".triangle-status",
		hexagon: ".hex-status",
		"bar-row": ".bar-row-status",
		"bar-list": ".bar-list-status",
		"bar-thin": ".bar-thin-status",
		"bar-vert": ".bar-vert-status",
		"bar-pill": ".bar-pill-status",
	};

	$("main .player-status .status-wrapper").hide();
	$(hudTypeWrappers[settings.hudType] || ".square-status")
		.show()
		.css("display", "flex");

	if (settings.showInfo) {
		if (settings.showInfoJob !== false) $(".info-job").show();
		else $(".info-job").hide();
		if (settings.showInfoBank !== false) $(".info-bank").show();
		else $(".info-bank").hide();
		if (settings.showInfoMoney !== false) $(".info-money").show();
		else $(".info-money").hide();
		if (settings.showInfoId !== false) $(".info-id").show();
		else $(".info-id").hide();
		if (settings.showInfoPlayers !== false) $(".info-players").show();
		else $(".info-players").hide();
		if (settings.showInfoPing !== false) $(".info-ping").show();
		else $(".info-ping").hide();
		if (settings.showInfoLogo !== false) $(".pi-logo").show();
		else $(".pi-logo").hide();

		if (settings.showWeapon !== false) {
			// flat widget visibility is managed by updateGun when armed
		} else {
			$(".pi-weapon").hide();
		}
	} else {
		$(".pi-hud-item").hide();
	}

	if (settings.showInfoBg === false) {
		$(".pi-item").addClass("pi-no-bg");
	} else {
		$(".pi-item").removeClass("pi-no-bg");
	}

	if (settings.showOutline) {
		$(".map-outline").css("opacity", 1);
	} else {
		$(".map-outline").css("opacity", 0);
	}

	// The round map replaces the squared frame with a ring, and pulls the address/time row up
	// so it still sits directly above the minimap instead of over it.
	$(".map-wrapper").toggleClass("map-circle", settings.mapShape === "circle");
	$(".map-wrapper").toggleClass("map-bordered", settings.mapShape === "bordered");
	renderMapGeometry();

	if (settings.showKeys) {
		$(".keys-wrapper").show();
	} else {
		$(".keys-wrapper").hide();
	}

	if (settings.showSpeedo) {
		$(".speedo-wrapper-main").show();
	} else {
		$(".speedo-wrapper-main").hide();
	}

	if (settings.showMic) {
		$(".microphone-wrapper").show();
	} else {
		$(".microphone-wrapper").hide();
	}

	// A status-hud mogotti sotet folt. Ugyanaz a HUD marad, csak az arnyek nelkul.
	$("main .player-status").toggleClass("no-hud-shadow", settings.showHudShadow === false);

	saveSettings();
}

function playBuckleSound() {
	let buckleSound = new Audio();
	buckleSound.src = "sounds/buckle.mp3";
	buckleSound.play();
	buckleSound = null;
}

function playUnbuckleSound() {
	let unbuckleSound = new Audio();
	unbuckleSound.src = "sounds/unbuckle.mp3";
	unbuckleSound.play();
	unbuckleSound = null;
}
