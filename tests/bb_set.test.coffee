assert = require "assert"
{ BankersBox } = require "bankersbox"

exports.testDummy = ->
  assert.equal true, true, "dummy test"

###
* [SETS](http://redis.io/commands#set
  * sadd
  * scard
  * sismember
  * smembers
  * smove
  * spop
  * srandmember
  * srem
###