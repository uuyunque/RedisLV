[RedisLV-支持基于LevelDB的Redis持久化方法](https://github.com/ivanabc/RedisLV)
---

### Redis持久化的问题
1. RDB方式: 数据持久化的过程中可能存在大量额外内存消耗。
2. AOF方式: 通过aof文件恢复数据库的过程慢。

### RedisLV优点
1. 对于内存有限的服务，数据持久化不会带来额外的内存消耗。
2. 相对AOF方式，数据库的恢复更快。

### RedisLV缺点
1. 由于对redis写入操作需要同步到leveldb，导致性能损耗(读操作不受影响)。

### RedisLV备份
```
redis-cli backup dir(备份文件目录)
```
* 当备份目录中包含BACKUP.log文件并且文件中有SUCCESS字段，表示备份成功

### Redis命令支持状况(yes: 支持; no: 不支持), 当redis使用leveldb引擎时，命令支持状况(yes: 支持; no: 不支持)

| Key         |  redis_in_ldb  | redis_no_ldb |
|-------------|----------------| -------------|
| DEL         |       yes      |      yes     |
| DUMP        |       yes      |      yes     |
| EXISTS      |       yes      |      yes     |
| EXPIRE      |       no       |      yes     |
| EXPIREAT    |       no       |      yes     |
| KEYS        |       yes      |      yes     |
| MIGRATE     |       no       |      yes     |
| MOVE        |       no       |      yes     |
| OBJECT      |       yes      |      yes     |
| PERSIST     |       no       |      yes     |
| PEXPIRE     |       no       |      yes     |
| PEXPIREAT   |       no       |      yes     |
| PTTL        |       no       |      yes     |
| RANDOMKEY   |       yes      |      yes     |
| RENAME      |       no       |      yes     |
| RENAMENX    |       no       |      yes     |
| RESTORE     |       no       |      yes     |
| SORT        |  yes(not store)|      yes     |
| TTL         |       no       |      yes     |
| TYPE        |       yes      |      yes     |
| SCAN        |       yes      |      yes     |

---

| String      |  redis_in_ldb  | redis_no_ldb |
|-------------|----------------|--------------|
| APPEND      |       yes      |      yes     |
| BITCOUNT    |       yes      |      yes     |
| BITOP       |       yes      |      yes     |
| DECR        |       yes      |      yes     |
| DECRBY      |       yes      |      yes     |
| GET	      |       yes      |      yes     |
| GETBIT      |       yes      |      yes     |
| GETRANGE    |       yes      |      yes     |
| GETSET      |       yes      |      yes     |
| INCR        |       yes      |      yes     |
| INCRBY      |       yes      |      yes     |
| INCRBYFLOAT |       yes      |      yes     |
| MGET        |       yes      |      yes     |
| MSET        |       yes      |      yes     |
| MSETNX      |       yes      |      yes     |
| PSETEX      |       no       |      yes     |
| SET         |       yes      |      yes     |
| SETBIT      |       yes      |      yes     |
| SETEX       |       no       |      yes     |
| SETNX       |       yes      |      yes     |
| SETRANGE    |       yes      |      yes     |
| STRLEN      |       yes      |      yes     |

---

| Hash        |   redis_in_ldb | redis_no_ldb |
|-------------|----------------|--------------|
| HDEL        |       yes      |      yes     | 
| HEXISTS     |       yes      |      yes     |
| HGET        |       yes      |      yes     |
| HGETALL     |       yes      |      yes     |
| HINCRBY     |       yes      |      yes     |
| HINCRBYFLOAT|       yes      |      yes     |
| HKEYS       |       yes      |      yes     |
| HLEN        |       yes      |      yes     |
| HMGET       |       yes      |      yes     |
| HMSET       |       yes      |      yes     |
| HSET        |       yes      |      yes     |
| HSETNX      |       yes      |      yes     |
| HVALS       |       yes      |      yes     |
| HSCAN       |       yes      |      yes     |

---

| Set         |   redis_in_ldb | redis_no_ldb |
|-------------|----------------|--------------|
| SADD        |       yes      |      yes     |
| SCARD       |       yes      |      yes     |
| SDIFF       |       yes      |      yes     |
| SDIFFSTORE  |       no       |      yes     |
| SINTER      |       yes      |      yes     |
| SINTERSTORE |       no       |      yes     |
| SISMEMBERS  |       yes      |      yes     |
| SMEMBERS    |       yes      |      yes     |
| SMOVE       |       no       |      yes     |
| SPOP        |       no       |      yes     |
| SRANDMEMBER |       yes      |      yes     |
| SREM        |       yes      |      yes     |
| SUNION      |       yes      |      yes     |
| SUNIONSTORE |       no       |      yes     |
| SSCAN       |       yes      |      yes     |

---

| SortedSet       | redis_in_ldb | redis_no_ldb |
|-----------------|--------------|--------------|
| ZADD            |       yes    |      yes     |
| ZCARD           |       yes    |      yes     |
| ZCOUNT          |       yes    |      yes     |
| ZINCRBY         |       yes    |      yes     |
| ZRANGE          |       yes    |      yes     |
| ZRANGEBYSCORE   |       yes    |      yes     |
| ZRANK           |       yes    |      yes     |
| ZREM            |       yes    |      yes     |
| ZREMRANGEBYRANK |       yes    |      yes     |  
| ZREMRANGEBYSCORE|       yes    |      yes     |
| ZREVRANGE       |       yes    |      yes     |
| ZREVRANKBYSCORE |       yes    |      yes     |
| ZREVRANK        |       yes    |      yes     |
| ZSCORE          |       yes    |      yes     |
| ZUNIONSTORE     |       no     |      yes     |
| ZINTERSTORE     |       no     |      yes     |
| ZSCAN           |       yes    |      yes     |
| ZRANGEBYLEX     |       yes    |      yes     |
| ZLEXCOUNT       |       yes    |      yes     |
| ZREMRANGEBYLEX  |       yes    |      yes     |  
