#!/usr/bin/env python3
"""Copy the canonical, self-contained game into the iOS bundle."""
from pathlib import Path
import shutil
import subprocess
root = Path(__file__).resolve().parents[1]
subprocess.run(["npm", "run", "check"], cwd=root, check=True)
target = root / "ios/Web"
target.mkdir(parents=True, exist_ok=True)
shutil.copyfile(root / "dist/index.html", target / "index.html")
shutil.copyfile(root / "assets/gamecenter/definitions.json", target / "gamecenter.json")
print("iOS Web game and Game Center catalog synchronized")
