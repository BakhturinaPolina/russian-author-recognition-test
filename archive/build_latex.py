#!/usr/bin/env python3
"""
Build the Russian ART LaTeX report to PDF.

Run from project root with venv active:
    python scripts/build_latex.py

Requires a LaTeX installation on PATH (e.g. texlive):
    sudo apt install texlive-latex-base texlive-latex-extra latexmk
"""
from pathlib import Path
import shutil
import subprocess
import sys

PROJECT_ROOT = Path(__file__).resolve().parents[1]
LATEX_DIR = PROJECT_ROOT / "latex"
MAIN_TEX = LATEX_DIR / "main.tex"


def find_engine():
    """Prefer latexmk, then pdflatex."""
    for cmd in ("latexmk", "pdflatex"):
        if shutil.which(cmd):
            return cmd
    return None


def main():
    if not MAIN_TEX.exists():
        print(f"Not found: {MAIN_TEX}", file=sys.stderr)
        sys.exit(1)

    engine = find_engine()
    if not engine:
        print(
            "No LaTeX engine found. Install e.g.:\n"
            "  sudo apt install texlive-latex-base texlive-latex-extra latexmk",
            file=sys.stderr,
        )
        sys.exit(1)

    if engine == "latexmk":
        cmd = ["latexmk", "-pdf", "-interaction=nonstopmode", str(MAIN_TEX)]
        print(f"Running: {' '.join(cmd)}")
        result = subprocess.run(cmd, cwd=LATEX_DIR, capture_output=False)
    else:
        cmd = ["pdflatex", "-interaction=nonstopmode", str(MAIN_TEX)]
        stem = MAIN_TEX.stem
        print(f"Running: {' '.join(cmd)}")
        r1 = subprocess.run(cmd, cwd=LATEX_DIR, capture_output=False)
        if r1.returncode != 0:
            result = r1
        else:
            subprocess.run(["bibtex", stem], cwd=LATEX_DIR, capture_output=True)
            subprocess.run(cmd, cwd=LATEX_DIR, capture_output=False)
            result = subprocess.run(cmd, cwd=LATEX_DIR, capture_output=False)

    out_pdf = LATEX_DIR / MAIN_TEX.name.replace(".tex", ".pdf")
    if out_pdf.exists():
        print(f"Output: {out_pdf}")
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
