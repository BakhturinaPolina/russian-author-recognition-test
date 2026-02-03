#!/usr/bin/env python3
"""
Merge ART_prestest_responses.xlsx (800 participants, 205 items) with
pretest_dataset_ART_only_EN.xlsx (1,035 participants, 214 items).
Translate all Russian content to English (same approach as translate_art_dataset.py).
Output: single core dataset in English with 219 columns (5 demo + 214 items) + source.

Requires: pandas, openpyxl, deep-translator
Usage: python merge_and_translate_art.py [--out OUTPUT.xlsx] [--delay SEC]
"""

import argparse
import json
import re
import time
from pathlib import Path

import pandas as pd
from deep_translator import GoogleTranslator


def has_cyrillic(s: str) -> bool:
    if not isinstance(s, str) or not str(s).strip():
        return False
    return bool(re.search(r"[\u0400-\u04ff]", str(s)))


def translate_ru_en(
    text: str,
    translator: GoogleTranslator,
    cache: dict,
    delay: float = 0.2,
) -> str:
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


def normalize_sex(val) -> str:
    """Map Russian sex to F/M; leave others as-is (string)."""
    s = str(val).strip().upper()
    if s in ("Ж", "F", "FEMALE"):
        return "F"
    if s in ("М", "M", "МУЖ", "MALE"):
        return "M"
    return str(val).strip() if s else ""


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Merge 800 + 1,035 ART exports and translate Russian to English."
    )
    parser.add_argument(
        "--out",
        default="ART_pretest_merged_EN.xlsx",
        help="Output filename (default: ART_pretest_merged_EN.xlsx)",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.2,
        help="Seconds between translation API calls (default: 0.2)",
    )
    parser.add_argument(
        "--cache",
        default="",
        help="Path to JSON cache for translations (load/save); speeds up re-runs",
    )
    args = parser.parse_args()

    base = Path(__file__).resolve().parent.parent
    path_ru = base / "archive" / "ART_prestest_responses.xlsx"
    path_en = base / "data" / "raw" / "pretest_dataset_ART_only_EN.xlsx"
    out_path = base / "data" / "raw" / args.out if not Path(args.out).is_absolute() else Path(args.out)

    if not path_ru.exists():
        raise SystemExit(f"Not found: {path_ru}")
    if not path_en.exists():
        raise SystemExit(f"Not found: {path_en}")

    print("Loading pretest_dataset_ART_only_EN.xlsx (schema + Part A)...")
    pe = pd.read_excel(path_en, header=None)
    # Schema: row 0 = labels, row 1 = codes, rows 2+ = data (1,035 rows)
    labels = pe.iloc[0, :].tolist()
    codes = pe.iloc[1, :].tolist()
    part_a = pe.iloc[2:, :].copy()
    n_demo, n_items = 5, 214
    assert pe.shape[1] == n_demo + n_items, f"Expected {n_demo + n_items} cols, got {pe.shape[1]}"

    print("Loading ART_prestest_responses.xlsx (Part B)...")
    ar = pd.read_excel(path_ru, header=None)
    # Row 0 = Russian headers, rows 1+ = 800 participants, 5 demo + 205 items
    n_b = ar.shape[0] - 1
    assert ar.shape[1] == 5 + 205, f"Expected 210 cols, got {ar.shape[1]}"

    # Collect unique Cyrillic strings from Part B (all cells for translation)
    to_translate: set[str] = set()
    for r in range(1, ar.shape[0]):
        for c in range(ar.shape[1]):
            v = ar.iat[r, c]
            s = str(v).strip()
            if s and has_cyrillic(s):
                to_translate.add(s)

    print(f"Translating {len(to_translate)} unique Russian strings...")
    cache: dict[str, str] = {}
    cache["Ж"] = "F"
    cache["М"] = "M"
    for s in list(to_translate):
        if s in cache:
            to_translate.discard(s)
    cache_path = Path(args.cache) if args.cache else base / "data" / "processed" / "translate_cache_merge.json"
    if cache_path.exists():
        try:
            with open(cache_path, encoding="utf-8") as f:
                loaded = json.load(f)
            cache.update(loaded)
            for s in list(to_translate):
                if s in cache:
                    to_translate.discard(s)
            print(f"Loaded {len(loaded)} cached translations; {len(to_translate)} left to translate.")
        except Exception as e:
            print(f"Could not load cache: {e}")
    translator = GoogleTranslator(source="ru", target="en")
    for i, text in enumerate(sorted(to_translate, key=len)):
        translated = translate_ru_en(text, translator, cache, delay=args.delay)
        if translated != text:
            print(f"  {i+1}/{len(to_translate)}: {repr(text)[:45]} -> {repr(translated)[:45]}")

    try:
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        with open(cache_path, "w", encoding="utf-8") as f:
            json.dump(cache, f, ensure_ascii=False, indent=0)
        print(f"Saved translation cache to {cache_path}")
    except Exception as e:
        print(f"Could not save cache: {e}")

    # Build Part B: 800 x (5 demo + 214 items); last 9 items = NaN
    rows_b = []
    for r in range(1, ar.shape[0]):
        # Demo: col0 date, col1 age, col2 sex (normalize), col3 -> education, col4 -> wishes (translate)
        date_val = ar.iat[r, 0]
        age_val = ar.iat[r, 1]
        sex_val = normalize_sex(ar.iat[r, 2])
        spec_val = ar.iat[r, 3]
        wishes_val = ar.iat[r, 4]
        if has_cyrillic(str(spec_val)):
            spec_val = cache.get(str(spec_val).strip(), spec_val)
        if has_cyrillic(str(wishes_val)):
            wishes_val = cache.get(str(wishes_val).strip(), wishes_val)
        # Store education/specialty in "education and profession"; optional: append wishes
        education_val = spec_val if pd.notna(spec_val) and str(spec_val).strip() else "-"
        # Humanities: not asked in 800-file, use "-"
        row_demo = [date_val, age_val, sex_val, "-", education_val]
        # Items: first 205 from Part B, then 9 NaN
        row_items = ar.iloc[r, 5:210].tolist()
        row_items.extend([float("nan")] * (n_items - 205))
        rows_b.append(row_demo + row_items)

    part_b = pd.DataFrame(rows_b)
    part_b.columns = range(part_b.shape[1])

    # Add source column
    source_col = "source"
    part_b[part_b.shape[1]] = "ART_prestest_responses"
    part_a = part_a.copy()
    part_a[part_a.shape[1]] = "pretest_EN"
    labels.append(source_col)
    codes.append("")

    merged = pd.concat([part_b, part_a], axis=0, ignore_index=True)
    merged.columns = range(merged.shape[1])

    # Build output: row 0 = labels, row 1 = codes, then data
    out_header = pd.DataFrame([labels, codes])
    out_df = pd.concat([out_header, merged], axis=0, ignore_index=True)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    print(f"Writing {out_path} ({merged.shape[0]} rows, {merged.shape[1]} cols)...")
    out_df.to_excel(out_path, index=False, header=False)
    print("Done. Core dataset: 800 (ART_prestest_responses) + 1,035 (pretest_EN) =", merged.shape[0], "participants.")


if __name__ == "__main__":
    main()
