-module(tokk).

-compile([export_all]).

-import(string,[split/3]).

split_by_whitespaces(Inp) -> string:split(Inp, " ", all).

count(N, H) -> count(N, H, 0).
count(_, [], Count) -> Count;
count(X, [X|Rest], Count) -> count(X, Rest, Count+1);
count(X, [_|Rest], Count) -> count(X, Rest, Count).

remove_duplicates(List) ->
    Set = sets:from_list(List),
    sets:to_list(Set).

build_frequency_mapping(Inp) ->
    Tokens = split_by_whitespaces(Inp),
    Unique_tokens = remove_duplicates(Tokens),
    [io:format("Printing ~p ~n",[X])|| X <- Unique_tokens],
    Token_count_tuples = [{Unique_token, count(Unique_token, Tokens)} || Unique_token <- Unique_tokens],
    maps:from_list(Token_count_tuples).
