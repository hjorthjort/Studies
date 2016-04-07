-module(week2).
-include_lib("./automata.hrl").
-compile(export_all).

end_in_00(Strings) ->
    Automata = automata:new_automata(fun(State, Char) -> delta00(State,Char) end, q0, [q2]),
    automata:offer(Strings, Automata).

delta00(q0, "1") ->
    q0;

delta00(q0, "0") ->
    q1;

delta00(q1, "1") ->
    q0;

delta00(q1, "0") ->
    q2;

delta00(q2, "1") ->
    q0;

delta00(q2, "0") ->
    q2.

