# BankersBox

[![Build Status](https://secure.travis-ci.org/twilio/BankersBox.png)](http://travis-ci.org/twilio/BankersBox)

A redis-like wrapper for javascript data storage using localStorage as
the default persistent data-store.

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
client-side using localStorage as the default data backing
mechanism. You can store strings, arrays, and javscript objects in
BankersBox. Behind the scenes, BankersBox transparently uses
JSON.stringify and JSON.parse to save and restore non-string values to
their original types.

BankersBox uses a pluggable storage adapter system so that other
methods may be used to persist and restore data other than with
localStorage. See the Storage Adapters section below.

BankersBox is **not** a redis client. It is only meant to be a
storage abstraction with redis-like APIs and behaviors for those
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

### Simple key-value pairs

In redis, key-value values must also be strings, but with BankersBox you can also store numbers, booleans, arrays, and objects.

When dealing with operations that involve numeric values (incr, decr, etc) the values should be numbers (duh).

### LISTS

Values stored in lists can also be strings, numbers, booleans, arrays, and objects.

### SETS

Values stored in sets should be strings. When storing arrays or objects in sets, the behavior is undefined.

## Implemented Functions

* [KEYS](http://redis.io/commands#generic)
  * keys
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
* [SETS](http://redis.io/commands#set)
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

## Storage Adapters

By default, BankersBox will use localStorage to persist data between sessions.

The main bankersbox.js file comes with two adapters built in:

* BankersBoxLocalStorageAdapter - default adapter for using localStorage
* BankersBoxNullAdapter - adapter which does not persist or restore data anywhere, good for testing

To specify your desired storage adapter, pass it into the constructor in the options hash:

```js
bb = new BankersBox(1, {adapter: new BankersBoxNullAdapter()});
```

To create your own adapter, you must create an object which has the following three functions:

* ```storeItem(key, value)```
  * ```stores a value in the data-store associated with a key```
  * ```param: key - a string```
  * ```param: value - a string```
  * ```returns: void```
* ```getItem(key)```
  * ```retrieves a value from the data-store for the associated key```
  * ```param: key - a string```
  * ```returns: string - the value represented by key```
* ```removeItem(key)```
  * ```deletes the value in the data-store associated with the key```
  * ```param: key - a string```
  * ```returns: void```

If you create your own adapters, please add appropriate unit tests
following the examples in the tests/adapter_*.test.coffee files.

## API Usage

BankersBox has tried to adhere as closely as possible to the Redis
command API and return values associated with each command.

You can read the full [Redis Command Documentation](http://redis.io/commands).

In the cases where Redis would normally return a ```nil``` value,
BankersBox will return the javascript ```null``` value. In the cases
where Redis would return an error, BankersBox will throw a
```BankersBoxException``` or ```BankersBoxKeyException``` depending on
the situation.

## Usage On Your Webpage

Simply copy bankersbox.js (or bankersbox.min.js if you have minified)
to your site's static assets folder and link to it inside your page
source:

```
<script type="text/javascript" src="/path/to/bankersbox.js"></script>
```

BankersBox depends on using a global JSON object which must provide
```parse``` and ```stringify``` functions. Make sure to include a JSON
library in the page as well or BankersBox will throw an exception when
you try to instantiate.

## Development

To develop on BankersBox, simply hack on bankersbox.js.

To install the node modules needed for testing, simply:

```npm install```

## Testing

BankersBox has a large suite of unit tests. If you add new
functionality, please update (or add) the appropriate
tests/bb_*.test.coffee file with new tests. You can run the unit tests
with:

```make test```

## Minify

BankersBox is minified using the Google Closure javascript compression tool. This is handled in the Makefile with:

```make min```

This will output bankersbox.min.js. To test the minified version as well, simply:

```make testall```

## License

MIT License - see LICENSE for details

## Misc

Pull requests welcome, please contribute!