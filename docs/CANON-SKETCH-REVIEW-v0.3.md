# Confused Sketch — Confronto con il Canon v0.3

**Versione 0.3 · 29 ottobre 2026**
Documento separato da Confused-By-Me-Canon-v0.3.md. È un confronto documentale sullo snapshot già analizzato, arricchito con verifiche mirate di lingua e tutorial; non è una nuova review del main corrente né una certificazione della build installata. Non sono stati modificati codice, repository o TestFlight.

## 1. Ambito e metodo



Review statica del main al commit **bb9e064833064b4b8f8487cac4fb1a93566c8ab9**, non della build installata. Per l’audio sono stati aggiunti esperimenti isolati sul codice MUSIC estratto dall’HTML, con AudioContext simulato. Nessuna modifica al codice o rilascio effettuata.

## 2. Elementi già presenti nel codice

| Area | Evidenza osservata | Limite della verifica |
| --- | --- | --- |
| Home | Credits a sinistra, guida a destra, pulsanti da 46×46. | Da provare visivamente con titolo e safe area sui diversi iPhone. |
| Audio | Switch e volumi distinti, preferenze salvate, AudioContext condiviso. | La presenza dei controlli non garantisce che governino tutte le sorgenti. |
| Navigazione | panelHistory/backPanel e rientro da Lingua a Impostazioni. | Non è provata la conservazione dello scroll/scheda per ogni percorso. |
| Pausa | show() mette in pausa; blur/visibility salvano e puliscono contatti. | Sospensione audio completa insufficiente, vedi sotto. |
| Accessibilità | Testo +15%, contrasto alto, movimento ridotto, gestione del focus. | Necessaria verifica visiva; CSS usa zoom per ingrandire il pannello. |
| Input | pointerId, cancellazione contatti, lostpointercapture; blocco del pinch della pagina nel wrapper. | Necessaria prova multitouch reale e controllo che lo scroll dei pannelli resti disponibile. |
| Integrazioni | Bridge aptica, toggle Game Center e pulsante negli achievements. | Non prova funzionamento su device, sincronizzazione o asset pubblicati. |

## 3. Problemi e scostamenti verificati

**P1 — correggere prima di considerare affidabile il comportamento comune.**

1. **Jingle fuori dal canale Musica: problema riprodotto in test isolato.** MUSIC.jingle collega il gain direttamente alla destination, fissa il volume all’avvio e non conserva una sorgente cancellabile dalla regia. Spegnere Musica o mettere il volume a zero durante il jingle non ne cambia il gain e non lo ferma. Correzione: instradare nel bus Musica e gestire esplicitamente durata/annullamento del jingle. [S1:1410]
2. **Background senza sospensione audio centralizzata: lacuna verificata nel codice.** I listener mettono in pausa il gioco e spengono il rumore di gomma; il bus musicale controlla document.hidden tramite tick periodico. Non c’è una chiamata centralizzata immediata a suspend() per l’intero AudioContext. I jingle bypassano quel bus. Rischio: audio ancora attivo durante sospensione dei timer. L’effetto esatto richiede un iPhone. [S1:1329,1403–1412]
3. **Interruzioni iOS trattate tutte come ripresa: difetto verificato nel wrapper.** AVAudioSession.interruptionNotification invoca sempre resumeAudio(), senza leggere began/ended. Inoltre __audioResume arma soltanto il prossimo gesto: non tenta direttamente il recupero del contesto né della musica. Correzione: distinguere gli eventi e usare un’unica procedura di sospensione/ripresa coordinata con il web. [S2: observer delle notifiche e resumeAudio; S1:665]

**P2 — robustezza e coerenza da completare.**

4. **Rientro che ricrea la musica: problema strutturale riprodotto in test isolato.** focus, pageshow, visibility e sblocco chiamano revive(); revive scollega la voce corrente e ne crea una nuova dall’inizio. Le sorgenti precedenti non vengono fermate anticipatamente e attendono la fine già programmata. Eventi di rientro ravvicinati possono ricreare più voci e rendere percepibile il riavvio del brano. Correzione: resume idempotente; ricreazione solo se necessaria, con stop/cleanup delle vecchie sorgenti. [S1:662,664,1409]
5. **Sincronizzazione Game Center senza conferma al web o coda persistente dei tentativi nel bridge.** Gli errori sono registrati nei log; l’HTML riceve l’alias dopo login ma non l’esito di ogni report. Il reinvio dei progressi esiste, ma non equivale a un contratto affidabile di consegna; va verificato anche il cambio account. [S3; S1:312–321,1380]
6. **Automazione del catalogo Game Center incompleta rispetto al canon.** gc-sync.rb crea gli obiettivi mancanti e le loro localizzazioni; salta quelli esistenti, non carica immagini né crea classifiche e lo dichiara nell’ultima riga. Nell’albero di questo commit assets/gamecenter contiene definitions.json, senza badge. Questo non dimostra che manchino immagini su App Store Connect: occorre leggerne lo stato corrente separatamente. [S4]
7. **Capacità aptica sovrastimata nel web.** hapticAvailable restituisce true anche per la sola presenza di ontouchstart; viene tentato un fallback con checkbox switch nascosta. Non garantisce feedback degli eventi di gioco. Correzione: nel wrapper affidarsi al bridge, nel web descrivere/mostrare solo capacità verificate o indicare esplicitamente il limite. [S1:697–699]
8. **Ingressi del bridge meno verificati di Photon.** I bridge Sketch controllano la struttura di base del body ma non validano main frame e URL della pagina come fa GameWebController di Photon; gli ID Game Center non sono filtrati contro un catalogo. È un intervento di robustezza del wrapper, non evidenza di un attacco. [S3, S5]

**Da verificare, senza dichiararli bug:** overflow con Testo grande, tutti i percorsi di navigazione, copertura delle traduzioni e nomi accessibili, hit area dei controlli secondari, comportamento del Silenzioso, AirPods/Bluetooth, reset audio, memoria dopo rientri ripetuti, Game Center reale e aptica fisica.


## 4. Confronto con le integrazioni del Canon v0.3

“Presente” indica evidenza nel codice; “parziale” indica scostamenti specifici; “non verificato” non significa assente. Non sono stati eseguiti in questa revisione un audit completo del codice morto, una scansione di sicurezza, una certificazione delle traduzioni o un profiling su device.

| Requisito | Stato su Sketch | Evidenza / lavoro richiesto |
| --- | --- | --- |
| CODE-01–02: ricerca e rimozione codice morto prima della build | Non verificato | Non è stato prodotto un inventario di raggiungibilità né completata una pulizia. Gli handler HTML e i lookup dinamici richiedono controllo prima di cancellare candidati segnalati. |
| CODE-03–06: qualità e controllo pacchetto | Parzialmente osservato | Esiste tests/check.cjs e una CI di controlli nello snapshot; non è provato che coprano tutti i gate del nuovo canon. Vanno verificati lint/equivalente, error handling e assenza di hook/segreti nel pacchetto candidato. |
| MEM-01: budget | Non verificato | Non sono disponibili in questa review misure e soglie per heap/audio/GPU sui device supportati. |
| MEM-02 e MEM-04: cleanup e limiti | Parziale, problema audio verificato | revive() sostituisce la voce senza fermare anticipatamente le sorgenti precedenti. Non è una prova di perdita illimitata; è cleanup incompleto. Servono inventario cache, timer e listener e prove ripetute. |
| MEM-03 e MEM-05–06: ottimizzazione/profiling | Non verificato | Il codice mostra decoding su richiesta e cache audio; la sola presenza non certifica il budget complessivo, la memoria GPU o una sessione lunga. |
| SEC-01–08: audit sicurezza | Parziale, non certificato | Il bridge ha le lacune di validazione descritte nel punto 8. Restano da controllare flussi DOM, interpolazione JavaScript, navigazione, secret, CI e dipendenze. Nessuna vulnerabilità sfruttata è stata dimostrata. |
| I18N-01–04: tutte le traduzioni prima della build | Non verificato in modo completo | Catalogo e applicazione dinamica esistono per IT/EN/ES/FR/DE/JA. Non basta la presenza di sei colonne: servono copertura di tutti i testi, placeholder, tutorial, achievements, nomi accessibili e wrapper. |
| LO-04 SHOULD: default EN, poi lingua dispositivo | Parziale / scostamento verificato | LANG parte da 'it'; detectLang usa navigator.language oppure 'it' e in catch ritorna 'it'; una lingua non supportata dà invece 'en'. La scelta manuale salvata prevale già. Rendere EN anche stato iniziale, rilevamento assente/fallito e fallback dei testi. [S1:1,621–650] |
| TUT-01: tutorial presente e ripetibile | Presente nel codice | guide() offre startTutorial(); il tutorial interattivo usa il motore reale. Va confermata l’accessibilità da ogni percorso rilevante. [S1:729,1354–1370] |
| TUT-02 SHOULD: primo accesso, skip, progressione | Parzialmente presente | choosePaper() propone il tutorial quando manca meta.tutDone; tutShow() espone progressione e Salta. Non è stata provata l’effettiva proposta in tutti gli ingressi della home. [S1:1264,1367] |
| TUT-03: separazione da progressi e salvataggi | Parzialmente presente | Commento e codice prevedono modalità senza salvataggio/record e completamento distinto da skip. Servono test per preservare una partita già salvata ed escludere premi/score normali. [S1:1354,1366–1369] |
| TUT-04: traduzioni, accessibilità e interruzioni | Non verificato completamente | I testi del coach passano da tr(); ciò non prova completezza linguistica, leggibilità o ripresa corretta su device. |
| REPO-01 SHOULD: struttura | Parzialmente allineata | Ci sono assets/, docs/, ios/, scripts/, tests/, dist/ e workflow. Manca la separazione web/src/ nello snapshot; dist/index.html contiene anche la logica. Non va spostato senza chiarire il ruolo sorgente/output e aggiornare build/test. |
| REPO-02 SHOULD e REPO-03 MUST: toolchain e output | Da verificare | Esistono script di generazione/sincronizzazione. Serve una mappa completa: file autorevole → comando → output → verifica di coerenza. Non è necessario introdurre dipendenze Node solo per avere un package.json. |

### Integrazioni specifiche della versione 0.3

| Requisito | Stato sullo snapshot Sketch | Verifica necessaria |
| --- | --- | --- |
| GC-06: gamepad uniforme in alto a destra | Scostamento nel codice già letto | notebook() usa ICO.trophy per il pulsante gc-open. Sostituire con la geometria gamepad condivisa; non è stata applicata alcuna modifica. [S1:310] |
| GC-07: comportamento degli stati del gamepad | Parziale | Il pulsante è condizionato a GC.available(); invia showGameCenter ma il bridge torna senza aprire se disattivato/non autenticato. Serve un percorso comprensibile e coerente per questi stati. [S1:310–320; S3] |
| RESP-01–04: matrice schermi/device | Non verificato completamente | Il codice contiene regole responsive e safe area; questa review non ha eseguito la matrice di prove su viewport/simulatori/device fisici. Non attestare compatibilità universale. |
| UX-09 SHOULD: tab e accordion nelle impostazioni | Parzialmente osservato | settingsMenu() usa settingsTabs() e settingsSection(); ciò non prova il comportamento di accordion, l’accessibilità o la leggibilità su ogni schermo. Valutare gruppi di controlli frequenti e dettagli secondari; documentare eventuali eccezioni. [S1:751] |
| UX-10: stato e ritorni | Da verificare | La navigazione a cronologia è presente; verificare mantenimento della scheda, stato espanso, focus e scroll, inclusi cambio lingua e testo grande. |
| STR-01–05: canon/skill condivisi | Non configurato da questa attività | Sono stati aggiornati soltanto i documenti. Nessuna skill è stata installata e nessuna istruzione AGENTS.md/CLAUDE.md o CI del gioco è stata aggiornata. |

### Casi di prova aggiuntivi

1. Nuova installazione con lingua dispositivo EN, IT, JA e una non supportata; API di rilevamento assente o in errore: risultato atteso secondo LO-04, senza flash o fallback italiano involontario.
2. Scelta manuale FR salvata, riapertura con dispositivo IT: resta FR. Preferenza non valida: si torna alla lingua dispositivo supportata o EN.
3. Rimozione simulata di una traduzione richiesta: il gate deve fallire anche se il runtime mostra un fallback leggibile.
4. Tutorial: entrare, completare, saltare e ripetere; verificare che una partita salvata resti disponibile e che non cambino classifiche/record normali.
5. Build pulita da checkout: ricostruzione, analisi codice morto con verifica dei riferimenti dinamici e confronto dell’output; nessuna correzione manuale al bundle.
6. Misure a punti equivalenti dopo 10 riavvii e 10 rientri: sorgenti audio attive, timer, listener, heap e GPU entro budget documentati.

## 5. Priorità per l’applicazione a Sketch

1. Correggere i tre difetti audio P1 e rendere idempotente il recupero della musica.
2. Attivare il gate di qualità prima della build, includendo pulizia verificata, sicurezza, memoria e traduzioni; non dichiararlo passato finché mancano evidenze.
3. Allineare il default linguistico EN e completare la verifica del tutorial e dei salvataggi.
4. Rafforzare bridge e sincronizzazione Game Center, poi verificare catalogo e asset sul servizio.
5. Adottare gradualmente la struttura SHOULD del repo preservando il comportamento e la riproducibilità della build.

Queste sono attività proposte, non interventi già eseguiti. Il gate di distribuzione del Canon v0.3 resta **non attestato** per lo snapshot esaminato.

## 6. Fonti e limiti



Snapshot letti tramite i repository collegati:

- Photon main: `4a845fe2231d770f82ddaa40791c07d0dc70fa2d`. Letti docs/CANON.md, docs/TECHNICAL.md, docs/BRIDGE.md, template, CSS, game.js e wrapper iOS. Il canon storico contiene anche sezioni superate: per esempio la dichiarazione iniziale di aptica assente è seguita dalla sua implementazione.
- Droplet main: `f5e9531c72fa3ded41f58d53c693c6f717626ddc`. Letti web/src/index.html, wrapper iOS e changelog. Riferimenti: home 485–505; audioIdle/musicSync/winStop 3723–3749; audioPause/audioResume 3768–3785.
- Sketch main: `bb9e064833064b4b8f8487cac4fb1a93566c8ab9`. Le numerazioni sotto appartengono a questo snapshot.

Collegamenti di evidenza:

- [S1 — Sketch HTML](https://github.com/cugius/game-confused-sketch/blob/bb9e064833064b4b8f8487cac4fb1a93566c8ab9/dist/index.html)
- [S2 — Sketch GameViewController](https://github.com/cugius/game-confused-sketch/blob/bb9e064833064b4b8f8487cac4fb1a93566c8ab9/ios/ConfusedSketch/GameViewController.swift)
- [S3 — Sketch GameCenterBridge](https://github.com/cugius/game-confused-sketch/blob/bb9e064833064b4b8f8487cac4fb1a93566c8ab9/ios/ConfusedSketch/GameCenterBridge.swift)
- [S4 — Sketch gc-sync](https://github.com/cugius/game-confused-sketch/blob/bb9e064833064b4b8f8487cac4fb1a93566c8ab9/scripts/gc-sync.rb)
- [S5 — Photon GameWebController](https://github.com/cugius/game-confused-photon/blob/4a845fe2231d770f82ddaa40791c07d0dc70fa2d/ios/ConfusedPhoton/GameWebController.swift)
- [Photon canon](https://github.com/cugius/game-confused-photon/blob/4a845fe2231d770f82ddaa40791c07d0dc70fa2d/docs/CANON.md)
- [Droplet sorgente](https://github.com/cugius/game-confused-droplet/blob/f5e9531c72fa3ded41f58d53c693c6f717626ddc/web/src/index.html)
- [Apple — Handling audio interruptions](https://developer.apple.com/documentation/avfaudio/handling-audio-interruptions): distingue inizio e fine; usare l’API appropriata al deployment target e la politica di ripresa del gioco.
- [Apple — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons): riferimento per azioni riconoscibili e aree utili dei controlli.

Gli esperimenti audio usano mock, non un motore audio reale: verificano instradamento, gestione delle sorgenti e reazione del gain alle preferenze. Le conseguenze udibili e il comportamento di iOS restano da provare su dispositivo.
