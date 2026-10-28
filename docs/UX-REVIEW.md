# Confused Sketch: review UX/UI e meccaniche

Base: `confused-sketch-v0.13.html`. Versione modificata: `confused-sketch-v0.14.html`.
Verifica: screenshot a 390×844 (iPhone), test di interazione in Chromium headless, nessun errore JavaScript.

---

## 1. Sintesi

Il gioco ha già una direzione forte (carta a quadretti, toni inchiostro, linguaggio da quaderno). Il problema non è il tono, ma la quantità di strati: troppi pannelli, troppi pulsanti che fanno la stessa cosa, troppo testo prima di giocare. Per un tower defense moderno servono tre cose: un'azione primaria chiara in ogni schermata, meno chrome sopra il campo, e feedback leggibile in combattimento.

Priorità, dalla più alta:

1. **Navigazione dei pannelli**: ogni pannello aveva tre modi di tornare indietro (‹ Indietro, ▷ Riprendi in alto, pulsante in basso). Ora c'è una sola riga: ‹ e × .
2. **Menu**: da 10 voci a 6, con le utilità spostate in *Impostazioni*.
3. **Primo contatto**: l'intro aveva 4 pulsanti di pari peso. Ora c'è un'unica azione primaria (*Gioca*), due modalità e un link per le regole.
4. **Guida**: da 13 paragrafi densi a 5 regole brevi.
5. **Velocità di gioco**: non esisteva un controllo. Ora c'è 1× / 2×.
6. **Poteri**: il pulsante di combattimento mostrava "Soffio ×0" come pulsante morto. Ora dice "compra" e apre il Laboratorio.

---

## 2. Pannello per pannello

| Pannello | Problema trovato | Stato in v0.14 | Proposta ulteriore |
|---|---|---|---|
| **Intro** | Quattro o cinque CTA di pari peso, "Come si gioca" come pulsante pieno | Gioca (primaria), Sfida del giorno + Modalità gomma affiancate, "Come si gioca" come link | Nessuna |
| **Guida** | 13 voci dense, più di 1.200 parole, prima di qualunque gioco | 5 regole brevi | Suggerimenti contestuali (un tooltip alla prima costruzione, alla prima ondata, al primo boss) al posto della guida lunga |
| **Menu** | 10 pulsanti in 6 righe, mescolati azioni e impostazioni, tre pulsanti "Riprendi"/"Torna" | 6 voci: Riprendi, Ripassa, Laboratorio, Gommario/Diario, Impostazioni, Nuovo foglio | Nessuna |
| **Impostazioni** (nuovo) | Non esisteva: suoni, ricentra, stato foglio e aiuto erano sparsi nel menu | Contiene suoni, ricentra, stato del foglio, come si gioca, nota di installazione | Aggiungere la scelta della velocità e la lingua |
| **Intestazione dei pannelli** | Due pulsanti grandi (52px) occupavano il terzo superiore dello schermo, più un titolo duplicato dall'eyebrow | Una riga da 44px: ‹ a sinistra, × a destra; il titolo duplicato è stato tolto | Nessuna |
| **Laboratorio** | Tre livelli di schede (Ricerca / Manutenzione / Cariche), poi sotto-categorie (Scoperte / Progetti / Studi): cinque scelte prima di comprare qualcosa | Non modificato | Appiattire a tre schede: **Ricerca** (con Scoperte, Potenziamenti; "Studi" dentro Potenziamenti), **Cure** (foglio e difese), **Cariche** |
| **Catalogo "Costruisci"** | Chiaro, ma le icone sono in uno stile diverso da quelle sul campo | Icone con lo stesso inserto interno delle torri sul campo | Mostrare la gittata e il danno della torre, non solo la descrizione |
| **Postazione (torre)** | Il pulsante di potenziamento non dice cosa ottieni; "Cancella · recupera 15✎" mescola un'azione distruttiva con un dato economico | Non modificato | Mostrare il "prima → dopo" del potenziamento (danno, gittata) e separare Cancella in un'area secondaria |
| **Evoluzione** | Testo in due colonne senza confronto | Non modificato | Due card affiancate con icona, nome, effetto e un'anteprima |
| **Poteri** | Un potere si usa in combattimento, si sceglie in un pannello, si compra nel Laboratorio: tre posti | Il pulsante di combattimento porta al Laboratorio se non hai cariche | Un'unica sorgente: carica il potere dalla card stessa |
| **Prossima ondata** | Accessibile solo da una riga di testo piccolissima in basso | Non modificato | Icone e conteggi dei nemici, non solo rapporti percentuali |
| **Ripassa (strumenti)** | Il pulsante ha icona ✎ e l'etichetta "Ripassa", ma apre tre strumenti (matita, cucitura, toppa) | Non modificato | Nome più chiaro: "Strumenti" |
| **Velocità** | Assente | Pulsante 1×/2× nella barra di fase, visibile solo durante gli assalti | Aggiungere 3× dopo le prime ondate |

### Problemi trasversali non risolti in v0.14

- **Dimensioni del testo**: etichette a 7–8px (GRAFITE, SCINTILLA, "Usura", stato del foglio nei telefoni piccoli). Sotto 10px non è leggibile all'aperto. Minimo consigliato: 11px per le etichette, 12px per i valori.
- **Icone**: il gioco mescola simboli Unicode (▱ ⌂ ◌ ⊙ ▤ ♫ ✓) che possono cambiare aspetto tra iOS e Android. Conviene un unico set SVG.

---

## 3. Grafica delle forme (torri)

**Fatto in v0.14:**
- Il livello ora si legge con puntini (1 per il livello 2, 3 per il livello 3) al posto di "II" e "III", che erano illeggibili a 10px.
- Ogni torre ha un inserto interno, più leggero, che la rende un "gettone" di smalto anche al livello 1. Lo stesso inserto è nelle icone del catalogo, così campo e catalogo coincidono.

**Non fatto, ma consigliato:**
- **Silhouette a 40px**: pentagono, ottagono, stella e triangolo hanno una dimensione simile, quindi a colpo d'occhio si distinguono male. Ingrandire le torri a circa 48–52px, o aggiungere un contorno più scuro per i tipi più piccoli.
- **Rombo (cecchino)**: è la forma più debole. Una linea di mira, o un piccolo cannocchiale, la renderebbe riconoscibile.
- **Leggibilità dei nemici**: nel fotogramma di combattimento le gomme hanno tinte pastello molto vicine a quelle delle torri. Un contorno inchiostro più marcato e un'ombra leggera sui nemici risolverebbero il problema.
- **Feedback di tiro**: esiste un lampo giallo sulla torre, ma nessun rinculo né scia. Un piccolo rinculo (2–3px) al colpo renderebbe ogni torre "viva".

---

## 4. Meccaniche da introdurre

Già presenti nel gioco (non le riproporrei): specializzazioni, evoluzioni, alleati, boss, ricerca, progetti, poteri, tipi di carta, cerchi concentrici, sfida giornaliera, modalità gomma, livelli XP.

Ordine per impatto/sforzo:

1. ~~**Chiamata anticipata dell'ondata**~~ *(corretto)*: la fase di preparazione non ha timer, l'ondata parte solo con "Inizia", quindi non c'è attesa da accorciare. Resta valida solo come scommessa ("senza acquisti, +8 grafite"), a basso impatto.
2. **Priorità di bersaglio per torre** (Primo / Più forte / Più vicino / Più debole). *Nota dal codice*: la logica `t.priority === 'strong'` esiste già nel motore di tiro, ma nessuna interfaccia la imposta: è codice morto. Serve solo il selettore nel pannello della torre.
3. **Stelle per ondata** (1–3, in base a quanta scintilla resta intatta e a quanti pezzi di grafite si spendono): dà un motivo per rigiocare il quaderno.
4. **Numeri di danno e ricompense**: "−13" sul nemico, "+8✎" alla cancellazione. Nel codice non ho trovato testo fluttuante, quindi il giocatore non vede quanto danno fa.
5. **Telegrafia per tutti i nemici**: il Rullo già segnala la corsia. Estendere l'anticipo a *Punta blu* e *Gomma pane* chiarirebbe da dove arrivano.
6. **Sinergie visibili**: il testo dice "Spirale perfetta con gli esplosivi", ma il gioco non lo mostra. Un'etichetta "+20% con Spirale" nel dettaglio dell'esagono renderebbe il sistema leggibile.
7. **Briciole raccoglibili**: le gomme cancellate lasciano piccole ricompense da raccogliere con un tocco. Premia il ripasso attivo.
8. **Modificatori d'ondata**: "Carta umida" (torri più lente, nemici più rapidi), "Notte di gomme" (un boss in anticipo). Dà varietà senza nuove torri.
9. **Ricompensa di sblocco**: le stelle sbloccano carte o torri, come nei TD a campagna.

---

## 5. Cosa è cambiato nel file v0.14

- Intestazione dei pannelli compatta (‹ / ×), titolo duplicato rimosso.
- Menu da 10 a 6 voci; nuovo pannello *Impostazioni* (suoni, ricentra, stato del foglio, come si gioca).
- Intro: un'azione primaria, due modalità, link per le regole.
- Guida ridotta a 5 regole.
- Pulsante velocità 1×/2× durante gli assalti.
- Pulsante Poteri: "compra" con zero cariche, apre il Laboratorio invece di essere morto.
- Torri: puntini di livello, inserto interno su tutti i gettoni, icone del catalogo allineate.

Il codice è un unico file HTML: sono state modificate circa 38 righe (aggiunte e rimozioni), senza riscrivere la logica di gioco.

---

## 6. Limiti della verifica

- Test in Chromium headless con viewport 390×844. Non ho testato su dispositivi reali né su iOS Safari (il comportamento di `dvh` e delle barre può differire).
- Non ho bilanciato nulla: velocità 2× e nuovo testo non cambiano i numeri del gioco.
- Non ho misurato la leggibilità in movimento con persone reali; le osservazioni sui nemici vengono da un singolo fotogramma.
- Il Laboratorio a tre schede e il selettore di priorità sono proposte, non implementate.

---

## v0.45 · Seconda review (home, tema, impostazioni, audio)

Metodo: screenshot a 390×780 di 21 pannelli (home, carta, mappe, menu, impostazioni ×4, guida, gommario, diario, lingua, laboratorio ×2, catalogo difese, dettagli torre, foglio, poteri, strumenti, previsione).

### Trovato e corretto

| Area | Problema | Intervento |
|---|---|---|
| Home | Scheda centrata su fondo quasi opaco: il gioco non si vedeva, cinque pulsanti di pari peso | Home stile Droplet: partita dimostrativa animata dietro (isolata: non salva, non conta statistiche, non suona), titolo in alto, in basso un solo CTA grande + griglia 2×3 con icone, crediti (i) e regole (?) negli angoli, "Riprendi" prima di tutto se c'è un foglio salvato |
| Tema | Georgia + verde generico: nulla legava la grafica di gioco (matita, polvere di grafite) all'interfaccia | Tema "penna colorata": Caveat (OFL) per titoli e pulsanti, bordi a mano libera, sottolineatura a onda rossa sui titoli, inchiostri blu/rosso/verde |
| Impostazioni | Doppioni: velocità (c'è già 1×/2× nel gioco), "Ricentra il foglio", "Stato del foglio" (è nel Laboratorio), "Prova suoni", guida duplicata, nota di installazione anche dentro l'app | Rimossi o spostati: la velocità resta solo nel gioco, "Ricentra" è un pulsante sul campo che compare solo quando la vista è spostata, la nota di installazione solo su iPhone in Safari. Info ora contiene Crediti e licenze, guida, cancella dati |
| Icona impostazioni | Ingranaggio ⚙ | Icona a cursori (la stessa di Confused Words), SVG |
| Tab impostazioni | Glifi Unicode di dimensione incoerente (◐ minuscolo) | Icone SVG a tratto |
| Laboratorio | Schede senza figura con il glifo ⌁ ripetuto; chip che finiscono fuori schermo senza segnali | Icone SVG per tipo (cucitura, cerchi, vento, scudo, stasi, tempesta, evoluzione, goccia, lampadina); chip con sfumatura sul bordo e stile penna |
| Audio | Effetti inudibili, musica assente | Vedi `docs/MUSIC.md` |
| Crediti | Non esistevano | Pagina Crediti e licenze (musiche, effetti, caratteri con testo OFL, grafica, tecnologie, lingue, dati) + `THIRD-PARTY-NOTICES.txt` |

### Ancora da fare (non toccato)
- Bestiario e Diario sono elenchi di testo: aggiungere la miniatura di ogni gomma.
- Laboratorio: sei chip e molte schede lunghe; una vista ad albero delle ricerche renderebbe chiari i prerequisiti.
- Schermate di vittoria/sconfitta dei Percorsi: aggiungere il riepilogo (gomme fermate, difese perse).
- Verificare su dispositivo: Caveat a 22 px per i pulsanti nel Giapponese (fallback `cursive` di sistema), consumo della home animata su iPhone vecchi (si può spegnere con movimento ridotto).
