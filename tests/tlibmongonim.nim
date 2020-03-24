import strutils, os, unittest, libmongonim, mongo

suite "MongoDB client tests":

  test "initialize client":
    var oid = bson_oid_t()
    let client = client_new("mongodb://localhost:27017/?appname=insert-example")
    let collection = client.client_get_collection("mydb", "mycol")

    let doc = bson_new()
    bson_oid_init(addr oid, nil)
    discard doc.bson_append_oid("_id", 3, addr oid)
    discard doc.bson_append_utf8("hello", 5, "world", 5)

    let error = bson_error_t()
    if not collection.collection_insert_one(doc, nil, nil, unsafeAddr error):
      echo join(error.message)

    doc.bson_destroy()
    collection.collection_destroy()
    client.client_destroy()
    cleanup()
