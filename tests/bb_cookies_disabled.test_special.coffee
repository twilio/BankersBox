GLOBAL.window = {}
Object.defineProperty window, 'localStorage', get: -> throw 'ERR'

assert = require "assert"
{ BankersBox } = require "bankersbox"

exports.testWithCookiesDisabled = ->
  assert.equal BankersBox, undefined, "BankersBox is expected to be undefined"
