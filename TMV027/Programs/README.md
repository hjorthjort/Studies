# Programs

Programs simulating automata in different languages.

## Erlang

To create an automata in the Erlang module, compile module "automata" and call new_automata. It takes the following arguments:

* Delta: A function that takes an atom (representing a state) and a single character, and returns an atom (a new state).
* Start: An atom representing the start state.
* AcceptingStates: A list of atoms representing the accepting states.

Note that the automata doesn't take an alphabet or a list of possible states. Instead, you must only use this automata with strings for which the delta function is defined. The list of possible states is uneccessary, since it can be inferred from the delta function, but this also means that the delta function must accept all reachable states.
