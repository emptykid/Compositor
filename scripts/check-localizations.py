#!/usr/bin/env python3
"""Check translations and, optionally, strings extracted by a local Xcode build."""

import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess


def placeholders(value):
    pattern = r"%(?:\d+\$)?[-+0#]*\d*(?:\.\d+)?(?:hh|ll|h|l|L|z|t|j)?[@diuoxXfFeEgGaAcCsSp]"
    return Counter(re.sub(r"^%\d+\$", "%", item)
                   for item in re.findall(pattern, value.replace("%%", "")))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--derived-data", type=Path,
                        help="Also check the Debug build's extracted .stringsdata files")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    catalog = json.loads((root / "Compositor/Resources/Localizable.xcstrings").read_text())
    errors = []
    for key, entry in catalog["strings"].items():
        for language in ("en", "zh-Hans"):
            unit = entry.get("localizations", {}).get(language, {}).get("stringUnit", {})
            if unit.get("state") != "translated" or "value" not in unit:
                errors.append(f"Missing {language} translation: {key!r}")
            elif placeholders(key) != placeholders(unit["value"]):
                errors.append(f"Mismatched {language} format arguments: {key!r}")
    if args.derived_data:
        objects = args.derived_data / "Build/Intermediates.noindex/Compositor.build/Debug/Compositor.build/Objects-normal"
        files = list(objects.rglob("*.stringsdata"))
        if not files:
            errors.append(f"No extracted strings found in {objects}")
        missing = set()
        for path in files:
            data = json.loads(subprocess.check_output(["plutil", "-convert", "json", "-o", "-", str(path)]))
            for entries in data.get("tables", {}).values():
                for entry in entries:
                    if entry["key"] not in catalog["strings"]:
                        missing.add(entry["key"])
        errors.extend(f"Extracted string missing from catalog: {key!r}" for key in sorted(missing))
    if errors:
        raise SystemExit("\n".join(errors))
    print(f"Validated {len(catalog['strings'])} English and Simplified Chinese entries.")


if __name__ == "__main__":
    main()
