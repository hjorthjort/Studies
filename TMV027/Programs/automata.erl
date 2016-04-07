-module(automata).
-export([offer/2, new_automata/3]).
-include_lib("./automata.hrl").

new_automata(Delta, Start, AcceptingStates) when is_function(Delta) andalso
                                                    is_atom(Start) andalso
                                                    is_list(AcceptingStates) ->
    #automata{delta=Delta, state=Start, accepting=AcceptingStates}.


% Offer a list of strings to automata
offer([], _) ->
    [];

offer([H|T], Automata) ->
    offer_aux([H|T], [], Automata).


% Goes through a list of strings, retaining those which are accepted by the automata.
offer_aux([], Accepted, _) ->
    Accepted;

offer_aux([H|T], Accepted, Automata) ->
    case offer_string(H, Automata) of 
        true ->
            offer_aux(T, Accepted ++ [H], Automata);
        false ->
            offer_aux(T, Accepted, Automata)
    end.

% Returns true if the offered string is accepted by the automata
offer_string([], Automata) ->
    lists:any(fun(Elem) -> Elem =:= Automata#automata.state end, Automata#automata.accepting);

offer_string([H|T], Automata) ->
    Delta = Automata#automata.delta,
    NewState = Delta(Automata#automata.state, [H]),
    NewAutomata = Automata#automata{state = NewState},
    offer_string(T, NewAutomata).
