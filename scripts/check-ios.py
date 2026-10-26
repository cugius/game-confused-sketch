#!/usr/bin/env python3
from pathlib import Path
import plistlib, json
root = Path(__file__).resolve().parents[1]
assert (root/'ios/Web/index.html').read_bytes() == (root/'dist/index.html').read_bytes()
info = plistlib.loads((root/'ios/ConfusedSketch/Info.plist').read_bytes())
assert info['CFBundleDisplayName'] == 'Confused Sketch'
assert info['CFBundleIdentifier'] == '$(PRODUCT_BUNDLE_IDENTIFIER)'
privacy = plistlib.loads((root/'ios/ConfusedSketch/PrivacyInfo.xcprivacy').read_bytes())
assert not privacy['NSPrivacyTracking']
icons = json.loads((root/'ios/ConfusedSketch/Assets.xcassets/AppIcon.appiconset/Contents.json').read_text())
assert all((root/'ios/ConfusedSketch/Assets.xcassets/AppIcon.appiconset'/i['filename']).exists() for i in icons['images'])
print('PASS: bundled HTML, Info.plist, privacy manifest and icons')
