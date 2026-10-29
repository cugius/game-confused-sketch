# Confused Sketch working agreements

Read `docs/CANON.md` (v0.3), `docs/CANON-EXCEPTIONS.md` and `docs/GAMEPLAY.md` before changes. Apply the `confused-by-me-canon` skill in `.agents/skills/`.

- Edit `web/src/` and original `assets/`; `dist/index.html` and `ios/Web/` are generated. Run `npm run build` and `python3 scripts/sync-ios.py`.
- Keep save keys, gameplay, approved white-paper icon and Game Center IDs stable. Preserve concurrent changes.
- Run `npm run check`, `node tests/balance.cjs`, `python3 tests/gamecenter-sync-test.py`, and `python3 scripts/check-ios.py`. Run `npm run test:ui` with Playwright browsers installed for layout/i18n changes.
- Do not claim native-device, memory/GPU or Apple delivery checks passed from mocks. Document remaining checks.
- Fix requests do not start TestFlight or App Store review. Follow the explicit release authorization in the current conversation.
