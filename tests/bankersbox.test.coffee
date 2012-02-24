assert = require "assert"
BankersBox = require "../bankersbox"

module.exports.testExistsFalse = ->
  console.log(BankersBox)
  bb = new BankersBox.BankersBox(1)
  console.log(bb)
  assert.equal bb.exists("foo"), false, "key exists should be false"
