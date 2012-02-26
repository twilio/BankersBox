assert = require "assert"
{ BankersBox } = require "bankersbox"

exports.testTypeSet = ->
  bb = new BankersBox(1)
  bb.sadd "myset", "foo"
  assert.equal bb.type("myset"), "set", "test set type"

exports.testSaddNewMember = ->
  bb = new BankersBox(1)
  assert.equal bb.sadd("foo", "bar"), 1, "test sadd new member"

exports.testSaddExistingMember = ->
  bb = new BankersBox(1)
  bb.sadd "foo", "bar"
  assert.equal bb.sadd("foo", "bar"), 0, "test sadd existing member"

exports.testScardNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.scard("myset"), 0, "test scard non existent key"

exports.testScard = ->
  bb = new BankersBox(1)
  bb.sadd "myset", "a"
  bb.sadd "myset", "b"
  bb.sadd "myset", "c"
  assert.equal bb.scard("myset"), 3, "test scard"

exports.testSisimemberNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.sismember("myset", "foo"), false, "test sismember non existent key"

exports.testSismemberTrue = ->
  bb = new BankersBox(1)
  bb.sadd "myset", "foo"
  bb.sadd "myset", "bar"
  assert.equal bb.sismember("myset", "foo"), true, "test sismember true 1"
  assert.equal bb.sismember("myset", "bar"), true, "test sismember true 2"

exports.testSismemberTrue = ->
  bb = new BankersBox(1)
  bb.sadd "myset", "foo"
  bb.sadd "myset", "bar"
  assert.equal bb.sismember("myset", "baz"), false, "test sismember false 1"
  assert.equal bb.sismember("myset", "qux"), false, "test sismember false 2"

exports.testSmembersNonKey = ->
  bb = new BankersBox(1)
  assert.eql bb.smembers("myset"), [], "test smemebers non existent key"

exports.testSmembers = ->
  bb = new BankersBox(1)
  bb.sadd "myset", "a"
  bb.sadd "myset", "b"
  bb.sadd "myset", "c"
  ret = bb.smembers "myset"
  assert.equal ret.length, 3, "test smembers return length"
  assert.includes ret, "a", "test smembers contains a"
  assert.includes ret, "b", "test smembers contains b"
  assert.includes ret, "c", "test smembers contains c"

###
* [SETS](http://redis.io/commands#set
  x* sadd
  x* scard
  x* sismember
  x* smembers
  * smove
  * spop
  * srandmember
  * srem
###