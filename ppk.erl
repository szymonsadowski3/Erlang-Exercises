konsument(DataReceived)->
  receive
    {_,posrednik} -> io:format(DataReceived)
  end.

posrednik()->
receive
    {Od, Dane} ->
      POSRid = spawn(ppk, konsument, [Dane]),
      POSRid!{self(),posrednik}
  end,
  posrednik().

producent(_, 0)->0;

producent(FPid, N)->
  FPid!{self(), "dane od posrednika ~n"},
  producent(FPid, N-1).

producentInit(N)->
 FPid=spawn(ppk,posrednik,[]),
 producent(FPid, N).

fmain() ->
  FPid=spawn(ppk,producentInit,[2]).
