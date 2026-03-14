@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo === PySInfo PyPI Upload ===

echo [1/6] Bumping patch version...
python -c "import re; t=open('pysinfo/__init__.py', encoding='utf-8').read(); m=re.search(r'(__version__\s*=\s*\"(\d+\.\d+\.)(\d+)\")', t); new_v=m.group(2)+str(int(m.group(3))+1); open('pysinfo/__init__.py', 'w', encoding='utf-8').write(t.replace(m.group(1), '__version__ = \"'+new_v+'\"')); print(f'  {m.group(2)}{m.group(3)} -> {new_v}')"

for /f "tokens=*" %%i in ('python -c "import re; t=open('pysinfo/__init__.py', encoding='utf-8').read(); m=re.search(r'__version__\s*=\s*\"(\d+\.\d+\.\d+)\"', t); print(m.group(1) if m else 'unknown')"') do set NEW_VERSION=%%i

echo [2/6] Cleaning old builds...
if exist dist rmdir /s /q dist
if exist build rmdir /s /q build
if exist *.egg-info rmdir /s /q *.egg-info
if exist pysinfo.egg-info rmdir /s /q pysinfo.egg-info

echo [3/6] Installing build tools...
python -m pip install --upgrade build twine -q

echo [4/6] Building package...
python -m build
python -m twine check dist/*

echo [5/6] Uploading to PyPI...
python -m twine upload dist/*

echo [6/6] Pushing to Git...
git add -A
git commit -m "Bump version to %NEW_VERSION%"
git push

echo === Done! Version %NEW_VERSION% uploaded and pushed ===