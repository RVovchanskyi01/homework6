-module(homework6).
-compile([export_all]).

% Явно вказуємо експортовані функції
-export([create/1, insert/3, insert/4, lookup/2, delete_obsolete/1]).

create(Name) ->
    io:format("Creating cache table ~s~n", [Name]),
    ok.

insert(Name, _Key, Value) ->
    io:format("Inserting ~s into cache table ~s~n", [Value, Name]),
    ok.

insert(Name, _Key, Value, _TTL) ->
    io:format("Inserting ~s with TTL into cache table ~s~n", [Value, Name]),
    ok.

lookup(Name, Key) ->
    io:format("Looking up key ~s in cache table ~s~n", [Key, Name]),
    undefined. % Default return if the key is not found

delete_obsolete(Name) ->
    io:format("Deleting obsolete entries from cache table ~s~n", [Name]),
    ok.
