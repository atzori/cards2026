<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<title>Casino Cards</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
.scene {
    width: 90px;
    height: 130px;
    perspective: 900px;
}

.card {
    width: 100%;
    height: 100%;
    position: relative;
    transform-style: preserve-3d;
    cursor: pointer;
    transition:
        transform 0.6s ease,
        box-shadow 0.2s ease;
    /*transition:
        transform 0.75s cubic-bezier(.25,.8,.25,1.25),
        box-shadow 0.2s;*/
}

.card.flipped {
    transform: rotateY(180deg);
}

.card.locked {
    pointer-events: none;
/*    opacity: 0.85;*/
}

.card-face {
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 10px;
    border: 1px solid #111;
    backface-visibility: hidden;
    background: white;
    padding: 6px;
    font-size: 18px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.card-front {
    background: linear-gradient(135deg, #ffffff, #f1f1f1);
}

.card-back {
    transform: rotateY(180deg);
    color: white;
    font-size: 30px;
    font-weight: bold;
    justify-content: center;
    align-items: center;
    letter-spacing: 2px;
}

.card-back.red {
    background: radial-gradient(circle, #ff6b6b, #b11226);
    box-shadow: 0 0 20px rgba(220,53,69,.8);
}

.card-back.blue {
    background: radial-gradient(circle, #6ea8fe, #084298);
    box-shadow: 0 0 20px rgba(13,110,253,.8);
}

.bottom {
    transform: rotate(180deg);
}

/* tavolo verde */
body {
    background: radial-gradient(circle at center, #146c43, #0f5132);
}
</style>
</head>

<body>

<div class="container py-4">
<h1 class="text-center text-light mb-4">🎰 Casino Cards</h1>

<div class="row g-3 justify-content-center">
% for carta in carte:
<div class="col-auto">
    <div class="scene">
        <div class="card {{'locked' if carta['cliccata'] else ''}}"
		     data-codice="{{carta['codice']}}"
		     data-parita="{{'pari' if carta['numero'] % 2 == 0 else 'dispari'}}"
		     data-locked="{{'true' if carta['cliccata'] else 'false'}}">

            <!-- FRONT -->
            <div class="card-face card-front {{carta['seme']['colore']}}">
                <div>{{carta['valore']}} {{carta['seme']['simbolo']}}</div>
                <div class="text-center fs-3">{{carta['seme']['simbolo']}}</div>
                <div class="bottom">{{carta['valore']}} {{carta['seme']['simbolo']}}</div>
            </div>

            <!-- BACK -->
            <div class="card-face card-back">🂠</div>

        </div>
    </div>
</div>
% end


<!-- BOTTONI -->
<div class="text-center mt-4">
    <a href="/reset" class="btn btn-danger me-3">
        🔄 Reset
    </a>

    <a href="/schermo"
       id="btn-schermo"
       target="_blank"
       rel="noopener noreferrer"
       class="btn btn-warning btn-lg {{'disabled' if count < 5 else ''}}">
        🎰 Vai allo schermo
    </a>

    <div class="text-light mt-2">
        Carte selezionate: <span id="counter">{{count}}</span> / 5
    </div>
</div>


</div>
</div>

<script>
$(function () {

    // OMBRA DINAMICA (NO ROTAZIONE)
    $('.scene').on('mousemove', function (e) {
        const card = $(this).find('.card');
        const rect = this.getBoundingClientRect();

        const x = e.clientX - rect.left - rect.width / 2;
        const y = e.clientY - rect.top - rect.height / 2;

        const shadowX = (-x / 10).toFixed(1);
        const shadowY = (-y / 10).toFixed(1);

        card.css({
            boxShadow: `${shadowX}px ${shadowY}px 25px rgba(0,0,0,.45)`
        });
    });

    $('.scene').on('mouseleave', function () {
        $(this).find('.card').css({
            boxShadow: '0 8px 20px rgba(0,0,0,.4)'
        });
    });

    // FLIP SOLO AL CLICK

    $('.card').on('click', function () {
        const card = $(this);

        if (card.data('locked') === true) return;

        const codice = card.data('codice');
        const parita = card.data('parita');
        const back = card.find('.card-back');

        $.post('/send', { codice }, function (res) {

            if (res.status !== 'ok') return;

            back.addClass(parita === 'pari' ? 'blue' : 'red');
            card.addClass('flipped locked')
                .data('locked', true);

            $('#counter').text(res.count);

            if (res.count === 5) {
                $('#btn-schermo').removeClass('disabled');
            }
        });
    });

});
</script>


</body>
</html>

