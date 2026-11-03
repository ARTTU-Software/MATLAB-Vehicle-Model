#!/usr/bin/env python3
"""Verify inventory readability, counts and saved-file freshness; no MATLAB."""
import gzip
import hashlib
import json
from pathlib import Path
import sys
import xml.etree.ElementTree as ET
import zipfile


def sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def main():
    root = Path(__file__).resolve().parents[2]
    folder = root/'SimulationStudies/inventory/saved'
    manifest = json.loads((folder/'manifest.json').read_text())
    models = json.loads((folder/'models.json').read_text())
    errors = []
    block_total = 0
    for entry in models:
        with gzip.open(folder/entry['record'], 'rt', encoding='utf-8') as f:
            model = json.load(f)
        if len(model['blocks']) != entry['blocks']:
            errors.append('Block count mismatch: '+entry['source'])
        block_total += len(model['blocks'])
    if block_total != manifest['counts']['saved_blocks']:
        errors.append('Manifest total block count mismatch')
    for kind, field in [('variables','variable_records'), ('parameters','parameter_records')]:
        with gzip.open(folder/(kind+'.jsonl.gz'), 'rt', encoding='utf-8') as f:
            count = sum(1 for line in f if json.loads(line))
        if count != manifest['counts'][field]: errors.append(kind+' count mismatch')
    fingerprints = json.loads((folder/'fingerprints.json').read_text())
    for source, record in fingerprints.items():
        if source.startswith('@library'):
            alias, relative = source.split('/',1)
            path = Path(manifest['library_roots'][alias])/relative
        else: path = root/source
        if not path.exists() or sha256(path) != record['sha256']:
            errors.append('Missing or changed source: '+source)
    with zipfile.ZipFile(root/'sm_car.slx') as archive:
        raw_blocks = sum(len(ET.fromstring(archive.read(n)).findall('.//Block'))
                         for n in archive.namelist() if n.startswith('simulink/systems/') and n.endswith('.xml') and '/_rels/' not in n)
    main = next(m for m in models if m['source'] == 'sm_car.slx')
    if raw_blocks != main['blocks']:
        errors.append('sm_car XML declarations do not match exported block count')
    result = {'passed': not errors, 'errors': errors, 'model_records_read': len(models),
              'source_fingerprints_checked': len(fingerprints), 'sm_car_raw_block_count': raw_blocks,
              'cached_model_records_reused': manifest.get('model_records_reused_by_fingerprint'),
              'scope': 'Saved-file integrity only; no runtime verification'}
    (folder/'verification.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))
    return 0 if not errors else 1


if __name__ == '__main__':
    sys.exit(main())
