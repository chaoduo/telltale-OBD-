#!/usr/bin/env python3
"""Turn a translator's CSV into a shipped ARB locale.

The CSV is what a translator fills in by hand: one row per message key, the
first column the key, the second the target text. Everything else about the
file — key order, the `@@locale` tag, which keys exist — comes from the English
template, so a translation cannot quietly drop a key or invent one.

Read the CSV leniently, write the ARB strictly. A hand-edited spreadsheet grows
line breaks inside cells, and the exporter may leave those unquoted; a record
therefore continues until the next line that starts with `key,`. What survives
that repair is then checked: missing keys, unknown keys, empty values and ICU
argument drift are all failures, and `i18n_verify/check_arb.py` re-checks the
written file against the template before the exit code says 0.

    python3 tool/i18n/apply_translation.py --locale zh_Hans --csv translated.csv
"""
from __future__ import annotations

import argparse
import csv
import io
import json
import re
import sys
from pathlib import Path

_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(_ROOT / "tool" / "i18n_verify"))

from check_arb import _icu_names, check_files  # noqa: E402

_RECORD_START = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*,")


def _records(text: str) -> list[str]:
    """Split CSV text into records, keeping line breaks inside a cell."""
    records: list[str] = []
    for line in text.splitlines():
        if _RECORD_START.match(line) or not records:
            records.append(line)
        else:
            records[-1] += "\n" + line
    return [record for record in records if record.strip()]


def _fields(record: str) -> list[str]:
    """Split one record.

    Falls back to the first comma when a newline inside a cell arrived
    unquoted: `csv` reads such a line as the start of a second record and would
    drop everything after the break.
    """
    try:
        rows = list(csv.reader(io.StringIO(record)))
    except csv.Error:
        rows = []
    if len(rows) == 1:
        return rows[0]
    key, _, rest = record.partition(",")
    if len(rest) >= 2 and rest.startswith('"') and rest.endswith('"'):
        rest = rest[1:-1].replace('""', '"')
    return [key, rest]


def read_csv(path: Path, column: str | None) -> tuple[dict[str, str], list[str]]:
    """Return key -> translation, plus the complaints that did not stop it."""
    warnings: list[str] = []
    rows = _records(path.read_text(encoding="utf-8-sig"))
    if not rows:
        raise SystemExit(f"{path}: empty")
    header = _fields(rows[0])
    index = 1
    if column is not None:
        if column not in header:
            raise SystemExit(f"{path}: no column {column!r} in {header}")
        index = header.index(column)
    elif len(header) < 2:
        raise SystemExit(f"{path}: header has no translation column: {header}")

    values: dict[str, str] = {}
    for record in rows[1:]:
        fields = _fields(record)
        key = fields[0].strip()
        if len(fields) <= index:
            warnings.append(f"{key}: no value in column {index}; left empty")
            values[key] = ""
            continue
        if len(fields) > index + 1:
            warnings.append(
                f"{key}: {len(fields) - 1} fields, expected "
                f"{index + 1}; joined the extras with commas"
            )
        values[key] = ",".join(fields[index:]).strip()
    return values, warnings


def build(template: dict[str, object], values: dict[str, str], locale: str) -> tuple[dict[str, object], list[str]]:
    keys = [key for key in template if not key.startswith("@")]
    errors: list[str] = []

    for key in keys:
        if key not in values:
            errors.append(f"missing translation for {key}")
    for key in values:
        if key not in keys:
            errors.append(f"unknown key {key} (not in the template)")
    for key in keys:
        text = values.get(key)
        if not text:
            errors.append(f"empty translation for {key}")
            continue
        wanted = _icu_names(str(template[key]))
        got = _icu_names(text)
        if wanted != got:
            errors.append(
                f"{key}: ICU arguments {sorted(got)} != {sorted(wanted)}"
            )
    if errors:
        return {}, errors

    arb: dict[str, object] = {"@@locale": locale}
    for key in keys:
        arb[key] = values[key]
    return arb, []


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--locale", required=True, help="ARB locale tag, e.g. zh_Hans")
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--column", default=None, help="translation column name")
    parser.add_argument("--template", type=Path, default=_ROOT / "lib/l10n/app_en.arb")
    parser.add_argument("--out", type=Path, default=None)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)

    out = args.out or _ROOT / "lib/l10n" / f"app_{args.locale}.arb"
    template = json.loads(args.template.read_text(encoding="utf-8"))
    values, warnings = read_csv(args.csv, args.column)
    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)

    arb, errors = build(template, values, args.locale)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        print(f"{len(errors)} problem(s); nothing written", file=sys.stderr)
        return 1

    text = json.dumps(arb, ensure_ascii=False, indent=2) + "\n"
    if args.dry_run:
        print(f"dry run: {out} would carry {len(arb) - 1} messages")
        return 0
    out.write_text(text, encoding="utf-8")

    problems = check_files([args.template, out])
    if problems:
        print("\n".join(problems), file=sys.stderr)
        return 1
    print(f"wrote {out} ({len(arb) - 1} messages, locale {args.locale})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
