#!/usr/bin/env python3
"""Copy the canonical, self-contained game into the iOS bundle."""
from pathlib import Path
import shutil
root = Path(__file__).resolve().parents[1]
target = root / "ios/Web"
target.mkdir(parents=True, exist_ok=True)
shutil.copyfile(root / "dist/index.html", target / "index.html")
print("iOS Web/index.html synchronized")
