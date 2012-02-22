# BankersBox

A redis-like wrapper for client side javascript localStorage

## Motivation

Modern browsers provide a native javascript **localStorage** object
which acts as a simple client-side key-value store per
origin. Currently, storage is limited to 5MB and can only store
strings as values (integers, floats, and booleans are coerced into
strings upon save).

[Redis](http://redis.io) is an insanely popular key-value server on
steroids. It provides many more capabilities than just simple key-value 
storage.

BankersBox aims to bring redis-like APIs and behavior to the
client-side using localStorage as the data backing mechanism. You can
store strings, arrays, and javscript objects in BankersBox. Behind the
scenes, BankersBox transparently uses JSON.stringify and JSON.parse to
save and restore non-string values to their original types.

BankersBox is **not** a redis client. It is only meant to be a
localStorage abstraction with redis-like APIs and behaviors for those
familiar with the redis way. If you are looking for a javascript redis
client (e.g. for use with node.js) please turn back now.

## Usage

Like redis, BankersBox has the concept of "databases" which are just
stores with different index numbers. BankersBox takes the id of the
store you wish to use in the constructor. Each id maps to a different
store, so if you set "foo" in two separate stores, they will retain
their separate values.

```js
var bb = new BankersBox(1);

bb.set("foo", "bar");
bb.get("foo"); // returns "bar"

bb.set("count", 10);
bb.incr("count"); // sets "count" to 11, returns 11

bb.incr("newcount"); // sets "newcount" to 1, returns 1

bb.lpush("mylist", "hello");
bb.lrange("mylist", 0, -1); // returns ["hello"]

bb.rpush("mylist", "world");
bb.lrange("mylist", 0, -1); // returns ["hello", "world"]

bb.sadd("myset", "apple");
bb.sadd("myset", "oragne");
bb.smembers("myset"); // returns ["apple", "orange"]
bb.sismember("myset", "apple"); // returns true
bb.sismember("myset", "lemon"); // returns false
bb.scard("myset"); // returns 2

```

## Notes on BankersBox data types

### Keys

Keys must be strings.

### Simple key-value pairs (aka STRINGS)

In redis, key-value values must also be strings, but with BankersBox you can also store arrays and objects.

When dealing with operations that involve numeric values (incr, decr, etc) the values should be numbers (duh).

### LISTS

Values stored in lists should be primative values. When storing arrays or objects in lists, the behavior is undefined.

### SETS

Values stored in sets should be primitive values. When storing arrays or objects in lists, the behavior is undefined.

## Implemented Functions

* [KEYS](http://redis.io/commands#generic)
  * del
  * exists
  * type
* [STRINGS](http://redis.io/commands#string)
  * append
  * decr
  * decrby
  * incr
  * incrby
  * get
  * getset
  * set
  * setnx
  * strlen
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

## Implementation Notes

BankersBox uses an internal write-through cache object for quick
reads. This means, however, that if the cache is cold (e.g. after a
page refresh), BankersBox will go to localStorage to fill the
cache. Since localStorage stores all values as strings, cold cache
values for primitive types will be filled with strings. If you are
storing values that are integers, floats, or booleans, you will need
to coerce these values back into your preferred type after reading
them from BankersBox. This only holds true for simple key-value
operation reads (e.g. get). Operations on lists and sets will return
the proper types within their arrays or objects.
