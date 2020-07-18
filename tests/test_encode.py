import sys

import pytest

from avroc.schema import Schema

_TEST = {
    "boolean": [(True, b"\x01"), (False, b"\x00")],
    "bytes": [
        (b"", b"\x00"),
        (b"\x01", b"\x02\x01"),
        (b"\x01\x02", b"\x04\x01\x02"),
        (b"\xDE\xAD\xBE\xEF", b"\x08\xDE\xAD\xBE\xEF"),
    ],
    "int": [
        (0, b"\x00"),
        (1, b"\x02"),
        (-1, b"\x01"),
        (2 ** 31 - 1, b"\xfe\xff\xff\xff\x0f"),
        (-(2 ** 31) + 1, b"\xfd\xff\xff\xff\x0f"),
    ],
    "long": [
        (0, b"\x00"),
        (1, b"\x02"),
        (-1, b"\x01"),
        (2 ** 63 - 1, b"\xfe\xff\xff\xff\xff\xff\xff\xff\xff\x01"),
        (-(2 ** 63) + 1, b"\xfd\xff\xff\xff\xff\xff\xff\xff\xff\x01"),
    ],
    "float": [(0.0, b"\x00\x00\x00\x00"), (+1.0, b"\x00\x00\x80?"), (-1.0, b"\x00\x00\x80\xbf")],
    "double": [
        (0.0, b"\x00\x00\x00\x00\x00\x00\x00\x00"),
        (+1.0, b"\x00\x00\x00\x00\x00\x00\xf0?"),
        (-1.0, b"\x00\x00\x00\x00\x00\x00\xf0\xbf"),
        (sys.float_info.max, b"\xff\xff\xff\xff\xff\xff\xef\x7f"),
        (sys.float_info.min, b"\x00\x00\x00\x00\x00\x00\x10\x00"),
    ],
    "null": [(None, b"")],
    "string": [("", b"\x00"), ("a", b"\x02a"), ("strlen", b"\x0cstrlen"), ("🚒", b"\x08\xf0\x9f\x9a\x92")],
}


@pytest.mark.parametrize(
    "of_type, value, expected",
    [(of_type, value, expected) for of_type, values in _TEST.items() for value, expected in values],
    ids=[f"{of_type}_{value}" for of_type, values in _TEST.items() for value, _ in values],
)
def test_encode(of_type, value, expected):
    a_schema = {"type": of_type, "name": "a"}
    parsed_schema = Schema.from_py_object(a_schema)
    res = parsed_schema.encode(value)
    assert isinstance(res, bytes)
    assert res == expected

    # used temporarily to validate consistency
    # import fastavro
    # from io import BytesIO
    #
    # fastavro_schema = fastavro.parse_schema(a_schema)
    # with BytesIO() as fp:
    #     fastavro.schemaless_writer(fp, fastavro_schema, value)
    #     assert fp.getvalue() == res


def test_bad_encode():
    schema = Schema.from_py_object({"type": "boolean", "name": "a"})
    with pytest.raises(ValueError, match=f"cannot convert {repr(object)} as boolean"):
        schema.encode(object)
