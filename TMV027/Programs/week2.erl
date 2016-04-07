-module(week2).
-include_lib("./automata.hrl").
-compile(export_all).

end_in_00(Strings) ->
    Automata = automata:new_automata(fun(State, Char) -> delta00(State,Char) end, q0, [q2]),
    automata:offer(Strings, Automata).

has_000(Strings) ->
    Automata = automata:new_automata(fun delta000/2, q0, [q3]),
    automata:offer(Strings, Automata).

has_011(Strings) ->
    Automata = automata:new_automata(fun delta011/2, q0, [q3]),
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

delta000(State, "0") ->
    case State of 
        q0 ->
            q1;
        q1 ->
            q2;
        q2 ->
            q3;
        q3 ->
            q3
    end;

delta000(q3, "1") ->
    q3;

delta000(_, "1") ->
    q0.
    

delta011(State, "0") ->
    case State of 
        q0 ->
            q1;
        q1 ->
            q1;
        q2 ->
            q1;
        q3 ->
            q3
    end;

delta011(State, "1") ->
    case State of
        q0 ->
            q0;
        q1 ->
            q2;
        q2 ->
            q3;
        q3 ->
            q3
    end.
