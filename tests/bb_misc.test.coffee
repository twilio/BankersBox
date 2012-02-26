assert = require "assert"
{ BankersBox } = require "bankersbox"

exports.testBBToString = ->
  assert.equal BankersBox.toString(), "[object BankersBox]", "test BankersBox toString"

exports.testBBInstanceToString = ->
  bb = new BankersBox(1)
  assert.equal bb.toString(), "bb:1", "test BankersBox instance toString"

exports.testSelect = ->
  bb = new BankersBox(1)
  bb.set "foo", "bar"
  bb.select 2
  bb.set "foo", "qux"
  bb.select 1
  assert.equal bb.get("foo"), "bar", "test select 1"
  bb.select 2
  assert.equal bb.get("foo"), "qux", "test select 2"