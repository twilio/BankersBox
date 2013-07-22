assert = require "assert"
{ BankersBox } = require "bankersbox"

### STRING TESTS ###

exports.testSet = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.set("foo", "bar"), "OK", "test set"

exports.testSetAndGet = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  assert.equal bb.get("foo"), "bar", "test get"

exports.testGetNull = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.get("asdf"), null, "test get non-existing key"

exports.testTypeString = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "baz", "qwer"
  assert.equal bb.type("baz"), "string", "test string type"

exports.testSetnxSuccess = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.setnx("foo", "bar"), 1, "test setnx success"

exports.testSetnxFail = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "bar"
  assert.equal bb.setnx("foo", "qwer"), 0, "test setnx fail"

exports.testGetSet = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "hello"
  assert.equal bb.getset("foo", "goodbye"), "hello", "test getset return"
  assert.equal bb.get("foo"), "goodbye", "test getset new value"

exports.testStrlenNonKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.strlen("foo"), 0, "test strlen non existent key"

exports.testStrlen = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "foo", "123456789"
  assert.equal bb.strlen("foo"), 9, "test strlen"

exports.testIncrNewKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.incr("counter"), 1, "test incr new key"

exports.testIncrExistingKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "counter2", 10
  assert.equal bb.incr("counter2"), 11, "test incr existing key"

exports.testIncrbyNewKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.incrby("counter3", 5), 5, "test incrby new key"

exports.testIncrbyExistingKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "counter4", 10
  assert.equal bb.incrby("counter4", 7), 17, "test incrby existing key"

exports.testDecrNewKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.decr("counter5"), -1, "test decr new key"

exports.testDecrExistingKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "counter6", -6
  assert.equal bb.decr("counter6"), -7, "test decr existing key"

exports.testDecrbyNewKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.decrby("counter7", 8), -8, "test decrby new key"

exports.testDecrbyExistingKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "counter8", 10
  assert.equal bb.decrby("counter8", 7), 3, "test decrby existing key"

exports.testAppendNewKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.append("zxcv", "Hello"), 5, "test append new key return"
  assert.equal bb.get("zxcv"), "Hello", "test append new key"

exports.testAppendExistingKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "zxcv", "Hello"
  assert.equal bb.append("zxcv", " World"), 11, "test append new key return"
  assert.equal bb.get("zxcv"), "Hello World", "test append new key"

exports.testStringRepresentations = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.set "a", "a string"
  bb.set "b", 3
  bb.set "b2", 3.14159
  bb.set "c", true
  bb.set "d", [1, 2, 3]
  bb.set "e", {foo: "hello", bar: "goodbye"}
  bb.set "f", JSON.stringify({foo: "hello", bar: "goodbye"})
  bb.set "g", JSON.stringify({foo: "hello", bar: "goodbye", v: "uh oh"})
  cc = new BankersBox(1)
  assert.equal cc.get("a"), "a string"
  assert.equal cc.get("b"), 3
  assert.equal cc.get("b2"), 3.14159
  assert.equal cc.get("c"), true
  assert.eql cc.get("d"), [1, 2, 3]
  assert.eql cc.get("e"), {foo: "hello", bar: "goodbye"}
  assert.equal cc.get("f"), JSON.stringify({foo: "hello", bar: "goodbye"})
  assert.equal cc.get("g"), JSON.stringify({foo: "hello", bar: "goodbye", v: "uh oh"})