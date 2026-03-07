import argparse
from pathlib import Path

import torch
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Merge LoRA adapter into base model.")
    parser.add_argument("--base-model", default="Qwen/Qwen2.5-0.5B-Instruct")
    parser.add_argument("--adapter-dir", default="local_ai/models/qwen2.5-0.5b-lora")
    parser.add_argument("--output-dir", default="local_ai/models/qwen2.5-0.5b-merged")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    adapter_dir = Path(args.adapter_dir)
    if not adapter_dir.exists():
        raise FileNotFoundError(f"Adapter directory not found: {adapter_dir}")

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Loading base model: {args.base_model}")
    base_model = AutoModelForCausalLM.from_pretrained(
        args.base_model,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map="auto" if torch.cuda.is_available() else None,
    )
    tokenizer = AutoTokenizer.from_pretrained(args.base_model, use_fast=False)

    print(f"Loading LoRA adapter: {adapter_dir}")
    peft_model = PeftModel.from_pretrained(base_model, str(adapter_dir))

    print("Merging adapter into base model...")
    merged_model = peft_model.merge_and_unload()

    print(f"Saving merged model to: {output_dir}")
    merged_model.save_pretrained(str(output_dir))
    tokenizer.save_pretrained(str(output_dir))

    print("Done.")


if __name__ == "__main__":
    main()
