# Illustrated WebGL — direzione fedele al concept

Questa revisione sostituisce le figure procedurali semplificate con 18 asset illustrati ad alta risoluzione ricavati dai concept tramite imagegen, con alpha trasparente e materiali ricchi. Le immagini generate sono convertite in WebP qualità 92 con ffmpeg per la distribuzione; nessun ridisegno vettoriale o semplificazione del materiale. Atlas di origine in dist/assets/, incorporati anche nell’HTML per uso offline e wrapper iOS.

## Rendering reale

WebGL disegna sprite testurizzati con alpha blending, shader di impatto e pigmento per livello. Ordinamento per profondità, recoil, bob e squash limitati, dissolvenza guidata dalla vita. Non sono modelli mesh 3D né una camera orbitabile: è una resa illustrata 2.5D a vista fissa. I corpi non ruotano liberamente verso ogni bersaglio; proiettili e logica di puntamento mantengono le direzioni effettive. Per otto viste coerenti e animazioni articolate servono ulteriori atlas direzionali o modelli 3D. Il foglio, i testi e gli effetti esistenti rimangono sul canvas 2D; le figure illustrate sono sul livello WebGL.

Se WebGL è disabilitato, una composizione DOM mostra gli stessi atlas con gli stessi rettangoli, colori e opacità. Non si torna alle primitive semplificate. Il browser di QA in questa sessione non espone WebGL: verifica visiva fatta sul percorso DOM a identica resa, non su GPU iPhone. Shader e buffer hanno test strutturali; compilazione GPU reale da verificare su dispositivo. Nessun nuovo motore/CDN.

## Risorse

- Difese: triangolo, spirale, esagono, rombo, quadrato, pentagono, stella, ottagono, laboratorio.
- Gomme: rosa, punta blu, corazzata, pane, briciola, TU, Rullo, Squadra, Cancellatrice.
- Atlas source 1280×1280, ritagli UV espliciti con margine per evitare contaminazioni fra celle.
- Il tier modifica dimensione/pigmento e conserva i pips. I livelli non hanno ancora illustrazioni separate.

## Prova

Aprire dist/index.html e Atelier dalla home. Nessun download runtime richiesto, texture incorporate. 2.5D deve essere attiva nelle impostazioni. Main e pubblicazione principale non modificati.
