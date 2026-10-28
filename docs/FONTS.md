# Alternative al font dell'interfaccia

Oggi (v0.47): **Patrick Hand** (SIL OFL 1.1, scelto dopo il confronto sotto; prima era Caveat), incorporato come sottoinsieme latino (`fonts/PatrickHand-latin.woff`) in `dist/index.html`.

Candidati provati (tutti OFL, da `github.com/google/fonts/ofl/`), con campioni in `docs/fonts-A-matita-rapidograph.png` e `docs/fonts-B-china-pennino.png`:

| Tipo | Font | Note |
|---|---|---|
| Matita | Patrick Hand, Gaegu, Handlee, Neucha | stampatello morbido, molto leggibile |
| Rapidograph / tecnico | Architects Daughter, Amatic SC, Shadows Into Light Two | linea uniforme da disegno tecnico |
| Penna a china | Reenie Beanie, Covered By Your Grace, Nanum Pen Script, Sedgwick Ave | tratto più nervoso, meno leggibile a corpo piccolo |
| Pennino | Pinyon Script, Italianno | solo titoli: illeggibili sui pulsanti |

Per cambiare: sostituire `fonts/PatrickHand-latin.woff` e il blocco `/*FONT-BEGIN*/…/*FONT-END*/`, la variabile `--hand`, il testo OFL in `OFL_TEXT` (pagina Crediti) e `THIRD-PARTY-NOTICES.txt`. Per l'italiano servono le lettere accentate (àèéìòù, maiuscole incluse).
