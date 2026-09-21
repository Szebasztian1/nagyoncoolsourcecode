window.addEventListener('message', function(event) {
    if (event.data.type == "show") {
        document.body.style.display = event.data.enable ? "block" : "none";
        if (event.data.enable) {
            document.getElementById("note").value = event.data.text;
        }
    }
});

function exit() {
    var text = document.getElementById("note").value;
    fetch(`https://${GetParentResourceName()}/exit`, {
        method: 'POST',
        body: JSON.stringify({
            text: text
        })
    });
}