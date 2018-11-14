'use strict';

if (strategies === undefined) {
  var strategies = {};
}

if (cid === undefined) {
  var cid;
}

// Exchange this for your own cid
cid = 'hjortr';

// Defect: action 0
// Cooperate: action 1

strategies[cid + '10a'] = function () {
  function chooseAction(me, opponent, t) {
      // Defect in last round.
      if (t == 9) return 0;
      if (t == 0) return 1;
      // TfT.
      return (opponent[t-1]);
  }

  return chooseAction;
}

strategies[cid + '10b'] = function () {
  function chooseAction(me, opponent, t) {
      if (t == 9) return 0;
      if (t == 0) return 1;
      // Small chance of defecting.
      return Math.random() < 0.1 ? 0 : 1;
  }

  return chooseAction;
}


strategies[cid + '10c'] = function () {
    let defections = 0;
    function chooseAction(me, opponent, t) {
        // Allow only 2 mistakes.
        if (t == 9) return 0;
        defections += 1 - opponent[t-1];
        if (defections >= 2) {
            return 0;
        }
        return 1;
    }
    return chooseAction;
}


strategies[cid + '200a'] = function () {
  function chooseAction(me, opponent, t) {
      if (t >= 198) return 0;
      if (t <= 1) return 0; // Defect twice;
      if (opponent[2] == 1) return 0; // Look for gullible suckers.

      // Play TfT.
      return (opponent[t-1]);
  }
  return chooseAction;
}

strategies[cid + '200b'] = function() {
    // Cooperate if you haven't seen too many defections, but defect yourself towards the end.
    let maxDefections = 15;
    let defections = 0;
    function chooseAction(me, opponent, t) {
        if (t >= 198) return 0; // Start being uncooperative at the end.
        if (t <= 1) return 1;
        defections += 1 - opponent[t-1];
        if (defections > maxDefections) return 0;
        return 1;
    }
    return chooseAction;
}

strategies[cid + '200c'] = function () {
    // Play Tf2T, but exploit other Tf2T towards the end.
    function chooseAction(me, opponent, t) {
        if (t <= 1) return 1;
        if (t >= 160 && t % 2 == 0) return 0; // Start being uncooperative at the end.
        if (opponent[t-1] == 1 || opponent[t-2] == 1) return 1;
        return 0;
    }
    return chooseAction;
}
strategies[cid + '200mistakes'] = function () {
    // NOTE: Starts abusing later than 200x.
    // Play Tf2T, but exploit other Tf2T towards the end.
    function chooseAction(me, opponent, t) {
        if (t <= 1) return 1;
        if (t >= 175 && t % 2 == 0) return 0; // Start being uncooperative at the end.
        if (opponent[t-1] == 1 || opponent[t-2] == 1) return 1;
        return 0;
    }
    return chooseAction;
}

// Strategy for the replicator dynamics.
strategies[cid + '200replicator'] = function () {
    // Takes mistake rate into account, and allows opponent some extra patience.

    // Plays a "Patient Even Steven" (Even Steven defined in the comments
    // below), but uses the known mutation rate. Essentially, this strategy
    // punishes defections (in the long run), but discounts the "expected"
    // mistakes from the mistake rate.
    // This performs really well in the replicator dynamics, even for very high
    // mistake rates, up to 10%.
    let sum = (acc, x) => acc + x;
    let totalMistakes = 0;
    let lastMove; // Save to approximate mistake rate.
    function chooseAction(me, opponent, t) {
        if (t > 0 && lastMove != me[t-1]) totalMistakes++;
        let approxMistakeRate = totalMistakes / t;
        if (t > 200 * (1 - approxMistakeRate)) return 0; // Defect a lot at the end, proportional to expected mistakes.
        let myBetrayals = t - me.slice(0, t).reduce(sum, 0);
        let oppBetrayals = t - opponent.slice(0, t).reduce(sum, 0);
        if (oppBetrayals * (1 - approxMistakeRate) > myBetrayals) lastMove =  0;
        else lastMove = 1;

        return lastMove;
    }
    return chooseAction;
}

// Interesting and/or common strategies.

  // Powerful strategies (good adversaries)

strategies['evenSteven'] = function() {
    // Tries to make sure the number of defections are the same for bot players.
    let sum = (acc, x) => acc + x;
    function chooseAction(me, opponent, t) {
        let myBetrayals = t - me.slice(0, t).reduce(sum, 0);
        let oppBetrayals = t - opponent.slice(0, t).reduce(sum, 0);
        if (oppBetrayals > myBetrayals) return 0;
        return 1;
    }
    return chooseAction;
}

strategies['200tf2t'] = function () {
function chooseAction(me, opponent, t) {
if (t == 199) return 0;
// Tit for two tats

if (t <= 1) {
return 1; // cooperate round 0 and 1
}

if (opponent[t-2] == 0 && opponent[t-1] == 0) {
return 0; // defect if last two opponent moves were defect
}

return 1; // otherwise cooperate
}

return chooseAction;
}


// Common strategies (bad adversaries)

/*
strategies['detective'] = function() {
    let gullible = false;
    function chooseAction(me, opponent, t) {
        if (t <= 1) return 1;

        if (t == 3) return 1;
        if (t == 4) {
            gullible = opponent[0] + opponent[1] + opponent[2] + opponent[3] == 4;
        }
        // Exploit gullibles.
        if (gullible) return 0;
        // TfT.
        return opponent[t-1];
    }
    return chooseAction;
}

strategies['alwaysD'] = function () {
    function chooseAction(me, opponent, t) {
        return 0;
    }
    return chooseAction;
}

strategies['trigger'] = function () {
    let betrayed = false;
    function chooseAction(me, opponent, t) {
        if (t == 0) return 1;
        if (opponent[t-1] == 0) betrayed = true;
        if (betrayed) return 0;
        return 1;
    }
    return chooseAction;
}

strategies['tft'] = function () {
    function chooseAction(me, opponent, t) {
        if (t == 0) return 1;
        return opponent[t-1];
    }
    return chooseAction;
}

/*

strategies['alwaysC'] = function () {
  function chooseAction(me, opponent, t) {
  return 1;
  }
  return chooseAction;
  }

strategies[cid + 'alternate'] = function() {
    function chooseAction(me, opponent, t) {
        if (t % 2 == 0) return 1;
        else return 0;
    }
    return chooseAction;
}
*/
