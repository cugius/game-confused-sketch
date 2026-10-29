# Confused By Me — Canon di design e sviluppo

**Versione 0.3 · 29 ottobre 2026**  
Ambito: giochi offline per mobile, versione web e wrapper iOS. Riferimenti: Confused Photon e Confused Droplet. Questo file contiene soltanto le regole comuni; il confronto con Sketch è nel documento separato Confused-Sketch-Confronto-Canon-v0.3.md. Non modifica i giochi e non certifica una build TestFlight.

## Indice

- 1. Principio comune
- 2. Home, Credits e navigazione
- 3. Audio: contratto unico
- 4. Touch, accessibilità e layout
- 5. Progressi, Game Center e bridge
- 6. Sviluppo e rilascio
- 7. Tutorial
- 8. Gate prima della build: codice morto e qualità
- 9. Memoria e prestazioni
- 10. Sicurezza e best practice del codice
- 11. Traduzioni: gate completo
- 12. Struttura consigliata del repository — SHOULD
- 13. Checklist prima del pacchetto candidato
- 14. Checklist funzionale comune
- 15. Cronologia e riferimenti
- 16. Riuso come skill tra assistenti — strategia consigliata

## 1. Principio comune

Ogni gioco mantiene la propria identità visiva e le proprie meccaniche. Posizione dei servizi, navigazione, impostazioni, audio, salvataggi e integrazioni native seguono regole comuni. Un comportamento entra nel canon se è comprensibile, verificabile e adatto alla famiglia di giochi; la sola presenza in Photon o Droplet non basta.

Le regole con MUST sono requisiti del canon proposto; SHOULD indica una preferenza con eccezioni motivate. Le eccezioni vanno documentate per gioco. Le integrazioni delle versioni 0.2 e 0.3 recepiscono la richiesta dell’autore del 29 ottobre 2026. Le altre regole mantengono il carattere di proposta operativa della versione 0.1.

## 2. Home, Credits e navigazione

| ID | Regola | Criterio di accettazione |
| --- | --- | --- |
| UX-01 | MUST: Credits/Informazioni in alto a sinistra nella home; aiuto rapido in alto a destra; titolo leggibile tra i due. | Entrambi raggiungibili senza scorrimento, rispettando safe area e testo ingrandito. Credits può restare anche nelle impostazioni. |
| UX-02 | MUST: il gioco e l’azione principale dominano la home. SHOULD: una CTA principale, o due modalità di pari importanza se il gioco lo richiede. | Anteprima visibile, azioni secondarie più discrete, nessun obbligo di leggere una pagina prima di giocare. |
| UX-03 | MUST: Indietro torna al pannello chiamante; Home torna alla home; Chiudi chiude il contesto corrente. | Da Impostazioni → Lingua → scelta si torna a Impostazioni conservando scheda e posizione, se praticabile. Nessuna navigazione riavvia una partita. |
| UX-04 | MUST: aprire un pannello durante una partita ferma simulazione e timer di gioco. | Nessun danno, costo, avanzamento o spawn mentre si leggono menu e guida. Le animazioni decorative possono continuare. |
| UX-05 | MUST: dopo un’interruzione esterna la partita resta in pausa fino a Riprendi. | Nessun salto temporale, dito rimasto premuto o attacco involontario. Il recupero dell’audio è indipendente dalla ripresa della simulazione. |
| UX-06 | MUST: durante il gioco niente scroll della pagina; nei pannelli lunghi un solo corpo scorrevole, comandi di navigazione raggiungibili. | Nessun testo o pulsante tagliato a 320–440 CSS px di larghezza e con ingrandimento interno. Le barre possono essere discrete senza eliminare lo scorrimento. |
| UX-07 | MUST: impostazioni organizzate in sezioni stabili: Gioco, Aspetto, Audio e accessibilità/lingua. | Stesse parole per la stessa funzione; assenza di opzioni duplicate o di termini tecnici inutili. “Particelle avanzate” invece di “WebGL”. |
| UX-08 | SHOULD: controlli touch con area utile almeno 44×44; simboli coerenti e nome accessibile. | Stato premuto, selezionato e disabilitato distinguibili. La dimensione dell’icona può essere inferiore all’area toccabile. |
| UX-09 | SHOULD: nelle impostazioni usare tab per le sezioni principali e accordion per dettagli, spiegazioni e opzioni secondarie; mantenere i controlli frequenti subito visibili. | Eccezioni ammesse per esigenze specifiche del gioco, poche opzioni che non giustificano tab o vincoli di spazio/accessibilità: documentarne il motivo. Evitare pannelli affollati e accordion annidati. |
| UX-10 | MUST: tab e accordion conservano un comportamento coerente e accessibile. | Scheda attiva e stato aperto/chiuso riconoscibili; ruoli/stati semantici, focus e tastiera appropriati. Indietro da un sotto-menu conserva scheda e contesto; niente intestazioni tagliate con testo grande. |


**Derivazione:** Droplet separa Credits e guida ai lati della home. Photon usa un pulsante Informazioni in alto a sinistra con guida, crediti e privacy nello stesso pannello: è una variante osservata, non una corrispondenza perfetta al layout proposto. La conformità di ogni gioco viene documentata nel suo confronto separato.

## 3. Audio: contratto unico

| Stato/evento | Comportamento richiesto |
| --- | --- |
| Primo accesso | Avviare l’audio quando consentito dalla piattaforma; se necessario sbloccarlo con il primo gesto valido. Nessun errore blocca il gioco. |
| Home e partita | Una regia sceglie la musica in base al contesto; transizioni brevi e controllate. Evitare cambi continui per eventi ravvicinati. |
| Pausa interna e menu di partita | Musica attenuata; rumori continui della simulazione e suoni di combattimento fermi. Eventuale feedback UI breve. |
| Background, blocco schermo, interruzione iniziata | Silenzio immediato su musica, jingle, effetti, riverbero e rumori continui; fermare scheduler e input. Non attendere il prossimo frame grafico. |
| Ritorno in primo piano/interruzione terminata | Riattivare la sessione e il contesto quando consentito e secondo le preferenze. Ripristinare la traccia corretta una sola volta. Se serve un gesto, usare il successivo tocco valido. Partita ancora in pausa. |
| Musica OFF | Silenziare anche jingle di vittoria/sconfitta e code di riverbero; effetti indipendenti. Nessun brano già decodificato può avviarsi in ritardo. |
| Effetti OFF | Silenziare anche loop di gomma, vento e altri suoni continui; musica indipendente. |
| Volume a zero | Silenzio del relativo canale anche se un suono è già in esecuzione. |
| Cambio pannello o nuova partita | Cancellare jingle e timer appartenenti al contesto precedente. |

- **AU-01 MUST:** interruttori e volumi separati per Musica ed Effetti, persistenti. Aptica indipendente dall’audio.
- **AU-02 MUST:** una sola regia audio con stato esplicito: attivo, sospeso, in attesa di gesto. Ricevere due volte lo stesso evento non crea due tracce né riavvia quella corretta.
- **AU-03 MUST:** tutto il contenuto musicale, inclusi jingle, passa dal bus Musica; tutti gli effetti dal bus Effetti. Il controllo di background vale per entrambi.
- **AU-04 MUST:** conservare riferimenti a sorgenti, timer e dissolvenze; fermare e scollegare le sorgenti sostituite. Il semplice disconnect non sostituisce la gestione della loro durata.
- **AU-05 MUST:** dopo operazioni asincrone di caricamento/decodifica ricontrollare preferenze, visibilità e validità del contesto prima di riprodurre.
- **AU-06 MUST:** il wrapper distingue inizio e fine delle interruzioni AVAudioSession. Gestire anche ritorno in primo piano, cambi di uscita e reset dei servizi audio con una politica documentata.
- **AU-07 SHOULD:** riprendere la posizione dei loop; far ripartire solo i jingle legati a un nuovo evento valido. Normalizzare i brani per evitare salti di volume.
- **AU-08 MUST:** documentare la politica del tasto Silenzioso e della musica di altre app. Non scegliere playback/mixWithOthers solo per aggirare un problema di sblocco. La scelta comune resta da ratificare: il requisito certo è il rispetto degli interruttori in gioco e del background.

Photon offre un riferimento per selezione musicale, ripresa della posizione, attenuazione e limiti di memoria. Droplet offre un riferimento per audioPause/audioResume e per fermare il jingle quando si lascia il risultato. Queste parti vanno adattate a un unico contratto, evitando la somma di listener scollegati.

## 4. Touch, accessibilità e layout

- **IN-01 MUST:** tracciare ogni contatto con pointerId; consentire le combinazioni simultanee previste dal gioco. Gestire pointercancel, lostpointercapture, blur e background ripulendo lo stato.
- **IN-02 MUST:** impedire zoom involontario, selezione e lente sul campo di gioco. Conservare gli eventuali gesti intenzionali di zoom della camera del gioco; distinguere camera e zoom della pagina.
- **IN-03 MUST:** non bloccare indiscriminatamente tutte le gesture nei pannelli; scorrimento e controlli accessibili devono funzionare. La lettura dei testi deve restare possibile tramite una soluzione di ingrandimento affidabile.
- **AC-01 MUST:** testo ingrandito e movimento ridotto verificati sul layout reale, senza sovrapposizioni. L’opzione riduce anche shake e particelle non essenziali, senza cancellare avvisi utili.
- **AC-02 MUST:** le informazioni essenziali non dipendono soltanto da colore, suono o vibrazione. Controlli con etichette tradotte, stato semantico e focus gestito nei pannelli.
- **AC-03 MUST:** mostrare l’aptica secondo capacità effettiva; nel wrapper usare il bridge nativo, con eventi brevi e frequenza limitata. Il solo supporto al touch non prova il supporto aptico.
- **LO-01 MUST:** gestire safe area su tutti i lati, altezze ridotte e orientamenti dichiarati dal singolo gioco. Non imporre landscape a un’app portrait.
- **LO-02 MUST:** ogni lingua dichiarata copre menu, tutorial, testi dinamici, achievements e nomi accessibili. La completezza viene controllata prima di ogni build di distribuzione secondo I18N-01–04.
- **LO-04 SHOULD:** nei giochi multilingue la lingua base e il default sono inglese (EN); poi si applica la lingua del dispositivo se supportata. Una scelta manuale già salvata prevale sull’automatismo. Ordine effettivo: scelta manuale valida → lingua del dispositivo supportata → inglese. Se il rilevamento fallisce si rimane in inglese; nessun fallback accidentale all’italiano. SHOULD non autorizza traduzioni mancanti nelle lingue dichiarate.
- **LO-03 MUST:** le lingue sono definite per progetto: Photon/Droplet hanno PT, Sketch ha JA. Non sostituire una lingua per uniformare soltanto il conteggio.

### Verifica su schermi e dispositivi diversi

- **RESP-01 MUST:** prima della build di distribuzione eseguire una matrice di prove su schermi supportati piccoli, medi e grandi; verificare viewport CSS, densità pixel, safe area, altezze effettive e orientamenti dichiarati. Provare home, impostazioni, achievements, tutorial, partita, pausa e risultato; includere le lingue più lunghe e il testo ingrandito.
- **RESP-02 MUST:** nessun elemento essenziale nascosto da notch/Dynamic Island/home indicator, niente scroll orizzontale involontario o comandi sovrapposti; il campo resta usabile e i pannelli lunghi scorrono internamente con navigazione raggiungibile.
- **RESP-03 MUST:** registrare modello/viewport, sistema e browser o wrapper, orientamento, scala del testo, schermata ed esito. Usare viewport automatici/simulatori per la copertura, più dispositivi fisici rappresentativi per confermare resa, safe area e touch. Un semplice ridimensionamento desktop non certifica tutti i device. Le prove fisiche mancanti restano non verificate.
- **RESP-04 SHOULD:** automatizzare screenshot e controlli di overflow con viewport rappresentativi. Aggiornare la matrice quando cambiano dispositivi supportati, layout, font o sistemi operativi.

| Classe di schermo | Esempi iniziali di viewport, in CSS px | Copertura minima |
| --- | --- | --- |
| Compatto | 320×568 e/o 375×667, se supportati | Titolo, CTA, pannelli, tutorial e area di gioco anche con testo grande. |
| Medio | 390×844 o 393×852 | Percorsi completi, safe area, achievements e impostazioni. |
| Grande | 430×932 o 440×956 | Distribuzione dello spazio, allineamenti e comandi raggiungibili. |
| Tablet | Viewport rappresentativi dei tablet dichiarati | Solo se supportati; layout dedicato o adattato verificato. |
| Landscape | Viewport ruotati delle classi applicabili | Solo se supportato; in alternativa rispettare il blocco di orientamento dichiarato. |

Le misure sono casi di prova iniziali, non un elenco universale dei modelli né una promessa di supporto. Scegliere e aggiornare i device reali dalla matrice di compatibilità del progetto.

## 5. Progressi, Game Center e bridge

- **GC-01 MUST:** il gioco completo funziona offline e senza autenticazione. Game Center è un servizio opzionale con stato comprensibile: non disponibile, disattivato, accesso in corso, connesso, errore.
- **GC-02 MUST:** interruttore e pulsante negli achievements con comportamento coerente. Attivare o disattivare governa i nuovi invii del gioco; non implica uscita dall’account Apple.
- **GC-06 MUST:** uniformare l’accesso al servizio di gioco negli achievements con la stessa icona di **gamepad**, in alto a destra nell’intestazione, allineata al titolo e con area utile almeno 44×44. Riutilizzare la stessa geometria vettoriale e proporzioni in tutti i giochi; possono adattarsi colore e contenitore al tema. Il trofeo resta il simbolo degli obiettivi locali, non sostituisce il gamepad per aprire il servizio. Riferimento iniziale: gamepad di Droplet; conservarne una versione condivisa identificabile. È un pulsante del servizio, non un’indicazione che il gioco supporta controller fisici.
- **GC-07 MUST:** il gamepad apre il pannello nativo del servizio quando connesso. Se disponibile ma disattivato, guida all’attivazione; se non autenticato, avvia il percorso di accesso consentito o spiega lo stato. Durante accesso o invio impedisce presentazioni duplicate. Se il servizio non è disponibile, non mostrare un pulsante apparentemente funzionante. Nome accessibile tradotto e specifico, per esempio “Apri Game Center”; l’icona da sola non sostituisce lo stato e non attiva silenziosamente il servizio.
- **GC-03 MUST:** conservare progressi locali e ritentare gli invii falliti con conferma dell’esito e deduplicazione. Non confondere messaggio inviato al bridge e progresso accettato da Game Center.
- **GC-04 MUST:** proteggere la riconciliazione quando cambia account; nessuna fusione automatica dei progressi di persone diverse. Identificativi stabili, catalogo validato e valori numerici ammessi.
- **GC-05 MUST:** il catalogo verifica obiettivi, punti, traduzioni, immagini e classifiche; lo stato completo del deploy va letto dal servizio. Presenza di un PNG nel repository e successo del caricamento non sono equivalenti.
- **BR-01 MUST:** bridge con contratto versionato, validazione di mittente/main frame/pagina, tipo e dimensione dei payload; feedback native confinati alle capacità dichiarate.
- **SV-01 MUST:** preferenze e salvataggi versionati, validati e migrabili. Salvataggio all’uscita e nei checkpoint significativi, errori di storage gestiti. Cancellazione dati distinta da disconnessione Game Center.

## 6. Sviluppo e rilascio

- **DEV-01 MUST:** una fonte autorevole per ogni elemento; dichiarare se l’HTML è sorgente o output. Ricostruire web e wrapper tramite script, senza correggere separatamente copie generate.
- **DEV-02 SHOULD:** sorgenti separati per logica, stile, audio, lingue e integrazioni, mantenendo se utile l’esportazione HTML unica offline. I tre progetti hanno strutture diverse: la separazione è una proposta, non un fatto comune.
- **DEV-03 MUST:** logica della simulazione separata da render e UI. Clock di gioco, UI e audio espliciti; nessun recupero di minuti trascorsi in background in un singolo frame.
- **DEV-04 MUST:** obiettivo di fluidità verificato su device rappresentativi; qualità grafica scalabile, limiti a particelle, sorgenti audio e risorse decodificate. Evitare allocazioni e decodifiche ripetute nei percorsi frequenti.
- **DEV-05 MUST:** asset e font disponibili offline; dipendenze e licenze inventariate; Credits corrispondenti alle risorse davvero distribuite. La preferenza per codice MIT non elimina gli obblighi di licenze diverse per font e asset già approvati.
- **REL-01 MUST:** ogni review indica branch, commit e ambiente verificato. Un controllo di codice non certifica la build installata; un mock non certifica l’audio su iPhone.
- **REL-02 MUST:** test automatici sui comportamenti critici, prova visiva dei layout e prova fisica per audio, aptica e multitouch prima del rilascio.
- **REL-03 MUST:** build riproducibile con versione, Bundle ID, icona, entitlements e risorse coerenti. Dichiarare separatamente: commit pronto, CI passata, upload riuscito, elaborazione terminata, build disponibile ai tester.
- **REL-04 MUST:** aggiornare il canon con versione, decisione, motivo ed eventuali eccezioni. Le review future devono valutare tutte le regole applicabili e motivare i casi non applicabili.


## 7. Tutorial

- **TUT-01 MUST:** prevedere un tutorial che insegni i comandi e le meccaniche essenziali. Deve essere raggiungibile dalla guida o dalla home e ripetibile; la sola descrizione delle regole non sostituisce la verifica pratica dei comandi.
- **TUT-02 SHOULD:** tutorial breve, interattivo, progressivo e proposto al primo accesso, con possibilità di saltarlo. Mostrare un’azione alla volta, usando i controlli reali e situazioni leggibili; evitare un blocco obbligatorio di testo.
- **TUT-03 MUST:** isolare il tutorial da record, classifiche, sfide e risorse della partita normale; eventuali obiettivi dedicati al tutorial devono essere espliciti. Distinguere completamento e salto, conservare il flag e non cancellare una partita salvata quando si entra o si esce.
- **TUT-04 MUST:** tutorial tradotto in tutte le lingue dichiarate, leggibile con testo grande e utilizzabile con le opzioni di accessibilità; dopo interruzione o riapertura non deve lasciare input o timer incoerenti. SHOULD: introdurre in contesto le meccaniche avanzate delle altre modalità.

## 8. Gate prima della build: codice morto e qualità

Per “prima della build” si intende prima di produrre il pacchetto candidato alla distribuzione/TestFlight. Compilazioni e build diagnostiche restano consentite per analizzare problemi. I controlli automatici girano anche nelle PR, ma il gate viene rivalutato sul commit esatto da distribuire.

| ID | Livello e controllo | Evidenza richiesta |
| --- | --- | --- |
| CODE-01 | MUST: cercare e rimuovere codice morto prima della build: funzioni e import inutilizzati, rami irraggiungibili, implementazioni superate, flag di prova, listener duplicati e asset non referenziati. | Rapporto di analisi e diff della pulizia; test dei flussi coinvolti. Un risultato dell’analizzatore è un candidato, non un’autorizzazione a cancellare. |
| CODE-02 | MUST: prima della rimozione verificare gli usi indiretti: handler HTML, nomi di eventi, callback native, reflection, selettori CSS, template, cataloghi e lookup costruiti a runtime. | Ogni candidato rimosso ha una verifica di raggiungibilità; esclusioni e falsi positivi hanno motivo, proprietario e revisione. Non cancellare fallback o migrazioni ancora necessari. |
| CODE-03 | MUST: eseguire parsing/compilazione, lint o equivalente, controlli dei tipi dove adottati e test significativi; non aggiungere errori o avvisi critici. | Output sul commit candidato, strumenti e versioni riproducibili. Gli avvisi esistenti ammessi vanno registrati, non nascosti da esclusioni generiche. |
| CODE-04 | MUST: verificare error handling, validazione degli input, numeri finiti e limiti, promesse rifiutate, cleanup e concorrenza asincrona. | Nessuna eccezione non gestita nei percorsi provati; errori non silenziati senza un fallback deliberato. |
| CODE-05 | SHOULD: moduli con responsabilità chiare, nomi espliciti, configurazioni centralizzate, duplicazioni ridotte e formattazione uniforme. | Review del codice; eccezioni motivate quando una rifattorizzazione comporterebbe rischi superiori al beneficio. |
| CODE-06 | MUST: escludere dalla release hook di debug, cheat, log sensibili, strumenti di sviluppo e credenziali. | Ispezione anche del bundle finale, non soltanto dei sorgenti; nessuna modifica al comportamento di gioco introdotta dalla pulizia. |

La rimozione del codice morto è obbligatoria per i candidati confermati e rimovibili in sicurezza. Una lista vuota non prova da sola la qualità: va dichiarata la copertura dell’analisi, soprattutto in un HTML con handler e lookup dinamici.

## 9. Memoria e prestazioni

| ID | Regola | Verifica prima della build |
| --- | --- | --- |
| MEM-01 | MUST: definire budget per heap, buffer audio decodificati, texture/GPU, particelle, entità, listener e timer in base ai device supportati. | Registrare device, scenario, unità, soglia e motivo. Non imporre un unico numero a giochi diversi. |
| MEM-02 | MUST: rilasciare risorse quando si cambia scena, si riavvia o si distrugge una vista. | Stop/disconnect delle sorgenti; annullamento timer e rAF non più necessari; rimozione listener/observer; rilascio texture, buffer GPU, URL temporanei e riferimenti native/web. |
| MEM-03 | SHOULD: caricamento e decodifica su richiesta, cache con limite ed espulsione, riuso di buffer/oggetti nei percorsi frequenti, densità pixel e qualità grafica adattate. | Confronto prima/dopo. Il pooling viene usato se utile e misurato: un pool illimitato è a sua volta una perdita di memoria. |
| MEM-04 | MUST: evitare crescita senza limite di cronologie, code, particelle, buffer e riferimenti a DOM scollegato; deduplicare richieste e decoding concorrenti. | Almeno 10 cicli di partita/menu/riavvio e 10 rientri dal background; confrontare punti equivalenti dopo stabilizzazione. Nessuna crescita persistente non spiegata; le cache devono raggiungere un limite documentato. |
| MEM-05 | MUST: misurare frame time, picchi e memoria nello scenario più oneroso; includere una sessione prolungata rappresentativa. | Profilo su dispositivo fisico o ambiente equivalente dichiarato. Un mock non certifica memoria GPU/native. Se la misura non è possibile, la verifica resta aperta. |
| MEM-06 | MUST: ridurre il lavoro in background e gestire perdita/ripristino del contesto grafico quando applicabile. | Niente simulazione o scheduler audio residui; al recupero risorse coerenti senza duplicazione o loop di crash. |

Gli interventi devono produrre un beneficio misurabile o rimuovere una crescita chiaramente dimostrata. Non sacrificare correttezza, accessibilità o qualità leggibile per ottimizzazioni speculative.

## 10. Sicurezza e best practice del codice

- **SEC-01 MUST:** prima della build fare una review delle superfici del progetto: input, salvataggi importabili, URL, DOM, bridge, dipendenze, pipeline e pacchetto. Registrare risultati e mitigazioni anche per giochi offline.
- **SEC-02 MUST:** nessun secret in repository, HTML, asset, log, artifact o bundle. Credenziali di firma e accesso solo nei sistemi previsti; privilegi CI minimi e niente output di token. Se un secret è esposto, rimuoverlo dal codice non basta: va revocato/ruotato.
- **SEC-03 MUST:** validare schema, tipo, dimensione e limiti dei dati esterni e dei messaggi native; verificare frame/origine/pagina autorizzata e ID ammessi. Costruire gli argomenti JavaScript con serializzazione sicura, non concatenazione di valori non fidati.
- **SEC-04 MUST:** evitare inserimenti DOM non sicuri; testo non fidato tramite API sicure o escaping/sanitizzazione appropriati. innerHTML non è vietato per template fidati, ma non deve ricevere contenuti non validati. Niente esecuzione dinamica non necessaria di input.
- **SEC-05 MUST:** limitare navigazione, apertura link, accesso ai file e capacità del wrapper alle esigenze reali; prevedere una policy dei contenuti appropriata quando applicabile. Non disabilitare protezioni di piattaforma per aggirare errori.
- **SEC-06 MUST:** inventariare dipendenze dirette/transitive, versioni, provenienza e licenze; controllare vulnerabilità applicabili e aggiornamenti necessari. SHOULD: lockfile ove previsto, versioni/toolchain riproducibili e azioni CI fissate a riferimenti immutabili.
- **SEC-07 MUST:** assenza di vulnerabilità critiche/alte applicabili e irrisolte nel candidato. Un falso positivo o una non applicabilità richiedono prova e motivazione; gli altri rischi residui hanno priorità e responsabile. Un tool senza risultati non equivale a una certificazione di sicurezza.
- **SEC-08 MUST:** permessi e comunicazioni di rete minimi, privacy e Credits coerenti con il software effettivamente distribuito; nessun endpoint o telemetria introdotto accidentalmente. Per questa famiglia resta il vincolo di nessun backend dello sviluppatore.

## 11. Traduzioni: gate completo

| ID | Regola | Esito richiesto |
| --- | --- | --- |
| I18N-01 | MUST: inventario delle stringhe per tutte le lingue dichiarate, con EN come base secondo LO-04. Comprende menu, tutorial, achievements, errori, conferme, testi dinamici, accessibilità e testi del wrapper. | Nessuna chiave richiesta mancante o traduzione vuota. Le stringhe volutamente non traducibili, come marchi e licenze, sono elencate. |
| I18N-02 | MUST: validare placeholder, plurali, parametri, caratteri e composizione delle frasi. | Stessi parametri attesi, niente token visibili o pezzi di frase nella lingua sbagliata. Il fallback EN evita il crash ma non rende completa una localizzazione. |
| I18N-03 | MUST: verificare i percorsi dinamici e i testi visualizzati oltre ai cataloghi statici. | Controllo automatico di copertura più smoke test nelle lingue dichiarate, inclusi tutorial e achievements; nessuna stringa mancante nascosta dal fallback. |
| I18N-04 | MUST: controllare layout e coerenza dei cataloghi tra gioco e integrazioni pubblicate. | Niente tagli con lingue lunghe/testo grande; font con glifi richiesti; obiettivi e descrizioni Game Center coerenti. Non confondere invio al servizio con verifica dell’esito. |

## 12. Struttura consigliata del repository — SHOULD

È un modello logico adattabile alle tecnologie: i nomi delle directory sono consigliati, la responsabilità di ciascuna deve essere chiara. Non richiede di spostare tutto prima di una correzione urgente.

| Percorso consigliato | Responsabilità |
| --- | --- |
| README.md | Avvio, comandi di build/test, toolchain, piattaforme, fonte autorevole e artifact generati. |
| AGENTS.md | Istruzioni operative per chi modifica il progetto, regole del canon e controlli richiesti. |
| docs/CANON.md | Canon applicabile o riferimento a una versione precisa del canon comune; eccezioni del gioco. |
| docs/ | Gameplay, architettura, bridge, decisioni, changelog, rilascio, privacy e rapporti di verifica. |
| web/src/ | Logica, UI, stile, servizi audio/input/persistenza e template separati quando utile. |
| assets/ | Audio, font, immagini e cataloghi autorevoli i18n/Game Center; licenze e provenienza. |
| ios/ e android/ | Wrapper nativi, configurazioni e integrazioni; risorse generate chiaramente marcate. |
| scripts/ | Build, sincronizzazione, validazione, migrazioni e preparazione asset ripetibili. |
| tests/ | Test unitari/integrati e smoke test; scenari per audio, lifecycle, touch e traduzioni. |
| .github/workflows/ | CI di qualità, build e distribuzione con responsabilità distinte. |
| dist/ | Output generati; mai una seconda fonte modificata manualmente se esiste già un sorgente autorevole. |
| THIRD-PARTY-NOTICES.txt e file di licenza | Attribuzioni reali; nessuna licenza globale inventata per contenuti con diritti diversi. |

- **REPO-01 SHOULD:** adottare questa separazione o un equivalente documentato; un singolo HTML distribuibile può restare il risultato della build.
- **REPO-02 SHOULD:** dichiarare dipendenze, versioni degli strumenti e comandi in un manifest/lockfile appropriato alla tecnologia; evitare comandi nascosti o passaggi manuali non riproducibili.
- **REPO-03 MUST:** ogni file generato ha una provenienza e un comando di ricostruzione; eliminare sorgenti concorrenti e copie obsolete dopo averne verificato gli usi.

## 13. Checklist prima del pacchetto candidato

| Gate | Condizione di passaggio |
| --- | --- |
| Pulizia | Codice morto individuato, verificato e rimosso; eccezioni documentate. |
| Qualità | Parsing/compilazione, lint o equivalente, controlli dei tipi adottati e test critici passati. |
| Memoria | Budget e profili registrati, cicli ripetuti senza crescita incontrollata, risorse ripulite. |
| Sicurezza | Review completata, secret assenti, vulnerabilità applicabili valutate e bloccanti risolte. |
| Lingue | Tutte le traduzioni richieste, placeholder e percorsi dinamici validati; fallback EN e priorità della lingua provati. |
| UX e tutorial | Tutorial presente e ripetibile; matrice schermi/device RESP-01–04 compilata, navigazione, testo grande e flussi essenziali verificati. |
| Audio e input | Mute completo, interruzioni, recupero, multitouch e cancellazione gesti verificati. |
| Integrità | Sorgenti e output coerenti, ricostruzione riuscita, licenze e cataloghi allineati. |
| Tracciabilità | Rapporto con commit esatto, strumenti, device, esiti e limitazioni; ogni controllo classificato passato, fallito o non verificato. |

Un MUST applicabile fallito blocca la distribuzione del candidato; un MUST non verificato non può essere segnato passato. Una regola realmente non applicabile richiede una motivazione, non una spunta automatica. Dopo le correzioni si ripetono i controlli interessati e il gate finale. Il rilascio non cambia autonomamente il livello delle regole.

## 14. Checklist funzionale comune



| Prova | Esito richiesto |
| --- | --- |
| Quattro combinazioni Musica/Effetti ON/OFF | Canali sempre indipendenti; aptica indipendente. |
| Musica OFF e volume zero durante vittoria/sconfitta | Anche il jingle in corso tace. |
| Jingle: uscita dal risultato, nuova partita, background | Nessuna coda appartenente al contesto precedente. |
| Dieci cicli app switch/blocco schermo/ritorno | Silenzio in background; al rientro nessun brano duplicato e partita in pausa. |
| Chiamata/Siri, interruzione senza ended, uscita/rientro | Gestione del tipo di interruzione, recupero senza forzare riproduzione durante l’interruzione. |
| Cuffie collegate/scollegate e Bluetooth | Politica coerente, nessun errore o volume inatteso. |
| Due dita, pressione prolungata, cancellazione gesto | Azioni previste simultanee, nessuna lente o input bloccato; camera interna controllabile. |
| Impostazioni → Lingua → cambio → Indietro | Rientro nel contesto corretto, partita preservata. |
| Tutte le lingue, testo grande e altezze ridotte | CTA e navigazione sempre raggiungibili, nessuno scroll orizzontale involontario. |
| Gamepad negli achievements | Geometria condivisa, posizione in alto a destra, nome accessibile e stati operativo/disattivo/non disponibile coerenti. |
| Impostazioni con tab e accordion | Struttura SHOULD applicata o eccezione motivata; apertura/ritorno mantengono scheda e contesto. |
| Connessione assente, login rifiutato, GC OFF/ON | Gioco locale completo; reinvio coerente quando permesso, stato comprensibile. |
| Cambio account Game Center | Nessuna fusione silenziosa; strategia esplicita di riconciliazione. |
| Nuova installazione e aggiornamento da versione precedente | Preferenze valide, progressi preservati, tutorial e record coerenti. |
| Apertura offline della build iOS | Nessun font/audio dipendente dalla rete; privacy aperta nel browser di sistema. |


## 15. Cronologia e riferimenti

- v0.1: regole iniziali e prima review ricavate da Photon/Droplet e dal codice Sketch.
- v0.2: separazione tra canon e confronto; gate espliciti per codice morto, memoria, sicurezza/qualità e traduzioni; default EN SHOULD con precedenza della scelta manuale, tutorial obbligatorio e struttura repo SHOULD.
- v0.3: icona gamepad uniforme negli achievements, stati del pulsante, matrice schermi/device esplicita e tab/accordion SHOULD per le impostazioni; strategia di riuso del canon.
- La review di un gioco deve indicare la versione del canon applicata e il commit analizzato. Questo documento non dichiara conformi i giochi esistenti.
- [Apple — Handling audio interruptions](https://developer.apple.com/documentation/avfaudio/handling-audio-interruptions)
- [Apple — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)

## 16. Riuso come skill tra assistenti — strategia consigliata

Il canon è la norma; la skill è la procedura per applicarla. Mantenere il testo completo versionato in una fonte comune e un SKILL.md breve che definisca quando usarlo, cosa leggere, come verificare e come rendicontare. Non mantenere una riscrittura indipendente per ciascun assistente.

**STR-01 SHOULD:** avere un repository comune per canon, risorse condivise come il gamepad e procedura della skill. Ogni repository di gioco include una copia sincronizzata a una versione/commit preciso del canon o un meccanismo equivalente disponibile anche quando la rete non funziona. Registrare versione e provenienza; gli aggiornamenti arrivano con modifiche esplicite e review, non tramite lettura automatica di un main remoto mutevole.

**STR-02 SHOULD:** conservare nel gioco istruzioni brevi per i diversi assistenti: AGENTS.md per Codex e CLAUDE.md per Claude Code, entrambi riferiti allo stesso canon locale. Questi file indicano anche comandi, sorgenti autorevoli ed eccezioni specifiche del gioco. Non duplicare il canon completo nei due file.

**STR-03 SHOULD:** rendere il medesimo contenuto disponibile come skill personale nelle applicazioni usate. SKILL.md contiene nome/descrizione, lettura del canon e delle eccezioni, identificazione del commit, controlli applicabili, esecuzione delle verifiche e rapporto con evidenze. Il report distingue passato, fallito, non verificato e non applicabile. L’installazione in ChatGPT e in Claude è separata: un file in un repository non configura automaticamente tutte le app.

**STR-04 MUST:** una skill non dichiara riusciti controlli impossibili nell’ambiente corrente. I controlli ripetibili vanno implementati anche in CI: istruzioni e skill aiutano l’agente, ma non sostituiscono gli esiti dei test o la verifica sul dispositivo.

**STR-05 SHOULD:** quando il lavoro avviene nel repository, la skill usa la versione fissata dal progetto; per un nuovo gioco usa una release esplicita della fonte comune. Se il pacchetto installato e il progetto hanno versioni diverse, dichiararlo e seguire quella fissata dal progetto, salvo richiesta esplicita di aggiornamento. Le eccezioni specifiche del gioco devono essere tracciate e autorizzate.

Le directory di scoperta e i comandi d’installazione dipendono dal prodotto: verificare la documentazione corrente prima di distribuirli. Questa sezione descrive la strategia; non installa una skill e non crea repository.
