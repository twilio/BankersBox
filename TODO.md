# TODO

* Error checking around correct number of arguments

* Allow functions to take variable arguments where appropriate (e.g. lpush, etc)

* There currenlty exists no concept of key expiry as redis has. Is this even wanted, needed?

* Privatize some of the internal functions so they are not exposed to the public (done in the privatize branch)

* Async version of the API so that new storage adapters could work on an async basis (e.g. AJAX posting to server storage)?

* Allow SETs to store aribrary data-type values

## Unimplemented Functions ##

Functions that are missing which might prove useful. All expiry-based functions are omitted since that is a larger question.

* [KEYS](http://redis.io/commands#generic)
  * keys (mostly implemented, only returns "*" at the moment)
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
