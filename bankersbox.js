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
  
  var _log = function(m) {
    if (console && console.log) {
      console.log(m);
    }
  };

  var BB = function(db, adapter) {

    if (isNaN(parseInt(db))) {
      throw(new BankersBoxException("db index must be an integer"));
    }
    db = parseInt(db);
    
    var self = this;

    this.db = db;
    this.adapter = adapter;

    if (adapter === undefined) {
      this.adapter = new BankersBoxLocalStorageAdapter();
    } else if (adapter === null) {
      this.adapter = new BankersBoxNullAdapter();
    }

    this.prefix = "bb:" + db.toString() + ":";
    this.store = {};

    this.toString = function() {
      return "bb:" + this.db.toString();
    };

    if (typeof(JSON) == 'undefined' && !(window.JSON && window.JSON.parse && window.JSON.stringify)) {
      throw("No JSON support detected. Please include a JSON module with 'parse' and 'stringify' functions.");
    }

    var exists_raw = function(k) {
      var ret = self.store[k] || ls_get(k);
      return ret ? true : false;
    };

    var get_raw = function(k, t) {
      var ret = self.store[k];
      if (ret !== undefined) {
        return ret;
      }
      if (t === undefined || t === "string") {
        ret = self.store[k] = ls_get(k);
      } else {
        ret = self.store[k] = JSON.parse(ls_get(k));
      }
      return ret;
    };

    var set_raw = function(k, v, t) {
      self.store[k] = v;
      if (t === undefined || t === "string") {
        ls_set(k, v);
      } else if (t === "list") {
        ls_set(k, JSON.stringify(v));
      } else if (t === "set") {
        ls_set(k, JSON.stringify(v));
      }
    };

    var del_raw = function(k) {
      delete self.store[k];
      ls_del(k);
    };

    var exists_bbkey = function(k) {
      return exists_raw(self.prefix + k);
    };

    var set_bbkey = function(k, v, t) {
      set_raw(self.prefix + k, v, t);
      if (t !== undefined) {
        set_bbkeytype(k, t);
      }
      keystore[k] = 1;
      set_raw(self.prefix + "___keys___", keystore, "set");
    };

    var get_bbkey = function(k, t) {
      return get_raw(self.prefix + k, t);
    };

    var del_bbkey = function(k) {
      del_raw(self.prefix + k);
      delete keystore[k];
      set_raw(self.prefix + "___keys___", keystore, "set");
    };

    var set_bbkeymeta = function(k, meta, v) {
      set_raw(self.prefix + k + ":__" + meta + "__", v);
    };

    var get_bbkeymeta = function(k, meta) {
      return get_raw(self.prefix + k + ":__" + meta + "__");
    };

    var del_bbkeymeta = function(k, meta) {
      del_raw(self.prefix + k + ":__" + meta + "__");
    };

    var set_bbkeytype = function(k, v) {
      set_bbkeymeta(k, "type", v);
    };

    var get_bbkeytype = function(k) {
      return get_bbkeymeta(k, "type");
    };

    var del_bbkeytype = function(k) {
      del_bbkeymeta(k, "type");
    };

    var validate_key = function(k, checktype) {
      var keytype = self.type(k);
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

      if (tmap[checktype] === undefined) {
        throw new BankersBoxException("unknown key operation in validate_key");
      }

      if (keytype === undefined || keytype === null || tmap[checktype] === undefined || tmap[checktype] == keytype) {
        return true;
      }
      throw(new BankersBoxKeyException("invalid operation on key type: " + keytype));
    };

    /* ---- PRIVILEGED METHODS ---- */

    /* ---- KEY ---- */

    this.del = function(k) {
      del_bbkey(k);
      del_bbkeytype(k);
      /*
        TODO:
        delete other meta depending on key type
      */
    };

    this.exists = function(k) {
      return exists_bbkey(k);
    };

    this.type = function(k) {
      return get_bbkeytype(k);
    };


    /* ---- STRING ---- */

    this.get = function(k) {
      validate_key(k, "get");
      return get_bbkey(k);
    };

    this.getset = function(k, v) {
      validate_key(k, "getset");
      var val = self.get(k);
      self.set(k, v);
      return val;
    };

    this.append = function(k, v) {
      validate_key(k, "append");
      var val = self.get(k);
      if (val !== null) {
        self.set(k, val + v);
        return (val + v).length;
      }
      self.set(k, v);
      return v.toString().length;
    };

    this.decr = function(k) {
      return self.incrby(k, -1);
    };

    this.decrby = function(k, i) {
      return self.incrby(k, 0 - i);
    };

    this.incr = function(k) {
      return self.incrby(k, 1);
    };

    this.incrby = function(k, i) {
      validate_key(k, "incrby");
      var val = self.get(k);
      if (val !== null) {
        if (isNaN(parseInt(val))) {
          throw(new BankersBoxKeyException("key is not parsable as an integer"));
        }
        self.set(k, val + i);
        return val + i;
      }
      self.set(k, i);
      return i;
    };

    this.set = function(k, v) {
      validate_key(k, "set");
      set_bbkey(k, v);
      set_bbkeytype(k, "string");
      return "OK";
    };

    this.setnx = function(k, v) {
      validate_key(k, "setnx");
      var val = self.get(k);
      if (val !== null) {
        return 0;
      }
      self.set(k, v);
      return 1;
    };

    this.strlen = function(k) {
      validate_key(k, "strlen");
      var v = self.get(k);
      if (v !== null) {
        return v.toString().length;
      }
      return 0;
    };

    /* ---- LIST ---- */

    this.llen = function(k) {
      validate_key(k, "llen");
      var val = get_bbkey(k, "list");
      if (val === null) {
        return 0;
      }
      return val.length;
    };

    this.lindex = function(k, i) {
      validate_key(k, "lindex");
      var val = get_bbkey(k, "list");
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

    this.lpop = function(k) {
      validate_key(k, "lpop");
      var val = get_bbkey(k, "list");
      if (val === null) {
        return null;
      }
      var ret = val.shift();
      if (val.length === 0) {
        self.del(k);
      } else {
        set_bbkey(k, val, "list");
      }
      return ret;
    };

    this.lpush = function(k, v) {
      validate_key(k, "lpush");
      var val = get_bbkey(k, "list");
      if (val === null) {
        val = [];
      }
      val.unshift(v);
      set_bbkey(k, val, "list");
      return val.length;
    };

    this.lpushx = function(k, v) {
      validate_key(k, "lpushx");
      var val = get_bbkey(k, "list");
      if (val !== null) {
        return self.lpush(k, v);
      }
      return 0;
    };

    this.lrange = function(k, start, end) {
      validate_key(k, "lrange");
      var val = get_bbkey(k, "list");
      if (val === null) {
        return [];
      }
      if (end === -1) {
        return val.slice(start);
      }
      return val.slice(start, end + 1);
    };

    this.lrem = function(k, count, v) {
      validate_key(k, "lrem");
      var val = get_bbkey(k, "list");
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
        self.del(k);
      } else {
        set_bbkey(k, val, "list");
      }
      if (count == 0) {
        return ret;
      } else {
        return Math.min(ret, Math.abs(count));
      }
    };

    this.lset = function(k, i, v) {
      validate_key(k, "lset");
      var val = get_bbkey(k, "list");
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
      set_bbkey(k, val, "list");
      return "OK";
    };

    this.ltrim = function(k, start, end) {
      validate_key(k, "ltrim");
      var val = get_bbkey(k, "list");
      if (val === null) {
        return "OK";
      }
      if (end === -1) {
        val = val.slice(start);
      } else {
        val = val.slice(start, end + 1);
      }
      if (val.length === 0) {
        self.del(k);
      } else {
        set_bbkey(k, val, "list");
      }
      return "OK";
    };

    this.rpop = function(k) {
      validate_key(k, "rpop");
      var val = get_bbkey(k, "list");
      if (val === null) {
        return null;
      }
      var ret = val.pop();
      if (val.length === 0) {
        self.del(k);
      } else {
        set_bbkey(k, val, "list");
      }
      return ret;
    };

    this.rpush = function(k, v) {
      validate_key(k, "rpush");
      var val = get_bbkey(k);
      if (val === null) {
        val = [];
      }
      val.push(v);
      set_bbkey(k, val, "list");
      return val.length;
    };

    this.rpushx = function(k, v) {
      validate_key(k, "rpushx");
      var val = get_bbkey(k, "list");
      if (val !== null) {
        return self.rpush(k, v);
      }
      return 0;
    };

    this.rpoplpush = function(src, dest) {
      validate_key(src, "rpoplpush");
      validate_key(dest, "rpoplpush");

      var srcval = get_bbkey(src, "list");
      var destval = get_bbkey(dest, "list");

      if (srcval === null) {
        return null;
      }

      var val = self.rpop(src);
      self.lpush(dest, val);
      return val;
    };


    /* ---- SET ---- */

    this.sadd = function(k, v) {
      validate_key(k, "sadd");
      var val = get_bbkey(k, "set");
      var scard;
      var ret = 0;
      if (val === null) {
        val = {};
        scard = 0;
      } else {
        scard = parseInt(get_bbkeymeta(k, "card"));
      }
      if (val[v] !== 1) {
        ret = 1;
        scard = scard + 1;
      }
      val[v] = 1;
      set_bbkey(k, val, "set");
      set_bbkeymeta(k, "card", scard);
      return ret;
    };

    this.scard = function(k) {
      validate_key(k, "scard");
      if (self.exists(k)) {
        return parseInt(get_bbkeymeta(k, "card"));
      };
      return 0;
    };

    this.sismember = function(k, v) {
      validate_key(k, "sismember");
      var val = get_bbkey(k, "set");
      if (val === null) {
        return false;
      }
      if (val[v] === 1) {
        return true;
      }
      return false;
    };

    this.smembers = function(k) {
      validate_key(k, "smembers");
      var val = get_bbkey(k, "set");
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

    this.smove = function(src, dest, v) {
      validate_key(src, "smove");
      validate_key(dest, "smove");
      var srcval = get_bbkey(src, "set");
      if (srcval === null) {
        return 0;
      }
      var ret = self.srem(src, v);
      if (ret) {
        self.sadd(dest, v);
      }
      return ret;
    };

    this.spop = function(k) {
      validate_key(k, "spop");
      var member = self.srandmember(k);
      if (member !== null) {
        self.srem(k, member);
      }
      return member;
    };

    this.srandmember = function(k) {
      validate_key(k, "srandmember");
      var val = get_bbkey(k, "set");
      if (val === null) {
        return null;
      }
      var members = self.smembers(k);
      var i = Math.floor(Math.random() * members.length);
      var ret = members[i];
      return ret;
    };

    this.srem = function(k, v) {
      validate_key(k, "srem");
      var val = get_bbkey(k, "set");
      if (val === null) {
        return 0;
      }
      var ret = 0;
      if (val[v] === 1) {
        ret = 1;
        delete val[v];
        var scard = parseInt(get_bbkeymeta(k, "card")) - 1;
        if (scard === 0) {
          self.del(k);
        } else {
          set_bbkey(k, val, "set");
          set_bbkeymeta(k, "card", scard);
        }
      }
      return ret;
    };

    /* ---- SERVER ---- */

    this.keys = function(filter) {
      // TODO: implement filter.. for now just return *
      var ret = [];
      for (var k in keystore) {
        if (keystore.hasOwnProperty(k)) {
          ret.push(k);
        }
      }
      return ret;
    };

    this.flushdb = function() {
      var keys = self.keys("*");
      for (var i in keys) {
        self.del(keys[i]);
      }
      del_raw(self.prefix + "___keys___");
      return "OK";
    };

    this.select = function(i) {
      self.db = i;
      self.prefix = "bb:" + i.toString() + ":";
      keystore = get_bbkey("___keys___", "set") || {};
    };

    var keystore = get_bbkey("___keys___", "set") || {};

  }; /* end constructor */


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

  ctx.BankersBox = BB;
  ctx.BankersBoxException = BankersBoxException;
  ctx.BankersBoxKeyException = BankersBoxKeyException;
  ctx.BankersBoxLocalStorageAdapter = BankersBoxLocalStorageAdapter;
  ctx.BankersBoxNullAdapter = BankersBoxNullAdapter;
  if (ctx !== window) {
    ctx.mock_window = window;
  }
  
})(typeof(module) !== 'undefined' && module && module.exports ? module.exports : window);
