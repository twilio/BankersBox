assert = require "assert"
{ BankersBox } = require "bankersbox"

### LIST TESTS ###

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
  assert.equal bb.lset("mylist", 0, "f"), "OK", "test lset return 1"
  assert.eql bb.lrange("mylist", 0, 0), ["f"], "test lset remaining 1"
  # test negative index
  assert.equal bb.lset("mylist", -1, "g"), "OK", "test lset return 2"
  assert.eql bb.lrange("mylist", -1, -1), ["g"], "test lset remaining 2"

exports.testLtrimNonKey = ->
  bb = new BankersBox(1)
  assert.equal bb.ltrim("mylist", 1, -1), "OK", "test ltrim non existent key"

exports.testLtrim = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.equal bb.ltrim("mylist", 1, -1), "OK", "test ltrim return 1"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "c", "d"], "test ltrim remaining 1"
  # test non -1 second index
  assert.equal bb.ltrim("mylist", 0, 1), "OK", "test ltrim return 2"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "c"], "test ltrim reamining 2"
  # test other negative second index
  bb.rpush "mylist", "e"
  bb.rpush "mylist", "f"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "c", "e", "f"], "test ltrim sanity check"
  assert.equal bb.ltrim("mylist", 0, -2), "OK", "test ltrim return 3"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "c", "e"], "test ltrim remaining 3"
  # test out of range returns - end out of range
  assert.equal bb.ltrim("mylist", 1, 10), "OK", "test ltrim return 4"
  assert.eql bb.lrange("mylist", 0, -1), ["c", "e"], "test ltrim remaining 4"
  # test out of range return - start > length
  assert.equal bb.ltrim("mylist", 5, 10), "OK", "test ltrim return 5"
  assert.eql bb.lrange("mylist", 0, -1), [], "test ltrim remaining 5"
  # test out of range return - start > end
  bb.rpush "mylist", "a"
  bb.rpush "mylist", "b"
  bb.rpush "mylist", "c"
  bb.rpush "mylist", "d"
  assert.eql bb.lrange("mylist", 0, -1), ["a", "b", "c", "d"], "test ltrim sanity check"
  assert.equal bb.ltrim("mylist", 1, 0), "OK", "test ltrim return 6"
  assert.eql bb.lrange("mylist", 0, -1), [], "test ltrim remaining 6"

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

exports.testLpopEmptyListRemoved = ->
  bb = new BankersBox(1)
  bb.lpush "foo", "a"
  bb.lpush "foo", "b"
  bb.lpop "foo"
  bb.lpop "foo"
  assert.equal bb.exists("foo"), false, "test lpop empty list becomes deleted"

exports.testRpopEmptyListRemoved = ->
  bb = new BankersBox(1)
  bb.rpush "foo", "a"
  bb.rpush "foo", "b"
  bb.rpop "foo"
  bb.rpop "foo"
  assert.equal bb.exists("foo"), false, "test rpop empty list becomes deleted"

exports.testRpoplpushEmptyListRemoved = ->
  bb = new BankersBox(1)
  bb.lpush "foo", "a"
  bb.lpush "foo", "b"
  bb.rpop "foo"
  bb.rpoplpush "foo", "bar"
  assert.equal bb.exists("foo"), false, "test rpoplpush empty list becomes deleted"

exports.testLtrimEmptyListRemoved = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.lpush "mylist", "c"
  bb.lpush "mylist", "d"
  # out of range - start > length
  bb.ltrim "mylist", 5, 10
  assert.equal bb.exists("mylist"), false, "test ltrim out of range deletes key 1"
  # reset
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "b"
  bb.lpush "mylist", "c"
  bb.lpush "mylist", "d"
  # out of range - start > end
  bb.ltrim "mylist", 1, 0
  assert.equal bb.exists("mylist"), false, "test ltrim out of range deletes key 2"

exports.testLremEmptyListRemoved = ->
  bb = new BankersBox(1)
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "a"
  bb.lpush "mylist", "a"
  bb.lrem "mylist", 0, "a"
  assert.equal bb.exists("mylist"), false, "test lrem empty list becomes deleted"