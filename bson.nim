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
  outdir = baseDir / "build"
)

cPlugin:
  import regex, strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.replace(re"_[_]+", "_").strip(chars = {'_'})

cOverride:
  type
    INNER_C_STRUCT_a_38* {.bycopy.} = object
      timestamp*: uint32
      increment*: uint32

    INNER_C_STRUCT_a_42* {.bycopy.} = object
      str*: cstring
      len*: uint32

    INNER_C_STRUCT_a_46* {.bycopy.} = object
      data*: ptr uint8
      data_len*: uint32

    INNER_C_STRUCT_a_50* {.bycopy.} = object
      data*: ptr uint8
      data_len*: uint32
      subtype*: bson_subtype_t

    INNER_C_STRUCT_a_55* {.bycopy.} = object
      regex*: cstring
      options*: cstring

    INNER_C_STRUCT_a_59* {.bycopy.} = object
      collection*: cstring
      collection_len*: uint32
      oid*: bson_oid_t

    INNER_C_STRUCT_a_64* {.bycopy.} = object
      code*: cstring
      code_len*: uint32

    INNER_C_STRUCT_a_68* {.bycopy.} = object
      code*: cstring
      scope_data*: ptr uint8
      code_len*: uint32
      scope_len*: uint32

    INNER_C_STRUCT_a_74* {.bycopy.} = object
      symbol*: cstring
      len*: uint32

    INNER_C_UNION_a_30* {.bycopy.} = object {.union.}
      v_oid*: bson_oid_t
      v_int64*: int64
      v_int32*: int32
      v_int8*: int8
      v_double*: cdouble
      v_bool*: bool
      v_datetime*: int64
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
      padding*: int32
      value*: INNER_C_UNION_a_30

# cmake
cIncludeDir(baseDir / "build" / "buildcache" / "src" / "libbson" / "src" / "bson")

when not defined(bsonStatic):
  cImport(bsonPath, recurse = true, dynlib = "bsonLPath")
else:
  cImport(bsonPath, recurse = true)
