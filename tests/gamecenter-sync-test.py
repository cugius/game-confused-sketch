#!/usr/bin/env python3
"""Offline checks for the Game Center definitions (no network, no Apple account)."""
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('gc_sync', ROOT / 'scripts/gc-sync.py')
gc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gc)


def main():
    errors, total = gc.validate()
    if errors:
        print('\n'.join(errors))
        return 1
    # Negative checks: the validator must reject a broken definition.
    broken = json.loads(gc.DEFS.read_text(encoding='utf8'))
    broken['achievements'][0]['names'].pop('ja')
    if not gc.validate(broken)[0]:
        print('FAIL: il validatore non rileva una lingua mancante')
        return 1
    print(f'PASS: Game Center definitions complete ({total} punti)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
