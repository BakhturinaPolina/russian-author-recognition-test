#!/usr/bin/env python3
"""
Translate Russian text in pretest_dataset_ART_only.xlsx to English.
Produces an English-only copy for readers who don't know Russian.

Requires: pip install pandas openpyxl deep-translator
Usage: python translate_art_dataset.py [--out OUTPUT.xlsx] [--delay SEC]
"""

import argparse
from pathlib import Path

import pandas as pd
from deep_translator import GoogleTranslator

from _translate_utils import has_cyrillic, translate_ru_en


def main() -> None:
    parser = argparse.ArgumentParser(description="Translate Russian text in ART dataset to English.")
    parser.add_argument(
        "--input",
        default="",
        help="Input Excel file (default: data/raw/pretest_dataset_ART_only.xlsx)",
    )
    parser.add_argument(
        "--out",
        default="",
        help="Output Excel file (default: data/processed/pretest_dataset_ART_only_EN.xlsx)",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.2,
        help="Seconds between translation API calls to avoid rate limits (default: 0.2)",
    )
    args = parser.parse_args()

    _script_dir = Path(__file__).resolve().parent
    project_root = _script_dir.parent.parent if _script_dir.name == "data_prep" else _script_dir.parent
    raw_dir = project_root / "data" / "raw"
    processed_dir = project_root / "data" / "processed"
    inp = raw_dir / "pretest_dataset_ART_only.xlsx" if not args.input else Path(args.input)
    out = processed_dir / "pretest_dataset_ART_only_EN.xlsx" if not args.out else Path(args.out)
    if not inp.is_absolute():
        inp = project_root / inp
    if not out.is_absolute():
        out = project_root / out

    if not inp.exists():
        raise SystemExit(f"Input file not found: {inp}")

    print(f"Reading {inp} ...")
    df = pd.read_excel(inp, header=None)

    translator = GoogleTranslator(source="ru", target="en")
    cache: dict[str, str] = {}

    # Collect all unique string values that contain Cyrillic (header + body)
    to_translate: set[str] = set()
    for c in range(df.shape[1]):
        for r in range(df.shape[0]):
            v = df.iat[r, c]
            if has_cyrillic(str(v)):
                to_translate.add(str(v).strip())

    print(f"Found {len(to_translate)} unique Russian strings to translate.")
    for i, text in enumerate(sorted(to_translate, key=len)):
        translated = translate_ru_en(text, translator, cache, delay=args.delay)
        if translated != text:
            print(f"  {i+1}/{len(to_translate)}: {repr(text)[:45]} -> {repr(translated)[:45]}")

    # Build reverse map: original -> translated (use cache)
    # Apply translations to dataframe
    for c in range(df.shape[1]):
        for r in range(df.shape[0]):
            v = df.iat[r, c]
            s = str(v).strip()
            if s and s in cache and has_cyrillic(s):
                df.iat[r, c] = cache[s]

    out.parent.mkdir(parents=True, exist_ok=True)
    print(f"Writing {out} ...")
    df.to_excel(out, index=False, header=False)
    print("Done. File is readable in English.")


if __name__ == "__main__":
    main()
