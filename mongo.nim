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

cPlugin:
  import regex, strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.replace(re"_[_]+", "_").strip(chars = {'_'})
    sym.name = sym.name.replace("mongoc_", "")

cOverride:
  type
    iovec* {.importc,header:"<sys/uio.h>".} = object
    iovec_t* {.importc,header:"<sys/uio.h>".} = object
    sockaddr* {.importc,header:"<sys/types.h>".} = object
    addrinfo* {.importc,header:"<sys/types.h>".} = object

cIncludeDir(bsonPath.parentDir().parentDir())
cIncludeDir(baseDir / "build" / "buildcache" / "src" / "libmongoc" / "src" / "mongoc")

when not defined(mongocStatic):
  cImport(mongocPath, recurse = true, dynlib = "mongocLPath")
else:
  cImport(mongocPath, recurse = true)
  {.passL: bsonLPath.}
