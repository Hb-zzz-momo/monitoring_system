import json
from pathlib import Path
import sys

BACKEND_DIR = Path(__file__).resolve().parents[1]
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

import database as db


def build_samples() -> list[dict]:
    return db.list_training_messages()


def main() -> None:
    repo_root = Path(__file__).resolve().parents[2]
    output_path = repo_root / "local_ai" / "data" / "train.jsonl"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    samples = build_samples()
    with output_path.open("w", encoding="utf-8") as f:
        for item in samples:
            f.write(json.dumps(item, ensure_ascii=False) + "\n")

    print(f"Exported {len(samples)} samples to: {output_path}")


if __name__ == "__main__":
    main()
