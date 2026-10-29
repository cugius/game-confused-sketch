---
name: confused-by-me-canon
description: Applica il canon di design e sviluppo ai giochi Confused By Me, inclusi Sketch, Photon e Droplet. Usare per sviluppo, modifiche UI, review, bug fix, audio e lifecycle iOS, multitouch, accessibilità, traduzioni, tutorial, Game Center, sicurezza, memoria, repository e preparazione build o rilascio. Non applicare a progetti estranei né trattare una verifica documentale come certificazione su device.
---

# Confused By Me Canon

## Scegliere la fonte

1. Leggere istruzioni del progetto (AGENTS.md, CLAUDE.md) e individuare repository, branch e commit attuali. Preservare cambi concorrenti, identità visiva, gameplay e salvataggi.
2. Leggere `docs/CANON.md` e le eccezioni autorizzate del gioco. La versione fissata nel progetto prevale sul riferimento incluso; dichiarare la differenza. Per nuovi progetti o in assenza di un canon locale usare [canon v0.3](references/canon.md), riportandone la versione.
3. Leggere sorgenti e workflow prima di cambiare file; distinguere sorgenti autorevoli e output generati. Non prendere vecchie review come descrizione del main corrente.

## Eseguire il lavoro

- Per una review, analizzare e riportare. Per una richiesta di fix, implementare e verificare i fix autorizzati; non fermarsi alla proposta.
- Applicare i MUST pertinenti. Applicare gli SHOULD oppure documentare la ragione dell’eccezione specifica. Non trasformare un limite dell’ambiente in un controllo passato.
- Verificare home/Credits/guida, navigazione, tab/accordion, gamepad uniforme negli achievements, tutorial ripetibile e isolato, accessibilità e matrice schermi.
- Trattare musica, effetti e aptica come canali indipendenti. Fermare tutti i suoni in background, inclusi jingle/code; rendere recupero e cleanup idempotenti. Tenere la partita in pausa al rientro.
- Usare EN come default e fallback secondo LO-04; rispettare scelta manuale e lingua supportata del dispositivo. Controllare tutte le lingue dichiarate, placeholder, testi dinamici e accessibilità.
- Validare bridge, URL e input, proteggere secret, conservare progressi locali offline; gestire errori e account Game Center senza fusione silenziosa.

## Verificare prima della distribuzione

1. Cercare codice/import/asset morti; verificare usi indiretti prima della rimozione. Conservare fallback e migrazioni necessari. Eseguire parsing/lint/controlli dei tipi adottati e test critici.
2. Verificare budget e cleanup di audio/GPU/memoria, cicli ripetuti e prestazioni. Misurare su device quando disponibile; distinguere misure reali da mock o analisi statica.
3. Controllare sicurezza, dipendenze/licenze, traduzioni complete, tutorial, layout e input; ricostruire gli output e controllarne la coerenza.
4. Eseguire solo le azioni di pubblicazione/distribuzione comprese nell’autorizzazione corrente; una richiesta di fix non implica avviare TestFlight o una revisione App Store.

## Consegnare evidenze

Produrre un rapporto proporzionato con versione canon, commit, file/linee, problema, correzione, verifiche e limiti. Classificare ogni controllo pertinente come passato, fallito, non verificato o non applicabile con motivo. Separare codice corretto, test automatici, prova fisica e stato del deploy. Non dichiarare completati misure device, upload Apple o test non eseguiti. Aggiornare documentazione e integrazioni nel perimetro richiesto senza cambiare il canon per far passare il codice.
