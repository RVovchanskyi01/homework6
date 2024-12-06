-module(homework6_server).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {tables = #{}}).

%% API
start_link() ->
    gen_server:start_link({local, homework6_server}, ?MODULE, [], []).

%% Callbacks
init([]) ->
    %% Запускаємо таймер для періодичного очищення
    erlang:send_after(60000, self(), clean_cache),
    {ok, #state{}}.

handle_call({create, TableName}, _From, State) ->
    ets:new(TableName, [named_table, public, set]),
    {reply, ok, State#state{tables = maps:put(TableName, true, State#state.tables)}}.

handle_call({insert, TableName, Key, Value}, _From, State) ->
    ets:insert(TableName, {Key, Value, infinity}),
    {reply, ok, State};

handle_call({insert, TableName, Key, Value, TTL}, _From, State) ->
    Expiry = erlang:system_time(second) + TTL,
    ets:insert(TableName, {Key, Value, Expiry}),
    {reply, ok, State};

handle_call({lookup, TableName, Key}, _From, State) ->
    case ets:lookup(TableName, Key) of
        [] -> {reply, undefined, State};
        [{_Key, Value, Expiry}] ->
            CurrentTime = erlang:system_time(second),
            if
                Expiry == infinity; Expiry > CurrentTime -> {reply, Value, State};
                true -> {reply, undefined, State}
            end
    end.

handle_info(clean_cache, State) ->
    %% Видаляємо застарілі записи
    maps:map(fun(TableName, _) ->
        CurrentTime = erlang:system_time(second),
        Fun = fun({Key, _Value, Expiry}) ->
            Expiry =/= infinity andalso Expiry =< CurrentTime
        end,
        ets:select_delete(TableName, [{{'$1', '$2', '$3'}, [{Fun, [true]}], ['$1']}])
    end, State#state.tables),
    %% Перезапускаємо таймер
    erlang:send_after(60000, self(), clean_cache),
    {noreply, State};

handle_info(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
