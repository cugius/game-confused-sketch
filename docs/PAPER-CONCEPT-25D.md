# Paper concept 2.5D — cinque passaggi

Branch: codex/paper-concept-25d. Base esatta: cc18660f2d94b3c9caa61be5b8c594db257d756a, branch claude/graphics-25d. Nessun merge su main e nessuna modifica della pubblicazione principale.

1. Difese: sostituzione delle basi a gradini con impronte geometriche e rilievi bassi di carta. Facce laterali con strati, pigmento fisso, punte di grafite. Spirale come nastro, laboratorio come quaderno con compasso.
2. Gomme: blocchi satinati con bevel e piccoli occhi, punta blu affusolata, gomma pane irregolare, fascia e stella TU, corona del boss disegnata, Squadra con apertura. Oscillazioni limitate rispettano riduzione movimento. Non sono mesh 3D.
3. Foglio: via plinti occupati e ombreggiatura ampia centrale. I cerchi tornano tratti di grafite; contatto delle figure segue la forma, senza ombre ellittiche. Proiezione verticale 0.84; conversione dei tocchi continua a usare TL.
4. Atelier: ?atelier mostra gli stessi renderer del gioco. Schede Difese/Gomme e tre livelli. Non esegue battaglia, non salva una partita di prova. Ingresso dalla home. Accenti di tiro sulle punte conservano il rinculo esistente.
5. Controllo: tutti i tipi e livelli, orientamenti dei nemici, coordinate 2.5D, salvataggi, poteri e gesto multitouch tramite test; controllo browser dell’atelier a 393×852 e desktop. Corretto il blocco input ereditato da sheet-open e resa continua della spirale. Eliminati i tre renderer sostituiti per evitare dichiarazioni duplicate.

## Motore

Resta Canvas2D. Obiettivo: stile artigianale, sagome forti e risorsa HTML offline senza nuove dipendenze. PlayCanvas offre WebGL2/WebGPU, PBR e luci, ma per sfruttarli occorrono geometrie/UV/materiali e una conversione del renderer. Non basta cambiare motore per ottenere la texture del concept. Qui pigmento e lati sono procedurali, non texture fotografiche né sprite estratti dalle immagini. La somiglianza è nella direzione artistica; il concept illustrato conserva maggior dettaglio e irregolarità.

Riferimenti: https://developer.playcanvas.com/user-manual/graphics/ e https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas

## Prova

Aprire dist/index.html oppure servire dist/ con HTTP. Dalla home aprire Atelier per confrontare figure e livelli. Per la partita mantenere Grafica → 2.5D; Classica resta disponibile. Non effettuato test su iPhone fisico o misurazioni prestazionali su hardware iOS. Il pilota sintetico mantiene campagna a 82% core e prima fortezza Gomma vinta a circa 24s.
