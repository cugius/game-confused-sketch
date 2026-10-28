# Prompt musiche · Confused Sketch (Gemini)

**Perché nuove musiche.** I brani attuali vengono da altri giochi della serie: kalimba e gocce d'acqua (Droplet: natura, pioggia), arpeggi sintetici «neon» e un jingle di sconfitta spaziale (Photon). Funzionano come segnaposto, ma raccontano acqua e spazio, non un foglio di carta con matita e gomme. Per Sketch serve una tavolozza sonora «da cartoleria»: pizzicato, pianoforte ovattato, xilofono, legnetti, spazzole, piccoli rumori di carta e matita.

**Come usarli.** Un prompt per messaggio, in una chat nuova per ogni brano (Gemini genera un solo brano per richiesta). Se un brano esce più lungo o con uno stacco in mezzo va bene lo stesso: si taglia e si rifà la giunzione del loop. Per un suono unitario si può aggiungere a ogni prompt: «same sonic palette as a cohesive game soundtrack: pizzicato strings, felt piano, xylophone, wood blocks, brushed snare, no synths».

Nome file consigliato → momento in cui suona (il lettore è `MUSIC` in `dist/index.html`, vedi `docs/MUSIC.md`: basta mettere i file in `assets/audio/` con questi nomi e lanciare `node scripts/embed-music.cjs`).

| File | Momento |
|---|---|
| `menu.mp3` | home |
| `build.mp3` | preparazione tra le ondate |
| `wave.mp3` | ondata in corso (Quaderno e Sfida) |
| `paths.mp3` | ondata in corso nei Percorsi |
| `boss.mp3` | ondata con boss (opzionale) |
| `victory.mp3` | jingle di vittoria |
| `gameover.mp3` | jingle di sconfitta |

---

## 01 · menu
```
Create ONE single instrumental track, about 60 seconds, seamless loop. Playful stationery-shop ambient game music: plucked pizzicato strings, soft felt piano, light xylophone, a gentle brushed snare and wood-block ticks like a pencil tapping on paper, warm and whimsical, 80 bpm, major key. No vocals.
```

## 02 · build
```
Create ONE single instrumental track, about 60 seconds, seamless loop. Calm thinking-at-the-desk music: slow felt piano, soft harp-like plucks, distant clock ticking, a warm low cello pad, curious and relaxed, 66 bpm. No vocals, no drums.
```

## 03 · wave
```
Create ONE single instrumental track, about 60 seconds, seamless loop. Mischievous cat-and-mouse tension: staccato pizzicato strings, upright bass walking line, wood blocks and brushed snare, a few xylophone accents, light and quick but a little tense, 112 bpm, minor key. No vocals, no synths.
```

## 04 · paths
```
Create ONE single instrumental track, about 60 seconds, seamless loop. Steady strategic march for a tower-defense game drawn on paper: ukulele and pizzicato ostinato, glockenspiel melody, soft marching snare brushes, determined and cheerful, 100 bpm, major key with a minor turn. No vocals, no synths.
```

## 05 · boss
```
Create ONE single instrumental track, about 60 seconds, seamless loop. A giant eraser boss arrives: low cello and double bass ostinato, deep soft timpani pulse, dry wood percussion, short squeaky rubbing textures, dramatic but playful rather than scary, 120 bpm, minor key. No vocals.
```

## 06 · victory (10 secondi, una sola volta)
```
Create ONE single short instrumental jingle, 10 seconds, played only once and ending cleanly. Cheerful victory: xylophone and glockenspiel run, warm felt piano chords and light strings, a final page-turning flourish, resolves brightly. No vocals.
```

## 07 · gameover (8 secondi, una sola volta)
```
Create ONE single short instrumental jingle, 8 seconds, played only once and ending cleanly. Gentle defeat: a descending pizzicato phrase and a soft muted piano, a small sigh of strings, like a crumpled sheet of paper, sad but tender and not dramatic. No vocals.
```

---

## Dopo la generazione
1. Tagliare e normalizzare come per gli altri brani (loudnorm −20 LUFS, MP3 80 kbps, 44,1 kHz): vedi `docs/MUSIC.md`.
2. Aggiornare `MAP` in `MUSIC` (`build`, `wave`, `paths`, `boss`) e la pagina Crediti non cambia: dichiara già «generate con IA (Google Gemini)».
3. Controllare le condizioni d'uso di Google per l'uso commerciale prima della pubblicazione sullo store.
