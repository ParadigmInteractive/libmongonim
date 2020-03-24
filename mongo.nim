import bson
import os, strutils

import nimterop/[build, cimport]

const
  baseDir* = getProjectCacheDir("libmongonim")
  mongocDir = baseDir / "src" / "libmongoc" / "src" / "mongoc"
  cmakeFlags =
    "-DENABLE_STATIC=ON " & getCmakeIncludePath([bsonPath.parentDir()])

static:
  cDebug()
  echo baseDir

getHeader(
  "src" / "libmongoc" / "src" / "mongoc" / "mongoc.h",
  giturl = "https://github.com/mongodb/mongo-c-driver",
  outdir = baseDir / "build",
  cmakeFlags = cmakeFlags,
)

proc mongocPreBuild(outdir, path: string) =
  putEnv("CFLAGS", "-I" &
    bsonPath.parentDir().replace("\\", "/").replace("C:", "/c")
  )

  let
    lcm = baseDir / "src" / "libmongoc" / "CMakeLists.txt"

  echo(lcm.fileExists()) # not printing

  if lcm.fileExists():
    var
      lcmd = lcm.readFile()
    lcmd = lcmd.multiReplace([
      ("add_library (mongoc_shared SHARED ${SOURCES} ${HEADERS} ${HEADERS_FORWARDING})", ""),
      ("set_target_properties (mongoc_shared PROPERTIES CMAKE_CXX_VISIBILITY_PRESET hidden)", ""),
      ("target_link_libraries (mongoc_shared PRIVATE ${LIBRARIES} PUBLIC ${BSON_LIBRARIES})", ""),
      ("target_include_directories (mongoc_shared BEFORE PUBLIC ${MONGOC_INTERNAL_INCLUDE_DIRS})", ""),
      ("target_include_directories (mongoc_shared PRIVATE ${PRIVATE_ZLIB_INCLUDES})", ""),
      ("target_include_directories (mongoc_shared PRIVATE ${LIBMONGOCRYPT_INCLUDE_DIRECTORIES})", ""),
      ("set (TARGETS_TO_INSTALL mongoc_shared)", ""),
      ("set (TARGETS_TO_INSTALL mongoc_shared mongoc_static)", "set (TARGETS_TO_INSTALL mongoc_static)"),
      ("target_link_libraries (mongoc_static ${STATIC_LIBRARIES} ${BSON_STATIC_LIBRARIES})", "target_link_libraries (mongoc_static ${STATIC_LIBRARIES} \"{bsonPath}\"")
    ])
    lcm.writeFile(lcmd)

cPlugin:
  import regex, strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.replace(re"_[_]+", "_").strip(chars = {'_'})
    sym.name = sym.name.replace("mongoc_", "")

when not defined(mongocStatic):
  cImport(mongocPath, recurse = true, dynlib = "mongocLPath")
else:
  cImport(mongocPath, recurse = true)
  {.passL: bsonLPath.}
