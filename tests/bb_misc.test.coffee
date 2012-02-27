assert = require "assert"
{ BankersBox } = require "bankersbox"

exports.testBBToString = ->
  assert.equal BankersBox.toString(), "[object BankersBox]", "test BankersBox toString"

exports.testBBInstanceToString = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.toString(), "bb:1", "test BankersBox instance toString"

exports.testSelect = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  bb.select 2
  bb.set "foo", "qux"
  bb.select 1
  assert.equal bb.get("foo"), "bar", "test select 1"
  bb.select 2
  assert.equal bb.get("foo"), "qux", "test select 2"

exports.testFlushdb = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  bb.set "baz", "qux"
  assert.equal bb.flushdb(), "OK", "test flushdb"
  assert.eql bb.keys("*"), [], "test flushdb keys remaining"

exports.testKyesAll = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  bb.set "baz", "qux"
  assert.includes bb.keys(), "foo", "test keys * foo"
  assert.includes bb.keys(), "baz", "test keys * bar"
  assert.equal bb.keys().length, 2, "test keys * length"