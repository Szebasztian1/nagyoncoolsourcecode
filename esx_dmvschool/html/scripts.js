// question variables
var questionNumber = 1;
var userAnswer = [];
var goodAnswer = [];
var questionUsed = [];
var nbQuestionToAnswer = 10; // don't forget to change the progress bar max value in html
var nbAnswerNeeded = 5; // out of nbQuestionToAnswer
var nbPossibleQuestions = 10; // number of questions in database questions.js
var lastClick = 0;

function getRandomQuestion() {
	var random = Math.floor(Math.random() * nbPossibleQuestions);

	while (true) {
		if (questionUsed.indexOf(random) === -1) {
			break;
		}

		random = Math.floor(Math.random() * nbPossibleQuestions);
	}

	questionUsed.push(random);

	return random;
}

// Partial Functions
function closeMain() {
	$(".home").css("display", "none");
}
function openMain() {
	$(".home").css("display", "block");
}
function closeAll() {
	$(".body").css("display", "none");
}
function openQuestionnaire() {
	$(".questionnaire-container").css("display", "block");
	var randomQuestion = getRandomQuestion();

	$("#questionNumero").html(questionNumber + ". Kérdés");
	$("#question").html(tableauQuestion[randomQuestion].question);
	$(".answerA").html(tableauQuestion[randomQuestion].propositionA);
	$(".answerB").html(tableauQuestion[randomQuestion].propositionB);
	$(".answerC").html(tableauQuestion[randomQuestion].propositionC);
	$(".answerD").html(tableauQuestion[randomQuestion].propositionD);
	$('input[name=question]').attr('checked', false);

	goodAnswer.push(tableauQuestion[randomQuestion].reponse);
	$(".questionnaire-container .progression").val(questionNumber - 1);
}
function openResultGood() {
	$(".resultGood").css("display", "block");
}
function openResultBad() {
	$(".resultBad").css("display", "block");
}
function openContainer() {
	$(".question-container").css("display", "block");
}
function closeContainer() {
	$(".question-container").css("display", "none");
}

// Listen for NUI Events
window.addEventListener('message', function (event) {
	var item = event.data;

	// Open & Close main window
	if (item.openQuestion == true) {
		openContainer();
		openMain();
	}

	if (item.openQuestion == false) {
		closeContainer();
		closeMain();
	}

	// Open sub-windows / partials
	if (item.openSection == "question") {
		closeAll();
		openQuestionnaire();
	}

	// Autósiskola menü panel
	if (item.openMenu === true) {
		openDmvMenu(item.title, item.options);
	}

	if (item.openMenu === false) {
		closeDmvMenu();
	}
});

// ===== Autósiskola menü panel =====
function openDmvMenu(title, options) {
	$("#dmvMenuTitle").text(title || "Autósiskola");

	var list = $("#dmvMenuList");
	list.empty();

	if (!options || options.length === 0) {
		list.append('<div class="dmv-menu-empty">Minden jogosítványod megvan! 🎉</div>');
	} else {
		options.forEach(function (opt) {
			var item = $('<a href="#" class="dmv-menu-item"></a>');
			item.attr("data-value", opt.value);
			item.attr("data-type", opt.type || "");
			item.html(
				'<span class="label"></span><span class="price"></span>'
			);
			item.find(".label").text(opt.label);
			item.find(".price").text(opt.price);
			list.append(item);
		});
	}

	$("#dmvMenu").addClass("open");
}

function closeDmvMenu() {
	$("#dmvMenu").removeClass("open");
}

// Menüpont kiválasztása (delegált, mert dinamikusan jönnek létre)
$(document).on("click", ".dmv-menu-item", function (e) {
	e.preventDefault();
	$.post(
		"http://esx_dmvschool/dmvSelect",
		JSON.stringify({
			value: $(this).attr("data-value"),
			type: $(this).attr("data-type")
		})
	);
});

// Bezárás gomb
$("#dmvMenuClose").click(function (e) {
	e.preventDefault();
	$.post("http://esx_dmvschool/dmvClose", JSON.stringify({}));
});

// ESC a bezáráshoz (csak ha a menü nyitva van)
document.onkeyup = function (data) {
	if (data.key === "Escape" && $("#dmvMenu").hasClass("open")) {
		$.post("http://esx_dmvschool/dmvClose", JSON.stringify({}));
	}
};

// Handle Button Presses
$(".btnQuestion").click(function () {
	$.post('http://esx_dmvschool/question', JSON.stringify({}));
});

$(".btnClose").click(function () {
	$.post('http://esx_dmvschool/close', JSON.stringify({}));
	userAnswer = [];
	goodAnswer = [];
	questionUsed = [];
	questionNumber = 1;
});

$(".btnKick").click(function () {
	$.post('http://esx_dmvschool/kick', JSON.stringify({}));
	userAnswer = [];
	goodAnswer = [];
	questionUsed = [];
	questionNumber = 1;
});

// Handle Form Submits
$("#question-form").submit(function (e) {
	e.preventDefault();

	if (questionNumber != nbQuestionToAnswer) {
		//question 1 to 9: pushing answer in array
		closeAll();
		userAnswer.push($('input[name="question"]:checked').val());
		questionNumber++;
		openQuestionnaire();
	} else {
		// question 10: comparing arrays and sending number of good answers
		userAnswer.push($('input[name="question"]:checked').val());
		var nbGoodAnswer = 0;
		for (i = 0; i < nbQuestionToAnswer; i++) {
			if (userAnswer[i] == goodAnswer[i]) {
				nbGoodAnswer++;
			}
		}

		closeAll();
		if (nbGoodAnswer >= nbAnswerNeeded) {
			openResultGood();
		} else {
			openResultBad();
		}
	}

	return false;
});
