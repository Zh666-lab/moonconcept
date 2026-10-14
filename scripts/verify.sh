#!/usr/bin/env bash
set -euo pipefail
target="${1:-wasm-gc}"
moon info
moon fmt --check
git diff --exit-code -- '*.mbti'
moon check --target "$target" --deny-warn
moon test --target "$target" --deny-warn
moon build --target "$target" --deny-warn
moon run examples/features --target "$target" > features.json
moon run examples/roles --target "$target" > roles.txt
moon run examples/catalog --target "$target" > catalog.json
python3 - <<'PY'
import json
from pathlib import Path
features = json.loads(Path('features.json').read_text())
roles = json.loads(Path('roles.txt').read_text().splitlines()[0])
catalog = json.loads(Path('catalog.json').read_text())
assert features['touch_closure'] == ['touch', 'portable']
assert roles['violating_identities'] == ['contributor']
assert catalog['merged_objects'] == 4 and catalog['cxt_roundtrip_equal']
for path in ('features.json', 'roles.txt', 'catalog.json'):
    Path(path).unlink()
PY
python3 scripts/measure.py
