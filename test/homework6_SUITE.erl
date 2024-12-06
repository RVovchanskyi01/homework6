-module(homework6_SUITE).
-include_lib("common_test/include/ct.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1, init_per_testcase/2, end_per_testcase/2]).
-export([test_create/1, test_insert_and_lookup/1, test_expiry/1]).

all() -> [test_create, test_insert_and_lookup, test_expiry].

init_per_suite(_Config) ->
    application:start(homework6),
    ok.

end_per_suite(_Config) ->
    application:stop(homework6),
    ok.

init_per_testcase(_TestCase, _Config) ->
    ok.

end_per_testcase(_TestCase, _Config) ->
    ok.

test_create(_Config) ->
    ok = homework6:create(my_table),
    ?assertEqual(true, ets:info(my_table) =/= undefined).

test_insert_and_lookup(_Config) ->
    ok = homework6:create(my_table),
    ok = homework6:insert(my_table, key1, value1),
    ?assertEqual(value1, homework6:lookup(my_table, key1)).

test_expiry(_Config) ->
    ok = homework6:create(my_table),
    ok = homework6:insert(my_table, key2, value2, 1),
    timer:sleep(1500),
    ?assertEqual(undefined, homework6:lookup(my_table, key2)).
