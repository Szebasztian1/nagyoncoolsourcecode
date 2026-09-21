window.addEventListener('message', function(event) {
    var data = event.data

    if (data.type == "open") {
        $('body').css('display', 'block');
        SetPlayerStats(data.stats, data.remaining)
        
        if (data.remaining == 0) {
            $('.playerstatremaining').text("Megöltétek az összes ellenséget, menjetek és lootoljatok!")
        }

    }

    if (data.type == "close") {
        $('body').css('display', 'none');
    }

})

const SetPlayerStats = (stats, remaining) => {
    let array = '';
    let list = document.getElementById('playerstats');

    array = array + `
    <div class="playerstatremaining">
        Hátralévő Ellenség: ${remaining}
    </div> 
    `

    for (const player of stats) {
        array = array + `
        <div class="playerstat">
        ${player.rank}.<img class="staticon" src="imgs/player.png" width="20vw"> ${player.name} <img class="staticon" src="imgs/kill.png" width="20vw"> ${player.kill}
        </div> 
    `
    }

    list.innerHTML = `${array}`
}