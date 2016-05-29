-module(week2).
-include_lib("./automata.hrl").
-compile(export_all).

do(Strings, Fun, Accepting) ->
    Automata = automata:new_automata(Fun, q0, Accepting),
    automata:offer(Strings, Automata).


end_in_00(Strings) ->
    do(Strings, fun delta00/2, [q2]).

has_000(Strings) ->
    do(Strings, fun delta000/2, [q3]).

has_011(Strings) ->
    do(Strings, fun delta011/2, [q3]).

end_in_0100(Strings) ->
    do(Strings, fun delta0100/2, [q4]).

has_bba(Strings) ->
    do(Strings, fun delta_bba/2, [q3]).

has_no_bba(Strings) ->
    do(Strings, fun delta_bba/2, [q0,q1,q2]).

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

%--------------------
delta0100(State, "0") ->
    case State of
        q0 -> q1;
        q1 -> q1;
        q2 -> q3;
        q3 -> q4;
        q4 -> q1
    end;

delta0100(State, "1") ->
    case State of
        q0 -> q0;
        q1 -> q2;
        q2 -> q0;
        q3 -> q2;
        q4 -> q2
    end.

%--------------------

delta_bba(q3, _) ->
    q3;

delta_bba(State, "a") ->
    case State of
        q0 -> q0;
        q1 -> q0;
        q2 -> q3
    end;

delta_bba(State, "b") ->
    case State of
        q0 -> q1;
        q1 -> q2;
        q2 -> q2
    end.
