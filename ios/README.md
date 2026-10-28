# Wrapper iOS — Confused Sketch

Bundle ID: `com.confusedbyme.confusedsketch`. iOS 16+, iPhone e iPad. UIKit + WKWebView: il gioco è copiato da `dist/index.html` a `ios/Web/index.html` durante la build e resta offline.

- [Pubblicazione TestFlight e secret richiesti](TESTFLIGHT.md).
- `project.yml`: specifica XcodeGen; progetto Xcode e cartella Web vengono generati, non mantenuti a mano.
- `ConfusedSketch/`: sorgenti nativi, Game Center, feedback aptico, privacy manifest e icona.
- La pipeline Simulator non produce build TestFlight.

Il progetto usa firma automatica con App Store Connect API durante l'export. La scheda app Apple deve già esistere con il Bundle ID esatto e la chiave deve potervi accedere.

Per verificare le risorse: `python3 scripts/sync-ios.py` e `python3 scripts/check-ios.py` dalla radice.
