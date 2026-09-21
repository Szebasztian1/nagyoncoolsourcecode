// From cfx-keks (https://github.com/citizenfx/cfx-server-data/tree/master/resources/%5Btest%5D/keks)
$(document).ready(function () {
	var play = false;
	var myAudio = document.getElementById("statusAudio");

	myAudio.volume = 0.1;
	function onKeyDown(event) {
		switch (event.keyCode) {
			case 32:
				if (play) {
					myAudio.pause();
					play = false;
				} else {
					myAudio.play();
					play = true;
				}
				break;
		}
		return false;
	}

	window.addEventListener("keydown", onKeyDown, false);

	var count = 0;
	var thisCount = 0;

	$("#js-rotating").Morphext({
		separator: ";",
		speed: "7000",
		animation: "fadeIn",
	});

	function setProgress(fraction) {
		var pct = Math.min(100, Math.max(0, Math.round(fraction * 100)));
		var bar = document.querySelector(".progress-custom");
		if (bar) {
			bar.style.width = pct + "%";
			var span = bar.querySelector("span");
			if (span) span.innerHTML = "<b>Betöltés... " + pct + "%</b>";
		}
	}

	const handlers = {
		loadProgress(data) {
			setProgress(data.loadFraction);
		},
		startInitFunctionOrder(data) {
			count = data.count;
		},
		initFunctionInvoking(data) {
			setProgress(data.idx / count);
		},
		startDataFileEntries(data) {
			count = data.count;
		},
		performMapLoadFunction(data) {
			++thisCount;
			setProgress(thisCount / count);
		},
	};
	window.addEventListener("message", function (e) {
		(handlers[e.data.eventName] || function () {})(e.data);
	});
});
