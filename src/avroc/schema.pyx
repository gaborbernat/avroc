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

cdef parse(schema):
    cdef avro_schema_t parsed_schema
    cdef bytes schema_bytes = schema.encode()
    cdef char* schema_c = schema_bytes
    cdef int result = avro_schema_from_json_length(schema, len(schema_bytes), &parsed_schema)
    return result
