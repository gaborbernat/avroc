import json


def test_version():
    from avroc import __version__

    assert __version__


def test_parse_schema():
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
            }
        ],
    }
    from avroc import parse

    result = parse(json.dumps(json_schema_raw))

    assert False, result
