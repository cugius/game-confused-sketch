# Musica e suoni

## Musica
Sette brani in `assets/audio/`, incorporati in base64 in `dist/index.html` (`<script id="music-data">`) con `node scripts/embed-music.cjs` (`--check` verifica l'allineamento; non modificare il blocco a mano). Sono stati generati con Gemini (prompt in `docs/prompt musiche gemini.md`) e tagliati dai file originali da ~60 s.

| File | Durata | Origine (taglio dall'originale) | Momento |
|---|---|---|---|
| `menu.mp3` | 46,1 s | `01-the_sunday_notebook` 12,25–58,35 s (salta l'intro quieta di 11 s) | home |
| `build.mp3` | 51,0 s | `02-second_hand_solitude` 4,40–55,35 s | preparazione |
| `wave.mp3` | 41,1 s | `03-midnight_parlor_scramble` 8,45–49,50 s (evita la pausa a 39–41 s) | ondata Quaderno e Sfida |
| `paths.mp3` | 30,7 s | `04-the_mapmaker_s_shuffle` 1,15–31,85 s | ondata nei Percorsi |
| `boss.mp3` | 53,1 s | `05-the_margin_s_heavy_step` 6,90–59,95 s | ondata con un boss in campo |
| `victory.mp3` | 8,9 s | `06-folded_corners` 2,0–10,9 s (fine naturale della frase), dissolvenza finale 0,7 s | jingle di vittoria |
| `gameover.mp3` | 7,6 s | `07-the_last_crease` 0–7,6 s, dissolvenza finale 0,8 s | jingle di sconfitta |

**Loop.** Il lettore sovrappone gli ultimi 3 s del brano ai primi 3 s della ripetizione. Per ogni loop il punto di taglio è stato scelto cercando la coppia inizio/fine con più somiglianza spettrale tra la coda e l'attacco (stesso punto della battuta, stessa armonia) e il minimo calo di volume nella giunzione. La curva di dissolvenza è un compromesso tra lineare ed equipotenza (nessun buco di volume né picco). Tutti: loudnorm −20 LUFS, MP3 80 kbps 44,1 kHz stereo, dissolvenza d'ingresso di 20 ms contro i click.

Mappatura in `MAP` dentro `MUSIC`: ondata con boss (`isBoss`) → `boss`; nei Percorsi → `paths`; altrimenti `wave`. Pausa abbassa al 35 %, fine partita al 40 %, jingle al 12 %. Impostazioni → Audio: interruttore e volume della musica, indipendenti dagli effetti.

## Effetti
Sintetizzati (`SFX` in `dist/index.html`): oscillatori e rumore filtrato, compressore sul bus. Dalla v0.48 i suoni di battaglia (`shoot`, `hit`, `pop`, `breach`) sono più morbidi (tick di matita, tonfo sordo, sbuffo di carta) e durante le ondate c'è un fruscio continuo di gomma sul foglio (`SCRAPE`, più intenso con più gomme in campo, con qualche squittio leggero; si ferma in pausa e a fine ondata). Il volume (`prefs.volume`, default 80) è un'uscita reale: picchi da −8 a −25 dBFS prima del compressore. Limitatore di frequenza per `shoot`/`hit`/`pop`.

### Perché prima non si sentivano
1. Bip sinusoidali da 0,045 di guadagno (circa −27 dBFS; `shoot` −35 dBFS) senza compressione.
2. Su iOS il Web Audio in WKWebView è zittito dal tasto Silenzioso con la sessione audio predefinita: ora `navigator.audioSession.type='playback'` + `AVAudioSession .playback` in `AppDelegate.swift`.
3. Lo sblocco avveniva su `pointerdown`; iOS richiede un gesto "vero" (`touchend`/`click`): i listener restano armati finché il contesto non è `running` e si riarmano dopo sospensioni/interruzioni (`window.__audioResume` chiamato da Swift).
4. Mancavano le chiamate agli effetti di sparo e danno alle difese.

## Non ancora verificato su dispositivo
Bilanciamento musica/effetti, ripresa dopo interruzioni e memoria in WKWebView (circa 35 MB per `menu`, 21 MB per gli altri brani decodificati).
