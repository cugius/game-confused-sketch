# Canon v0.3 — Sketch implementation review

29 October 2026. Based on upstream main `274fdf7ad51b8a238c57090965ce6bc9588f4224`. This report covers implementation and local checks; it is not a TestFlight or physical-device certification.

## Implemented

- One shared music bus governs loops and result jingles. Volume zero/mute affect playing jingles; leaving a context or going to background cancels pending decodes and stops jingles. Foreground events resume the intact voice without recreating it. Music scheduler stops while suspended/muted; decoded cache is limited to 64 MiB with eviction.
- Native interruption begin/end, foreground, output-route change and media-services reset have distinct handlers. Activation is retried in foreground even if iOS did not deliver an interruption-ended event. Gameplay stays paused. The existing playback/mixWithOthers policy remains documented.
- Native Game Center and haptic bridges accept only versioned, size-limited messages from the bundled main frame. Catalog IDs and numeric limits are validated. JavaScript arguments use JSON serialization.
- Game Center submissions have account-bound persistent pending records, bounded catalog keys, delivery receipts and exponential retry up to 60 seconds. Changing accounts does not silently upload the previous account's local progress. The explicit local-data reset clears the binding, not Apple's records.
- Achievements use the shared Droplet gamepad, with explicit activation and translated connection/pending/error/account states. The local achievement icon remains a trophy.
- Aptics no longer claim capability from touch alone; native/vibrate support is required. Music and sound switches remain independent of aptics.
- Runtime language default/failure fallback is English, with manual choice then supported device language taking precedence. Added translations for new states and missing achievement labels; already translated values are recognized by dynamic localization.
- Tutorial cannot change ordinary statistics, badges, stars, scores or Game Center submissions and preserves an existing saved run. Completion remains a separate flag.
- Settings details use an accordion, tabs have accessible relationships/keyboard navigation and compact labels; enlarged text no longer scales the entire panel with CSS zoom.
- Authoritative sources are split under web/src; assets remain originals. build-web.cjs produces the same single offline HTML. Original helper commands delegate to the source build. Native bundling runs the preflight/regression checks.
- Removed 12 verified unused legacy helper functions, including the obsolete achievement renderer/service button, old drawing helpers, obsolete audio alias/toggle and unused camera/perk test helpers. Existing runtime gestures, fallback renderer and migrations remain.
- Visual caches are cleared between runs; bounded WebGL layers delete GPU buffers, and context restoration can reinitialize the renderer.
- Added CSP restricting network/execution capabilities, focused source-security checks, lockfile/dependency audit and six native error localizations. Development browser tools are not bundled in the game.
- Canon, exceptions, portable skill variants, phone setup instructions and AGENTS.md/CLAUDE.md are included. Historical comparison remains explicitly pinned to its earlier snapshot; it is not the current compliance report.

## Local evidence

- Gameplay regression suite and balance simulations passed.
- Music regression mocks passed: live jingle mute/volume zero, suspension/scheduler, repeated foreground, late-decoding cancellation and cache budget.
- Canon behavior tests passed: device/manual language priority, tutorial isolation/saved run, real haptic capability, gamepad activation and status.
- Original Game Center catalog tests passed; local artwork validation confirms 47 images, six locales and 945 points. No Apple catalog delivery was performed by this change.
- Reproducible source/bundle, syntax, locale columns/placeholders, bridge guards, private-key scan and unreferenced-function candidate checks passed.
- npm dependency audit returned zero known vulnerabilities at the time of the local check. This is not a complete security certification.
- Browser matrix scripts cover five viewport classes, six languages, both text scales and nine routes, collecting screenshots, overflow checks, uncaught errors and dynamic missing translations. Final matrix: **540/540 routes passed**, zero uncaught browser errors, zero required missing translations and no viewport overflow. Screenshots from representative English/large-text cases were visually inspected; compact tab wrapping was corrected. These are Chromium software-rendered checks, not native-device certification.

## Budgets and remaining verification

The decoded music cache is capped at 64 MiB; dynamic GPU particles at the existing 7,000 cap, spark particles at 260 and static WebGL layers at 14. These are code limits, not measured native peak-memory budgets. Physical-device heap/GPU profiling and prolonged sessions remain open.

The Linux environment cannot compile UIKit/GameKit; a simulator build is still required. Physical iPhone/iPad tests remain required for audio routes, interruption recovery, Silent Mode, actual aptics, safe area, multitouch and GameKit account behavior. A passing browser matrix does not certify Safari/WKWebView or all devices.

Remote publication was blocked by automatic approval review, which requested explicit approval of publication to the public cugius/game-confused-sketch repository. No workaround is used. TestFlight and App Store review have not been started.
