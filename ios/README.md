# Wrapper iOS — Confused Sketch

Bundle ID proposto: `com.confusedbyme.sketch`. Deployment target: iOS 16. Nome visibile: Confused Sketch. Nessun server, pubblicità, tracciamento, accesso fotocamera o microfono.

## Senza installare Xcode sul proprio computer

A ogni push su main GitHub Actions esegue **Game checks** e **iOS Simulator**. La seconda produce un archivio `.app` per simulatore macOS, non installabile sul telefono. Il file HTML resta giocabile da Safari.

## Apertura su Mac / firma

1. Installa Xcode e XcodeGen (`brew install xcodegen`).
2. Dalla radice esegui `python3 scripts/sync-ios.py`.
3. Esegui `xcodegen generate --spec ios/project.yml` e apri `ios/ConfusedSketch.xcodeproj`.
4. In Signing & Capabilities seleziona il tuo Team Apple. Conferma il Bundle ID: deve corrispondere all’App ID e all’app App Store Connect.
5. Per un iPhone collegato scegli il dispositivo e Run. Per TestFlight: Generic iOS Device → Product → Archive → Distribute App → App Store Connect.

La firma/il caricamento non sono configurati con credenziali nel repository. Per una futura pipeline TestFlight serviranno Team ID, App ID definitivo e una strategia di firma (certificato/profilo o firma automatica autorizzata), oltre alla chiave App Store Connect. Non inserire chiavi o certificati nei sorgenti.

## Comportamento nativo

- `WKWebView` carica `Web/index.html` dal bundle, con accesso limitato alla cartella Web.
- Dati persistenti WebKit sul dispositivo; il passaggio Safari → app non importa automaticamente i salvataggi.
- Nessuna navigazione remota, nessun SDK aggiuntivo.
- Zoom nativo disattivato; gesture JavaScript del canvas ancora disponibili.
- Uscire dall’app invia l’evento di pausa/salvataggio al gioco.
- Icona geometrica provvisoria inclusa, da sostituire se si approva un’identità definitiva.

La compilazione nativa viene verificata dai runner macOS: l’ambiente di sviluppo Linux non esegue Xcode.
