from libc.string cimport strlen

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

def parse(schema):
    if isinstance(schema, unicode):
        schema = (<unicode> schema).encode('utf8')
    cdef avro_schema_t parsed_schema
    cdef int result = avro_schema_from_json_length(schema, strlen(schema), &parsed_schema)
    if result != 0:
        raise ValueError(avro_strerror().decode('UTF-8'))
