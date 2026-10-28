# Informativa privacy — Confused Sketch

`docs/privacy/confused-sketch.html` è l'unico testo canonico (sei lingue nella stessa pagina: it, en, es, fr, de, ja; selettore lingua, `?lang=xx` la imposta; senza parametro è in inglese (predefinito, indipendentemente dal browser). Il link in Crediti passa la lingua del gioco). Stessa struttura e stesso editore della pagina di Confused Droplet.

- URL previsto (da inserire in App Store Connect): https://confusedbyme.com/confused-sketch.html
- Va caricata nella cartella pubblica del sito (Hostinger) insieme a `confused-droplet.html` e `index.html` dello studio. **Da fare:** aggiungere Sketch all'elenco giochi in `index.html` dello studio.
- Il link «Privacy» in Crediti punta a quell'URL; il wrapper iOS (`GameViewController.swift`) lo apre nel browser di sistema, tutte le altre navigazioni esterne restano bloccate.
- `ios/ConfusedSketch/PrivacyInfo.xcprivacy` dichiara nessun dato raccolto e nessun tracciamento: coerente con l'informativa.

## Quando aggiornarla
A ogni cambiamento che tocchi i dati (acquisti in-app, analytics, pubblicità, nuovi permessi, servizi esterni). Oggi l'unico servizio esterno è Game Center, facoltativo. Rivedere anche le risposte «Privacy dell'app» in App Store Connect.

## Da verificare dal titolare
Testo redatto da Claude sulla base della pagina di Droplet e del comportamento del gioco: va riletto prima della pubblicazione.
