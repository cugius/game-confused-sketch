#!/usr/bin/env python3
"""Validate the Game Center definitions before any App Store Connect sync.

The network sync itself lives in scripts/gc-sync.rb (dry run by default).
`--validate-only` runs offline checks and never contacts Apple.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFS = ROOT / 'assets/gamecenter/definitions.json'
LANGS = ['it', 'en', 'es', 'fr', 'de', 'ja']
MAX_TOTAL_POINTS = 1000   # Game Center limit per app
MAX_POINTS_EACH = 100     # Game Center limit per achievement
ACHIEVEMENT_COUNT = 44
LEADERBOARD_COUNT = 3


def validate(data=None):
    if data is None:
        data = json.loads(DEFS.read_text(encoding='utf8'))
    errors = []
    prefix = data.get('prefix', '')
    if not prefix:
        errors.append('prefix mancante')
    achievements = data.get('achievements', [])
    leaderboards = data.get('leaderboards', [])
    if len(achievements) != ACHIEVEMENT_COUNT:
        errors.append(f'achievement: attesi {ACHIEVEMENT_COUNT}, trovati {len(achievements)}')
    if len(leaderboards) != LEADERBOARD_COUNT:
        errors.append(f'classifiche: attese {LEADERBOARD_COUNT}, trovate {len(leaderboards)}')
    ids = [a.get('id') for a in achievements] + [l.get('id') for l in leaderboards]
    if len(set(ids)) != len(ids):
        errors.append('id duplicati')
    total = 0
    for a in achievements:
        aid = a.get('id', '?')
        if not str(aid).startswith(prefix):
            errors.append(f'{aid}: id senza prefisso {prefix}')
        pts = a.get('points')
        if not isinstance(pts, int) or pts <= 0 or pts % 5 or pts > MAX_POINTS_EACH:
            errors.append(f'{aid}: punti non validi ({pts})')
        else:
            total += pts
        for field in ('names', 'descriptions'):
            values = a.get(field, {})
            for lang in LANGS:
                if not isinstance(values.get(lang), str) or not values[lang].strip():
                    errors.append(f'{aid}: {field}[{lang}] mancante')
    if total > MAX_TOTAL_POINTS:
        errors.append(f'punti totali {total} oltre il limite {MAX_TOTAL_POINTS}')
    for board in leaderboards:
        bid = board.get('id', '?')
        for lang in LANGS:
            value = board.get('names', {}).get(lang)
            if not isinstance(value, str) or not value.strip():
                errors.append(f'{bid}: nome[{lang}] mancante')
    return errors, total


def main(argv):
    if '--validate-only' not in argv:
        print('Uso: python3 scripts/gc-sync.py --validate-only (la sincronizzazione è in scripts/gc-sync.rb)')
        return 2
    errors, total = validate()
    if errors:
        print('\n'.join(errors))
        return 1
    print(f'PASS: definizioni Game Center valide ({ACHIEVEMENT_COUNT} traguardi, {total} punti, {LEADERBOARD_COUNT} classifiche)')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
