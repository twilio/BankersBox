assert = require "assert"
{ BankersBoxNullAdapter } = require "bankersbox"

exports.testNullAdapter =->
  adapter = new BankersBoxNullAdapter()
  assert.equal adapter.getItem("foo"), undefined, "test getItem"
  assert.equal adapter.storeItem("foo", "bar"), undefined, "test storeItem"
  assert.equal adapter.removeItem("foo"), undefined, "test removeItem"
  assert.equal adapter.clear(), undefined, "test clear"
