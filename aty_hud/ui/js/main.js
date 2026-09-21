let defaultSettings = {
	hudType: "circle",
	showMap: true,
	mapShape: "square",
	showHealth: true,
	showArmor: true,
	showHunger: true,
	showThirst: true,
	showStamina: true,
	showOxygen: true,
	showStress: true,
	speetUnit: "kmh",
	showInfo: true,
	showInfoJob: true,
	showInfoBank: true,
	showInfoMoney: true,
	showInfoId: true,
	showInfoPlayers: true,
	showInfoPing: true,
	showInfoLogo: true,
	showInfoBg: true,
	showOutline: false,
	// A status-hud mogotti sotet radialis folt (main .player-status::after).
	// Ez a HUD szinei miatt kell a vilagos hatterek elott, viszont tobben
	// zavaronak talaltak -- ezert kikapcsolhato (2026-09-17, Rikszii otlete).
	showHudShadow: true,
	showKeys: true,
	showSpeedo: true,
	speedoType: "rpm-circle",
	showMic: true,
	showCinematic: false,
	scaleSpeedo: 100,
	showWeapon: true,
	hudColors: {
		health: "#FF2B5A",
		armor: "#4589EE",
		hunger: "#FFB44B",
		thirst: "#6EFFF6",
		stamina: "#6E7DFF",
		oxygen: "#924FFF",
		stress: "#FF1686",
	},
};

var lastbank = 0;
var lastmoney = 0;
var currentMaxClip = 0;
var currentWeaponName = null;
var piInitialized = false;
// Set once layoutInfoTiles() has actually placed the info tiles. Separate from
// piInitialized: the first updatePlayerInfo can land while the HUD is hidden
// (pause menu, hideHud, still fading in), and then nothing gets positioned.
var infoTilesPacked = false;

let editMode = false;
var colorInput = null;
let vehicleType = null;
let speedoDisplayState = null;
let currentVehicle = null;
let useInGameTimer = false;
let bikes = [];
let helis = [];
let bikeDistance = 0;
let bikeLastUpdateTime = null;
let settings = localStorage.getItem("aty_hud:settings") != null ? JSON.parse(localStorage.getItem("aty_hud:settings")) : defaultSettings;
settings.showMap = true;

// Settings saved before the round map existed have no mapShape at all; fall back to the frame
// they have been looking at rather than silently switching their minimap on update.
if (!["square", "bordered", "circle"].includes(settings.mapShape)) {
	settings.mapShape = "square";
}

// Aki a kapcsolo elott mentett beallitast, annal ez a kulcs hianyzik -- undefined
// pedig hamis lenne, es magatol eltunne az arnyek mindenkinel. Marad a regi kinezet,
// amig o maga at nem kapcsolja.
if (typeof settings.showHudShadow !== "boolean") {
	settings.showHudShadow = true;
}

beltsound();

var sbinvehicle = false;
var sbseatbelton = false;
var sbsoundoff = false;

function beltsound() {
	if (sbinvehicle && !sbseatbelton && !sbsoundoff) {
		var sbsound = new Audio();
		sbsound.src = "sounds/seatbelt.ogg";
		sbsound.play();
		sbsound = null;
	}
	setTimeout(beltsound, 5000);
}

dateshow();
function dateshow() {
	var d = new Date();
	document.getElementById("nowdate").innerHTML = d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
	setTimeout("dateshow()", 10000);
}

// Exclusive speedo-type visibility. Called from the (undeduped, ~600ms) updateVehicle
// tick, from updateStatus, and immediately on a speedoType setting change — relying on
// updateStatus alone left this waiting on the player-stat de-dupe in SendHudMessage,
// so entering a vehicle (or switching type mid-drive) could sit unshown/stale for a
// long time. The DOM is only touched when the resolved target actually changes
// (speedoDisplayState), so being called every ~600ms can't stack/replay fade
// animations or fight itself into a stuck-hidden state.
const SPEEDO_TYPE_SELECTORS = {
	bike: ".speedo-type-bike",
	one: ".speedo-type-one",
	two: ".speedo-type-two",
	three: ".speedo-type-three",
	four: ".speedo-type-four",
	five: ".speedo-type-five",
};

function updateSpeedoVisibility() {
	if (!vehicleType) return;

	let isBicycle = currentVehicle != null && bikes.includes(currentVehicle.toLowerCase());
	let isHeli = vehicleType === "heli" || vehicleType === "plane";

	let target;
	if (!settings.showSpeedo || isHeli) {
		target = "none";
	} else if (isBicycle) {
		target = "bike";
	} else if (settings.speedoType === "flat") {
		target = "three";
	} else if (settings.speedoType === "flat2") {
		target = "four";
	} else if (settings.speedoType === "circle") {
		target = "one";
	} else if (settings.speedoType === "tiszta") {
		target = "five";
	} else {
		// rpm-circle (default) — use type-two for autos/bikes, type-one otherwise
		target = vehicleType == "automobile" || (vehicleType == "bike" && currentVehicle != null && !bikes.includes(currentVehicle.toLowerCase())) ? "two" : "one";
	}

	if (target === speedoDisplayState) return;
	speedoDisplayState = target;

	$(".speedo-type-bike, .speedo-type-one, .speedo-type-two, .speedo-type-three, .speedo-type-four, .speedo-type-five").stop(true, true);

	for (const key in SPEEDO_TYPE_SELECTORS) {
		if (key !== target) $(SPEEDO_TYPE_SELECTORS[key]).hide();
	}

	if (target === "four" || target === "five") {
		$(SPEEDO_TYPE_SELECTORS[target]).css({ display: "flex", opacity: 0 }).animate({ opacity: 1 }, 200);
	} else if (target !== "none") {
		$(SPEEDO_TYPE_SELECTORS[target]).fadeIn(200);
	}
}

function xssprotect(string) {
	var reg = /<(.|\n)*?>/g;
	return reg.test(string);
}

function cehckxss(xssobj) {
	for (var key in xssobj) {
		if (!xssobj.hasOwnProperty(key)) continue;

		var val = xssobj[key];
		if (typeof val === "object") {
			if (cehckxss(val)) {
				return true;
			}
		} else if (typeof val === "string") {
			if (xssprotect(val)) {
				return true;
			}
		}
	}
	return false;
}
/*
if (cehckxss(event.data)) {
    return false;
}
*/

$(function () {
	loadSetting();
	setPositions();

	$.post(`https://${GetParentResourceName()}/loaded`, function (data) {
		if (data.BikeModels) bikes = data.BikeModels.map(m => m.toLowerCase());
		if (data.HeliModels) helis = data.HeliModels.map(m => m.toLowerCase());

		//if(!data.UseSeatBelt){
		//    $(".seatbelt-indicator").remove()
		//}
		if (!data.UseCruiseControl) {
			$(".cruise-indicator").remove();
		}
		if (!data.UseNitro) {
			$(".nitro-wrapper").remove();
		}
		if (!data.UseStress) {
			$(".stress-stat").remove();
		}
		if (data.UseInGameTimer) {
			useInGameTimer = true;
		} else {
			/*setInterval(function(){
                let date = new Date()
                let hours = date.getHours()
                let minutes = date.getMinutes()
                let seconds = date.getSeconds()

                if(hours < 10){
                    hours = "0"+hours
                }

                if(minutes < 10){
                    minutes = "0"+minutes
                }

                if(seconds < 10){
                    seconds = "0"+seconds
                }

                $(".time-wrapper .text").html(hours+":"+minutes)
                date = null
                hours = null
                minutes = null
                seconds = null
            }, 1000)*/
		}

		data.Keys.forEach((key) => {
			$(".keys-wrapper").append(`
            <div class="key">
                <div class="key-box">
                    <div class="key-name">${key.key}</div>
                    <img src="assets/images/key-bg.png">
                </div>

                <div class="title">${key.title}</div>
            </div>
            `);
		});
	});

	/*const settings = localStorage.getItem("bc-hud-settings");
                fetch('http://'+GetParentResourceName()+'/loadSetting',  {
                    "method": "POST",
                    "body": JSON.stringify({
                        setid: settings
                    })
                });
     window.addEventListener('message', function (event) {
            if (event.data.action == "setsettingid") {
                localStorage.setItem("bc-hud-settings", event.data.setid)
            }
        });*/

	window.addEventListener("message", function (event) {
		let data = event.data;

		if (cehckxss(event.data)) {
			return false;
		}

		if (data.action == "toggle") {
			if (data.status) {
				$("body").fadeIn(150);
				// The HUD is visible again, so the tiles can finally be measured.
				// Retry if the initial pass ran against a hidden HUD and placed
				// nothing — otherwise they would stay stacked until a manual reset.
				if (piInitialized && !infoTilesPacked) {
					layoutInfoTiles();
				}
			} else {
				$("body").fadeOut(150);
			}
		}

		if (data.action == "notification") {
			let text = data.text;
			let icon = data.icon;
			let color = data.color;
			let duration = data.duration;

			let randomId = Math.floor(Math.random() * 1000000000);

			$(".notification-wrapper").append(`
            <div class="notification ${color ? color : "yellow"} ${randomId}">
                <div class="icon"><i class="${icon}"></i></div>
                <div class="text">${text}</div>
                <div class="bar-wrapper">
                    <div class="bar"></div>
                </div>
            </div>`);

			$(`.notification.${randomId}`).fadeIn(200);
			$(`.notification.${randomId}`).css("display", "flex");

			$("." + randomId + " .bar").animate(
				{
					width: "0%",
				},
				duration,
				function () {
					$(`.notification.${randomId}`).fadeOut(200);
					setTimeout(function () {
						$(`.notification.${randomId}`).remove();
					}, 200);
				},
			);
		}

		if (data.action == "updateGun") {
			let gunName = data.gunName;
			let isArmed = data.isArmed;
			let fullAmmo = data.fullAmmo;
			let clipAmmo = data.clipAmmo;

			gunName = (gunName || "").replace("weapon_", "");

			if (isArmed && settings.showWeapon !== false) {
				// Track max clip per weapon for ring progress
				if (currentWeaponName !== gunName) {
					currentWeaponName = gunName;
					currentMaxClip = clipAmmo > 0 ? clipAmmo : 30;
				} else if (clipAmmo > currentMaxClip) {
					currentMaxClip = clipAmmo;
				}

				// Generic placeholder for unknown/custom weapons or missing assets
				var placeholder = "assets/weapons/default.svg";
				if (gunName) {
					var img = new Image();
					img.onload = function () {
						$(".gun-img img").attr("src", `assets/weapons/${gunName}.webp`);
					};
					img.onerror = function () {
						$(".gun-img img").attr("src", placeholder);
					};
					img.src = `assets/weapons/${gunName}.webp`;
				} else {
					$(".gun-img img").attr("src", placeholder);
				}

				$("#player-weapon").fadeIn(100);

				$(".full-ammo").text(fullAmmo);
				$(".clip-ammo").text(clipAmmo);
			} else {
				$("#player-weapon").fadeOut(100);
				currentWeaponName = null;
				currentMaxClip = 0;
			}
		}

		if (data.action == "setVoiceMode") {
			if (data.value == 1) {
				$(".microphone-wrapper .top").css("stroke-dashoffset", 96);
			} else if (data.value == 2) {
				$(".microphone-wrapper .top").css("stroke-dashoffset", 48);
			} else {
				$(".microphone-wrapper .top").css("stroke-dashoffset", 0);
			}
		}

		if (data.action == "isTalking") {
			let isTalking = data.isTalking;
			if (isTalking) {
				$(".microphone-wrapper").css("opacity", 1);
			} else {
				$(".microphone-wrapper").css("opacity", 0.3);
			}
		}

		if (data.action == "toggleCruise") {
			let cruise = data.cruise;
			if (cruise) {
				$(".cruise-indicator path").css("fill", "#4C6EF5");
			} else {
				$(".cruise-indicator path").css("fill", "");
			}
		}

		if (data.action == "bc_toggleBelt") {
			let seatBelt = data.seatBelt;
			let mute = data.sbsoundoff;
			/*if (mute) {
                seatbeltsound = true;
            } else {*/

			sbseatbelton = seatBelt;
			sbsoundoff = mute;
			if (seatBelt) {
				playBuckleSound();
				$(".seatbelt-indicator path").css("fill", "#4C6EF5");
			} else {
				playUnbuckleSound();
				$(".seatbelt-indicator path").css("fill", "");
			}
			//}
		}

		if (data.action == "nitro") {
			if (data.nitro < 1) {
				$(".speedo-type-one .nitro-wrapper, .speedo-type-two .nitro-wrapper").hide();
				$(".speedo-type-five .nitro-wrapper").hide();
			} else {
				$(".speedo-type-one .nitro-wrapper, .speedo-type-two .nitro-wrapper").show();
				$(".speedo-type-five .nitro-wrapper").show();
			}

			$(".speedo-type-one .nitro-wrapper .top").css("stroke-dashoffset", convertValue(data.nitro, 0, 100, 830, 600));
			$(".speedo-type-two .nitro-wrapper .top").css("stroke-dashoffset", convertValue(data.nitro, 0, 100, 960, 775));
			$(".s3-nitro-bar-fill").css("width", data.nitro + "%");
			$(".s3-nitro-value").text(Math.round(data.nitro) + "%");
			$(".s4-nitro-vert-fill").css("height", data.nitro + "%");
			$(".st5-nitro-fill").css("width", data.nitro + "%");
			$(".st5-nitro-pct").text(Math.round(data.nitro) + "%");
		}

		if (data.action == "toggleSettings") {
			$(".settings").fadeIn(150);
			$(".settings").css("display", "flex");
		}

		if (data.action == "mapGeometry") {
			applyMapGeometry(data);
		}

		if (data.action == "updateVehicle") {
			let speed = data.speed;
			let fuel = data.fuel;
			let rpm = data.rpm;
			let lightOn = data.lightsOn;
			let isDoorOpen = data.isDoorOpen;
			let highlightsOn = data.highlightsOn;
			currentVehicle = data.vehicleHash;
			rpm < 0.2 ? (rpm = 0.2) : (rpm = rpm);
			vehicleType = data.vehicleType;

			updateSpeedoVisibility();

			if (vehicleType == "automobile") {
				$(".fuel-wrapper").show();
				$(".gear-wrapper, .st5-gear-block").show();
				$(".seatbelt-indicator").show();
				$(".cruise-indicator").show();
				$(".lights-indicator").show();
				$(".door-indicator").show();
			} else if (vehicleType == "bike" && !bikes.includes(currentVehicle.toLowerCase())) {
				$(".fuel-wrapper").show();
				$(".gear-wrapper, .st5-gear-block").show();
				$(".seatbelt-indicator").hide();
				$(".cruise-indicator").show();
				$(".lights-indicator").show();
				$(".door-indicator").hide();
			} else if (vehicleType == "boat") {
				$(".fuel-wrapper").show();
				$(".gear-wrapper, .st5-gear-block").hide();
				$(".seatbelt-indicator").hide();
				$(".cruise-indicator").hide();
				$(".lights-indicator").show();
				$(".door-indicator").hide();
			} else if (vehicleType == "plane" || vehicleType == "heli") {
				$(".fuel-wrapper").show();
				$(".gear-wrapper, .st5-gear-block").hide();
				$(".seatbelt-indicator").show();
				$(".cruise-indicator").hide();
				$(".lights-indicator").show();
				$(".door-indicator").show();
			}

			if (bikes.includes(data.vehicleHash.toLowerCase())) {
				$(".fuel-wrapper").hide();
				$(".gear-wrapper, .st5-gear-block").hide();
				$(".indicators, .st5-indicators").hide();
				$(".rpm-wrapper .top").css("stroke-dashoffset", 0);
			} else {
				$(".indicators, .st5-indicators").show();
				$(".rpm-wrapper .top").css("stroke-dashoffset", convertValue(rpm, 0.0, 1.0, 830, 0));
			}

			if ((!vehicleType == "automobile" && !vehicleType == "bike" && bikes.includes(data.vehicleHash.toLowerCase())) || vehicleType == "boat" || vehicleType == "plane" || vehicleType == "heli") {
				$(".rpm-wrapper .top").css("stroke-dashoffset", 0);
			}

			if (lightOn || highlightsOn) {
				$(".lights-indicator path").css("fill", "#4C6EF5");
			} else {
				$(".lights-indicator path").css("fill", "");
			}

			if (data.braking) {
				$(".brake-indicator path").css("fill", "#4C6EF5");
			} else {
				$(".brake-indicator path").css("fill", "");
			}

			if (isDoorOpen) {
				$(".door-indicator path").css("fill", "#4C6EF5");
			} else {
				$(".door-indicator path").css("fill", "");
			}

			if (data.engineHealth < 600) {
				$(".engine-indicator path").css("fill", "#4C6EF5");
			} else {
				$(".engine-indicator path").css("fill", "");
			}

			// Motor es karosszeria KULON - korabban a ketto atlaga ment ki egy szamban.
			// A vehicle_failure a karosszeria-serulest 5.9x szorzoval a MOTORBA vezeti at
			// (vehicle_failure/config.lua: damageFactorBody), a karosszeria erteket viszont
			// nem csokkenti: ep karosszeria + halott motor = 45% atlag, amit a jatekos
			// "de hiszen full az auto"-kent olvasott. Kulon-kulon lathato, melyik a rossz.
			let engineHealthPct = Math.round(Math.max(0, Math.min(100, (data.engineHealth / 1000) * 100)));
			let bodyHealthPct = Math.round(Math.max(0, Math.min(100, (data.bodyHealth / 1000) * 100)));
			let condClass = function (pct) {
				return pct >= 70 ? "condition-good" : pct >= 40 ? "condition-mid" : "condition-bad";
			};

			// Motor
			$(".engine-percent, .s3-engine-value, .st5-engine-pct").text(engineHealthPct + "%");
			$(".s3-engine-fill, .st5-engine-fill").css("width", engineHealthPct + "%");
			$(".s4-engine-vert-fill").css("height", engineHealthPct + "%");
			$(".engine-badge, .s3-engine-row, .s4-engine-vert, .st5-engine-row")
				.removeClass("condition-good condition-mid condition-bad")
				.addClass(condClass(engineHealthPct));

			// Karosszeria
			$(".body-percent, .s3-body-value, .st5-body-pct").text(bodyHealthPct + "%");
			$(".s3-body-fill, .st5-body-fill").css("width", bodyHealthPct + "%");
			$(".s4-body-vert-fill").css("height", bodyHealthPct + "%");
			$(".body-badge, .s3-body-row, .s4-body-vert, .st5-body-row")
				.removeClass("condition-good condition-mid condition-bad")
				.addClass(condClass(bodyHealthPct));

			$(".vehicle-speed").text(String(speed).padStart(3, "0"));
			$(".speedo-type-one .fuel-wrapper .top").css("stroke-dashoffset", convertValue(fuel, 0, 100, 830, 600));
			$(".speedo-type-two .fuel-wrapper .top").css("stroke-dashoffset", convertValue(fuel, 0, 100, 960, 775));
			$(".needle").css("rotate", convertValue(rpm, 0.2, 1.0, -122, 84) + "deg");

			// Type-three flat speedo updates
			let fuelPct = Math.round(fuel);
			$(".s3-fuel-value").text(fuelPct + "%");
			$(".s3-fuel-bar-fill").css("width", fuelPct + "%");
			$(".s4-fuel-vert-fill").css("height", fuelPct + "%");
			let rpmBars = Math.round(convertValue(rpm, 0, 1.0, 0, 100));
			$(".s3-rpm-bar-fill").css("width", rpmBars + "%");
			$(".s4-arc-fill").css("stroke-dashoffset", (122 * (1 - rpmBars / 100)).toFixed(1));
			$(".st5-rpm-fill").css("width", rpmBars + "%");
			$(".st5-fuel-fill").css("width", fuelPct + "%");
			$(".st5-fuel-pct").text(fuelPct + "%");
			if (rpm > 0.85) {
				$(".s3-rpm-bar-fill").addClass("redline");
				$(".s4-arc-fill").addClass("redline");
				$(".st5-rpm-fill").addClass("redline");
			} else {
				$(".s3-rpm-bar-fill").removeClass("redline");
				$(".s4-arc-fill").removeClass("redline");
				$(".st5-rpm-fill").removeClass("redline");
			}

			if (data.vehReversing) {
				$(".gear-wrapper .prev").css("opacity", 0);
				$(".gear-wrapper .active").text("R");
				$(".gear-wrapper .next").text("N");
				$(".gear-wrapper-s3").text("R");
				$(".s4-gear").text("R");
				$(".gear-wrapper-st5").text("R");
			} else {
				$(".gear-wrapper .prev").css("opacity", 1);

				if (data.gear == 0) {
					$(".gear-wrapper .prev").text("R");
					$(".gear-wrapper .active").text("N");
					$(".gear-wrapper .next").text("1");
					$(".gear-wrapper-s3").text("N");
					$(".s4-gear").text("N");
					$(".gear-wrapper-st5").text("N");
				} else if (data.gear == 1) {
					$(".gear-wrapper .prev").text("N");
					$(".gear-wrapper .active").text("1");
					$(".gear-wrapper .next").text("2");
					$(".gear-wrapper-s3").text("1");
					$(".s4-gear").text("1");
					$(".gear-wrapper-st5").text("1");
				} else {
					$(".gear-wrapper .prev").text(data.gear - 1);
					$(".gear-wrapper .active").text(data.gear);
					$(".gear-wrapper .next").text(data.gear + 1);
					$(".gear-wrapper-s3").text(data.gear);
					$(".s4-gear").text(data.gear);
					$(".gear-wrapper-st5").text(data.gear);
				}

				if (data.gear == data.lastGear) {
					$(".gear-wrapper .next").css("opacity", 0);
				} else {
					$(".gear-wrapper .next").css("opacity", 1);
				}
			}

			// Bicycle HUD updates
			if (bikes.includes(data.vehicleHash.toLowerCase())) {
				let speedKmh = parseInt(data.speed);
				$(".bike-speed-val").text(String(speedKmh).padStart(3, "0"));

				let now = Date.now();
				if (bikeLastUpdateTime !== null) {
					let elapsedHours = (now - bikeLastUpdateTime) / 3600000;
					bikeDistance += speedKmh * elapsedHours;
				}
				bikeLastUpdateTime = now;
				$(".bike-dist-val").text(bikeDistance.toFixed(1));

				let slope = typeof data.pitch === "number" ? data.pitch : 0;
				$(".bike-slope-val").text((slope >= 0 ? "+" : "") + slope.toFixed(1));
			} else {
				bikeLastUpdateTime = null;
			}
		}

		if (data.action == "updateStatus") {
			// Biztonsagi vagas: negativ ertek (pl. fuldoklaskor az oxigen) negativ SVG height/viewBox-ot adna
			for (const stat of ["health", "armor", "hunger", "thirst", "stamina", "oxygen"]) {
				if (data[stat] < 0) data[stat] = 0;
			}

			let isTalking = data.isTalking;
			if (isTalking) {
				$(".microphone-wrapper").css("opacity", 1);
			} else {
				$(".microphone-wrapper").css("opacity", 0.5);
			}

			if (data.isInVehicle) {
				if (vehicleType == "automobile") {
					sbinvehicle = true;
				}

				$(".map-outline").css("height", "20vh");

				updateSpeedoVisibility();
			} else {
				/*seatbeltsound = false;
                sbinvehicle = false;*/

				sbinvehicle = false;
				bikeDistance = 0;
				bikeLastUpdateTime = null;
				vehicleType = null;
				currentVehicle = null;
				speedoDisplayState = null;
				$(".speedo-wrapper").fadeOut(150);

				$(".cruise-indicator path").attr("fill", "#3E3D3D");
				$(".seatbelt-indicator path").attr("fill", "#3E3D3D");
				$(".door-indicator path").attr("fill", "#3E3D3D");
				$(".light-indicator path").attr("fill", "#3E3D3D");
				$(".brake-indicator path").attr("fill", "#3E3D3D");
				$(".engine-indicator path").attr("fill", "#3E3D3D");

				if (!settings.showMap) {
					$(".map-outline").css("height", "0vh");
				} else {
					$(".map-outline").css("height", "20vh");
				}
			}

			if (!settings.showHealth && data.health == 100) {
				$(".health-stat").fadeOut(150);
			} else if (!settings.showHealth && data.health < 100) {
				$(".health-stat").fadeIn(150);
			} else {
				$(".health-stat").fadeIn(150);
			}

			if (!settings.showArmor && data.armor == 0) {
				$(".armor-stat").fadeOut(150);
			} else if (!settings.showArmor && data.armor > 0) {
				$(".armor-stat").fadeIn(150);
			} else {
				$(".armor-stat").fadeIn(150);
			}

			if (!settings.showHunger && data.hunger == 100) {
				$(".hunger-stat").fadeOut(150);
			} else if (!settings.showHunger && data.hunger < 100) {
				$(".hunger-stat").fadeIn(150);
			} else {
				$(".hunger-stat").fadeIn(150);
			}

			if (!settings.showThirst && data.thirst == 100) {
				$(".thirst-stat").fadeOut(150);
			} else if (!settings.showThirst && data.thirst < 100) {
				$(".thirst-stat").fadeIn(150);
			} else {
				$(".thirst-stat").fadeIn(150);
			}

			if (!settings.showStamina && data.stamina == 100) {
				$(".stamina-stat").fadeOut(150);
			} else if (!settings.showStamina && data.stamina < 100) {
				$(".stamina-stat").fadeIn(150);
			} else {
				$(".stamina-stat").fadeIn(150);
			}

			if (!settings.showOxygen && !data.isInWater) {
				$(".oxygen-stat").fadeOut(150);
			} else if (!settings.showOxygen && data.isInWater) {
				$(".oxygen-stat").fadeIn(150);
			} else {
				$(".oxygen-stat").fadeIn(150);
			}

			let health = data.health.toFixed(0) + "%";
			let armor = data.armor.toFixed(0) + "%";
			let hunger = data.hunger.toFixed(0) + "%";
			let thirst = data.thirst.toFixed(0) + "%";
			let stamina = data.stamina.toFixed(0) + "%";
			let oxygen = data.oxygen.toFixed(0) + "%";

			data.oxygen <= 0 ? (oxygen = "0%") : (oxygen = data.oxygen.toFixed(0) + "%");
			data.health <= 0 ? (health = "0%") : (health = data.health.toFixed(0) + "%");

			$(".health-percent").text(health);
			$(".armor-percent").text(armor);
			$(".hunger-percent").text(hunger);
			$(".thirst-percent").text(thirst);
			$(".stamina-percent").text(stamina);
			$(".oxygen-percent").text(oxygen);

			// Csikos (bar) HUD tipusok kitoltese
			setBarStat("health", data.health <= 0 ? 0 : data.health);
			setBarStat("armor", data.armor);
			setBarStat("hunger", data.hunger);
			setBarStat("thirst", data.thirst);
			setBarStat("stamina", data.stamina);
			setBarStat("oxygen", data.oxygen);

			$(".health-stat .top").css("stroke-dashoffset", convertValue(data.health <= 0 ? 0 : data.health, 0, 100, 145, 0));
			$(".armor-stat .top").css("stroke-dashoffset", convertValue(data.armor, 0, 100, 145, 0));
			$(".hunger-stat .top").css("stroke-dashoffset", convertValue(data.hunger, 0, 100, 145, 0));
			$(".thirst-stat .top").css("stroke-dashoffset", convertValue(data.thirst, 0, 100, 145, 0));
			$(".stamina-stat .top").css("stroke-dashoffset", convertValue(data.stamina, 0, 100, 145, 0));
			$(".oxygen-stat .top").css("stroke-dashoffset", convertValue(data.oxygen, 0, 100, 145, 0));
			// Circle v2 overrides (r=27, circumference≈170)
			$(".circle-v2-status .health-stat .top").css("stroke-dashoffset", convertValue(data.health <= 0 ? 0 : data.health, 0, 100, 170, 0));
			$(".circle-v2-status .armor-stat .top").css("stroke-dashoffset", convertValue(data.armor, 0, 100, 170, 0));
			$(".circle-v2-status .hunger-stat .top").css("stroke-dashoffset", convertValue(data.hunger, 0, 100, 170, 0));
			$(".circle-v2-status .thirst-stat .top").css("stroke-dashoffset", convertValue(data.thirst, 0, 100, 170, 0));
			$(".circle-v2-status .stamina-stat .top").css("stroke-dashoffset", convertValue(data.stamina, 0, 100, 170, 0));
			$(".circle-v2-status .oxygen-stat .top").css("stroke-dashoffset", convertValue(data.oxygen, 0, 100, 170, 0));

			$(".health-stat .tri-img .progress-poly").css("stroke-dashoffset", convertValue(data.health <= 0 ? 0 : data.health, 0, 100, 180, 0));
			$(".health-stat .hex-img .progress-poly").css("stroke-dashoffset", convertValue(data.health <= 0 ? 0 : data.health, 0, 100, 196, 0));
			$(".armor-stat .tri-img .progress-poly").css("stroke-dashoffset", convertValue(data.armor, 0, 100, 180, 0));
			$(".armor-stat .hex-img .progress-poly").css("stroke-dashoffset", convertValue(data.armor, 0, 100, 196, 0));
			$(".hunger-stat .tri-img .progress-poly").css("stroke-dashoffset", convertValue(data.hunger, 0, 100, 180, 0));
			$(".hunger-stat .hex-img .progress-poly").css("stroke-dashoffset", convertValue(data.hunger, 0, 100, 196, 0));
			$(".thirst-stat .tri-img .progress-poly").css("stroke-dashoffset", convertValue(data.thirst, 0, 100, 180, 0));
			$(".thirst-stat .hex-img .progress-poly").css("stroke-dashoffset", convertValue(data.thirst, 0, 100, 196, 0));
			$(".stamina-stat .tri-img .progress-poly").css("stroke-dashoffset", convertValue(data.stamina, 0, 100, 180, 0));
			$(".stamina-stat .hex-img .progress-poly").css("stroke-dashoffset", convertValue(data.stamina, 0, 100, 196, 0));
			$(".oxygen-stat .tri-img .progress-poly").css("stroke-dashoffset", convertValue(data.oxygen, 0, 100, 180, 0));
			$(".oxygen-stat .hex-img .progress-poly").css("stroke-dashoffset", convertValue(data.oxygen, 0, 100, 196, 0));

			$(".health-stat .square-stat svg").attr("height", convertValue(data.health <= 0 ? 0 : data.health, 0, 100, 0, 52));
			$(".health-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.health <= 0 ? 0 : data.health, 0, 100, 0, 52));
			$(".armor-stat .square-stat svg").attr("height", convertValue(data.armor, 0, 100, 0, 52));
			$(".armor-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.armor, 0, 100, 0, 52));
			$(".hunger-stat .square-stat svg").attr("height", convertValue(data.hunger, 0, 100, 0, 52));
			$(".hunger-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.hunger, 0, 100, 0, 52));
			$(".thirst-stat .square-stat svg").attr("height", convertValue(data.thirst, 0, 100, 0, 52));
			$(".thirst-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.thirst, 0, 100, 0, 52));
			$(".stamina-stat .square-stat svg").attr("height", convertValue(data.stamina, 0, 100, 0, 52));
			$(".stamina-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.stamina, 0, 100, 0, 52));
			$(".oxygen-stat .square-stat svg").attr("height", convertValue(data.oxygen, 0, 100, 0, 52));
			$(".oxygen-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.oxygen, 0, 100, 0, 52));

			if (data.health >= 50) {
				$(".health-stat .top-2").css("opacity", convertValue(data.health, 50, 100, 0, 1));
				$(".health-stat .bottom-2").css("opacity", convertValue(data.health, 50, 100, 0, 1));
				$(".health-stat .top-1").css("opacity", 1);
				$(".health-stat .bottom-1").css("opacity", 1);
			} else {
				$(".health-stat .top-2").css("opacity", 0);
				$(".health-stat .bottom-2").css("opacity", 0);
				$(".health-stat .top-1").css("opacity", convertValue(data.health, 0, 50, 0, 1));
				$(".health-stat .bottom-1").css("opacity", convertValue(data.health, 0, 50, 0, 1));
			}
			if (data.armor >= 50) {
				$(".armor-stat .top-2").css("opacity", convertValue(data.armor, 50, 100, 0, 1));
				$(".armor-stat .bottom-2").css("opacity", convertValue(data.armor, 50, 100, 0, 1));
				$(".armor-stat .top-1").css("opacity", 1);
				$(".armor-stat .bottom-1").css("opacity", 1);
			} else {
				$(".armor-stat .top-2").css("opacity", 0);
				$(".armor-stat .bottom-2").css("opacity", 0);
				$(".armor-stat .top-1").css("opacity", convertValue(data.armor, 0, 50, 0, 1));
				$(".armor-stat .bottom-1").css("opacity", convertValue(data.armor, 0, 50, 0, 1));
			}
			if (data.hunger >= 50) {
				$(".hunger-stat .top-2").css("opacity", convertValue(data.hunger, 50, 100, 0, 1));
				$(".hunger-stat .bottom-2").css("opacity", convertValue(data.hunger, 50, 100, 0, 1));
				$(".hunger-stat .top-1").css("opacity", 1);
				$(".hunger-stat .bottom-1").css("opacity", 1);
			} else {
				$(".hunger-stat .top-2").css("opacity", 0);
				$(".hunger-stat .bottom-2").css("opacity", 0);
				$(".hunger-stat .top-1").css("opacity", convertValue(data.hunger, 0, 50, 0, 1));
				$(".hunger-stat .bottom-1").css("opacity", convertValue(data.hunger, 0, 50, 0, 1));
			}
			if (data.thirst >= 50) {
				$(".thirst-stat .top-2").css("opacity", convertValue(data.thirst, 50, 100, 0, 1));
				$(".thirst-stat .bottom-2").css("opacity", convertValue(data.thirst, 50, 100, 0, 1));
				$(".thirst-stat .top-1").css("opacity", 1);
				$(".thirst-stat .bottom-1").css("opacity", 1);
			} else {
				$(".thirst-stat .top-2").css("opacity", 0);
				$(".thirst-stat .bottom-2").css("opacity", 0);
				$(".thirst-stat .top-1").css("opacity", convertValue(data.thirst, 0, 50, 0, 1));
				$(".thirst-stat .bottom-1").css("opacity", convertValue(data.thirst, 0, 50, 0, 1));
			}
			if (data.stamina >= 50) {
				$(".stamina-stat .top-2").css("opacity", convertValue(data.stamina, 50, 100, 0, 1));
				$(".stamina-stat .bottom-2").css("opacity", convertValue(data.stamina, 50, 100, 0, 1));
				$(".stamina-stat .top-1").css("opacity", 1);
				$(".stamina-stat .bottom-1").css("opacity", 1);
			} else {
				$(".stamina-stat .top-2").css("opacity", 0);
				$(".stamina-stat .bottom-2").css("opacity", 0);
				$(".stamina-stat .top-1").css("opacity", convertValue(data.stamina, 0, 50, 0, 1));
				$(".stamina-stat .bottom-1").css("opacity", convertValue(data.stamina, 0, 50, 0, 1));
			}
			if (data.oxygen >= 50) {
				$(".oxygen-stat .top-2").css("opacity", convertValue(data.oxygen, 50, 100, 0, 1));
				$(".oxygen-stat .bottom-2").css("opacity", convertValue(data.oxygen, 50, 100, 0, 1));
				$(".oxygen-stat .top-1").css("opacity", 1);
				$(".oxygen-stat .bottom-1").css("opacity", 1);
			} else {
				$(".oxygen-stat .top-2").css("opacity", 0);
				$(".oxygen-stat .bottom-2").css("opacity", 0);
				$(".oxygen-stat .top-1").css("opacity", convertValue(data.oxygen, 0, 50, 0, 1));
				$(".oxygen-stat .bottom-1").css("opacity", convertValue(data.oxygen, 0, 50, 0, 1));
			}
		}

		if (data.action == "stress") {
			// Biztonsagi vagas: negativ stressz negativ SVG height/viewBox-ot adna
			if (data.stress < 0) data.stress = 0;

			let stress = data.stress.toFixed(0) + "%";

			$(".stress-percent").text(stress);

			// Csikos (bar) HUD tipusok kitoltese
			setBarStat("stress", data.stress);

			$(".stress-stat .top").css("stroke-dashoffset", convertValue(data.stress, 0, 100, 145, 0));
			$(".circle-v2-status .stress-stat .top").css("stroke-dashoffset", convertValue(data.stress, 0, 100, 170, 0));

			$(".stress-stat .tri-img .progress-poly").css("stroke-dashoffset", convertValue(data.stress, 0, 100, 180, 0));
			$(".stress-stat .hex-img .progress-poly").css("stroke-dashoffset", convertValue(data.stress, 0, 100, 196, 0));

			$(".stress-stat .square-stat svg").attr("height", convertValue(data.stress, 0, 100, 0, 52));
			$(".stress-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.stress, 0, 100, 0, 52));

			if (data.stress >= 50) {
				$(".stress-stat .top-2").css("opacity", convertValue(data.stress, 50, 100, 0, 1));
				$(".stress-stat .bottom-2").css("opacity", convertValue(data.stress, 50, 100, 0, 1));
				$(".stress-stat .top-1").css("opacity", 1);
				$(".stress-stat .bottom-1").css("opacity", 1);
			} else {
				$(".stress-stat .top-2").css("opacity", 0);
				$(".stress-stat .bottom-2").css("opacity", 0);
				$(".stress-stat .top-1").css("opacity", convertValue(data.stress, 0, 50, 0, 1));
				$(".stress-stat .bottom-1").css("opacity", convertValue(data.stress, 0, 50, 0, 1));
			}

			$(".stress-stat .square-stat svg").attr("height", convertValue(data.stress, 0, 100, 0, 52));
			$(".stress-stat .square-stat svg").attr("viewBox", "0 0 52 " + convertValue(data.stress, 0, 100, 0, 52));

			if (!settings.showStress && data.stress == 0) {
				$(".stress-stat").fadeOut(150);
			} else if (!settings.showStress && data.stress > 0) {
				$(".stress-stat").fadeIn(150);
			} else {
				$(".stress-stat").fadeIn(150);
			}
		}

		if (data.action == "updatePlayerInfo") {
			$("#player-job").text(data.job);
			$("#player-id").text(data.id);
			$("#max-players").text(data.maxPlayers);

			if (useInGameTimer) {
				$(".time-wrapper .text").html(data.time);
			}
			$(".bike-time-val").text(data.time);

			if (!piInitialized) {
				// First update: set final values directly so tile widths are
				// correct, then pack the tiles once and reveal them.
				$("#player-bank").text(Intl.NumberFormat("us-US").format(data.bank));
				$("#player-money").text(Intl.NumberFormat("us-US").format(data.money));
				$("#player-ping").text(data.ping);
				$("#current-players").text(data.totalPlayers);
				lastbank = data.bank;
				lastmoney = data.money;
				layoutInfoTiles();
				piInitialized = true;
			} else {
				animateValue2(document.getElementById("player-bank"), lastbank, data.bank, 1500);
				animateValue2(document.getElementById("player-money"), lastmoney, data.money, 1500);
				animateValue(document.getElementById("player-ping"), parseInt($("#player-ping").text()), data.ping, 1500);
				animateValue(document.getElementById("current-players"), parseInt($("#current-players").text()), data.totalPlayers, 1500);
				lastbank = data.bank;
				lastmoney = data.money;
			}
		}

		if (data.action == "updateStreet") {
			$(".address-wrapper .subtitle").text(data.road);
			$(".address-wrapper .title").text(data.street);
		}
	});

	$(".settings .stat-wrapper").click(function (e) {
		if (colorInput) colorInput.remove();
		let itemClass = $(this).attr("id");

		colorInput = $(`<div class="color-input-wrapper"> 
			<div class="color-input-background"> </div>
			<input type="color" class="color-input" style="--x: ${e.clientX}px; --y: ${e.clientY}px;" />
		</div>`);

		$("body").append(colorInput);

		$(".color-input-background").click(() => {
			if (colorInput) {
				colorInput.remove();
				colorInput = null;
			}
		});

		colorInput.on("change input", (e) => {
			let hex = e.target.value;
			settings.hudColors[itemClass] = hex;
			loadSetting();
		});
	});

	$(".editable").draggable({
		cursor: "move",
		start: function (e) {
			const $target = $(this);
			const rect = this.getBoundingClientRect();

			// Convert right-based CSS position to left-based for jQuery draggable
			$target.css({
				left: rect.left + "px",
				right: "auto",
				bottom: "auto",
				position: "absolute",
			});
		},
		stop: function (e, ui) {
			const target = this;
			const className = target.classList[0];
			const rightVal = Math.round(window.innerWidth - ui.position.left - $(target).outerWidth());

			// Re-anchor by the right edge so the tile keeps growing leftwards
			// (matching the default behaviour) without waiting for a reload.
			$(target).css({ left: "auto", right: rightVal + "px" });

			const positions = JSON.parse(localStorage.getItem("aty_hud:editablePositions"));

			localStorage.setItem(
				"aty_hud:editablePositions",
				JSON.stringify({
					...positions,
					[className]: { top: ui.position.top, right: rightVal },
				}),
			);
		},
	});

	$(".edit-btn").on("click", function () {
		$(".settings").fadeOut();
		$(".editable").css({
			border: "1px dashed #a4a4a4",
		});

		editMode = true;
	});

	$(document).keyup(function (e) {
		if (e.key === "Escape") {
			editMode = false;
			$.post(`https://${GetParentResourceName()}/close`);
			$(".settings").fadeOut(150);
			$(".editable").css({
				border: "none",
			});
		}
	});

	$(document).on("click", ".reset-btn", function () {
		resetSettings();
		localStorage.removeItem("aty_hud:editablePositions");

		$(".editable").css({
			top: "",
			left: "",
			bottom: "",
			right: "",
		});

		layoutInfoTiles();
	});

	$(document).on("click", ".triangle-status .stress-stat, .hex-status .stress-stat", function () {
		let $pct = $(".triangle-status .percent, .hex-status .percent");
		if ($pct.first().is(":visible")) {
			$pct.fadeOut(150);
		} else {
			$pct.fadeIn(150);
		}
	});

	$(document).on("click", ".setting input[type='radio']", function () {
		let setting = $(this).attr("name");
		let value = $(this).data("status");
		settings[setting] = value;
		loadSetting();

		// speedoType/showSpeedo only take effect on the next vehicle/status tick
		// otherwise — apply immediately so switching mid-drive doesn't wait on it.
		if (setting === "speedoType" || setting === "showSpeedo") {
			updateSpeedoVisibility();
		}

		// Re-pack the info row only when a tile is shown/hidden, so the
		// remaining tiles close up or make room — never on unrelated settings.
		if (piInitialized && setting.indexOf("showInfo") === 0) {
			layoutInfoTiles();
		}
	});

	$(document).on("change", ".setting input[type='range']", function () {
		let setting = $(this).attr("name");
		let value = $(this).val();
		settings[setting] = value;
		loadSetting();
	});
});
