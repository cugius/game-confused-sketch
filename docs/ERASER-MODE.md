# Modalità Gomma (da recuperare)

Dalla v0.46 la modalità **Gomma** («attacca tu», `gameMode==='erasers'`) non compare più nella home. **Il codice è ancora tutto nel gioco** (`startReverse`, `ALLIES`, `attackShop`, `updateReverse`, `reverseGuide`, `useReverseRage`…): è stato rimosso solo il pulsante.

Versione completa con la home originale: tag git **`eraser-mode-v0.45`** (commit `db26848`, branch `claude/webgl-fx`). Per tornare a quella versione: `git checkout eraser-mode-v0.45 -- dist/index.html` (poi rifare `node tools/build-i18n.cjs` e `python3 scripts/sync-ios.py`).

## Rimetterla nella home
In `intro()` aggiungere un pulsante nella barra `ibar`:
```js
<button class="ib" onclick="startGame('erasers')">${ICO.eraser}<b>Gomma</b></button>
```
(la barra ha ora 4 colonne: portare `grid-template-columns` a `repeat(5,1fr)`, oppure rimetterla nel menu Impostazioni → Gioco).

## Traguardo rimosso
`eraser1` «Dall’altra parte» (vinci una partita in modalità Gomma, 30 punti) è stato tolto da `ACH` perché non più ottenibile; per riattivarlo ripristinare la riga in `ACH` (gruppo 4):
```js
['eraser1',4,'Dall’altra parte','Vinci una partita in modalità Gomma.',1,()=>statGet('eraserWins'),30],
```
e rigenerare `gamecenter/definitions.json` con `node tools/gc-definitions.cjs`. Nel «Gommario» e nelle statistiche non cambia nulla.
