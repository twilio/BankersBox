assert = require "assert"
{ BankersBox } = require "bankersbox"

### KEY ###

exports.testExistsFalse = ->
  bb = new BankersBox(1)
  assert.equal bb.exists("foo"), false, "key exists is false"

exports.testExistsTrue = ->
  bb = new BankersBox(1)
  bb.set "foo", "bar"
  assert.equal bb.exists("foo"), true, "key exists is true"

exports.testDelKey = ->
  bb = new BankersBox(1)
  bb.set "foo", "bar"
  assert.equal bb.exists("foo"), true, "test del key exists"
  bb.del "foo"
  assert.equal bb.get("foo"), null, "test del key get"
  assert.equal bb.exists("foo"), false, "test del key exists"

### STRING ###

exports.testSetAndGet = ->
  bb = new BankersBox(1)
  bb.set "foo", "bar"
  assert.equal bb.get("foo"), "bar", "test set"

exports.testGetNull = ->
  bb = new BankersBox(1)
  assert.equal bb.get("asdf"), null, "test get non-existing key"

exports.testTypeString = ->
  bb = new BankersBox(1)
  bb.set "baz", "qwer"
  assert.equal bb.type("baz"), "string", "test string type"

exports.testSetnxSuccess = ->
  bb = new BankersBox(1)
  assert.equal bb.setnx("foo", "bar"), 1, "test setnx success"

exports.testSetnxFail = ->
  bb = new BankersBox(1)
  bb.set "foo", "bar"
  assert.equal bb.setnx("foo", "qwer"), 0, "test setnx fail"

exports.testGetSet = ->
  bb = new BankersBox(1)
  bb.set "foo", "hello"
  assert.equal bb.getset("foo", "goodbye"), "hello", "test getset return"
  assert.equal bb.get("foo"), "goodbye", "test getset new value"

exports.testStrlen = ->
  bb = new BankersBox(1)
  bb.set "foo", "123456789"
  assert.equal bb.strlen("foo"), 9, "test strlen"

exports.testIncrNewKey = ->
  bb = new BankersBox(1)
  assert.equal bb.incr("counter"), 1, "test incr new key"

exports.testIncrExistingKey = ->
  bb = new BankersBox(1)
  bb.set "counter2", 10
  assert.equal bb.incr("counter2"), 11, "test incr existing key"

exports.testIncrbyNewKey = ->
  bb = new BankersBox(1)
  assert.equal bb.incrby("counter3", 5), 5, "test incrby new key"

exports.testIncrbyExistingKey = ->
  bb = new BankersBox(1)
  bb.set "counter4", 10
  assert.equal bb.incrby("counter4", 7), 17, "test incrby existing key"

exports.testDecrNewKey = ->
  bb = new BankersBox(1)
  assert.equal bb.decr("counter5"), -1, "test decr new key"

exports.testDecrExistingKey = ->
  bb = new BankersBox(1)
  bb.set "counter6", -6
  assert.equal bb.decr("counter6"), -7, "test decr existing key"

exports.testDecrbyNewKey = ->
  bb = new BankersBox(1)
  assert.equal bb.decrby("counter7", 8), -8, "test decrby new key"

exports.testDecrbyExistingKey = ->
  bb = new BankersBox(1)
  bb.set "counter8", 10
  assert.equal bb.decrby("counter8", 7), 3, "test decrby existing key"

exports.testAppendNewKey = ->
  bb = new BankersBox(1)
  assert.equal bb.append("zxcv", "Hello"), 5, "test append new key return"
  assert.equal bb.get("zxcv"), "Hello", "test append new key"

exports.testAppendExistingKey = ->
  bb = new BankersBox(1)
  bb.set "zxcv", "Hello"
  assert.equal bb.append("zxcv", " World"), 11, "test append new key return"
  assert.equal bb.get("zxcv"), "Hello World", "test append new key"

### LISTS ###

###
* [KEYS](http://redis.io/commands#generic)
  x* del
  x* exists
  * type - xstring, list, set
* [STRINGS](http://redis.io/commands#string)
  x* append
  x* decr
  x* decrby
  x* incr
  x* incrby
  x* get
  x* getset
  x* set
  x* setnx
  x* strlen
* [HASHES](http://redis.io/commands#hash)
  * none, see TODO.md
* [LISTS](http://redis.io/commands#list)
  * lindex
  * llen
  * lpop
  * lpush
  * lpushx
  * lrange
  * lrem
  * lset
  * ltrim
  * rpop
  * rpoplpush
  * rpush
  * rpushx
* [SETS](http://redis.io/commands#set
  * sadd
  * scard
  * sismember
  * smembers
  * smove
  * spop
  * srandmember
  * srem
* [SORTED SETS](http://redis.io/commands#sorted_set) (ZSET)
  * none, see TODO.md
* [CONNECTION](http://redis.io/commands#connection)
  * select

###
