#!/usr/bin/env python3
"""QG-10, the dependency and licence check (MOD15-P2-T01, CI_CD_AND_QUALITY_GATES.md section 4).

1. Every direct dependency of app/, backend/, backend/functions/ and admin/ is named in
   Documentation/DEPENDENCY_REGISTER.md.
2. Every direct npm dependency that is installed declares a licence on the allowed list.

Report only: it prints its findings and exits 0, unless --strict is given (then 1 on a finding).
Run from the repository root:  python3 scripts/checks/licence_check.py
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
REGISTER = (ROOT / 'Documentation' / 'DEPENDENCY_REGISTER.md').read_text(encoding='utf-8')
ALLOWED = {'MIT', 'ISC', 'BSD-2-Clause', 'BSD-3-Clause', 'Apache-2.0', '0BSD', 'BlueOak-1.0.0', 'Unlicense', 'CC0-1.0', 'Python-2.0'}


def registered(name):
    # A name counts when the register shows it in backticks or as a whole word in a table row.
    return (
        f'`{name}`' in REGISTER
        or re.search(rf'\|[^|\n]*\b{re.escape(name)}\b', REGISTER) is not None
        or re.search(rf'^#+ .*\b{re.escape(name)}\b', REGISTER, flags=re.M) is not None
    )


def dart_direct(lock):
    names, current = [], None
    for line in lock.read_text(encoding='utf-8').splitlines():
        m = re.match(r'^  ([a-z0-9_]+):$', line)
        if m:
            current = m.group(1)
        elif current and line.strip().startswith('dependency: "direct'):
            names.append(current)
    return names


def npm_direct(folder):
    package = json.loads((folder / 'package.json').read_text(encoding='utf-8'))
    return sorted({*package.get('dependencies', {}), *package.get('devDependencies', {})})


def npm_licence(folder, name):
    manifest = folder / 'node_modules' / name / 'package.json'
    if not manifest.exists():
        return None
    value = json.loads(manifest.read_text(encoding='utf-8')).get('license')
    return value.get('type') if isinstance(value, dict) else value


def licence_allowed(expression):
    parts = re.split(r'\s+(?:OR|AND)\s+', str(expression).strip('() '))
    return all(p.strip('() ') in ALLOWED for p in parts)


def main():
    findings = []
    lock = ROOT / 'app' / 'pubspec.lock'
    for name in dart_direct(lock):
        if name not in ('flutter', 'flutter_test', 'integration_test') and not registered(name):
            findings.append(f'app: {name} is not in DEPENDENCY_REGISTER.md')
    for sub in ('backend', 'backend/functions', 'admin'):
        folder = ROOT / sub
        if not (folder / 'package.json').exists():
            continue
        for name in npm_direct(folder):
            if not registered(name):
                findings.append(f'{sub}: {name} is not in DEPENDENCY_REGISTER.md')
            licence = npm_licence(folder, name)
            if licence is None:
                continue
            if not licence_allowed(licence):
                findings.append(f'{sub}: {name} declares {licence}, not on the allowed list')
    for finding in findings:
        print(f'QG-10 finding: {finding}')
    print(f'QG-10: {len(findings)} finding(s)')
    return 1 if findings and '--strict' in sys.argv else 0


if __name__ == '__main__':
    sys.exit(main())
