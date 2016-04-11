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
offer_string(String, Automata) ->
    ExitState = delta_hat(Automata#automata.state, String, Automata#automata.delta),
    lists:any(fun(Elem) -> Elem =:= ExitState end, Automata#automata.accepting).

% Delta-hat function representing the repeated application of the delta function on a word.
%
% Input:
% State     The initial state from which to apply delta-hat
% String    The string to be read
% Delta     The delta function of the automata
delta_hat(State, [], _) ->
    State;

delta_hat(State, [H|T], Delta) ->
    delta_hat(Delta(State, [H]), T, Delta).


