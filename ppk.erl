-module(ppk).
-compile([export_all]).

konsument(DataReceived)->
  receive
    {_,posrednik} -> io:format(DataReceived)
  end.

posrednik(DataReceived)->
  receive
    {Od,agh} ->
      POSRid = spawn(ppk, konsument, [DataReceived]),
      POSRid!{self(),posrednik}
  end.

producent()->
 FPid=spawn(ppk,posrednik,["dane od posrednika"]),
 FPid!{self(),agh}.
