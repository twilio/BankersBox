var BBException = function(msg) {
  this.type = "BBException";
  this.toString = function() {
    return this.type + ": " + msg.toString();
  };
};

var BBKeyException = function(msg) {
  BBException.call(this, msg);
  this.type = "BBKeyException";
};

var BankersBox = (function() {

// Array Remove - By John Resig (MIT Licensed)
  var arr_remove = function(array, from, to) {
    var rest = array.slice((to || from) + 1 || array.length);
    array.length = from < 0 ? array.length + from : from;
    return array.push.apply(array, rest);
  };
  
  var _log = function(m) {
    if (window.console && window.console.log) {
      window.console.log(m);
    }
  };
  
  var ls_set = function(k, v) {
    if (window.localStorage) {
      try {
        localStorage.setItem(k, v);
      } catch (e) {
        if (e == QUOTA_EXCEEDED_ERR) {
          _log("quota exceeded!");
        }
        throw(e);
      }
    }
  };
  
  var ls_get = function(k) {
    if (window.localStorage) {
      return window.localStorage.getItem(k);
    }
    return null;
  };
  
  var ls_del = function(k) {
    if (window.localStorage) {
      window.localStorage.removeItem(k);
    }
  };

  var BB = function(db) {
    
    this.db = db;
    this.prefix = "bb:" + db.toString() + ":";
    this.store = {};

    this.toString = function() {
      return "bb:" + this.db.toString();
    };

    if (!window.JSON || !window.JSON.parse || !window.JSON.stringify) {
      throw("No JSON support detected. Please include a JSON module with 'parse' and 'stringify' functions.");
    }

  };

  BB.prototype.get_raw = function(k, t) {
    var ret = this.store[k];
    if (ret !== undefined) {
      return ret;
    }
    if (t === undefined) {
      ret = this.store[k] = ls_get(k);
    } else {
      ret = this.store[k] = JSON.parse(ls_get(k));
    }
    return ret;
  };

  BB.prototype.set_raw = function(k, v, t) {
    this.store[k] = v;
    if (t === undefined) {
      ls_set(k, v);
    } else if (t === "list") {
      ls_set(k, JSON.stringify(v));
    } else if (t === "set") {
      ls_set(k, JSON.stringify(v));
    }
  };

  BB.prototype.del_raw = function(k) {
    delete this.store[k];
    ls_del(k);
  };

  BB.prototype.set_bbkey = function(k, v, t) {
    this.set_raw(this.prefix + k, v, t);
    if (t !== undefined) {
      this.set_bbkeytype(k, t);
    }
  };

  BB.prototype.get_bbkey = function(k, t) {
    return this.get_raw(this.prefix + k, t);
  };

  BB.prototype.del_bbkey = function(k) {
    this.del_raw(this.prefix + k);
  };

  BB.prototype.set_bbkeymeta = function(k, meta, v) {
    this.set_raw(this.prefix + k + ":__" + meta + "__", v);
  };

  BB.prototype.get_bbkeymeta = function(k, meta) {
    return this.get_raw(this.prefix + k + ":__" + meta + "__");
  };

  BB.prototype.del_bbkeymeta = function(k, meta) {
    this.del_raw(this.prefix + k + ":__" + meta + "__");
  };

  BB.prototype.set_bbkeytype = function(k, v) {
    this.set_bbkeymeta(k, "type", v);
  };

  BB.prototype.get_bbkeytype = function(k) {
    return this.get_bbkeymeta(k, "type");
  };

  BB.prototype.del_bbkeytype = function(k) {
    this.del_bbkeymeta(k, "type");
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
    tmap["lpop"] = "list";
    tmap["rpush"] = "list";
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

    if (keytype === undefined || keytype === null || tmap[checktype] === undefined || tmap[checktype] == keytype) {
      return true;
    }
    throw(new BBKeyException("invalid operation on key type: " + keytype));
  };

  /* ---- KEY ---- */

  BB.prototype.del = function(k) {
    this.del_bbkey(k);
    this.del_bbkeytype(k);
    /*
      TODO:
        delete other meta depending on key type
     */
  };

  BB.prototype.exists = function(k) {
    var val = this.get_bbkey(k);
    if (val !== null) {
      return true;
    }
    return false;
  };

  BB.prototype.type = function(k) {
    return this.get_bbkeytype(k);
  };


  /* ---- STRING ---- */

  BB.prototype.get = function(k) {
    this.validate_key(k, "get");
    return this.get_bbkey(k);
  }

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
      return;
    }
    this.set(k, v);
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
        throw(new BBKeyException("key is not parsable as an integer"));
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
  };

  BB.prototype.setnx = function(k, v) {
    this.validate_key(k, "setnx");
    var val = this.get(k);
    if (val !== null) {
      return;
    }
    this.set(k, v);
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
    this.validate_key(k, "list");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return null;
    }
    var ret = val.shift();
    if (ret === undefined) {
      ret = null;
    }
    this.set_bbkey(k, val, "list");
    return ret;
  };

  BB.prototype.lpush = function(k, v) {
    this.validate_key(k, "list");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      val = [];
    }
    val.unshift(v);
    this.set_bbkey(k, val, "list");
    return val.length;
  };

  BB.prototype.lpushx = function(k, v) {
    this.validate_key(k, "list");
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
      var i = to_remove.pop();
      arr_remove(val, i);
    }

    this.set_bbkey(k, val, "list");
    return Math.min(ret, Math.abs(count));

  };

  BB.prototype.lset = function(k, i, v) {
    this.validate_key(k, "lset");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      throw(new BBKeyException("no such key"));
    }
    if (i < 0) {
      i = val.length + i;
    }
    if (i < 0 || i >= val.length) {
      throw(new BBException("index out of range"));
    }
    val[i] = v;
    this.set_bbkey(k, val, "list");
    return true;
  };

  BB.prototype.ltrim = function(k, start, end) {
    this.validate_key(k, "ltrim");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return true;
    }
    if (end === -1) {
      val = val.slice(start);
    } else {
      val = val.slice(start, end + 1);
    }
    this.set_bbkey(k, val, "list");
    return true;
  };

  BB.prototype.rpop = function(k) {
    this.validate_key(k, "list");
    var val = this.get_bbkey(k, "list");
    if (val === null) {
      return null;
    }
    var ret = val.pop();
    if (ret === undefined) {
      ret = null;
    }
    this.set_bbkey(k, val, "list");
    return ret;
  };

  BB.prototype.rpush = function(k, v) {
    this.validate_key(k, "list");
    var val = this.get_bbkey(k);
    if (val === null) {
      val = [];
    }
    val.push(v);
    this.set_bbkey(k, val, "list");
    return val.length;
  };

  BB.prototype.rpushx = function(k, v) {
    this.validate_key(k, "list");
    var val = this.get_bbkey(k, "list");
    if (val !== null) {
      return this.rpush(k, v);
    }
    return 0;
  };

  BB.prototype.rpoplpush = function(src, dest) {
    this.validate_key(src, "list");
    this.validate_key(dest, "list");

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
    if (members.length === 0) {
      return null;
    }
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
      this.set_bbkey(k, val, "set");
      this.set_bbkeymeta(k, "card", scard);
    }
    return ret;
  };

  /* ---- SERVER ---- */
  
  BB.prototype.select = function(i) {
    this.db = i;
    this.prefix = "bb:" + i.toString() + ":";
  };

  BB.toString = function() {
    return "[object BankersBox]";
  };

  return BB;
  
})();