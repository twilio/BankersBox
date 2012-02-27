assert = require "assert"
{ BankersBox } = require "bankersbox"

exports.testTypeSet = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "foo"
  assert.equal bb.type("myset"), "set", "test set type"

exports.testSaddNewMember = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.sadd("foo", "bar"), 1, "test sadd new member"

exports.testSaddExistingMember = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "foo", "bar"
  assert.equal bb.sadd("foo", "bar"), 0, "test sadd existing member"

exports.testScardNonKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.scard("myset"), 0, "test scard non existent key"

exports.testScard = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "a"
  bb.sadd "myset", "b"
  bb.sadd "myset", "c"
  assert.equal bb.scard("myset"), 3, "test scard"

exports.testSisimemberNonKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.sismember("myset", "foo"), false, "test sismember non existent key"

exports.testSismemberTrue = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "foo"
  bb.sadd "myset", "bar"
  assert.equal bb.sismember("myset", "foo"), true, "test sismember true 1"
  assert.equal bb.sismember("myset", "bar"), true, "test sismember true 2"

exports.testSismemberTrue = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "foo"
  bb.sadd "myset", "bar"
  assert.equal bb.sismember("myset", "baz"), false, "test sismember false 1"
  assert.equal bb.sismember("myset", "qux"), false, "test sismember false 2"

exports.testSmembersNonKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.eql bb.smembers("myset"), [], "test smemebers non existent key"

exports.testSmembers = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "a"
  bb.sadd "myset", "b"
  bb.sadd "myset", "c"
  ret = bb.smembers "myset"
  assert.equal ret.length, 3, "test smembers return length"
  assert.includes ret, "a", "test smembers contains a"
  assert.includes ret, "b", "test smembers contains b"
  assert.includes ret, "c", "test smembers contains c"

exports.testSmove = ->
  bb = new BankersBox(1)
  bb.flushdb()
  # src and dst don't exists
  assert.equal bb.smove("myset1", "myset2", "foo"), 0, "test smove 1"
  assert.equal bb.exists("myset1"), false, "test smove 1 myset1 exists false"
  assert.equal bb.exists("myset2"), false, "test smove 1 myset2 exists false"
  # src exists, dst doesn't exist
  bb.sadd "myset1", "a"
  bb.sadd "myset1", "b"
  assert.equal bb.smove("myset1", "myset2", "a"), 1, "test smove 2"
  assert.eql bb.smembers("myset1"), ["b"], "test smove 2 myset1 remaining"
  assert.eql bb.smembers("myset2"), ["a"], "test smove 2 myset2 remaining"
  # reset
  bb.del "myset1"
  bb.del "myset2"
  # src exists, dst doesn't exist - move non existent member
  bb.sadd "myset1", "a"
  bb.sadd "myset1", "b"
  assert.equal bb.smove("myset1", "myset2", "c"), 0, "test smove 3"
  assert.includes bb.smembers("myset1"), "a", "test smove 3 myset1 remaining a"
  assert.includes bb.smembers("myset1"), "b", "test smove 3 myset1 remaining b"
  assert.equal bb.exists("myset2"), false, "test smove 3 myset2 exists false"
  # reset
  bb.del "myset1"
  # src and dst exist
  bb.sadd "myset1", "a"
  bb.sadd "myset1", "b"
  bb.sadd "myset2", "c"
  bb.sadd "myset2", "d"
  assert.equal bb.smove("myset1", "myset2", "a"), 1, "test smove 4"
  assert.equal bb.scard("myset1"), 1, "test smove 4 myset1 remaining length"
  assert.includes bb.smembers("myset1"), "b", "test smove 4 myset1 remianing b"
  assert.equal bb.scard("myset2"), 3, "test smove 4 myset2 remaining length"
  assert.includes bb.smembers("myset2"), "a", "test smove 4 myset2 remaining a"
  assert.includes bb.smembers("myset2"), "c", "test smove 4 myset2 remaining c"
  assert.includes bb.smembers("myset2"), "d", "test smove 4 myset2 remaining d"
  # reset
  bb.del "myset1"
  bb.del "myset2"
  # src and dst exist - move non existent member
  bb.sadd "myset1", "a"
  bb.sadd "myset1", "b"
  bb.sadd "myset2", "c"
  bb.sadd "myset2", "d"
  assert.equal bb.smove("myset1", "myset2", "e"), 0, "test smove 4"
  assert.equal bb.scard("myset1"), 2, "test smove 4 myset1 remaining length"
  assert.includes bb.smembers("myset1"), "a", "test smove 4 myset1 remianing a"
  assert.includes bb.smembers("myset1"), "b", "test smove 4 myset1 remianing b"
  assert.equal bb.scard("myset2"), 2, "test smove 4 myset2 remaining length"
  assert.includes bb.smembers("myset2"), "c", "test smove 4 myset2 remaining c"
  assert.includes bb.smembers("myset2"), "d", "test smove 4 myset2 remaining d"

exports.testSpopNonKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.spop("myset"), null, "test spop non existent key"

exports.testSpop = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "a"
  bb.sadd "myset", "b"
  bb.sadd "myset", "c"
  ret = bb.spop "myset"
  assert.includes ["a", "b", "c"], ret, "test spop ret was in myset"
  assert.equal bb.sismember("myset", ret), false, "test spop ret is no longer in myset"
  assert.equal bb.scard("myset"), 2, "test spop myset remaining length"

exports.testSrandmemberNonKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.srandmember("myset"), null, "test srandmember non existent key"

exports.testSrandmember = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "a"
  bb.sadd "myset", "b"
  bb.sadd "myset", "c"
  ret = bb.srandmember "myset"
  assert.includes ["a", "b", "c"], ret, "test spop ret was in myset"
  assert.equal bb.sismember("myset", ret), true, "test srandmember ret is still in myset"
  assert.equal bb.scard("myset"), 3, "test srandmember myset remaining length"

exports.testSremNonKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  assert.equal bb.srem("myset", "a"), 0, "test srem non existent key"

exports.testSrem = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "myset", "a"
  bb.sadd "myset", "b"
  bb.sadd "myset", "c"
  # remove non existent member
  assert.equal bb.srem("myset", "d"), 0, "test srem non existent member"
  assert.equal bb.scard("myset"), 3, "test srem remaining length"
  # remove existing member
  assert.equal bb.srem("myset", "b"), 1, "test srem existing member"
  assert.equal bb.scard("myset"), 2, "test srem remaining length"
  assert.equal bb.sismember("myset", "b"), false, "test srem member is not in set"


exports.testSremEmptySetRemovesKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "foo", "a"
  bb.sadd "foo", "b"
  bb.srem "foo", "a"
  bb.srem "foo", "b"
  assert.equal bb.exists("foo"), false, "test srem empty set deletes key"

exports.testSpopEmptySetRemovesKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "foo", "a"
  bb.sadd "foo", "b"
  bb.srem "foo", "a"
  bb.spop "foo"
  assert.equal bb.exists("foo"), false, "test spop empty set deletes key"

exports.testSmoveEmptySetRemovesKey = ->
  bb = new BankersBox(1)
  bb.flushdb()
  bb.sadd "foo", "a"
  bb.sadd "foo", "b"
  bb.srem "foo", "a"
  bb.smove "foo", "bar", "b"
  assert.equal bb.exists("foo"), false, "test smove empty set deletes key"

###
* [SETS](http://redis.io/commands#set
  x* sadd
  x* scard
  x* sismember
  x* smembers
  x* smove
  x* spop
  x* srandmember
  x* srem
###