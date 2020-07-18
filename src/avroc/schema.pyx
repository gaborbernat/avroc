import json

from libc.string cimport strlen
from libc.stdint cimport int64_t
from cpython.exc cimport PyErr_SetFromErrnoWithFilenameObject

cdef extern from "avro/errors.h":
    const char *avro_strerror()

cdef extern from "avro/basics.h":
    cdef enum avro_type_t:
        AVRO_STRING
        AVRO_BYTES
        AVRO_INT32
        AVRO_INT64
        AVRO_FLOAT
        AVRO_DOUBLE
        AVRO_BOOLEAN
        AVRO_NULL
        AVRO_RECORD
        AVRO_ENUM
        AVRO_FIXED
        AVRO_MAP
        AVRO_ARRAY
        AVRO_UNION
        AVRO_LINK

    cdef enum avro_class_t:
        AVRO_SCHEMA
        AVRO_DATUM

    cdef struct  avro_obj_t:
        avro_type_t type
        avro_class_t class_type
        int refcount

cdef extern from "avro/schema.h":
    ctypedef avro_obj_t *avro_schema_t
    int avro_schema_from_json_length(const char *jsontext, size_t length, avro_schema_t *schema)

cdef extern from "avro/value.h":
    cdef struct avro_value_iface
    ctypedef avro_value_iface avro_value_iface_t
    cdef struct avro_value:
        avro_value_iface_t  *iface;
        void  *self
    ctypedef avro_value avro_value_t
    int avro_value_set_boolean(avro_value_t*value, int val)
    int avro_value_set_int(avro_value_t*value, int val)
    int avro_value_set_long(avro_value_t*value, long val)
    int avro_value_set_float(avro_value_t*value, float val)
    int avro_value_set_double(avro_value_t*value, double val)
    int avro_value_set_null(avro_value_t*value)
    int avro_value_set_string(avro_value_t*value, const char*val)
    int avro_value_set_bytes(avro_value_t*value, void*val, size_t size)


cdef extern from "avro/generic.h":
    int avro_generic_value_new(avro_value_iface_t *iface, avro_value_t *dest)
    avro_value_iface_t *avro_generic_class_from_schema(avro_schema_t schema)


cdef extern from "avro/io.h":
    enum avro_io_type_t:
        AVRO_FILE_IO
        AVRO_MEMORY_IO
    cdef struct avro_writer_t_:
        avro_io_type_t type
        int  refcount
    ctypedef avro_writer_t_ *avro_writer_t
    avro_writer_t avro_writer_memory(const char *buf, int64_t len)
    int avro_value_write(avro_writer_t writer, avro_value_t *src)
    int64_t avro_writer_tell(avro_writer_t writer)

cdef class Schema:
    cdef avro_schema_t _schema

    def __init__(self, schema):
        cdef avro_schema_t parsed_schema
        if isinstance(schema, unicode):
            schema = (<unicode> schema).encode('utf8')
        cdef int result = avro_schema_from_json_length(schema, strlen(schema), &parsed_schema)
        if result != 0:
            raise ValueError(avro_strerror().decode('UTF-8'))
        self._schema = parsed_schema

    @classmethod
    def from_py_object(cls, object obj):
        return cls(json.dumps(obj))

    def encode(self, object value):
        # first convert the python JSON object to AVRO-C representation
        cdef avro_value_t val
        from_py_to_c(self._schema, value, &val)
        # then perform the binary encoding
        cdef char buf[4096]
        cdef avro_writer_t writer = avro_writer_memory(buf, sizeof(buf))
        avro_value_write(writer, &val)
        return buf[:avro_writer_tell(writer)]

cdef int from_py_to_c(avro_schema_t schema, object value, avro_value_t*val) except -1:
    """convert a Python JSON object to Avro-C representation"""
    cdef avro_value_iface_t  *i_face = avro_generic_class_from_schema(schema)
    avro_generic_value_new(i_face, val)
    if schema.type == avro_type_t.AVRO_STRING:
        encoded = value.encode('utf8')
        avro_value_set_string(val, encoded)
    elif schema.type == avro_type_t.AVRO_BYTES:
        avro_value_set_bytes(val, get_bytes(value), len(value))
    elif schema.type == avro_type_t.AVRO_INT32:
        avro_value_set_int(val, value)
    elif schema.type == avro_type_t.AVRO_INT64:
        avro_value_set_long(val, value)
    elif schema.type == avro_type_t.AVRO_FLOAT:
        avro_value_set_float(val, value)
    elif schema.type == avro_type_t.AVRO_DOUBLE:
        avro_value_set_double(val, value)
    elif schema.type == avro_type_t.AVRO_BOOLEAN:
        if type(value) != bool:
            PyErr_SetFromErrnoWithFilenameObject(ValueError, 'cannot convert {!r} as boolean'.format(value))
            return -1
        avro_value_set_boolean(val, 1 if value else 0)
    elif schema.type == avro_type_t.AVRO_NULL:
        avro_value_set_null(val)
    else:
        PyErr_SetFromErrnoWithFilenameObject(ValueError, 'unsupported {!r}'.format(value))
        return -1
    return 0

cdef inline const char*get_bytes(bytes data):
    return data
