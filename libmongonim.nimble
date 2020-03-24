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
  exec "nim c -d:mongocGit -d:bsonGit -p:.. -r tests/tlibmongonim.nim"
  # NOTE: requires that nimterop accept hypen in -static as valid static lib regex, coming in next version
  # exec "nim c -d:mongocGit -d:mongocStatic -d:bsonGit -d:bsonStatic -p:.. -r tests/tlibmongonim.nim"
