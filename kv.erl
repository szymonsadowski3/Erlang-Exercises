-module(kv).

-export([start/0, stop/0, store/2, lookup/1, delete/1, hash/1]).

-export([server_loop/1]).

%---------------------------------------------------------------------------------------------
% Client API
%---------------------------------------------------------------------------------------------

% Start the KV-store.
start() ->
    crypto:start(),
    Pid = spawn(?MODULE, server_loop, [dict:new()]),
    register(?MODULE, Pid),
    ok.

stop() -> ?MODULE ! {stop}.

% Add a new value to the the KV-store. The return value is the new KEY related to the value V.
store(K, V) -> rpc({store, K, V, self()}).

% Lookup a value in the KV-store. If the key is not found, return the atom not_found.
lookup(K) -> rpc({lookup, K, self()}).

% Delete an existing key K. Returns ok or not_found.
delete(K) -> rpc({delete, K, self()}).

%---------------------------------------------------------------------------------------------
% Server Implementation
%---------------------------------------------------------------------------------------------
server_loop(Dict) ->
    receive
        {store, K, V, Client} ->
            Dict2 = dict:store(K, V, Dict),
            Client ! {hash, K},
            server_loop(Dict2);
        {lookup, K, Client} ->
            Reply = case dict:find(K, Dict) of
                {ok, Value} -> Value;
                error       -> not_found
            end,
            Client ! {value, Reply},
            server_loop(Dict);
        {delete, K, Client} ->
            Dict2 = case dict:is_key(K, Dict) of
                true -> dict:erase(K, Dict);
                false -> Dict
            end,
            Client ! {deleted, ok},
            server_loop(Dict2);
        {stop} -> exit(shutdown)
    end.

%---------------------------------------------------------------------------------------------
% Utilities
%---------------------------------------------------------------------------------------------
rpc(Message) ->
    ?MODULE ! Message,
    receive
        {hash, Hash} -> Hash;
        {value, Value} -> Value;
        {deleted, Outcome} -> Outcome
    end.

hash(Data) when is_atom(Data) -> hash(atom_to_list(Data));
hash(Data) ->
    Binary160 = crypto:hash(sha, Data),
    hexstring(Binary160).

% Convert a 160-bit binary hash to a hex string.
hexstring(<<X:160/big-unsigned-integer>>) ->
    lists:flatten(io_lib:format("~40.16.0b", [X])).

%---------------------------------------------------------------------------------------------
% Unit Tests
%---------------------------------------------------------------------------------------------
