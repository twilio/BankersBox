assert = require "assert"
{ BankersBox, BankersBoxNullAdapter } = require "bankersbox"

exports.testNullAdapter =->
  adapter = new BankersBoxNullAdapter()
  assert.equal adapter.getItem("foo"), undefined, "test getItem"
  assert.equal adapter.storeItem("foo", "bar"), undefined, "test storeItem"
  assert.equal adapter.removeItem("foo"), undefined, "test removeItem"
  assert.equal adapter.clear(), undefined, "test clear"

exports.testBankersBoxWithNullAdapter =->
  adapter = new BankersBoxNullAdapter()
  bb = new BankersBox(1, {adapter: adapter})
  bb.flushdb()
  assert.equal bb.set("foo", "bar"), "OK", "test set"
  assert.equal bb.get("foo"), "bar", "test get"
