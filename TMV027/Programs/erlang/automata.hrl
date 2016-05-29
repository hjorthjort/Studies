
% delta must be a function with arity 2, state must be a single atom, and accepting a list of atoms.
-record(automata, { delta, state, accepting}).
