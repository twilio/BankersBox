assert = require "assert"
{ mock_window, BankersBoxLocalStorageAdapter } = require "bankersbox"

exports.testBBSAStoreItem = ->
  adapter = new BankersBoxLocalStorageAdapter()
  adapter.clear()
  assert.equal adapter.storeItem("foo", "bar"), undefined, "test storeItem return"
  assert.equal mock_window.localStorage.store["foo"], "bar", "test localStorage value"

exports.testBBSAGetItem = ->
  adapter = new BankersBoxLocalStorageAdapter()
  adapter.clear()
  adapter.storeItem "foo", "bar"
  assert.equal adapter.getItem("foo"), "bar", "test getItem"

exports.testBBSARemoveItem = ->
  adapter = new BankersBoxLocalStorageAdapter()
  adapter.clear()
  adapter.storeItem "foo", "bar"
  assert.equal adapter.removeItem("foo", "bar"), undefined, "test removeItem return"
  assert.equal adapter.getItem("foo"), null, "test removeItem - getItem after remove"
  assert.equal mock_window.localStorage.store["foo"], undefined, "test removeItem - localStorage value"

exports.testBBSAClear = ->
  adapter = new BankersBoxLocalStorageAdapter()
  adapter.clear()
  adapter.storeItem "foo", "bar"
  adapter.storeItem "baz", "qux"
  adapter.storeItem "abc", "def"
  assert.equal adapter.clear(), undefined, "test clear return"
  assert.equal adapter.getItem("foo"), null, "test clear - getItem after clear 1"
  assert.equal adapter.getItem("baz"), null, "test clear - getItem after clear 2"
  assert.equal adapter.getItem("abc"), null, "test clear - getItem after clear 3"
  assert.eql mock_window.localStorage.store, {}, "test clear - localStorage value"
