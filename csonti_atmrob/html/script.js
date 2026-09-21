
$(function () {

    function display(bool) {
        if (bool) {
            $("#container").show();
        } else {
            $("#container").hide();
        }
    }

    display(true);

    $("#welding").hide();
    $("#cells").hide();
    
    


    function moneyFormat(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    document.addEventListener('keydown', function(event){  
        if(event.key === "Escape"){
            $.post('http://csonti_atmrob/esc', JSON.stringify({}));
            $("#welding").hide();
            $("#cells").hide();
            clearInterval(progBar);
        }
    });

    function shake(element){
        $("#welding").toggleClass("welding-red");
        $("#key-container").toggleClass("welding-red");
        $("#weld-prog").toggleClass("bg-success");
        $("#weld-prog").toggleClass("bg-danger");
        $(element).animate({left:'49%'}, 50, function(){
            $(element).animate({left:'51%'}, 50, function(){
                $(element).animate({left:'49%'}, 50, function(){
                    $(element).animate({left:'51%'}, 50, function(){
                        $(element).animate({left:'49%'}, 50, function(){
                            $(element).animate({left:'51%'}, 50, function(){
                                $(element).animate({left:'50%'}, 50, function(){ 
                                    $("#welding").toggleClass("welding-red"); 
                                    $("#key-container").toggleClass("welding-red");
                                    $("#weld-prog").toggleClass("bg-success");
                                    $("#weld-prog").toggleClass("bg-danger");                                
                                });
                            });
                        });
                    });
                });
            });
        });
    }


    var keys = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    function startWelding(weldSpeed, weldError){
        $("#welding").show();
        var progress = 0;
        var key = keys[Math.floor(Math.random()*keys.length)];
        document.getElementById("weld-prog").style.width = progress + "%";

        $("#key").html(key.toUpperCase());
        document.onkeypress = function (e) {
            if (e.key.toLowerCase() === key){
                $("#key").removeClass("key");
                progress = progress + weldSpeed;
                document.getElementById("weld-prog").style.width = progress + "%";
                key = keys[Math.floor(Math.random()*keys.length)];
                $("#key").html(key.toUpperCase());
                $("#key-container").toggleClass("key-press");
                setTimeout(function(){
                    $("#key-container").toggleClass("key-press")          
                  },100)

            }  
            else {
                progress = (((progress-weldError) >= 0) ? (progress-weldError) : 0);
                document.getElementById("weld-prog").style.width = progress + "%";
                shake("#welding");
            }
            if (progress >= 100) {  
                $("#welding").hide();
                $.post('http://csonti_atmrob/welddone', JSON.stringify({}));
            }
        };
    }

    

    var openedCells = 0
    function startCells(){
        $("#cells").show();
        $(".cell").show();
        $(".progress-bar").width(0);
        openedCells = 0;
        document.getElementById('cells').style.pointerEvents = 'auto';
    }

    var cellOpenSpeed;
    var progBar;
    function cellProg(cell){
        var progress = 0;
        progBar = setInterval(function() {
            progress = progress + 1;
            document.getElementById(cell+"-prog").style.width = progress + "%";
            if (progress == 100){
                clearInterval(progBar);
                $("#"+cell).fadeOut(300);
                openedCells = openedCells + 1;
                document.getElementById('cells').style.pointerEvents = 'auto';

                $.post('http://csonti_atmrob/cellOpened', JSON.stringify({}));

                if (openedCells == 5){
                    $.post('http://csonti_atmrob/cellsEmpty', JSON.stringify({}));
                    $("#cells").hide();
                }
            }
        }, cellOpenSpeed);
    }
   

    $("#cell1").click(function() {
        cellProg("cell1")
        document.getElementById('cells').style.pointerEvents = 'none';
    });

    $("#cell2").click(function() {
        cellProg("cell2")
        document.getElementById('cells').style.pointerEvents = 'none';
    });

    $("#cell3").click(function() {
        cellProg("cell3")
        document.getElementById('cells').style.pointerEvents = 'none';
    });

    $("#cell4").click(function() {
        cellProg("cell4")
        document.getElementById('cells').style.pointerEvents = 'none';
    });

    $("#cell5").click(function() {
        cellProg("cell5")
        document.getElementById('cells').style.pointerEvents = 'none';
    });

    
    window.addEventListener('message', function(event) {
        if (event.data.type === "ui") {
            if (event.data.status == true) {
                display(true)
            }
            else {
                display(false)
            }
        }

        else if (event.data.type == "weld") {
            if (event.data.start == true) {
                startWelding(event.data.weldSpeed, event.data.weldError);
            }
        }    
        else if (event.data.type == "cells") {
            if (event.data.start == true) {
                startCells();
                cellOpenSpeed = event.data.cellOpenSpeed;
            }
        }   
    })
   
})