# TestFlight — Confused Sketch

Workflow: .github/workflows/ios-testflight.yml. Bundle ID: com.confusedbyme.sketch.

Uses the same cloud signing configuration as Confused Photon. Configure these four secrets at repository level or in the testflight environment:

- ASC_KEY_ID
- ASC_ISSUER_ID
- ASC_KEY_P8_BASE64 (base64-encoded App Store Connect .p8 API key)
- APPLE_TEAM_ID

The existing App Store Connect app must use the exact bundle ID above, and the API key must have access to its Apple team and cloud-managed signing.

Run iOS TestFlight upload from Actions on main. Default version: 0.57.0. The build number is github.run_number; retry a failed run only if upload did not succeed. A new run generates a new build number. Changes to this workflow also trigger a build on main; ordinary game pushes retain the simulator checks and do not upload automatically.

The job validates secret presence without displaying values, tests and synchronizes the offline HTML, generates the Xcode project, archives with Xcode 26, preserves Game Center entitlements and exports/uploads with automatic distribution signing. The API key is removed even on failure. Logs are retained for seven days.

A successful upload is followed by Apple processing; it does not publish the app on the App Store or automatically assign testers. Check App Store Connect > Confused Sketch > TestFlight for processing, compliance questions and tester-group assignment.
