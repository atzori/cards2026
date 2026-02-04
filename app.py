from bottle import Bottle, run, template, request, redirect
import random, math

import socket

ip_locale = socket.gethostbyname(socket.gethostname())

PREFIX = ""		# on local machine
if not ip_locale.startswith("127.0"):
    PREFIX = "/cards2026"  	# on the server

app = Bottle()

# lista globale eventi click
carte_cliccate = []
mazzo_ordinato = []


@app.route('/')
def index():
    redirect(PREFIX + '/carte')


@app.route('/reset')
def reset():
    carte_cliccate.clear()
    redirect(PREFIX +'/carte')

@app.route('/carte')
def carte():
    semi = [
        {"simbolo": "♥", "codice": "H", "colore": "text-danger"},
        {"simbolo": "♦", "codice": "D", "colore": "text-danger"},
        {"simbolo": "♣", "codice": "C", "colore": "text-dark"},
        {"simbolo": "♠", "codice": "S", "colore": "text-dark"},
    ]

    valori = [
        ("A", 1), ("2", 2), ("3", 3), ("4", 4), ("5", 5),
        ("6", 6), ("7", 7), ("8", 8), ("9", 9),
        ("10", 10), ("J", 11), ("Q", 12), ("K", 13)
    ]

    carte = []
    for seme in semi:
        for valore, numero in valori:
            carte.append({
                "valore": valore,
                "numero": numero,
                "seme": seme,
                "codice": f"{valore}{seme['codice']}",
                "cliccata": f"{valore}{seme['codice']}" in carte_cliccate
            })


    global mazzo_ordinato 
    mazzo_ordinato =  [c['valore']+c['seme']['codice'] for c in carte]
    random.shuffle(carte)
    print("mazzo ordinato", mazzo_ordinato)
    
    return template(
        "carte",
        carte=carte,
        count=len(carte_cliccate)
    )

@app.post('/send')
def send():
    codice = request.forms.get('codice')

    if not codice:
        return {"status": "error"}

    if codice in carte_cliccate:
        return {"status": "ignored"}

    if len(carte_cliccate) >= 5:
        return {"status": "full"}

    carte_cliccate.append(codice)
    return {"status": "ok", "count": len(carte_cliccate)}
    
@app.route('/schermo')
def schermo():
    # prime 5 carte cliccate
    selezionate = carte_cliccate[:5]


    meta_del_mazzo = riordina(selezionate)

    semi_map = {
        "H": {"simbolo": "♥", "colore": "text-danger"},
        "D": {"simbolo": "♦", "colore": "text-danger"},
        "C": {"simbolo": "♣", "colore": "text-dark"},
        "S": {"simbolo": "♠", "colore": "text-dark"},
    }

    valori_map = {
        "A": 1, "2": 2, "3": 3, "4": 4, "5": 5,
        "6": 6, "7": 7, "8": 8, "9": 9,
        "10": 10, "J": 11, "Q": 12, "K": 13
    }

    carte = []
    for codice in selezionate:
        valore = codice[:-1]
        seme = codice[-1]

        carte.append({
            "valore": valore,
            "numero": valori_map[valore],
            "seme": semi_map[seme],
            "codice": codice,
            "colore": valori_map[valore] % 2 ^ 1 # xor inverte la parita' di numero
        })

    carte[-1]['colore'] = meta_del_mazzo
    return template("schermo", carte=carte)

# riordina localmente carte_cliccate e restituisce il colore della ultima carta

def riordina(carte_cliccate):
	#return riordina_matematicamente(carte_cliccate)
	return riordina_mnemonico(carte_cliccate)

def riordina_mnemonico(carte_cliccate):
	carta_da_indovinare = carte_cliccate[-1]
	carte_scelte = carte_cliccate[:4]
	carte_scelte.sort(key=lambda x: mazzo_ordinato.index(x))
	print("carte scelte ordinate", carte_cliccate)
	print("carta da indovinare", carta_da_indovinare)
		
	
	if carta_da_indovinare[0] != "K": # se non e' un Re
		i = "HDCS".index(carta_da_indovinare[-1])	
		permutazione = [carte_scelte[i], None, None, None] # inserisco il seme
		carte_scelte.pop(i)

		n = carta_da_indovinare[:-1]
		if n=="J": n="11"
		elif n=="Q": n="12"
		n = int(n)
		
		if n>6:
			n-=6
			meta_del_mazzo = 1
		else:	
			meta_del_mazzo = 0
		
		if n>3:
			n-=3
			swap = True
		else:
			swap = False
	
		print("n",n)
		print("carte scelte",carte_scelte)
		permutazione[1] = carte_scelte[n-1]
		carte_scelte.pop(n-1)
		
		if not swap:
			permutazione[2:4] = carte_scelte
		else: 
			permutazione[2:4] = carte_scelte[::-1]
	
	
		if not swap:
			permutazione[2:] = carte_scelte
		else:
			permutazione[2:] = carte_scelte[::-1]
		
		print("permutazione", permutazione)
		

		carte_cliccate[0:4] = permutazione 	
		
		print("nuove carte cliccate", carte_cliccate)
		return meta_del_mazzo
	else: # la carta da indovinare è un K
		# e' necessario codificare una carta diversa da K... quale?
		semiK = "HDCS"
		semi_da_scartare = "".join([carta[-1] for carta in carte_scelte if carta[0]=="K"])
		for s in semi_da_scartare:
			semiK = semiK.replace(s,"")

		print("semiK",semiK)
		print("seme da indovinare", carta_da_indovinare[-1])
		i = semiK.index(carta_da_indovinare[1])
		print("indice del seme da indovinare",i)
		carte_scelte = [c for c in sorted(carte_cliccate[:4]) if c[0]!="K"]

		nuova_carta_da_indovinare = carte_scelte[i]
		print("nuova carta da indovinare",nuova_carta_da_indovinare)

		carte_cliccate[-1] = nuova_carta_da_indovinare

		meta_del_mazzo = riordina_mnemonico(carte_cliccate)

		carte_cliccate[-1] = carta_da_indovinare

		return meta_del_mazzo
    		
    		

def riordina_matematicamente(carte_cliccate):

	def n_esima_permutazione(lista, n):
		lista = lista.copy()
		risultato = []

		for i in range(len(lista), 0, -1):
			f = math.factorial(i - 1)
			indice = n // f
			n = n % f
			risultato.append(lista.pop(indice))

		return risultato


	carta_da_indovinare = carte_cliccate[-1]
	carte_scelte = carte_cliccate[:4]
	carte_scelte.sort(key=lambda x: mazzo_ordinato.index(x))
	print("carte scelte ordinate", carte_cliccate)
	print("carta da indovinare", carta_da_indovinare)
	
	mazzo = mazzo_ordinato
	
	for c in carte_scelte:
	    mazzo.remove(c)
	mazzo = mazzo[:24] + mazzo[24:][::-1]


	print("len mazzo",len(mazzo))
	
	indice_0based = mazzo.index(carta_da_indovinare) # da 0 a 47
	meta_del_mazzo = 0 # 0= prima meta' del mazzo, 1= seconda meta
	if(indice_0based>=24): # seconda meta' del mazzo
	    meta_del_mazzo = 1
	    indice_0based = 47 - indice_0based #valore partendo dalla fine del mazzo

	print("indice calcolato (base 0)",indice_0based)
	print("meta del mazzo",meta_del_mazzo)
	
	permutazione =  n_esima_permutazione(carte_scelte, indice_0based)

	print("permutazione",permutazione)

	

	carte_cliccate[0:4] = permutazione 	
	
	print("nuove carte cliccate", carte_cliccate)
	return meta_del_mazzo
    
if __name__ == "__main__":
    #run(app, host="localhost", port=8080, debug=True)
    run(app, host="0.0.0.0", port=8080, debug=True)
    


