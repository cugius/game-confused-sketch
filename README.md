# Confused Sketch

Un gioco di **Confused By Me**: difendi un disegno con la matita o conquista il foglio con un esercito di gomme.

## Gioco web

`dist/index.html` è la fonte unica, completamente offline e senza dipendenze runtime. Aprilo nel browser o servilo con `python3 -m http.server 4173 --directory dist`.

- Un dito ripara; due dita sul campo spostano/ingrandiscono la camera e sospendono la battaglia.
- Home e pannelli non consentono zoom della pagina; i pannelli scorrono in verticale.
- In Gomma: scegli tipo → tocca fascia esterna → conferma Schiera. Pagamento solo alla conferma.
- Salvataggi e diario restano sul dispositivo. Le vecchie chiavi `ultimo-tratto-*` sono mantenute per compatibilità.

## Verifiche

```sh
node tests/check.cjs
node tests/balance.cjs
python3 scripts/sync-ios.py
python3 scripts/check-ios.py
```

## iOS

Wrapper UIKit + WKWebView, iOS 16+, iPhone/iPad, portrait e landscape. Il gioco è incluso nel bundle e funziona senza rete. Pinch nativo della pagina disabilitato: lo zoom del campo resta gestito dal canvas.

La workflow **iOS Simulator** genera il progetto Xcode con XcodeGen e compila un `.app` per simulatore senza certificati. Scarica l’artefatto dalla scheda Actions. Non è un IPA installabile su iPhone.

Vedi [ios/README.md](ios/README.md) per firma e dispositivo/TestFlight. Nessun upload su TestFlight viene eseguito automaticamente.

## Struttura

- `dist/`: gioco e manifest web
- `tests/`: regressioni e simulazioni di bilanciamento
- `docs/`: regole e storico
- `ios/`: wrapper nativo e specifica XcodeGen
- `scripts/`: sincronizzazione e validazione bundle

Il nome è un nome di progetto; disponibilità commerciale/marchio da verificare prima della pubblicazione sugli store.
