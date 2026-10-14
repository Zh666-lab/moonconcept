"""Conservative production-line measurement: excludes tests, examples and generated files."""
from pathlib import Path
import json

root = Path(__file__).resolve().parent.parent
files = []
for path in sorted(root.glob('*.mbt')):
    if path.name.endswith(('_test.mbt', '_wbtest.mbt')):
        continue
    lines = path.read_text(encoding='utf-8-sig').splitlines()
    substantive = sum(bool(line.strip()) and not line.lstrip().startswith('//') for line in lines)
    files.append({'path': path.name, 'physical': len(lines), 'nonblank_noncomment': substantive})
summary = {'files': files, 'physical': sum(f['physical'] for f in files),
           'nonblank_noncomment': sum(f['nonblank_noncomment'] for f in files)}
print(json.dumps(summary, indent=2))
assert summary['nonblank_noncomment'] >= 1500
