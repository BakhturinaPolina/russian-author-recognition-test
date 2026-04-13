"""Shared helpers for RU→EN translation in data_prep scripts."""
import json
import re
from pathlib import Path

from deep_translator import GoogleTranslator


def has_cyrillic(s: str) -> bool:
    """True if string contains any Cyrillic character."""
    if not isinstance(s, str) or not str(s).strip():
        return False
    return bool(re.search(r"[\u0400-\u04ff]", str(s)))


def translate_ru_en(
    text: str,
    translator: GoogleTranslator,
    cache: dict[str, str],
    delay: float = 0.2,
) -> str:
    """Translate Russian to English; use cache to avoid duplicate API calls."""
    import time
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
        return cache[text]


def load_cache(path: Path) -> dict[str, str]:
    """Load translation cache from JSON; return empty dict on error."""
    if not path.exists():
        return {}
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"Could not load cache: {e}")
        return {}


def save_cache(cache: dict[str, str], path: Path) -> None:
    """Save translation cache to JSON."""
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(cache, f, ensure_ascii=False, indent=0)
        print(f"Saved translation cache to {path}")
    except Exception as e:
        print(f"Could not save cache: {e}")
