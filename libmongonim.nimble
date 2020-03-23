# Package

version       = "0.1.0"
author        = "Kenneth Malac"
description   = "A libmongoc binding for Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.0.2"
requires "nimterop >= 0.4.4"

task test, "Run tests":
  exec "nim c -d:mongocGit -p:.. -r tests/tlibmongonim.nim"
  exec "nim c -d:mongocGit -d:mongocStatic -p:.. -r tests/tlibmongoc.nim"
