import os, strutils

import nimterop/[build, cimport]

const
  baseDir* = getProjectCacheDir("libmongonim")
  bsonDir = baseDir / "src" / "libbson" / "src" / "bson"

static:
  cDebug()
  echo baseDir

getHeader(
  "src" / "libbson" / "src" / "bson" / "bson.h",
  giturl = "https://github.com/mongodb/mongo-c-driver",
  outdir = baseDir / "build",
  conFlags = ""
)

cPlugin:
  import regex, strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.replace(re"_[_]+", "_").strip(chars = {'_'})

cOverride:
  type
    uint64_t* {.importc,header:"<stdint.h>".} = uint64
    uint32_t* {.importc,header:"<stdint.h>".} = uint32
    uint16_t* {.importc,header:"<stdint.h>".} = uint16
    uint8_t* {.importc,header:"<stdint.h>".} = uint8

    int64_t* {.importc,header:"<stdint.h>".} = int64
    int32_t* {.importc,header:"<stdint.h>".} = int32
    int16_t* {.importc,header:"<stdint.h>".} = int16
    int8_t* {.importc,header:"<stdint.h>".} = int8

  type
    bson_type_t* = enum
      BSON_TYPE_EOD = 0x00000000, BSON_TYPE_DOUBLE = 0x00000001,
      BSON_TYPE_UTF8 = 0x00000002, BSON_TYPE_DOCUMENT = 0x00000003,
      BSON_TYPE_ARRAY = 0x00000004, BSON_TYPE_BINARY = 0x00000005,
      BSON_TYPE_UNDEFINED = 0x00000006, BSON_TYPE_OID = 0x00000007,
      BSON_TYPE_BOOL = 0x00000008, BSON_TYPE_DATE_TIME = 0x00000009,
      BSON_TYPE_NULL = 0x0000000A, BSON_TYPE_REGEX = 0x0000000B,
      BSON_TYPE_DBPOINTER = 0x0000000C, BSON_TYPE_CODE = 0x0000000D,
      BSON_TYPE_SYMBOL = 0x0000000E, BSON_TYPE_CODEWSCOPE = 0x0000000F,
      BSON_TYPE_INT32 = 0x00000010, BSON_TYPE_TIMESTAMP = 0x00000011,
      BSON_TYPE_INT64 = 0x00000012, BSON_TYPE_DECIMAL128 = 0x00000013,
      BSON_TYPE_MAXKEY = 0x0000007F, BSON_TYPE_MINKEY = 0x000000FF
    bson_subtype_t* = enum
      BSON_SUBTYPE_BINARY = 0x00000000, BSON_SUBTYPE_FUNCTION = 0x00000001,
      BSON_SUBTYPE_BINARY_DEPRECATED = 0x00000002,
      BSON_SUBTYPE_UUID_DEPRECATED = 0x00000003, BSON_SUBTYPE_UUID = 0x00000004,
      BSON_SUBTYPE_MD5 = 0x00000005, BSON_SUBTYPE_USER = 0x00000080

  type
    INNER_C_STRUCT_a_38* {.bycopy.} = object
      timestamp*: uint32_t
      increment*: uint32_t

    INNER_C_STRUCT_a_42* {.bycopy.} = object
      str*: cstring
      len*: uint32_t

    INNER_C_STRUCT_a_46* {.bycopy.} = object
      data*: ptr uint8_t
      data_len*: uint32_t

    INNER_C_STRUCT_a_50* {.bycopy.} = object
      data*: ptr uint8_t
      data_len*: uint32_t
      subtype*: bson_subtype_t

    INNER_C_STRUCT_a_55* {.bycopy.} = object
      regex*: cstring
      options*: cstring

    INNER_C_STRUCT_a_59* {.bycopy.} = object
      collection*: cstring
      collection_len*: uint32_t
      oid*: bson_oid_t

    INNER_C_STRUCT_a_64* {.bycopy.} = object
      code*: cstring
      code_len*: uint32_t

    INNER_C_STRUCT_a_68* {.bycopy.} = object
      code*: cstring
      scope_data*: ptr uint8_t
      code_len*: uint32_t
      scope_len*: uint32_t

    INNER_C_STRUCT_a_74* {.bycopy.} = object
      symbol*: cstring
      len*: uint32_t

    INNER_C_UNION_a_30* {.bycopy.} = object {.union.}
      v_oid*: bson_oid_t
      v_int64*: int64_t
      v_int32*: int32_t
      v_int8*: int8_t
      v_double*: cdouble
      v_bool*: bool
      v_datetime*: int64_t
      v_timestamp*: INNER_C_STRUCT_a_38
      v_utf8*: INNER_C_STRUCT_a_42
      v_doc*: INNER_C_STRUCT_a_46
      v_binary*: INNER_C_STRUCT_a_50
      v_regex*: INNER_C_STRUCT_a_55
      v_dbpointer*: INNER_C_STRUCT_a_59
      v_code*: INNER_C_STRUCT_a_64
      v_codewscope*: INNER_C_STRUCT_a_68
      v_symbol*: INNER_C_STRUCT_a_74
      v_decimal128*: bson_decimal128_t

    bson_value_t* {.bycopy.} = object
      value_type*: bson_type_t
      padding*: int32_t
      value*: INNER_C_UNION_a_30


when not defined(bsonStatic):
  cImport(bsonPath, recurse = true, dynlib = "bson")
else:
  cImport(bsonPath, recurse = true)
