import os, strutils

import nimterop/[build, cimport]

const
  baseDir* = getProjectCacheDir("libmongonim")
  mongocDir = baseDir / "src" / "libmongoc" / "src" / "mongoc"

static:
  cDebug()
  echo baseDir

getHeader(
  "src" / "libmongoc" / "src" / "mongoc" / "mongoc.h",
  giturl = "https://github.com/mongodb/mongo-c-driver",
  outdir = baseDir / "build",
  conFlags = ""
)

cPlugin:
  import regex, strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.replace(re"_[_]+", "_").strip(chars = {'_'})
    sym.name = sym.name.replace("mongoc_", "")

when not defined(mongocStatic):
  cImport(mongocPath, recurse = true, dynlib = "mongoc")
else:
  cImport(mongocPath, recurse = true)
