start_server {tags {"basic_ldb"}} {
    test {DEL all keys to start with a clean DB} {
        foreach key [r keys *] {r del $key}
	LoadFromLdbIfConfig r
        r dbsize
    } {0}

    test {SET and GET an item} {
        r set x foobar
	LoadFromLdbIfConfig r
        r get x
    } {foobar}

    test {SET and GET an empty item} {
        r set x {}
	LoadFromLdbIfConfig r
        r get x
    } {}

    test {DEL against a single item} {
        r del x
	LoadFromLdbIfConfig r
        r get x
    } {}

    test {Vararg DEL} {
        r set foo1 a
        r set foo2 b
        r set foo3 c
	LoadFromLdbIfConfig r
        list [r del foo1 foo2 foo3 foo4] [r mget foo1 foo2 foo3]
    } {3 {{} {} {}}}

    test {KEYS with pattern} {
        foreach key {key_x key_y key_z foo_a foo_b foo_c} {
            r set $key hello
        }
	LoadFromLdbIfConfig r
        lsort [r keys foo*]
    } {foo_a foo_b foo_c}

    test {KEYS to get all keys} {
	LoadFromLdbIfConfig r
        lsort [r keys *]
    } {foo_a foo_b foo_c key_x key_y key_z}

    test {DBSIZE} {
	LoadFromLdbIfConfig r
        r dbsize
    } {6}

    test {DEL all keys} {
        foreach key [r keys *] {r del $key}
	LoadFromLdbIfConfig r
        r dbsize
    } {0}

    test {Very big payload in GET/SET} {
        set buf [string repeat "abcd" 1000000]
        r set foo $buf
	LoadFromLdbIfConfig r
        r get foo
    } [string repeat "abcd" 1000000]

    tags {"slow"} {
        test {Very big payload random access} {
            set err {}
            array set payload {}
            for {set j 0} {$j < 100} {incr j} {
                set size [expr 1+[randomInt 100000]]
                set buf [string repeat "pl-$j" $size]
                set payload($j) $buf
                r set bigpayload_$j $buf
            }
            for {set j 0} {$j < 1000} {incr j} {
                set index [randomInt 100]
                set buf [r get bigpayload_$index]
                if {$buf != $payload($index)} {
                    set err "Values differ: I set '$payload($index)' but I read back '$buf'"
                    break
                }
            }
            unset payload
            set _ $err
        } {}

        test {SET 10000 numeric keys and access all them in reverse order} {
            set err {}
            for {set x 0} {$x < 10000} {incr x} {
                r set $x $x
            }
            set sum 0
            for {set x 9999} {$x >= 0} {incr x -1} {
                set val [r get $x]
                if {$val ne $x} {
                    set err "Element at position $x is $val instead of $x"
                    break
                }
            }
            set _ $err
        } {}

        test {DBSIZE should be 10101 now} {
	    LoadFromLdbIfConfig r
            r dbsize
        } {10101}
    }

    test {INCR against non existing key} {
        set res {}
        append res [r incr novar]
        append res [r get novar]
    } {11}

    test {INCR against key created by incr itself} {
        r incr novar
    } {2}

    test {INCR against key originally set with SET} {
        r set novar 100
        r incr novar
    } {101}

    test {INCR over 32bit value} {
        r set novar 17179869184
        r incr novar
    } {17179869185}

    test {INCRBY over 32bit value with over 32bit increment} {
        r set novar 17179869184
        r incrby novar 17179869184
    } {34359738368}

    test {INCR fails against key with spaces (left)} {
        r set novar "    11"
        catch {r incr novar} err
        format $err
    } {ERR*}

    test {INCR fails against key with spaces (right)} {
        r set novar "11    "
        catch {r incr novar} err
        format $err
    } {ERR*}

    test {INCR fails against key with spaces (both)} {
        r set novar "    11    "
        catch {r incr novar} err
        format $err
    } {ERR*}

    test {INCR fails against a key holding a list} {
        r rpush mylist 1
        catch {r incr mylist} err
        r rpop mylist
        format $err
    } {WRONGTYPE*}

    test {DECRBY over 32bit value with over 32bit increment, negative res} {
        r set novar 17179869184
        r decrby novar 17179869185
    } {-1}

    test {INCRBYFLOAT against non existing key} {
        r del novar
	LoadFromLdbIfConfig r
        list    [roundFloat [r incrbyfloat novar 1]] \
                [roundFloat [r get novar]] \
                [roundFloat [r incrbyfloat novar 0.25]] \
                [roundFloat [r get novar]]
    } {1 1 1.25 1.25}

    test {DEL all keys again (DB 0)} {
        foreach key [r keys *] {
            r del $key
        }
	LoadFromLdbIfConfig r
        r dbsize
    } {0}

    test {DEL all keys again (DB 1)} {
        r select 10
        foreach key [r keys *] {
            r del $key
        }
	LoadFromLdbIfConfig r
        set res [r dbsize]
        r select 9
        format $res
    } {0}

    test {MOVE basic usage} {
        r set mykey foobar
        r move mykey 10
	LoadFromLdbIfConfig r
        set res {}
        lappend res [r exists mykey]
        lappend res [r dbsize]
        r select 10
	LoadFromLdbIfConfig r
        lappend res [r get mykey]
        lappend res [r dbsize]
        r select 9
        format $res
    } [list 0 0 foobar 1]

    test {MGET} {
        r flushdb
        r set foo BAR
        r set bar FOO
	LoadFromLdbIfConfig r
        r mget foo bar
    } {BAR FOO}

    test {MGET against non existing key} {
	LoadFromLdbIfConfig r
        r mget foo baazz bar
    } {BAR {} FOO}

    test {MGET against non-string key} {
        r sadd myset ciao
        r sadd myset bau
	LoadFromLdbIfConfig r
        r mget foo baazz bar myset
    } {BAR {} FOO {}}

    test {RANDOMKEY} {
        r flushdb
        r set foo x
        r set bar y
        set foo_seen 0
        set bar_seen 0
        for {set i 0} {$i < 100} {incr i} {
            set rkey [r randomkey]
            if {$rkey eq {foo}} {
                set foo_seen 1
            }
            if {$rkey eq {bar}} {
                set bar_seen 1
            }
        }
        list $foo_seen $bar_seen
    } {1 1}

    test {RANDOMKEY against empty DB} {
        r flushdb
	LoadFromLdbIfConfig r
        r randomkey
    } {}

    test {RANDOMKEY regression 1} {
        r flushdb
        r set x 10
        r del x
	LoadFromLdbIfConfig r
        r randomkey
    } {}

    test {GETSET (set new value)} {
        list [r getset foo xyz] [r get foo]
    } {{} xyz}

    test {GETSET (replace old value)} {
        r set foo bar
	LoadFromLdbIfConfig r
        list [r getset foo xyz] [r get foo]
    } {bar xyz}

    test {MSET base case} {
        r mset x 10 y "foo bar" z "x x x x x x x\n\n\r\n"
	LoadFromLdbIfConfig r
        r mget x y z
    } [list 10 {foo bar} "x x x x x x x\n\n\r\n"]


    test "STRLEN against plain string" {
        r set mystring "foozzz0123456789 baz"
	LoadFromLdbIfConfig r
        assert_equal 20 [r strlen mystring]
    }

    test "GETBIT against non-existing key" {
        r del mykey
	LoadFromLdbIfConfig r
        assert_equal 0 [r getbit mykey 0]
    }

    test "GETRANGE against integer-encoded value" {
        r set mykey 1234
	LoadFromLdbIfConfig r
        assert_equal "123" [r getrange mykey 0 2]
        assert_equal "1234" [r getrange mykey 0 -1]
        assert_equal "234" [r getrange mykey -3 -1]
        assert_equal "" [r getrange mykey 5 3]
        assert_equal "4" [r getrange mykey 3 5000]
        assert_equal "1234" [r getrange mykey -5000 10000]
    }


    test {KEYS * two times with long key, Github issue #1208} {
        r flushdb
        r set dlskeriewrioeuwqoirueioqwrueoqwrueqw test
        r keys *
        r keys *
    } {dlskeriewrioeuwqoirueioqwrueoqwrueqw}

    test {GETRANGE with huge ranges, Github issue #1844} {
        r set foo bar
        r getrange foo 0 4294967297
    } {bar}
}
