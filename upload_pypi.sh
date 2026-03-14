#!/usr/bin/env bash
# PySInfo - Build, upload to PyPI, and push to Git
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

PYTHON="${PYTHON:-python3}"
VERSION_FILE="pysinfo/__init__.py"

echo "=== PySInfo PyPI Upload ==="

echo "[1/6] Bumping patch version..."
"$PYTHON" -c "
import re, sys
p = '$VERSION_FILE'
t = open(p, encoding='utf-8').read()
m = re.search(r'(__version__\s*=\s*\"(\d+\.\d+\.)(\d+)\")', t)
if not m: print('ERROR: cannot parse version'); sys.exit(1)
old_v = m.group(2) + m.group(3)
new_v = m.group(2) + str(int(m.group(3)) + 1)
open(p, 'w', encoding='utf-8').write(t.replace(m.group(1), '__version__ = \"' + new_v + '\"'))
print(f'  {old_v} -> {new_v}')
"

NEW_VERSION=$("$PYTHON" -c "
import re
t = open('$VERSION_FILE', encoding='utf-8').read()
m = re.search(r'__version__\s*=\s*\"(\d+\.\d+\.\d+)\"', t)
print(m.group(1) if m else 'unknown')
")

echo "[2/6] Cleaning old builds..."
rm -rf dist/ build/ *.egg-info pysinfo.egg-info

echo "[3/6] Installing build tools..."
"$PYTHON" -m pip install --upgrade build twine -q

echo "[4/6] Building package..."
"$PYTHON" -m build
"$PYTHON" -m twine check dist/*

echo "[5/6] Uploading to PyPI..."
"$PYTHON" -m twine upload dist/*

echo "[6/6] Pushing to Git..."
git add -A
git commit -m "Bump version to $NEW_VERSION"
git push

echo "=== Done! Version $NEW_VERSION uploaded and pushed ==="