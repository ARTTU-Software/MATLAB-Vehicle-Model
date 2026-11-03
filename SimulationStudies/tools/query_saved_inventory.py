#!/usr/bin/env python3
"""Search saved inventory records without reading a model or starting MATLAB."""
import argparse
import gzip
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('text', help='Case-insensitive literal substring')
    parser.add_argument('--kind', choices=['variables', 'parameters', 'signals', 'models', 'dependencies'], default='variables')
    parser.add_argument('--limit', type=int, default=10)
    parser.add_argument('--inventory', type=Path, default=Path(__file__).resolve().parents[1]/'inventory/saved')
    args = parser.parse_args()
    if args.limit < 1: parser.error('limit must be positive')
    suffix = '.jsonl.gz' if args.kind in ('variables','parameters','signals') else '.json'
    path = args.inventory/(args.kind + suffix)
    needle = args.text.casefold()
    matches = 0
    opener = gzip.open if suffix.endswith('.gz') else open
    with opener(path, 'rt', encoding='utf-8') as f:
        rows = (json.loads(line) for line in f) if suffix.startswith('.jsonl') else iter(json.load(f))
        for row in rows:
            if needle in json.dumps(row, ensure_ascii=False).casefold():
                print(json.dumps(row, ensure_ascii=False, indent=2))
                matches += 1
                if matches == args.limit: break
    print(f'\nDisplayed {matches} match(es); limit {args.limit}.')


if __name__ == '__main__':
    main()
