/**
 * @license MIT License
 *
 * Copyright (c) 2012 Twilio Inc., Chad Etzel
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

(function(ctx) {

  if (typeof(window) === 'undefined') {
    window = {};
  }

  if (typeof(window.localStorage) === 'undefined' && ctx !== window) {
    // fake out localStorage functionality, mostly for testing purposes
    window.localStorage = {};
    window.localStorage.store = {};
    window.localStorage.setItem = function(k, v) {
      window.localStorage.store[k] = v;
    };
    window.localStorage.getItem = function(k) {
      var ret;
      ret = window.localStorage.store[k];
      if (ret === undefined) {
        return null;
      }
      return ret;
    };
    window.localStorage.removeItem  = function(k) {
      delete window.localStorage.store[k];
    };
    window.localStorage.clear = function() {
      window.localStorage.store = {};
    };
  }

// Array Remove - By John Resig (MIT Licensed)
  var arr_remove = function(array, from, to) {
    var rest = array.slice((to || from) + 1 || array.length);
    array.length = from < 0 ? array.length + from : from;
    return array.push.apply(array, rest);
  };

  var array_map;
  if (Array.prototype.map) {
    array_map = function(arr, fn) {
      return arr.map(fn);
    };
  } else {
    array_map = function(arr, fn) {
      var i, len = arr.length;
      var ret = [];
      for (i = 0; i < len; i++) {
        ret.push(fn(arr[i]));
      }
      return ret;
    };
  }

  var _log = function(m) {
    if (console && console.log) {
      console.log(m);
    }
  };

  var BB = function(db, opts) {

    if (isNaN(parseInt(db))) {
      throw(new BankersBoxException("db index must be an integer"));
    }
    db = parseInt(db);

    opts = opts || {};

    this.db = db;
    this.adapter = opts.adapter;

    if (this.adapter === undefined) {
      this.adapter = new BankersBoxLocalStorageAdapter();
    } else if (this.adapter === null) {
      this.adapter = new BankersBoxNullAdapter();
    }

    this.prefix = "bb:" + db.toString() + ":";
    this.keyskey = "bb:" + db.toString() + "k:___keys___";
    this.store = {};
    this.keystore = this.get_raw_value(this.keyskey, "set") || {};

    this.toString = function() {
      return "bb:" + this.db.toString();
    };

    if (typeof(JSON) == 'undefined' && !(window.JSON && window.JSON.parse && window.JSON.stringify)) {
      throw("No JSON support detected. Please include a JSON module with 'parse' and 'stringify' functions.");
    }

  };

  BB.prototype.exists_raw = function(k) {
    var ret = this.store[k] || this.adapter.getItem(k);
    return ret ? true : false;
  };

  BB.prototype.get_raw = function(k, t) {
    var ret = this.store[k];
    if (ret !== undefined) {
      return ret;
    }
    ret = this.adapter.getItem(k);
    var obj = ret;
    try {
      obj = JSON.parse(ret);
    } catch (e) {
    } finally {
      this.store[k] = obj;
    }
    return obj;
  };

  BB.prototype.set_raw = function(k, v, t) {
    this.store[k] = v;
    this.adapter.storeItem(k, JSON.stringify(v));
  };

  BB.prototype.del_raw = function(k) {
    delete this.store[k];
    this.adapter.removeItem(k);
  };

  BB.prototype.get_raw_value = function(k, t) {
    var val = this.get_raw(k, t);
    if (val === null) {
      return null;
    }
    return val.v;
  };

  BB.prototype.get_raw_meta = function(k, meta, t) {
    var val = this.get_raw(k, t);
    if (val === null) {
      return null;
    }
    return val.m[meta];
  };

  BB.prototype.set_raw_value = function(k, v, t) {
    var val = this.get_raw(k, t);
    if (val === undefined || val === null) {
      val = {};
      val.m = {};
    }
    val.v = v;
    if (t !== undefined) {
      val.m.t = t;
    }
    this.set_raw(k, val, t);
  };

  BB.prototype.set_raw_meta = function(k, meta, v) {
    var val = this.store[k];
    if (val === undefined || val === null) {
      return;
    }
    val.m[meta] = v;
    this.set_raw(k, val);
  };

  BB.prototype.set_bbkey = function(k, v, t) {
    this.set_raw_value(this.prefix + k, v, t);
    if (t !== undefined) {
      this.set_bbkeytype(k, t);
    }
    this.keystore[k] = 1;
    this.set_raw_value(this.keyskey, this.keystore, "set");
  };

  BB.prototype.exists_bbkey = function(k) {
    return this.exists_raw(this.prefix + k);
  };

  BB.prototype.get_bbkey = function(k, t) {
    return this.get_raw_value(this.prefix + k, t);
  };

  BB.prototype.del_bbkey = function(k) {
    this.del_raw(this.prefix + k);
    delete this.keystore[k];
    this.set_raw_value(this.keyskey, this.keystore, "set");
  };

  BB.prototype.set_bbkeymeta = function(k, meta, v) {
    this.set_raw_meta(this.prefix + k, meta, v);
  };

  BB.prototype.get_bbkeymeta = function(k, meta) {
    return this.get_raw_meta(this.prefix + k, meta);
  };

  BB.prototype.set_bbkeytype = function(k, v) {
    this.set_bbkeymeta(k, "t", v);
  };

  BB.prototype.get_bbkeytype = function(k) {
    return this.get_bbkeymeta(k, "t");
  };

  BB.prototype.validate_key = function(k, checktype) {
    var keytype = this.type(k);
    var tmap = {};
    tmap["get"] = "string";
    tmap["set"] = "string";
    tmap["strlen"] = "string";
    tmap["setnx"] = "string";
    tmap["append"] = "string";
    tmap["incr"] = "string";
    tmap["incrby"] = "string";
    tmap["getset"] = "string";
    tmap["lpush"] = "list";
    tmap["lpushx"] = "list";
    tmap["lpop"] = "list";
    tmap["rpush"] = "list";
    tmap["rpushx"] = "list";
    tmap["rpop"] = "list";
    tmap["rpoplpush"] = "list";
    tmap["llen"] = "list";
    tmap["lindex"] = "list";
    tmap["lrange"] = "list";
    tmap["lrem"] = "list";
    tmap["lset"] = "list";
    tmap["ltrim"] = "list";
    tmap["sadd"] = "set";
    tmap["scard"] = "set";
    tmap["sismember"] = "set";
    tmap["smembers"] = "set";
    tmap["srem"] = "set";
    tmap["smove"] = "set";
    tmap["spop"] = "set";
    tmap["srandmember"] = "set";
    tmap["zadd"] = "zset";
    tmap["zcard"] = "zset";
    tmap["zcount"] = "zset";
    tmap["zrangebyscore"] = "zset";

    if (tmap[checktype] === undefined) {
      throw new BankersBoxException("unknown key operation in validate_key");
    }

    if (keytype === undefined || keytype === null || tmap[checktype] == keytype) {
      return true;
    }
    throw(new BankersBoxKeyException("invalid operation on key type: " + keytype));
  };

  /* ---- KEY ---- */

  BB.prototype.del = function(k) {
    var type = this.type(k);
    this.del_bbkey(k);
  };

  BB.prototype.exists = function(k) {
    return this.exists_bbkey(k);
  };

  BB.prototype.type = function(k) {
    return this.get_bbkeytype(k);
  };


  /* ---- STRING ---- */

  BB.prototype.get = function(k) {
    this.validate_key(k, "get");
    return this.get_bbkey(k);
  };

  BB.prototype.getset = function(k, v) {
    this.validate_key(k, "getset");
    var val = this.get(k);
    this.set(k, v);
    return val;
  };

  BB.prototype.append = function(k, v) {
    this.validate_key(k, "append");
    var val = this.get(k);
    if (val !== null) {
      this.set(k, val + v);
      return (val + v).length;
    }
    this.set(k, v);
    return v.toString().length;
  };

  BB.prototype.decr = function(k) {
    return this.incrby(k, -1);
  };

  BB.prototype.decrby = function(k, i) {
    return this.incrby(k, 0 - i);
  };

  BB.prototype.incr = function(k) {
    return this.incrby(k, 1);
  };

  BB.prototype.incrby = function(k, i) {
    this.validate_key(k, "incrby");
    var val = this.get(k);
    if (val !== null) {
      if (isNaN(parseInt(val))) {
        throw(new BankersBoxKeyException("key is not parsable as an integer"));
      }
      this.set(k, val + i);
      return val + i;
    }
    this.set(k, i);
    return i;
  };

  BB.prototype.set = function(k, v) {
    this.validate_key(k, "set");
    this.set_bbkey(k, v);
    this.set_bbkeytype(k, "string");
    return "OK";
  };

  BB.prototype.setnx = function(k, v) {
    this.validate_key(k, "setnx");
    var val = this.get(k);
    if (val !== null) {
      return 0;
    }
    this.set(k, v);
    return 1;
  };

  BB.prototype.strlen = function(k) {
    this.validate_key(k, "strlen");
    var v = this.get(k);
    if (v !== null) {
      return v.toString().length;
    }
    return 0;
  };

  /* ---- LIST ---- */

  BB.prototype.llen = function(k) {
    this.validate_key(k, "llen");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return 0;
    }
    return val.length;
  };

  BB.prototype.lindex = function(k, i) {
    this.validate_key(k, "lindex");
    var val = this.get_bbkey(k, "list");
    if (val !== null) {
      if (i < 0) {
        i = val.length + i;
      }
      var ret = val[i];
      if (ret === undefined) {
        ret = null;
      }
      return ret;
    }
    return null;
  };

  BB.prototype.lpop = function(k) {
    this.validate_key(k, "lpop");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return null;
    }
    var ret = val.shift();
    if (val.length === 0) {
      this.del(k);
    } else {
      this.set_bbkey(k, val, "list");
    }
    return ret;
  };

  BB.prototype.lpush = function(k, v) {
    this.validate_key(k, "lpush");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      val = [];
    }
    val.unshift(v);
    this.set_bbkey(k, val, "list");
    return val.length;
  };

  BB.prototype.lpushx = function(k, v) {
    this.validate_key(k, "lpushx");
    var val = this.get_bbkey(k, "list");
    if (val !== null) {
      return this.lpush(k, v);
    }
    return 0;
  };

  BB.prototype.lrange = function(k, start, end) {
    this.validate_key(k, "lrange");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return [];
    }
    if (end === -1) {
      return val.slice(start);
    }
    return val.slice(start, end + 1);
  };

  BB.prototype.lrem = function(k, count, v) {
    this.validate_key(k, "lrem");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return 0;
    }
    var ret = 0;
    var to_remove = [];
    for (var i = 0; i < val.length; i++) {
      if (val[i] == v) {
        to_remove.push(i);
        ret++;
      }
    }

    if (count > 0) {
      to_remove = to_remove.slice(0, count);
    } else if (count < 0) {
      to_remove = to_remove.slice(count);
    }

    while(to_remove.length) {
      var el = to_remove.pop();
      arr_remove(val, el);
    }

    if (val.length === 0) {
      this.del(k);
    } else {
      this.set_bbkey(k, val, "list");
    }
    if (count == 0) {
      return ret;
    } else {
      return Math.min(ret, Math.abs(count));
    }
  };

  BB.prototype.lset = function(k, i, v) {
    this.validate_key(k, "lset");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      throw(new BankersBoxKeyException("no such key"));
    }
    if (i < 0) {
      i = val.length + i;
    }
    if (i < 0 || i >= val.length) {
      throw(new BankersBoxException("index out of range"));
    }
    val[i] = v;
    this.set_bbkey(k, val, "list");
    return "OK";
  };

  BB.prototype.ltrim = function(k, start, end) {
    this.validate_key(k, "ltrim");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return "OK";
    }
    if (end === -1) {
      val = val.slice(start);
    } else {
      val = val.slice(start, end + 1);
    }
    if (val.length === 0) {
      this.del(k);
    } else {
      this.set_bbkey(k, val, "list");
    }
    return "OK";
  };

  BB.prototype.rpop = function(k) {
    this.validate_key(k, "rpop");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return null;
    }
    var ret = val.pop();
    if (val.length === 0) {
      this.del(k);
    } else {
      this.set_bbkey(k, val, "list");
    }
    return ret;
  };

  BB.prototype.rpush = function(k, v) {
    this.validate_key(k, "rpush");
    var val = this.get_bbkey(k);
    if (val === null) {
      val = [];
    }
    val.push(v);
    this.set_bbkey(k, val, "list");
    return val.length;
  };

  BB.prototype.rpushx = function(k, v) {
    this.validate_key(k, "rpushx");
    var val = this.get_bbkey(k, "list");
    if (val !== null) {
      return this.rpush(k, v);
    }
    return 0;
  };

  BB.prototype.rpoplpush = function(src, dest) {
    this.validate_key(src, "rpoplpush");
    this.validate_key(dest, "rpoplpush");

    var srcval = this.get_bbkey(src, "list");
    var destval = this.get_bbkey(dest, "list");

    if (srcval === null) {
      return null;
    }

    var val = this.rpop(src);
    this.lpush(dest, val);
    return val;
  };


  /* ---- SET ---- */

  BB.prototype.sadd = function(k, v) {
    this.validate_key(k, "sadd");
    var val = this.get_bbkey(k, "set");
    var scard;
    var ret = 0;
    if (val === null) {
      val = {};
      scard = 0;
    } else {
      scard = parseInt(this.get_bbkeymeta(k, "card"));
    }
    if (val[v] !== 1) {
      ret = 1;
      scard = scard + 1;
    }
    val[v] = 1;
    this.set_bbkey(k, val, "set");
    this.set_bbkeymeta(k, "card", scard);
    return ret;
  };

  BB.prototype.scard = function(k) {
    this.validate_key(k, "scard");
    if (this.exists(k)) {
      return parseInt(this.get_bbkeymeta(k, "card"));
    };
    return 0;
  };

  BB.prototype.sismember = function(k, v) {
    this.validate_key(k, "sismember");
    var val = this.get_bbkey(k, "set");
    if (val === null) {
      return false;
    }
    if (val[v] === 1) {
      return true;
    }
    return false;
  };

  BB.prototype.smembers = function(k) {
    this.validate_key(k, "smembers");
    var val = this.get_bbkey(k, "set");
    if (val === null) {
      return [];
    }
    var ret = [];
    for (var v in val) {
      if (val.hasOwnProperty(v)) {
        ret.push(v);
      }
    }
    return ret;
  };

  BB.prototype.smove = function(src, dest, v) {
    this.validate_key(src, "smove");
    this.validate_key(dest, "smove");
    var srcval = this.get_bbkey(src, "set");
    if (srcval === null) {
      return 0;
    }
    var ret = this.srem(src, v);
    if (ret) {
      this.sadd(dest, v);
    }
    return ret;
  };

  BB.prototype.spop = function(k) {
    this.validate_key(k, "spop");
    var member = this.srandmember(k);
    if (member !== null) {
      this.srem(k, member);
    }
    return member;
  };

  BB.prototype.srandmember = function(k) {
    this.validate_key(k, "srandmember");
    var val = this.get_bbkey(k, "set");
    if (val === null) {
      return null;
    }
    var members = this.smembers(k);
    var i = Math.floor(Math.random() * members.length);
    var ret = members[i];
    return ret;
  };

  BB.prototype.srem = function(k, v) {
    this.validate_key(k, "srem");
    var val = this.get_bbkey(k, "set");
    if (val === null) {
      return 0;
    }
    var ret = 0;
    if (val[v] === 1) {
      ret = 1;
      delete val[v];
      var scard = parseInt(this.get_bbkeymeta(k, "card")) - 1;
      if (scard === 0) {
        this.del(k);
      } else {
        this.set_bbkey(k, val, "set");
        this.set_bbkeymeta(k, "card", scard);
      }
    }
    return ret;
  };

  /* ---- ZSET ---- */
  BB.prototype.zset_comparator = function(a, b) {
   return a.s - b.s;
  };

  BB.prototype.zadd = function(k, s, v) {
    this.validate_key(k, "zadd");
    var val = this.get_bbkey(k, "zset");
    var ret = 1;
    if (val === null) {
      val = [];
    }
    var i, len = val.length, found = false;
    for (i = 0; i < len; i++) {
      if (val[i].v == v) {
        val[i].s = s;
        found = true;
        ret = 0;
        break;
      }
    }
    if (!found) {
      val.push({v: v, s: s});
    }
    val.sort(this.zset_comparator);
    this.set_bbkey(k, val, "zset");
    return ret;
  };

  BB.prototype.zcard = function(k) {
    this.validate_key(k, "zcard");
    val = this.get_bbkey(k, "zset");
    if (val === null) {
      return null;
    }
    return val.length;
  };

  BB.prototype.zrangebyscore = function(k, start, end, withscores) {
    this.validate_key(k, "zrangebyscore");
    var val = this.get_bbkey(k, "zset");
    if (val === null) {
      return [];
    }
    if (typeof start === 'string' && start.substr(0,1) === '(') {
      start = parseInt(start.substr(1)) + 1;
    } else if (start === "-inf") {
      start = -Infinity;
    }
    if (typeof end === 'string' && end.substr(0,1) === '(') {
      end = parseInt(end.substr(1)) - 1;
    } else if (end === "+inf") {
      end = Infinity;
    }
    var arr = [], i = 0, len = val.length;
    for (i = 0; i < len; i++) {
      var score = val[i].s;
      if (score >= start && score <= end) {
        arr.push(val[i]);
      } else if (score > end) {
        break;
      }
    }
    if (withscores === undefined) {
      return array_map(arr, function(a) { return a.v; });
    } else {
      return array_map(arr, function(a) { return {value: a.v, score: a.s};});
    }
  };

  BB.prototype.zcount = function(k, start, end) {
    this.validate_key(k, "zcount");
    var val = this.zrangebyscore(k, start, end);
    return val.length;
  };

  /* ---- SERVER ---- */

  BB.prototype.keys = function(filter) {
    // TODO: implement filter.. for now just return *
    var ret = [];
    for (var k in this.keystore) {
      if (this.keystore.hasOwnProperty(k)) {
        ret.push(k);
      }
    }
    return ret;
  };

  BB.prototype.flushdb = function() {
    var keys = this.keys("*");
    for (var i in keys) {
      this.del(keys[i]);
    }
    return "OK";
  };

  BB.prototype.select = function(i) {
    if (isNaN(parseInt(i))) {
      throw(new BankersBoxException("db index must be an integer"));
    }
    this.db = i;
    this.prefix = "bb:" + i.toString() + ":";
    this.keyskey = "bb:" + i.toString() + "k:___keys___";
    this.keystore = this.get_raw_value(this.keyskey, "set") || {};
  };

  BB.toString = function() {
    return "[object BankersBox]";
  };

  var BankersBoxException = function(msg) {
    this.type = "BankersBoxException";
    this.toString = function() {
      return this.type + ": " + msg.toString();
    };
  };

  var BankersBoxKeyException = function(msg) {
    BankersBoxException.call(this, msg);
    this.type = "BankersBoxKeyException";
  };

  var BankersBoxLocalStorageAdapter = function() {

    if (typeof(window) === 'undefined' || typeof(window.localStorage) === 'undefined') {
      throw("window.localStorage is undefined, consider a different storage adapter");
    }

    this.getItem = function(k) {
      return window.localStorage.getItem(k);
    };

    this.storeItem = function(k, v) {
      try {
        window.localStorage.setItem(k, v);
      } catch (e) {
        if (e == QUOTA_EXCEEDED_ERR) {
          // TODO: properly handle quota exceeded behavior
        }
        throw(e);
      }
    };

    this.removeItem = function(k) {
      window.localStorage.removeItem(k);
    };

    this.clear = function() {
      window.localStorage.clear();
    };
  };

  var BankersBoxNullAdapter = function() {

    this.getItem = function(k) {
    };

    this.storeItem = function(k, v) {
    };

    this.removeItem = function(k) {
    };

    this.clear = function() {
    };
  };

  ctx.BankersBox = BB;
  ctx.BankersBoxException = BankersBoxException;
  ctx.BankersBoxKeyException = BankersBoxKeyException;
  ctx.BankersBoxLocalStorageAdapter = BankersBoxLocalStorageAdapter;
  ctx.BankersBoxNullAdapter = BankersBoxNullAdapter;
  if (ctx !== window) {
    ctx.mock_window = window;
  }

})(typeof(module) !== 'undefined' && module && module.exports ? module.exports : window);