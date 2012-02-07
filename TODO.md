# TODO

* Error checking around correct number of arguments

* Allow functions to take variable arguments where appropriate (e.g. lpush, etc)

* Delete key from the store when it is a List or Set that has become empty (to mimick redis implementation)

* There currenlty exists no concept of key expiry as redis has. Is this even wanted, needed?

* Store a reverse lookup set of all known keys (so as to implement the 'keys' function)

* Privatize some of the internal functions so they are not exposed to the public

## Unimplemented Functions ##

Functions that are missing which might prove useful. All expiry-based functions are omitted since that is a larger question.

* [KEYS](http://redis.io/commands#generic)
  * keys
  * move
  * randomkey
  * rename
  * renamenx
  * sort
* [STRINGS](http://redis.io/commands#string)
  * getbit
  * getrange
  * mget
  * mset
  * msetnx
  * setbit
  * setrange
* [HASHES](http://redis.io/commands#hash)
  * all functions
* [LISTS](http://redis.io/commands#list)
  * blpop, brpop, brpoplpush (seem unnecessary as js is single-threaded?)
  * linsert
* [SETS](http://redis.io/commands#set)
  * sdiff
  * sdiffstore
  * sinter
  * sinterstore
  * sunion
  * sunionstore
* [SORTED SETS](http://redis.io/commands#sorted_set) (ZSET)
  * all functions
