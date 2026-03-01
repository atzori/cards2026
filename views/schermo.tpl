<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<title>Schermo</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
.scene {
    width: 110px;
    height: 160px;
    perspective: 900px;
}

.card {
    width: 100%;
    height: 100%;
    position: relative;
    transform-style: preserve-3d;
    cursor: pointer;
    transition: transform 0.6s ease, box-shadow 0.2s ease;
}

.card.flipped {
    transform: rotateY(180deg);
}

.card-face {
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 10px;
    border: 1px solid #111;
    backface-visibility: hidden;
    background: white;
    padding: 8px;
    font-size: 20px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.card-back {
    transform: rotateY(180deg);
    color: white;
    font-size: 36px;
    font-weight: bold;
    justify-content: center;
    align-items: center;
}


.card-back.red  {
    background-image: url("static/img/napoletane_back.png");
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;

    box-shadow: 0 0 18px rgba(0,0,0,.85);
    border: 1px solid #111;
}

.card-back.redold {
    background: radial-gradient(circle, #ff6b6b, #b11226);
    box-shadow: 0 0 20px rgba(220,53,69,.8);
}

.card-back.blueold {
    background: radial-gradient(circle, #6ea8fe, #084298);
    box-shadow: 0 0 20px rgba(13,110,253,.8);
}

.card-back.blue {
    background-image: url("static/img/napoletane_back2.png");
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;

    box-shadow: 0 0 18px rgba(0,0,0,.85);
    border: 1px solid #111;
}

.bottom {
    transform: rotate(180deg);
}

body {
    background: radial-gradient(circle, #146c43, #0f5132);
}
</style>
</head>

<body>

<div class="container py-5 text-center">
<h1 class="text-light mb-5">🎰 Schermo</h1>

<div class="d-flex justify-content-center gap-4">
% for carta in carte:
<div class="scene">
    <div class="card flipped"
         data-parita="{{'pari' if carta['colore'] == 1 else 'dispari'}}">

        <!-- FRONT -->
        <div class="card-face {{carta['seme']['colore']}}">
            <div>{{carta['valore']}} {{carta['seme']['simbolo']}}</div>
            <div class="text-center fs-2">{{carta['seme']['simbolo']}}</div>
            <div class="bottom">{{carta['valore']}} {{carta['seme']['simbolo']}}</div>
        </div>

        <!-- BACK -->
        <div class="card-face card-back"><!-- 🂠 --></div>
    </div>
</div>
% end
</div>

<a href="/carte" class="btn btn-light mt-5">⬅ Torna alle carte</a>
</div>

<script>
$(function () {

    $('.card').each(function () {
        const card = $(this);
        const parita = card.data('parita');
        card.find('.card-back')
            .addClass(parita === 'pari' ? 'blue' : 'red');
    });

    $('.card').on('click', function () {
        $(this).toggleClass('flipped');
    });

});
</script>

</body>
</html>

