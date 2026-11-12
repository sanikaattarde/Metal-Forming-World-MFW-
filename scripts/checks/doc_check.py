#!/usr/bin/env python3
"""QG-12, the documentation check (MOD15-P2-T01, CI_CD_AND_QUALITY_GATES.md section 4).

1. Every relative link in a Markdown file of the repository points to a file or folder that exists.
2. Every task ID (MODnn-Pn-Tnn) named in Documentation/ is in IMPLEMENTATION_MODULE_INVENTORY.md or a roadmap.
3. Every DEC-nnn named in Documentation/ has a row in DECISION_LOG.md, and every OQ-nn one in OPEN_QUESTIONS.md.

Report only: it prints its findings and exits 0, unless --strict is given (then 1 on a finding).
Run from the repository root:  python3 scripts/checks/doc_check.py
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
DOCS = ROOT / 'Documentation'
SKIP = {'node_modules', '.git', 'build', 'dist', '.dart_tool', 'inputs', '.claude'}
LINK = re.compile(r'\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)')


def markdown_files():
    for path in ROOT.rglob('*.md'):
        if not any(part in SKIP for part in path.relative_to(ROOT).parts):
            yield path


def main():
    findings = []
    for path in markdown_files():
        text = path.read_text(encoding='utf-8')
        # Links inside code blocks are examples, not links.
        text = re.sub(r'```.*?```', '', text, flags=re.S)
        for target in LINK.findall(text):
            if re.match(r'^[a-z]+:', target) or target.startswith('#'):
                continue
            file_part = target.split('#', 1)[0]
            if file_part and not (path.parent / file_part).exists():
                findings.append(f'{path.relative_to(ROOT)}: broken link to {target}')

    tasks = set()
    for name in ('IMPLEMENTATION_MODULE_INVENTORY.md', 'SANIKA_IMPLEMENTATION_ROADMAP.md', 'YUVRAJ_IMPLEMENTATION_ROADMAP.md', 'SANIKA_WSA_IMPLEMENTATION_PLAN.md'):
        if (DOCS / name).exists():
            tasks |= set(re.findall(r'MOD\d{2}-P\d-T\d{2}', (DOCS / name).read_text(encoding='utf-8')))
    decision_rows = set(re.findall(r'^\| (DEC-\d{3}) \|', (DOCS / 'DECISION_LOG.md').read_text(encoding='utf-8'), flags=re.M))
    question_rows = set(re.findall(r'^\| (OQ-\d{2}) \|', (DOCS / 'OPEN_QUESTIONS.md').read_text(encoding='utf-8'), flags=re.M))
    for path in DOCS.rglob('*.md'):
        text = path.read_text(encoding='utf-8')
        name = path.relative_to(ROOT)
        for task in sorted(set(re.findall(r'MOD\d{2}-P\d-T\d{2}', text)) - tasks):
            findings.append(f'{name}: task {task} is in no roadmap')
        for dec in sorted(set(re.findall(r'\bDEC-\d{3}\b', text)) - decision_rows):
            findings.append(f'{name}: {dec} has no row in DECISION_LOG.md')
        for oq in sorted(set(re.findall(r'\bOQ-\d{2}\b', text)) - question_rows):
            findings.append(f'{name}: {oq} has no row in OPEN_QUESTIONS.md')
    for finding in findings:
        print(f'QG-12 finding: {finding}')
    print(f'QG-12: {len(findings)} finding(s)')
    return 1 if findings and '--strict' in sys.argv else 0


if __name__ == '__main__':
    sys.exit(main())
