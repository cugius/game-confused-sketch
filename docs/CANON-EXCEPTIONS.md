# Canon v0.3: Sketch implementation notes

- Runtime default/fallback is EN, then supported device language, with saved manual choice taking precedence. Italian lookup keys are retained for compatibility with the existing catalog; the key language is not the UI default. Catalog completeness is checked in six declared languages (IT/EN/ES/FR/DE/JA).
- The settings have four tabs (Audio, Game, Look, Info); graphics explanations use an accordion. Core controls remain visible.
- Native audio deliberately preserves the existing playback/mixWithOthers policy: audio follows in-game switches even with Silent Mode; external media is not forcibly interrupted. Background stops game audio. Reconsidering that UX policy requires an explicit product decision.
- First authenticated Game Center account owns local submissions. On an account change, local progress remains playable but is not uploaded to the other account. The explicit local-data reset clears that binding; it never resets Apple achievements/scores. This is intentionally conservative.
- Shared gamepad geometry is in assets/branding/gamepad.svg; in-game markup uses that same geometry.
- Tests on physical iPhones/iPads, Taptic Engine, GameKit authentication, Bluetooth route changes and native/GPU memory remain required before distribution. CI/simulation is not physical-device certification.
- This repository is currently the first pinned distribution of the common canon; a separate umbrella repository has not been created.
