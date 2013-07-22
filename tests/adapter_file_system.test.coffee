assert = require "assert"
fs = require "fs"
{ BankersBox, BankersBoxFileSystemAdapter } = require "bankersbox"

exports.testFileSystemAdapter =->
  adapter = new BankersBoxFileSystemAdapter("./bb_file_adapter.dat")
  assert.equal adapter.getItem("foo"), null, "test getItem"
  assert.equal adapter.storeItem("foo", "bar"), undefined, "test storeItem"
  assert.equal adapter.getItem("foo"), "bar", "test getItem after storeItem"
  assert.equal adapter.removeItem("foo"), undefined, "test removeItem"
  assert.equal adapter.getItem("foo"), null, "test getItem after removeItem"
  assert.equal adapter.clear(), undefined, "test clear"

exports.testBankersBoxWithFileSystemAdapter =->
  filename = "./bb_file_test.dat"
  adapter = new BankersBoxFileSystemAdapter(filename)
  bb = new BankersBox(1, {adapter: adapter})
  bb.flushdb()
  assert.equal bb.set("foo", "bar"), "OK", "test set"
  assert.equal bb.get("foo"), "bar", "test get"
  assert.equal fs.existsSync(filename), true, "backing file should exist"
  adapter.clear()
  assert.equal fs.existsSync(filename), false, "backing file should not exist"
