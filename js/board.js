var c = document.getElementById("myCanvas");
var ctx = c.getContext("2d");

var size = 9;

var spot_size = 40;
var empty = document.getElementById("empty");
var black = document.getElementById("black");
var white = document.getElementById("white");
var star = document.getElementById("star");
var mark = document.getElementById("mark");

var board = generate_empty_board(size);
var answer = generate_empty_board(size);

var new_problem_button = document.getElementById("new_problem");
var many_rocks = document.getElementById("many_rocks");
var seconds = document.getElementById("seconds");
var check_button = document.getElementById("check");
var result_message = document.getElementById("result");

var round = 0

new_problem_button.onclick = async function(){
    result_message.innerHTML = "";
    var x = await rpc.apost([]);
    load_the_board(x, many_rocks.value);
}

check_button.onclick = async function(){
    all_good = 1
    for(i=0;i<size;i++) {
        for(j=0;j<size;j++){
            if(board[i][j] !== answer[i][j]){
                all_good = 0
                console.log([i, j]);
                console.log("incorrect");
                ctx.drawImage(mark, i*spot_size, j*spot_size, spot_size, spot_size);
            }
        }
    }
    if(all_good == 1){
        console.log("perfect message");
        result_message.innerHTML = "Perfect!";
    }
}

start();

async function start(){
    var x = await rpc.apost([]);
    load_the_board(x, many_rocks.value);
}

function generate_empty_board(n) {
    var r = list_many(n, 0);
    return(list_many(n, r));
};
function list_many(n, r) {
    if(n<1){
        return([]);
    };
    var r2 = JSON.parse(JSON.stringify(r));
    return([r2].concat(list_many(n-1, r)));
};
function star_int(x) {
    if (size == 19) {
        return((x == 3) || (x == 9) || (x == 15));
    } else if (size == 13) {
        return((x == 3) || (x == 9));
    } else if (size == 9) {
        return((x == 2) || (x == 6));
    };
    return(false);
};
function is_odd(x) {
    return((x % 2) == 1);
};
function draw_board() {
    ctx.clearRect(0, 0, c.width, c.height);
    for(i=0;i<size;i++) {
        for(j=0;j<size;j++){
            var img;
            var b = board[i][j];
            if (b == 0) {
                img = empty;
                if ((star_int(i) && star_int(j))) {
                    img = star;
                };
                if (is_odd(size) && (i == Math.floor(size / 2))
                    && (j == Math.floor(size / 2))) {
                    img = star;
                };
            } else if (b == 1) {
                img = black;
            } else if (b == 2) {
                img = white;
            }
            ctx.drawImage(img, i*spot_size, j*spot_size, spot_size, spot_size);
        }
    }
};

function empty_the_board(){
    for(i=0;i<size;i++) {
        for(j=0;j<size;j++){
            board[i][j] = 0
        }
    }
    draw_board()
}
function copy_answer(){
    for(i=0;i<size;i++) {
        for(j=0;j<size;j++){
            answer[i][j] = board[i][j]
        }
    }
}


function letter2number(x) {
    if(x == "a"){return(1)};
    if(x == "b"){return(2)};
    if(x == "c"){return(3)};
    if(x == "d"){return(4)};
    if(x == "e"){return(5)};
    if(x == "f"){return(6)};
    if(x == "g"){return(7)};
    if(x == "h"){return(8)};
    if(x == "i"){return(9)};
    console.log("letter2number impossible error")
    console.log(x)
    return(0)
}

function load_the_board(s, many){
    empty_the_board();
    const moves = s.split(";");
    lim = Math.min(many, moves.length);
    for(i=1; i<=lim; i++){
        l1 = moves[i].substring(0, 1);
        l2 = moves[i].substring(1, 2);
        board[letter2number(l1)-1][letter2number(l2)-1] = ((i+1) % 2)+1;
    }
    copy_answer();
    draw_board();
    round += 1;
    var this_round = round;
    setTimeout(function(){
        if(round == this_round){
            empty_the_board();
        }
    }, (1000 * seconds.value));
}


document.addEventListener('click', function(e){
    var L = c.offsetLeft;
    var T = c.offsetTop;
    var W = c.width;
    var H = c.height;
    var mouseX = e.pageX;
    var mouseY = e.pageY;
    var X = mouseX - L;
    var Y = mouseY - T;
    board_size = size*spot_size;
    if((X > -1) && (X < (board_size + 1)) &&
       (Y > -1) && (Y < (board_size + 1))) {
        var X2 = Math.floor(X / spot_size);
        var Y2 = Math.floor(Y / spot_size);
        var b = board[X2][Y2];
        b = b + 1;
        if (b>2) {
            b = 0;
        };
        board[X2][Y2] = b;
        draw_board();
    };
})

setTimeout(function() {
    draw_board();
}, 100);
