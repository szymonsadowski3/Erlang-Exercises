%% -*- coding: utf-8 -*-
-module(lab5).
% nazwa modułu

-compile([export_all]).

-define(EMPTY_NODE, {node, 'empty'}).

init() ->
  ?EMPTY_NODE.

init(Numb) ->
  insert(Numb, init()).

randomTree() ->
  insertList([rand:uniform(1000) || _ <- lists:seq(1, 20)], init()).


insert(K, _Tree = ?EMPTY_NODE) ->
  {node, {K, init(), init()}};
insert(K, _Tree = {node, {NodeK, Left, Right}}) ->
  if K == NodeK -> % replace
      {node, {K, Left, Right}}
   ; K  < NodeK ->
      {node, {NodeK, insert(K, Left), Right}}
   ; K  > NodeK ->
      {node, {NodeK, Left, insert(K, Right)}}
  end.

%% @private
insertList([], Tree) -> Tree;
insertList([K|Rest], Tree) ->
  insertList(Rest, insert(K, Tree)).

concat(L,[]) ->
   L;
concat(L,[H|T]) ->
   concat(L ++ [H],T).


foldTreeToList(Tree = ?EMPTY_NODE) ->
  [];
foldTreeToList(Tree = {node, {NodeK, Left, Right}}) ->
  concat(foldTreeToList(Right), concat([NodeK], foldTreeToList(Left))).


lookup(_K, _Tree = ?EMPTY_NODE) ->
  false;
lookup(K, _Tree = {node, {NodeK, Left, Right}}) ->
  if K == NodeK -> true
   ; K <  NodeK -> lookup(K, Left)
   ; K >  NodeK -> lookup(K, Right)
  end.
