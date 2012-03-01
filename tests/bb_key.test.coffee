assert = require "assert"
{ BankersBox } = require "bankersbox"

### KEY TESTS ###

exports.testExistsFalse = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.exists("foo"), false, "key exists is false"

exports.testExistsTrue = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  assert.equal bb.exists("foo"), true, "key exists is true"

exports.testDelKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  assert.equal bb.exists("foo"), true, "test del key exists"
  bb.del "foo"
  assert.equal bb.get("foo"), null, "test del key get"
  assert.equal bb.exists("foo"), false, "test del key exists"

exports.testDelReturn = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  assert.equal bb.del("foo"), 1, "test del return is 1"
  assert.equal bb.del("blah"), 0, "test del return is 0"