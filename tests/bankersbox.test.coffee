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

exports.testSet = ->
  bb = new BankersBox(1)
  assert.equal bb.set("foo", "bar"), "OK", "test set"

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

exports.testStrlenNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.strlen("foo"), 0, "test strlen non existent key"

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

exports.testTypeList = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  assert.equal bb.type("mylist"), "list", "test list type"

exports.testLpushNewKey = ->
  bb = new BankersBox(1)
  assert.eql bb.lpush("mylist", "apple"), 1, "test lpush new key"

exports.testLpushExistingKey = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "apple"
  assert.eql bb.lpush("mylist", "banana"), 2, "test lpush existing key"

exports.testRpushNewKey = ->
  bb = new BankersBox(1)
  assert.eql bb.rpush("mylist", "apple"), 1, "test rpush new key"

exports.testRpushExistingKey = ->
  bb = new BankersBox(1)
  bb.rpush "mylist", "apple"
  assert.eql bb.rpush("mylist", "banana"), 2, "test rpush existing key"

exports.testLrangeNonKey = ->
  bb = new BankersBox(1)
  assert.eql bb.lrange("keydoesnotexist", 0, -1), [], "test lrange non existant key"

exports.testLrangeKey = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.eql bb.lrange("mylist", 0, -1), ["b", "a", "c", "d"], "test lrange 1"
  assert.eql bb.lrange("mylist", 0, 1), ["b", "a"], "test lrange 2"
  assert.eql bb.lrange("mylist", -2, -1), ["c", "d"], "test lrange 3"
  assert.eql bb.lrange("mylist", 0, 0), ["b"], "test lrange 4"
  assert.eql bb.lrange("mylist", 0, 3), ["b", "a", "c", "d"], "test lrange 5"
  assert.eql bb.lrange("mylist", 1, -1), ["a", "c", "d"], "test lrange 6"
  assert.eql bb.lrange("mylist", 5, 10), [], "test lrange 7"

exports.testLlenNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.llen("mylist"), 0, "test llen non existent key"

exports.testLlen = ->
  bb = new BankersBox(1)
  assert.equal bb.llen("mylist"), 0, "test llen 0"
  bb.lpush "mylist", "a"
  assert.equal bb.llen("mylist"), 1, "test llen 1"
  bb.lpush "mylist", "b"
  assert.equal bb.llen("mylist"), 2, "test llen 2"
  bb.rpush "mylist", "c"
  assert.equal bb.llen("mylist"), 3, "test llen 3"
  bb.rpush "mylist", "d"
  assert.equal bb.llen("mylist"), 4, "test llen 4"

exports.testLpushxNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.lpushx("mylist", "foo"), 0, "test lpushx non existent key"

exports.testLpushxKey = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "apple"
  assert.equal bb.lpushx("mylist", "banana"), 2, "test lpushx on existing key"

exports.testRpushxNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.rpushx("mylist", "foo"), 0, "test rpushx non existent key"

exports.testRpushxKey = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "apple"
  assert.equal bb.rpushx("mylist", "banana"), 2, "test rpushx on existing key"

exports.testLindexNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.lindex("mylist", 0), null, "test lindex non existent key"

exports.testLindex = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.equal bb.lindex("mylist", 0), "b", "test lindex 0"
  assert.equal bb.lindex("mylist", 1), "a", "test lindex 1"
  assert.equal bb.lindex("mylist", 2), "c", "test lindex 2"
  assert.equal bb.lindex("mylist", 3), "d", "test lindex 3"
  assert.equal bb.lindex("mylist", -4), "b", "test lindex -4"
  assert.equal bb.lindex("mylist", -3), "a", "test lindex -3"
  assert.equal bb.lindex("mylist", -2), "c", "test lindex -2"
  assert.equal bb.lindex("mylist", -1), "d", "test lindex -1"
  assert.equal bb.lindex("mylist", 4), null, "test lindex 4"
  assert.equal bb.lindex("mylist", -5), null, "test lindex -5"

exports.testLpopNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.lpop("mylist"), null, "test lpop non existent key"

exports.testLpopKey = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.equal bb.lpop("mylist"), "b", "test lpop return"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "c", "d"], "test lpop remaining"

exports.testRpopNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.rpop("mylist"), null, "test rpop non existent key"

exports.testRpopKey = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.equal bb.rpop("mylist"), "d", "test rpop return"
  assert.eql bb.lrange("mylist", 0, -1), ["b", "a", "c"], "test rpop remaining"

exports.testLset = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.equal bb.lset("mylist", 0, "f"), "OK", "test lset return"
  assert.eql bb.lrange("mylist", 0, 0), ["f"], "test lset remaining"

exports.testLtrimNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.ltrim("mylist", 1, -1), "OK", "test ltrim non existent key"

exports.testLtrim = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.equal bb.ltrim("mylist", 1, -1), "OK", "test ltrim return"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "c", "d"], "test ltrim remaining"

exports.testLremNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.lrem("mylist", 0, "a"), 0, "test lrem non existent key"

exports.testLrem = ->
  bb = new BankersBox(1)
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "b"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "d"
  bb.rpush "mylist", "a"
  assert.equal bb.lrem("mylist", 0, "a"), 4, "test lrem 0"
  assert.eql bb.lrange("mylist", 0, -1), ["b", "c", "d"], "test lrem 0 remaining"
  bb.del "mylist"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "b"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "d"
  bb.rpush "mylist", "a"
  assert.equal bb.lrem("mylist", 2, "a"), 2, "test lrem 2"
  assert.eql bb.lrange("mylist", 0, -1), ["b", "c", "a", "d", "a"], "test lrem 2 remaining"
  bb.del "mylist"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "b"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "d"
  bb.rpush "mylist", "a"
  assert.equal bb.lrem("mylist", -2, "a"), 2, "test lrem -2"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "b", "a", "c", "d"], "test lrem -2 remaining"

exports.testRpoplpush = ->
  bb = new BankersBox(1)
  # src exists, dst does not
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "b"
  assert.equal bb.rpoplpush("mylist", "newlist"), "b", "test rpoplpush"
  assert.eql bb.lrange("mylist", 0, -1), ["a"], "test rpoplpush mylist remaining"
  assert.eql bb.lrange("newlist", 0, -1), ["b"], "test rpoplpush newlist remaining"
  # reset
  bb.del "mylist"
  bb.del "newlist"
  # src exists, dst exists
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "newlist", "d"
  bb.rpush "newlist", "e"
  bb.rpush "newlist", "f"
  assert.equal bb.rpoplpush("mylist", "newlist"), "c", "test rpoplpush"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "b"], "test rpoplpush mylist remaining"
  assert.eql bb.lrange("newlist", 0, -1), ["c", "d", "e", "f"], "test rpoplpush newlist remaining"
  # reset
  bb.del "mylist"
  bb.del "newlist"
  # src not exist, dst does
  bb.rpush "newlist", "d"
  bb.rpush "newlist", "e"
  bb.rpush "newlist", "f"
  assert.equal bb.rpoplpush("mylist", "newlist"), null, "test rpoplpush"
  assert.eql bb.lrange("newlist", 0, -1), ["d", "e", "f"], "test rpoplpush newlist remaining"
  # reset
  bb.del "mylist"
  bb.del "newlist"
  # src is dst
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "b"
  bb.rpush "mylist", "c"
  assert.equal bb.rpoplpush("mylist", "mylist"), "c", "test rpoplpush"
  assert.eql bb.lrange("mylist", 0, -1), ["c", "a", "b"], "test rpoplpush mylist remaining"

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
  x* lindex
  x* llen
  x* lpop
  x* lpush
  x* lpushx
  x* lrange
  x* lrem
  x* lset
  x* ltrim
  x* rpop
  x* rpoplpush
  x* rpush
  x* rpushx
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
