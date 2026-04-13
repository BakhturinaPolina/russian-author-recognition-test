#!/usr/bin/env python3
"""Switch the active sample version used by all analysis notebooks.

Usage:
    python scripts/set_version.py full        # original n=908 sample
    python scripts/set_version.py strict_fa   # participants with <= 5 false alarms
"""

import json
import sys
from pathlib import Path

VALID_VERSIONS = ("full", "strict_fa")
CONFIG_PATH = Path(__file__).resolve().parent / "config.json"


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in VALID_VERSIONS:
        print(f"Usage: python {sys.argv[0]} <{'|'.join(VALID_VERSIONS)}>")
        sys.exit(1)

    version = sys.argv[1]

    with open(CONFIG_PATH) as f:
        config = json.load(f)

    config["SAMPLE_VERSION"] = version

    with open(CONFIG_PATH, "w") as f:
        json.dump(config, f, indent=2)
        f.write("\n")

    print(f"SAMPLE_VERSION set to '{version}' in {CONFIG_PATH}")


if __name__ == "__main__":
    main()
