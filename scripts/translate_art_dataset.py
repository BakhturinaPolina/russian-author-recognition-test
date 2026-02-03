#!/usr/bin/env python3
"""
Translate Russian text in pretest_dataset_ART_only.xlsx to English.
Produces an English-only copy for readers who don't know Russian.

Requires: pip install pandas openpyxl deep-translator
Usage: python translate_art_dataset.py [--out OUTPUT.xlsx] [--delay SEC]
"""

import argparse
import re
import time
from pathlib import Path

import pandas as pd
from deep_translator import GoogleTranslator


def has_cyrillic(s: str) -> bool:
    """True if string contains any Cyrillic character."""
    if not isinstance(s, str) or not s.strip():
        return False
    return bool(re.search(r"[\u0400-\u04ff]", s))


def translate_ru_en(text: str, translator: GoogleTranslator, cache: dict, delay: float = 0.2) -> str:
    """Translate Russian to English; use cache to avoid duplicate API calls."""
    text = str(text).strip()
    if not text or not has_cyrillic(text):
        return text
    if text in cache:
        return cache[text]
    time.sleep(delay)
    try:
        out = translator.translate(text)
        cache[text] = out or text
        return cache[text]
    except Exception as e:
        print(f"  [skip] {repr(text)[:50]}... -> {e}")
        cache[text] = text
        return text


def main() -> None:
    parser = argparse.ArgumentParser(description="Translate Russian text in ART dataset to English.")
    parser.add_argument(
        "--input",
        default="pretest_dataset_ART_only.xlsx",
        help="Input Excel file (default: pretest_dataset_ART_only.xlsx)",
    )
    parser.add_argument(
        "--out",
        default="pretest_dataset_ART_only_EN.xlsx",
        help="Output Excel file (default: pretest_dataset_ART_only_EN.xlsx)",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.2,
        help="Seconds between translation API calls to avoid rate limits (default: 0.2)",
    )
    args = parser.parse_args()

    base = Path(__file__).resolve().parent
    inp = base / args.input
    out = base / args.out

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

    print(f"Writing {out} ...")
    df.to_excel(out, index=False, header=False)
    print("Done. File is readable in English.")


if __name__ == "__main__":
    main()
