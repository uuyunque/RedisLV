start_server {tags {"maxmemoryb"}} {
    test "With maxmemory and set uplimit" {
        r flushall
        r config set maxmemory-policy noeviction 
        set numkeys 1 
	set veri_set_key "" 
	set veri_set_val "" 
	set veri_sadd_key "" 
        set veri_sadd_val "" 
	set veri_hash_key "" 
	set veri_mem_key ""
	set veri_hash_val "" 
	set veri_score "" 
	set veri_zadd_key "" 
	set veri_zadd_mem "" 
        set last_progress [clock seconds]
        while 1 {
            set set_key [randomKeyWithRange 90 127]
            set set_val [randomValue]
            set sadd_key [randomKeyWithRange 1 30]
            set sadd_val [randomKeyWithRange 1 127]
            set hash_key [randomKeyWithRange 30 60]
            set mem_key [randomKeyWithRange 1 127]
            set hash_val [randomSignedInt 4000000000]
            set score [randomSignedInt 4000000000]
            set zadd_key [randomKeyWithRange 60 90]
            set zadd_mem [randomKeyWithRange 1 127]

            if {[catch { r set $set_key $set_val } err]} {
                if {[string match {*maxmemory*} $err]} {
                } else {
                    puts "<erro:> set:<$set_key>:<$set_val>$err"
                }
                break
            }
            if {[catch { r sadd $sadd_key $sadd_val } err]} {
                if {[string match {*maxmemory*} $err]} {
                } else {
                    puts "<erro:> sadd:<$sadd_key>:<$sadd_val>$err"
                }
                break
            }
            if {[catch { r hset $hash_key $mem_key $hash_val } err]} {
                if {[string match {*maxmemory*} $err]} {
                } else {
                    puts "<erro:> hset:<$hash_key> <$mem_key>$err"
                }
                break
            }
            set tmp_rank [r zrank $zadd_key $zadd_mem]
            if {$tmp_rank >= 0} {
	        if {[catch { r zrem $zadd_key $zadd_mem} err]} {
	            puts "<erro:> zrem <$zadd_key>:<$zadd_mem>$err"
	            break
	        }
            }
            if {[catch { r zadd $zadd_key $score $zadd_mem} err]} {
                if {[string match {*maxmemory*} $err]} {
                } else {
                    puts "<erro:> zadd <$zadd_key>:<$score>:<$zadd_mem>$err"
                }
                break
            }
            # 用第一次的randomkey做一个初始化操作
            if {[string length $veri_set_key] == 0} {
		set veri_set_key $set_key
	        set veri_set_val $set_val
	        set veri_sadd_key $sadd_key
		set veri_sadd_val $sadd_val
		set veri_hash_key $hash_key
		set veri_mem_key $mem_key
		set veri_hash_val $hash_val
		set veri_score $score
		set veri_zadd_key $zadd_key
		set veri_zadd_mem $zadd_mem
            }
            incr numkeys
            set random_val [randomInt 4000000000]
            if {$random_val % 99 == 0} {
		set veri_set_key $set_key
	        set veri_set_val $set_val
	        set veri_sadd_key $sadd_key
		set veri_sadd_val $sadd_val
		set veri_hash_key $hash_key
		set veri_mem_key $mem_key
		set veri_hash_val $hash_val
		set veri_score $score
		set veri_zadd_key $zadd_key
		set veri_zadd_mem $zadd_mem
            }
            if {$random_val % 1000 == 0} {
                assert_equal $veri_set_val [r get $veri_set_key]
                assert_equal 1 [r sismember $veri_sadd_key $veri_sadd_val]
                assert_equal $veri_hash_val [r hget $veri_hash_key $veri_mem_key]
                set  get_rank [r zrank $veri_zadd_key $veri_zadd_mem]
                if {[string length $get_rank] == 0} {
		    puts "<erro:>zrank $veri_zadd_key:$veri_zadd_mem not exist"
                    break
                }
            }
            if {$random_val % 1000000 == 0} {
                set start [clock seconds]
                LoadFromLdbIfConfig r
                set num [r dbsize]
                set end [expr {[clock seconds]-$start}]
                puts "--------------load from leveldb num:<$num> cost:<$$end>---------------"
                assert_equal $veri_set_val [r get $veri_set_key]
                assert_equal 1 [r sismember $veri_sadd_key $veri_sadd_val]
                assert_equal $veri_hash_val [r hget $veri_hash_key $veri_mem_key]
                set  get_rank [r zrank $veri_zadd_key $veri_zadd_mem]
                if {[string length $get_rank] == 0} {
		    puts "<erro:>zrank $veri_zadd_key:$veri_zadd_mem not exist"
                    break
                }
            }
            if {$random_val % 1000000 == 0} {
                puts "do delete mem operation"
		r del $veri_set_key
                r srem $veri_sadd_key $veri_sadd_val
                r zrem $veri_zadd_key $veri_zadd_mem
                r hdel $veri_hash_key $veri_mem_key
                assert_equal "" [r get $veri_set_key]
                assert_equal 0 [r sismember $veri_sadd_key $veri_sadd_val]
                assert_equal "" [r hget $veri_hash_key $veri_mem_key]
                assert_equal "" [r zrank $veri_zadd_key $veri_zadd_mem]
                LoadFromLdbIfConfig r
                assert_equal "" [r get $veri_set_key]
                assert_equal 0 [r sismember $veri_sadd_key $veri_sadd_val]
                assert_equal "" [r hget $veri_hash_key $veri_mem_key]
                assert_equal "" [r zrank $veri_zadd_key $veri_zadd_mem]
		set $veri_set_key ""
            }
            if {$random_val % 10000000 == 0} {
                puts "do delete all db"
                r flushall
                assert_equal 0 [r dbsize]
	        LoadFromLdbIfConfig r
                assert_equal 0 [r dbsize]
		set $veri_set_key ""
            }
            if {$numkeys % 100000 == 0 } {
                set elapsed [expr {[clock seconds]-$last_progress}]
        	puts "--------------numkeys<$numkeys> cost time<$elapsed>--------------"
                set last_progress [clock seconds]
            }
        }
    }
}
