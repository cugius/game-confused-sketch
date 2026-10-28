# Musica e suoni

## Musica
Cinque brani in `audio/`, incorporati in base64 in `dist/index.html` (`<script id="music-data">`) con `node tools/embed-music.cjs` (`--check` verifica l'allineamento; non modificare il blocco a mano). Stesso lettore di Confused Words: Web Audio, decodifica al bisogno, loop con dissolvenza incrociata di 3 s, cambio brano con dissolvenza di 1,4 s.

| File | Origine | Momento | Note |
|---|---|---|---|
| `menu.mp3` (96 s) | Droplet `01-sun-dappled_canopy` (kalimba/marimba, 70 bpm) | home | già lavorato per Words |
| `frozen.mp3` (60 s) | Droplet `05-frozen-night` (celesta, 65 bpm) | preparazione | calmo, lascia pensare |
| `neon.mp3` (61 s) | Droplet `07-neon` (arpeggi, 90 bpm) | ondata in corso | più ritmo senza essere sintetico-aggressivo |
| `victory.mp3` (12 s) | Droplet `09-victory` | jingle di vittoria | la musica si abbassa durante il jingle |
| `gameover.mp3` (8 s) | Photon `game-over` | jingle di sconfitta | loudnorm −20 LUFS, MP3 80 kbps |

Scartati: le tracce Photon di menu/settori (synthwave spaziale, stona con carta e matita) e le tracce Droplet più "ambientali" per mondo (giungla, deserto, vulcano) che non hanno un momento di gioco corrispondente.

Mappatura in `MAP` dentro `MUSIC` (fondo dello script). Pausa abbassa al 35 %, fine partita al 40 %, jingle al 12 %. Impostazioni → Audio: interruttore e volume della musica (`prefs.music`, `prefs.musicVol`), indipendenti dagli effetti.

## Effetti
Sintetizzati (`SFX` in `dist/index.html`): oscillatori e rumore filtrato (matita, colpi, pop, gommata), compressore sul bus. Il volume (`prefs.volume`, default 80) è un'uscita reale: picchi da −8 a −25 dBFS prima del compressore. Limitatore di frequenza per `shoot`/`hit`/`pop`.

### Perché prima non si sentivano
1. Bip sinusoidali da 0,045 di guadagno (circa −27 dBFS; `shoot` −35 dBFS) senza compressione.
2. Su iOS il Web Audio in WKWebView è zittito dal tasto Silenzioso con la sessione audio predefinita: ora `navigator.audioSession.type='playback'` + `AVAudioSession .playback` in `AppDelegate.swift`.
3. Lo sblocco avveniva su `pointerdown`; iOS richiede un gesto "vero" (`touchend`/`click`): i listener restano armati finché il contesto non è `running` e si riarmano dopo sospensioni/interruzioni (`window.__audioResume` chiamato da Swift).
4. Mancavano le chiamate agli effetti di sparo e danno alle difese.

## Non ancora verificato su dispositivo
Bilanciamento musica/effetti, ripresa dopo interruzioni e memoria in WKWebView (circa 35 MB per `menu`, 21 MB per gli altri brani decodificati).
