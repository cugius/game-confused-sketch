# Aggiornamento v0.14 — isolamento Multi-Touch

Home e pannelli: touch-action pan-y, scorrimento verticale del corpo dei pannelli, blocco esplicito dei gesture events nativi Safari, doppio clic e Ctrl+wheel. Il canvas mantiene touch-action none: pinch e movimento modificano solo la camera del gioco. Se una sequenza multi-touch coinvolge un controllo/pannello, i contatti di gioco vengono annullati e l’input resta bloccato fino al rilascio di tutte le dita. Nessuna riparazione o movimento residuo della gomma.

Wrapper iOS nativo WKWebView: gioco incorporato offline, zoom della pagina disabilitato anche nel contenitore nativo. Codice, workflow CI e istruzioni nel repository GitHub cugius/game-confused-sketch.

# Aggiornamento v0.13 — Confused Sketch e schieramento gomme

Nome del gioco aggiornato a Confused Sketch, sotto Confused By Me. Le chiavi dei salvataggi restano compatibili.

Rinforzi: scelta del tipo con prezzo e icona → campo in pausa → tocco della fascia esterna → anteprima QUI e linea verso il contorno → conferma Schiera. Costo addebitato solo alla conferma; Annulla è gratuito. Ingresso esatto, senza casualità, a 45 unità fuori dal cerchio più esterno. Non si schiera dentro la fortezza. Limite 13 alleati, esplicitato nel menu. Le gomme autonome attaccano dal lato scelto. Se si apre un altro menu il posizionamento non confermato viene eliminato. I rinforzi confermati si salvano.

Gomma principale: un tocco mantiene la destinazione anche dopo il rilascio e continua a cancellare al contatto; trascinamento ancora disponibile. Il gesto a due dita interrompe la destinazione e mette in pausa il movimento. TU parte sotto il cerchio, vicino al contorno. Inquadratura dedicata include tutta la fascia. Guida riscritta in tre passaggi, pulsante ? nel dock, Furia disabilitata con briciole insufficienti.

Verifiche: flusso su viewport 375×667, scelta e conferma, mancata spesa prima della conferma, annullamento, posizione esatta, cerchi esterni, salvataggi e movimento a tocco; campagna e pilota gomma simulati.

# Aggiornamento v0.12 — navigazione e disegno tecnico

Indietro e Riprendi hanno testo 16 px, altezza minima 52 px (48 in orizzontale), contrasto distinto e restano fuori dal contenuto scorrevole. Pulsanti dei pannelli almeno 48 px; tutte le schede del Laboratorio almeno 44 px, senza riduzioni in orizzontale.

Le illustrazioni mostrano assi e cerchio di costruzione, il raggio della torre selezionata ha una scala da compasso e i dettagli hanno una scheda geometrica con raggio e integrità. Nessun nuovo bonus implicito o costo.

L’anteprima espone vita, danni, intervallo e velocità. Curva invariata, estratta in wavePressure: n=ondata−1; vita ×(1+.12n+.009n²), danno ×(1+.045n), velocità ×(1+min(.30,.035n)); intervallo max(.5,1.45−.08×ondata). I tipi e i boss cambiano fra ondate; il numero totale non è monotono. Endless continua la crescita della vita e del danno, mentre velocità e intervallo hanno un limite.

# Aggiornamento v0.11 — dissolvenza, HUD e icone leggibili

## Difese

Rimossi crepe, croci e rovine KO. L’opacità della figura scende progressivamente da 1 a 0,25 con la salute. A zero viene emesso un effetto di dispersione di frammenti del colore della difesa e il tipo della postazione torna vuoto. Si può costruire nuovamente sul +, pagando il costo normale: la nuova difesa riparte dal livello 1. Le difese ancora vive restano riparabili con grafite e conservano livello/specializzazione.

Le vecchie rovine dei salvataggi precedenti diventano postazioni libere. Se il bersaglio di una specializzazione in corso viene cancellato, il lavoro si interrompe e la parte di costo corrispondente al tempo non ancora svolto viene restituita. Se viene cancellato il Laboratorio, gli altri lavori restano sospesi; costruire un nuovo Laboratorio permette di riprendere il lavoro conservato. Non esistono ricostruzioni automatiche delle vecchie torri.

Figure sul campo ingrandite di circa il 20%; geometria di movimento, collisioni e postazioni immutate.

## HUD

Intestazione, risorse, riga dell’ondata, barra boss e avvisi appartengono a un unico contenitore con altezza reale e spaziatura. Non usano più offset indipendenti per sovrapporsi sul campo. La riga dell’ondata può andare a capo, mentre la barra boss resta sempre sotto. L’avviso ha un proprio spazio riservato e non copre i nemici.

L’inquadratura automatica misura il fondo del contenitore e il bordo superiore del dock. Osserva le variazioni di altezza e adatta lo spazio del gioco. Verificata una scena analoga allo screenshot dell’utente, con ondata 12 endless, due cerchi, due boss e usura elevata.

## Costruzione e Laboratorio

Le icone delle difese sono illustrazioni SVG incorporate: 72×72 px nella costruzione, 56×56 nel Laboratorio. Mostrano la forma e il colore del ruolo senza dipendere dai piccoli glifi di un font. Nome, descrizione, costo, durata ed eventuale blocco hanno righe distinte.

Il Laboratorio conserva Ricerca / Manutenzione / Cariche. Ricerca mostra una sola categoria alla volta fra Scoperte, Progetti e Studi; Manutenzione separa Foglio e Difese. Titolo, risorse, schede, categoria e stato del banco rimangono fissi sopra l’unico elenco scorrevole. Dopo tutte le scoperte, l’apertura iniziale suggerisce Studi. La costruzione ha intestazione fissa con numero della postazione e grafite disponibile.

## Verifiche

Suite del motore superata, più test di dissolvenza, dispersione, disponibilità della postazione dopo la distruzione, ricostruzione normale, rimborso della specializzazione interrotta, migrazione delle vecchie rovine e ritorno esatto alla categoria del Laboratorio. Simulazione campagna di otto ondate: scintilla finale 82%; primo assalto Sgomma del pilota completato in circa 23 secondi. Ricerche, cure e materiali restano presenti.

Browser: 393×656 (area simile alla webview dello screenshot), 375×667 e 852×393. Misurazioni dei rettangoli HUD senza intersezioni, con boss e avvisi presenti. Icone di costruzione misurate 72×72; un solo elemento scorrevole (panel-body), titolo/categorie esterni alla lista. Verificati i menu di progetti e manutenzione, le figure sul campo sbiadite e la postazione libera. Queste prove non sostituiscono il test su hardware iPhone fisico.

---

# Aggiornamento v0.10 — UX, navigazione e tratto a matita

Applicata la review della v0.9 senza modificare regole, collisioni, costi o progressione.

## Comandi e HUD

Grafite e scintilla sono le informazioni principali. Il livello resta compatto; gli XP si leggono nel menu. L’usura appare come pulsante leggibile dal 20%, con stato di attenzione dal 60%, e apre lo stato del foglio. Il Laboratorio ha un accesso separato e stabile nel dock sia in preparazione sia durante gli assalti. Il pulsante potere mostra sempre potere selezionato, cariche e cooldown; a scorta zero è disabilitato, non diventa un accesso al Laboratorio.

## Laboratorio e pannelli

Tre sezioni: Ricerca (scoperte, progetti e studi ripetibili, in gruppi richiudibili), Manutenzione (cure del foglio e riparazioni delle difese) e Cariche. Le scoperte già completate sono raccolte in un elenco chiuso. Ogni azione bloccata mostra il motivo: livello richiesto, ricerca precedente, banco occupato, grafite insufficiente, scorta completa o stato già ripristinato.

Ogni pannello ha un solo corpo scorrevole e una barra di navigazione separata. Indietro riapre il pannello padre e mantiene la pausa; Riprendi torna alla partita. La navigazione ricostruisce i pannelli dai dati aggiornati e conserva la sezione del Laboratorio. I cambi di scheda non creano passaggi di cronologia superflui. Ricentrare il foglio resta nel menu in pausa. Risolti i percorsi circolari fra guida/Sgomma e Laboratorio/rinforzi.

## Grafica

Contorni poligonali con imperfezioni leggere e determinate dalle coordinate: nessun tremolio casuale fra fotogrammi. I cerchi hanno pressione variabile e ripassi intermittenti, mantenendo invariata la geometria di gioco. Gli upgrade conservano il colore del ruolo; rimossi anelli decorativi e raggi sovrapposti. Restano dimensioni, riflessi contenuti e simbolo della specializzazione. Nessuna ombra ellittica reintrodotta.

Fondi distinti in coordinate del mondo: quadretti e margine per il quaderno; reticolo più fitto con linee maggiori per la millimetrata; fibre senza reticolo per la pergamena; puntinatura e frammenti per la riciclata. La selezione iniziale mostra piccoli campioni di materiale. Gomme rapide con sagoma appuntita, gomme pane con profilo morbido irregolare; mantenuti i riflessi satinati.

## Verifiche

Suite del motore e salvataggi superata, più nuovi test su Indietro senza riprendere, ripristino della scheda esatta, separazione Lab/poteri, motivazioni dei blocchi e percorsi Sgomma. Browser con viewport 393×852, 375×667 e 852×393: laboratorio, manutenzione, acquisto di una cura, motivazione Banco occupato, ritorno guida→menu, HUD e comandi. Ispezione DOM: il solo elemento scorrevole nei pannelli è panel-body; il dock non eccede la larghezza disponibile. Controllati visivamente pergamena e millimetrata, rovine, colori degli upgrade e tratto stabile. Le prove non equivalgono a un test su hardware iPhone fisico.

---

# Aggiornamento v0.9 — integrità delle difese

Importata prima la versione HTML v0.8 corrente: quattro materiali, ingiallimento con penalità alla rigenerazione, cure a tempo e conservazione del materiale/usura nei salvataggi. Queste funzioni restano presenti.

Tutte le otto difese e il Laboratorio hanno punti integrità, differenziati per tipo. Ogni livello aggiunge 45 punti di capacità. Un potenziamento aggiunge la capacità extra e conserva il danno già subito; non è una riparazione gratuita completa.

Le gomme normali scelgono difese raggiungibili entro 125 unità. Il percorso viene verificato contro gli archi ancora integri dei cerchi: non attraversano il muro per attaccare una torre. A contatto cancellano l’integrità; stordimento e rallentamento restano efficaci. Il Rullo danneggia le torri attraversate una volta per carica; Squadra e Cancellatrice infliggono danni ad area. Sigillo riduce i danni subiti dalle difese.

A zero integrità la difesa resta come rovina, conserva livello e specializzazione e non funziona più. Toccarla apre Ricostruisci. Le difese danneggiate hanno crepe e barra; il menu espone integrità numerica e costo. Riparazione e ricostruzione riportano al massimo per ceil(integrità mancante × 0,24 × costo ripasso del materiale). Non si può riparare senza grafite. La vendita di una torre danneggiata restituisce grafite proporzionale all’integrità; una rovina non restituisce grafite.

Un Laboratorio abbattuto conserva il lavoro in corso e ne ferma il tempo. Ricostruirlo permette di riprendere dall’avanzamento raggiunto. Non si possono costruire Laboratori duplicati per aggirare la rovina.

Sgomma: tenere la gomma principale contro una difesa raggiungibile la danneggia. Anche gli alleati attaccano le difese dopo le brecce. Abbattere una torre dà 45 punti e 8 briciole. La fortezza ripara lentamente le torri ancora attive usando la propria riserva; non ricostruisce le torri abbattute. La condizione di vittoria resta la cancellazione della percentuale richiesta del contorno.

Salvataggi: integrità e rovine incluse nello stato di ogni postazione. Le partite precedenti prive di questi campi caricano le difese integre, conservando il resto della progressione.

Verifiche: suite del motore superata, nuovi test di danno reale, riparazioni a pagamento, ricostruzione con specializzazione, nessun fuoco dalle rovine, protezione dei cerchi integri, stordimento, danni ad area, Laboratorio sospeso e ripristinato, salvataggi e migrazione, demolizione in Sgomma e conservazione delle cure v0.8. Simulazione campagna di otto ondate con scintilla finale 82%; primo assalto Sgomma completato dal pilota in circa 23 secondi. Questi valori non sostituiscono il playtest umano.

Verifica browser su 393×852 e 375×667: ricostruzione Triangolo III per 48 grafite con Ventaglio conservato, ricostruzione Laboratorio per 44 grafite con Balistica ancora in corso. Verificate rovine, crepe e barre nel foglio.

---

# Aggiornamento v0.7 — gomme e carta

Rimosse le ombre ellittiche sotto difese e gomme. Le difese conservano le ombre aderenti alla propria sagoma e i riflessi dei livelli superiori. Gomme con corpo satinato, bordo illuminato, sfumatura di volume, fascia superiore e piccole abrasioni. Corazza metallica e Squadra hanno riflessi dedicati. Dimensioni, collisioni e comportamento invariati.

Menu → Aspetto del foglio: invecchiamento opzionale, inizialmente spento, persistito sul dispositivo. Il colore passa dall’avorio al giallo tenue in base al maggiore fra livello giocatore e ondata (fortezza in Sgomma), con saturazione al livello 12 e transizione morbida. La tinta è disegnata prima del reticolo, degli oggetti e dei colpi: non modifica i colori del combattimento. Leggero scurimento ai bordi, nessun effetto sulle regole.

Verifica: suite del motore esistente superata; verifica browser della scena con tutte le gomme e tre boss a livello 12, confronto carta chiara/invecchiata e controllo del comando nel menu. Nessun cambiamento di bilanciamento.

## Proposta per i materiali — non ancora implementata

Scegliere il materiale all’inizio della partita, con un vantaggio e un costo leggibili. Il materiale resta quello scelto, mentre l’invecchiamento è solo estetico.

| Materiale | Vantaggio proposto | Compromesso proposto |
| --- | --- | --- |
| Quaderno a quadretti | Equilibrato, adatto a imparare | Nessuna abilità esclusiva |
| Pergamena | Sigilli e scudi durano più a lungo | Ripassare costa più grafite |
| Carta millimetrata | Maggiore gittata delle difese | Cerchi esterni più costosi |
| Carta riciclata | Rigenerazione di grafite più rapida | Il contorno si erode più facilmente |

Partire con questi quattro materiali prima di introdurre nuove valute o alberi separati. Il Laboratorio può poi ricercare trattamenti specifici del materiale (durata dei sigilli, fibre rinforzate, calibrazione), con tempo e costo: crea nuove scelte dopo gli sblocchi standard. I modificatori numerici richiedono playtest e non sono fissati in questa proposta.

---

# Aggiornamento v0.6 — figure e laboratorio continuo

Tre nuove difese portano il totale a otto, più il Laboratorio:
- Pentagono: fulmine a catena su tre bersagli; Arco lungo raggiunge cinque bersagli, Ionizzazione perfora e stordisce.
- Stella: danno radiale; Supernova amplia la gittata e aumenta il danno, Comete rallenta le gomme.
- Ottagono: crea scudi locali sul contorno; Bastione ne aumenta larghezza e capacità, Ritorsione danneggia le gomme vicine.

Ogni figura ha tre livelli visivi con palette, dimensioni, cornici e ombre diverse. I livelli superiori hanno riflessi più visibili, il terzo aggiunge bordo dorato e icona della specializzazione. I nuovi effetti comprendono fulmini a catena e raggi/raffiche a stella.

Il Laboratorio ha quattro schede: Scoperte, Progetti, Studi e Cariche. Tutte le scoperte, i progetti, gli ampliamenti del Laboratorio e le specializzazioni delle singole torri richiedono tempo di assalto. Il bonus si applica soltanto al completamento. Un unico banco impedisce lavori simultanei; le cariche già ricercate restano acquisti immediati. Una torre in specializzazione continua a sparare ma non può essere venduta prima del completamento.

Gli Studi sono ripetibili senza limite di cicli: danni, rigenerazione e riparazione. Costo e durata crescono fino a tetti di 110 grafite e 90 secondi; il beneficio diminuisce secondo 1/(1+ciclo×0,25). Restano disponibili dopo il completamento di tutte le scoperte, anche nell’endless, e diventano la scheda iniziale del laboratorio a scoperte esaurite. Nessun bonus gratuito a fine ondata.

I salvataggi includono il tipo di lavoro, il tempo restante, il bersaglio di una specializzazione e i cicli degli studi. Le ricerche delle versioni precedenti rimangono valide.

Verifica: suite del motore, ricerche a tempo e pause, incremento solo al completamento, ampliamenti, specializzazioni, impossibilità di vendere il bersaglio, studi ripetuti e salvataggi. Test meccanici per tre/cinque bersagli del Pentagono, area della Stella, scudo reale dell’Ottagono e tutte le forme ai tre livelli. Pilota sintetico con ricerche, due progetti danno e potenziamenti: otto ondate completate con scintilla all’82%. Prima fortezza Sgomma completata dal pilota precedente. Verifica browser su 393×852 e 375×667; il bilanciamento va confermato con playtest umano.

---

# Aggiornamento v0.5 — ricerca e Sgomma

- Laboratorio unico, costruibile su una postazione per 45 grafite. Due potenziamenti da 40 ne accelerano le ricerche.
- Dodici ricerche a pagamento, una alla volta, con prerequisiti e livello minimo. Il tempo avanza durante gli assalti e si ferma nelle pause e nella preparazione.
- Difese avanzate, cuciture, toppe, cerchi esterni, specializzazioni e poteri richiedono ricerca. Il triangolo resta disponibile da subito.
- Nessuna scelta gratuita al termine delle ondate. I vecchi bonus diventano progetti acquistabili nel laboratorio, con costo crescente e massimo tre acquisti per progetto.
- I poteri richiedono cariche acquistate separatamente, massimo tre per tipo. L’attivazione consuma una carica già pagata, mantiene il cooldown e non addebita nuovamente grafite.
- Sgomma: controllo diretto di una gomma con un dito, rinforzi acquistabili con briciole, Furia da 15 briciole. Due dita sospendono l’azione per spostare o ingrandire il foglio.
- Le fortezze sparano e riparano; vittoria cancellando dal 50 al 75% del contorno secondo la difficoltà, sconfitta perdendo la gomma principale. Fortezze successive aggiungono spirale, riparatore, mortaio, cecchino e un cerchio esterno.
- Salvataggio locale di ricerche, acquisti e modalità inversa. I vecchi salvataggi riconoscono le difese avanzate già costruite.

Validazione: test del motore, prerequisiti, addebiti singoli, avanzamento ricerca, salvataggi, assenza dei bonus gratuiti e vittoria/sconfitta inversa. Simulazione della campagna con ricerca reale: completate otto ondate, scintilla finale 46%. Pilota sintetico Sgomma con tre rinforzi: prima fortezza completata in circa 19 secondi. Questi risultati sono verifiche funzionali, non sostituiscono il playtest umano. Menu laboratorio e rinforzi verificati in browser con viewport iPhone 393×852 e 375×667.

---

# Aggiornamento v0.4 — effetti, livelli e boss

- Il livello della partita aumenta con esperienza da eliminazioni e ondate. Soffio è disponibile dal livello 1; Sigillo si sblocca al 3, Stasi al 5 e Tempesta al 7. Il selettore unico conserva la UX compatta e mostra costi, requisiti e recuperi.
- Le cinque difese hanno effetti dedicati: schegge con rinculo; granate con arco, reticolo e schizzi; raggi con nucleo luminoso; onde/fiocchi della spirale; fili e croci di riparazione. Effetti transitori limitati a 100 e polvere a 300 particelle.
- Boss: Rullo con corsia anticipata e contromisura Toppa; Squadra con due settori annunciati e una finestra senza corazza; Cancellatrice con rinforzi, impulsi ed enfasi sotto metà salute. I boss devono essere eliminati: arrivare al nucleo non li fa sparire e non chiude l’ondata.
- Nuova curva: salute crescente anche quadraticamente, incremento moderato della velocità, erosione più alta e gruppi aggiuntivi dalla terza ondata. L’anteprima usa la stessa composizione dell’assalto.
- Livello, XP, poteri, ricariche e stati attivi sono salvati con la partita. I salvataggi precedenti hanno valori predefiniti compatibili.

Verifiche automatizzate: requisiti di sblocco, costi e ricariche, riduzione dei danni del Sigillo, congelamento dei rinforzi, danni della Tempesta, disegno degli effetti, sequenze/vulnerabilità dei boss, permanenza al nucleo, ripresa e curva della difficoltà.

Benchmark deterministico: la strategia passiva termina alla quinta ondata; strategie miste e con espansione completano le otto ondate con il 64% della scintilla. Nella simulazione mista i livelli 3, 5 e 7 si raggiungono rispettivamente entro la seconda, quarta e quinta ondata. Sono controlli di raggiungibilità, non risultati di playtest umano.

QA visuale in browser alle dimensioni di iPhone 393×852, 375×667 e 852×393. Verificati selezione poteri, indicatori boss, riapertura salvataggio ed effetti in una scena di stress. Non equivale a una prova su hardware fisico.

---

# Aggiornamento v0.3

Il controllo attuale usa un dito per agire e due dita per pan/zoom simultanei. La barra camera e la modalità Vista sono state rimosse. Durante il gesto a due dita il combattimento si ferma e riprende dopo il rilascio di entrambe. Il foglio resta a tutto schermo; in assalto il dock contiene solo strumenti e Soffio.

Sono disponibili cucitura con estremità sane, toppa temporanea e dieci evoluzioni (due per torre). Il Rullo segnala una corsia prima della carica e può essere fermato da una toppa con almeno 100 di scudo. I salvataggi precedenti restano compatibili.

Verifiche: gesti naturali senza riparazioni involontarie, evoluzioni e proiettili specializzati, riparazioni valide/invalide, assorbimento e interruzione della carica, ripresa e tre formati iPhone nel browser. Nelle simulazioni aggiornate la strategia passiva perde alla sesta ondata; quelle miste e con espansione completano le otto. Restano prove automatizzate, non misure di retention.

---

# Ultimo tratto v0.2 — direzione e verifica

La promessa è una fortezza fatta a matita che puoi davvero ripassare ed estendere. Il gesto di riparare, i segni geometrici e le gomme che cancellano devono essere riconoscibili già nei primi secondi.

## Leve progettate

| Leva | Applicazione | Cosa verificare con persone reali |
| --- | --- | --- |
| Competenza | Erosione locale leggibile, riparazioni, anteprime e contromisure | Capiscono una breccia e riescono a salvarla? |
| Autonomia | Cinque torri, tre cerchi, sei potenziamenti, scelta su come spendere grafite | Emergono strategie diverse e comprensibili? |
| Scoperta | Corazze, sciami, gomma pane e boss introdotti nelle ondate | Vogliono provare un'altra combinazione? |
| Obiettivo vicino | Otto ondate nel quaderno; quattro nella sfida del giorno | Finiscono o abbandonano perché la durata non convince? |
| Continuità | Ripresa locale della partita e diario delle ultime dodici prove | La ripresa funziona quando cambiano app su iPhone? |
| Espressione visiva | Disegnare cerchi esterni ed espandere le postazioni | L'espansione sembra una conquista o solo altro lavoro? |

Il modello motivazionale di Przybylski, Rigby e Ryan collega l'attrattiva del gioco alla soddisfazione di competenza, autonomia e relazione. Qui si applicano soprattutto le prime due: feedback e contromisure per la competenza; combinazioni e progetti diversi per l'autonomia. Lo studio del 2009 degli stessi autori riporta associazioni fra autonomia/competenza, divertimento e desiderio di giocare ancora. Questo sostiene la direzione, non dimostra la retention di questo prototipo.

Fonti primarie:
- https://selfdeterminationtheory.org/SDT/documents/2010_PrzybylskiRigbyRyan_ROGP.pdf
- https://selfdeterminationtheory.org/SDT/documents/2009_PrzbylskiRyanRigby_PSPB.pdf

La sfida giornaliera e gli appunti sono ipotesi progettuali da verificare. Il diario rimane locale, non misura un pubblico e non trasmette eventi. I traguardi non aumentano il potere: ogni nuova partita parte con le stesse possibilità. Non servono serie obbligatorie o ricompense perse se salti un giorno.

## Dieci passaggi, verifiche e limiti

Le dieci iterazioni sono dieci passaggi di implementazione, con commit distinti: vedere ITERATIONS.md. Non equivalgono a dieci sessioni con tester umani.

Controlli riproducibili:

```
node tests/check.cjs
node tests/balance.cjs
```

La suite controlla collisioni ed erosione locale, tre cerchi indipendenti, costo dei disegni validi/invalidi, riparazione con due puntatori, separazione dalla camera, pausa tattica in Vista, pan e pinch, corazze e perforazione, divisione in briciole, riparatore, rallentamento, Soffio, salvataggi, sfida e diario.

Il benchmark usa tre semplici strategie deterministiche. Nel caso verificato, lasciare solo le torri iniziali porta alla sconfitta alla settima ondata; le strategie miste e con espansione completano le otto ondate. La riparazione automatizzata del benchmark è un'approssimazione molto precisa del giocatore: questi risultati verificano la raggiungibilità, non la difficoltà percepita su touch.

Problemi emersi e corretti: costo delle riparazioni eccessivo; stallo possibile quando un nemico era bloccato fuori gittata; etichette della camera non sincronizzate; controllo del disegno interrotto. La pressione crescente delle gomme, il costo ridotto e le indicazioni sulle torri esterne rispondono ai primi due problemi.

Verifica visuale in browser alle dimensioni 393×852, 375×667 e 852×393. Non è un test su hardware iPhone fisico; le safe area usano gli inset del dispositivo. Il sito resta privato con lo stesso pubblico precedente.

## Prossimo playtest

Con 5–10 persone: osservare se chiudono un cerchio, se passano senza errori dal dito singolo al gesto a due dita e se capiscono quale difesa contrasta una corazza. Raccogliere numero di tentativi spontanei, punto di abbandono, varietà di torri e percezione delle riparazioni. Solo dopo una prima prova riuscita ha senso misurare ritorno il giorno successivo e a una settimana; il diario locale attuale non permette di stimarli su una popolazione.
