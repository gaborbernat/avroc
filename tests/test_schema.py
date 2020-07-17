import json

import pytest

from avroc.schema import parse


def test_parse_schema_ok():
    json_schema_raw = {
        "name": "Data",
        "type": "record",
        "fields": [
            {
                "name": "sources",
                "type": {
                    "type": "array",
                    "items": [
                        {"name": "Url", "type": "record", "fields": [{"name": "url", "type": "string"}]},
                        {"name": "Source", "type": "record", "fields": [{"name": "data", "type": "string"}]},
                    ],
                },
            },
        ],
    }
    parse(json.dumps(json_schema_raw))


def test_parse_schema_bad_json():
    with pytest.raises(ValueError, match="Error parsing JSON: string or '}' expected near end of file"):
        parse("{")


def test_parse_schema_bad_avro():
    with pytest.raises(ValueError, match='Unknown Avro "type": magic'):
        parse(json.dumps({"name": "Data", "type": "magic"}))
