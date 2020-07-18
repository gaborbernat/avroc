import json

import pytest

from avroc import Schema


@pytest.fixture()
def person_schema_raw():
    return {
        "type": "record",
        "name": "Person",
        "fields": [
            {"name": "ID", "type": "long"},
            {"name": "First", "type": "string"},
            {"name": "Last", "type": "string"},
            {"name": "Phone", "type": "string"},
            {"name": "Age", "type": "int"},
        ],
    }


@pytest.fixture()
def person_schema(person_schema_raw):
    return json.dumps(person_schema_raw)


def test_parse_schema_ok(person_schema):
    assert Schema(person_schema)


def test_parse_schema_raw_ok(person_schema_raw):
    assert Schema.from_py_object(person_schema_raw)


def test_parse_schema_bad_json():
    with pytest.raises(ValueError, match="Error parsing JSON: string or '}' expected near end of file"):
        Schema("{")


def test_parse_schema_bad_avro():
    with pytest.raises(ValueError, match='Unknown Avro "type": magic'):
        Schema.from_py_object({"name": "Data", "type": "magic"})
