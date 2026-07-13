#!/usr/bin/env python3
"""Validate the bundled cable JSON before Flutter compilation."""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Any

DATABASE = Path(__file__).resolve().parents[1] / 'assets/data/cable_database_sample.json'
REQUIRED_FIELDS = {
    'id',
    'construction',
    'family',
    'material',
    'sizeSqmm',
    'cccAmps',
    'rOhmPerKm',
    'xOhmPerKm',
    'protectionClass',
    'brandGroup',
    'sourceNote',
}
NUMERIC_FIELDS = {'sizeSqmm', 'cccAmps', 'rOhmPerKm', 'xOhmPerKm'}


def fail(message: str) -> None:
    raise SystemExit(f'Database validation: FAIL — {message}')


def is_finite_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def main() -> None:
    try:
        payload = json.loads(DATABASE.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as exc:
        fail(str(exc))

    if not isinstance(payload, dict):
        fail('top-level JSON value must be an object')

    records = payload.get('records')
    if not isinstance(records, list) or not records:
        fail('records must be a non-empty list')

    seen_ids: set[str] = set()
    for index, record in enumerate(records, start=1):
        if not isinstance(record, dict):
            fail(f'row {index} is not an object')

        missing = REQUIRED_FIELDS.difference(record)
        if missing:
            fail(f'row {index} is missing: {sorted(missing)}')

        cable_id = record['id']
        if not isinstance(cable_id, str) or not cable_id.strip():
            fail(f'row {index} has an invalid id')
        if cable_id in seen_ids:
            fail(f'duplicate id: {cable_id}')
        seen_ids.add(cable_id)

        for field in NUMERIC_FIELDS:
            value = record[field]
            if not is_finite_number(value) or value < 0:
                fail(f'row {index} field {field} must be a finite non-negative number')

    declared_count = payload.get('meta', {}).get('recordCount')
    if declared_count is not None and declared_count != len(records):
        fail(f'meta.recordCount={declared_count} but actual count={len(records)}')

    print(f'Database validation: PASS ({len(records)} records, {len(seen_ids)} unique IDs)')


if __name__ == '__main__':
    main()
