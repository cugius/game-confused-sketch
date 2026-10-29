# Game Center artwork and approved app icon

The approved app icon is the dark green seal with **white graph paper**, three pencil rings, golden spark and pink eraser. It is exported as an opaque 1024×1024 RGB PNG into the existing iOS AppIcon catalog. No game version, gameplay, TestFlight upload workflow or Apple build is changed by this asset preparation.

## Files on main

- `assets/branding/app-icon-white-paper.webp.base64`: lossless, reproducible source of the approved icon, normalized to 1024×1024. Do not use earlier yellow-paper or triangle concepts.
- `assets/gamecenter/images/cs.*.png`: 44 achievement images and 3 leaderboard images, all distinct, 1024×1024 RGB, 72 dpi.
- The matching SVG sources, image SHA-256 values in `manifest.json`, and a `contact-sheet.jpg` visual index are in that same directory.
- `definitions.json` remains the source for the 44 achievement identifiers, 945 points, three leaderboard identifiers and six languages (IT, EN, ES, FR, DE, JA).

The artwork uses original vector motifs aligned with the game's ICO pictograms, a white notebook background and the six achievement group palettes. Images are language neutral; the same image is associated with each of the six localizations. Important leaderboard content remains within the central 1024×624 crop.

## Regenerate or check

```sh
python -m pip install Pillow CairoSVG requests PyJWT cryptography
python scripts/prepare-gamecenter-assets.py
python scripts/gc-sync.py --validate-only
python tests/gamecenter-sync-test.py
```

The **Prepare Game Center artwork** workflow exports and commits generated files using `[skip ci]`. Its preparation commit uses `[assets only]` so the simulator job is skipped. It does not launch an iOS build. After committing the files, a separate audit job uses the existing `testflight` credentials strictly for a read-only inventory on Apple and saves `gamecenter-apple-audit.json`. It never applies remote changes. Future normal Claude commits retain the existing simulator behavior.

## Apple synchronization

The separate **Game Center sync** workflow remains **manual**, with `apply=false` by default. Run it from main after the artwork preparation has completed. A dry run reports missing remote resources; setting `apply=true` creates missing achievements and leaderboards, reconciles six localizations, and uploads/commits/polls all localized images (47×6 = 282 associations).

The synchronizer can recover missing localizations after a partial prior run and resume image reservations. It skips completed images that match the content-addressed filenames. Existing achievement point mismatches stop the run for inspection. It never resets scores or submits an App Store review.

Local files being ready **does not certify that Apple already has them**. Only a successful remote apply run reporting 282/282 ready images certifies delivery. The local unit tests simulate Apple; they are not evidence of remote delivery.

## Handoff to Claude

Start from the latest main, preserve the AppIcon catalog, branding source, image identifiers and artwork scripts. Complete the pending game changes. The user will start the TestFlight build after those changes; choose the desired marketing version explicitly because the existing workflow default is still 0.57.0. App Store review and external tester availability are separate from generating these assets.
