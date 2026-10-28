# Confused Sketch

Gioco di **Confused By Me**. Il file da giocare e pubblicare è **[dist/index.html](dist/index.html)**: contiene codice, grafica, musica e font e funziona offline.

## Dove mettere le mani

| Cartella | A cosa serve | Necessaria |
|---|---|---|
| `dist/` | Gioco pronto e manifest web | Sì: sito e app |
| `ios/` | Wrapper Swift, icona, progetto XcodeGen e istruzioni TestFlight | Sì: iPhone/iPad |
| `assets/` | Originali di musica/font, traduzioni e definizioni Game Center | Sì: manutenzione e rigenerazione |
| `scripts/` | Tutti gli strumenti di sincronizzazione, generazione e pubblicazione | Sì: build e CI |
| `tests/` | Controlli del gameplay e simulazioni | Sì: regressioni |
| `docs/` | Regole, decisioni grafiche, licenze e pagina privacy | Documentazione; non inclusa nel gioco |
| `.github/workflows/` | Automazioni GitHub Actions | Sì: verifiche e build iOS |

Le vecchie cartelle `audio`, `fonts`, `i18n`, `gamecenter` sono ora raccolte in `assets/`. Gli strumenti di `tools/` sono in `scripts/`; la pagina in `site/` è in `docs/privacy/`. Nessuna risorsa è stata eliminata. Il branch `codex/paper-concept-25d` conserva l'esperimento sprite e resta separato da main.

## Provare il gioco

Aprire `dist/index.html` oppure eseguire `python3 -m http.server 4173 --directory dist`.
I salvataggi restano sul dispositivo. Home e pannelli non consentono zoom della pagina; la camera del campo ha i propri controlli touch.

## Verifiche e rigenerazione

```sh
node scripts/build-i18n.cjs --check
node scripts/embed-music.cjs --check
node tests/check.cjs
node tests/balance.cjs
python3 scripts/sync-ios.py
python3 scripts/check-ios.py
```

Per aggiornare le risorse: modificare gli originali in `assets/`, eseguire il relativo script senza `--check`, poi risincronizzare iOS. `scripts/gc-definitions.cjs` rigenera le definizioni Game Center e la relativa documentazione.

## iOS e TestFlight

**iOS Simulator** compila solo per il simulatore: il suo artefatto non si installa su iPhone.
**iOS TestFlight upload** verifica l'accesso all'app su Apple, compila, firma e invia ad App Store Connect. Vedi [istruzioni TestFlight](ios/TESTFLIGHT.md).

La prima build è stata compilata, ma l'export è fallito con `Error Downloading App Information`: non è stata caricata su Apple. Il preflight ora distingue chiave rifiutata, permessi insufficienti e scheda app mancante per `com.confusedbyme.confusedsketch`.

Non salvare credenziali, certificati o file P8 nel repository.
