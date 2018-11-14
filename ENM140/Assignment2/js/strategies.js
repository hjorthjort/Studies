'use strict';

if (strategies === undefined) {
  var strategies = {};
}

if (cid === undefined) {
  var cid;
}

// Exchange this for your own cid
cid = 'examplecid';

// Defect: action 0
// Cooperate: action 1


strategies[cid + '10a'] = function () {
  function chooseAction(me, opponent, t) {
    // Always defect
    return 0;
  }

  return chooseAction;
}


strategies[cid + '10b'] = function () {
  function chooseAction(me, opponent, t) {
    // Always cooperate
    return 1;
  }

  return chooseAction;
}


strategies[cid + '10c'] = function () {
  function chooseAction(me, opponent, t) {
    // Tit for tat

    if (t == 0) {
      return 1; // cooperate in first round
    }

    return opponent[t-1]; // otherwise copy opponent
  }

  return chooseAction;
}



strategies[cid + '200a'] = function () {
  function chooseAction(me, opponent, t) {
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


strategies[cid + '200b'] = function () {
  // evil is a state variable for this strategy.
  // The initialization code ('var evil = false;'') will be run
  // before each game, so the variable evil will always equal
  // false when the game starts.

  var evil = false; // start out as not evil

  function chooseAction(me, opponent, t) {
    // This strategy uses the state variable 'evil'.
    // In every round, turn evil with 5% probability.
    // (And remain evil until the 200 rounds are over.)
    if (Math.random() < 0.05) {
      evil = true;
    }

    // If evil, defect
    if (evil) return 0;

    return 1; // and cooperate otherwise
  }
  return chooseAction;
}


strategies[cid + '200c'] = function () {
  function chooseAction(me, opponent, t) {
    // Cooperate initially, but always defect if opponent has defected
    // more than 10 times in total

    var maxDefects = 10;
    if (t < maxDefects) {
      return 1;
    }

    var numDefects = 0;
    // Loop through all previous time steps
    for (var i = 0; i < t; i++) {
      if (opponent[i] == 0) { // if opponent defected in round i
        numDefects = numDefects + 1; // then add to counter
      }

      if (numDefects > maxDefects) {
        return 0; // Defect if opponent has defected at least 10 times
      } else {
        return 1; // Otherwise cooperate
      }
    }
  }

  return chooseAction;
}


strategies[cid + '200mistakes'] = function () {
  function chooseAction(me, opponent, t) {
    // This code does the exact same thing as the 200c strategy, but
    // implemented in another way, which might appeal more or less
    // to your style of thinking/programming.

    //Slice out the part of history between time 0 and time t.
    var maxDefects = 10;
    if (t < maxDefects) {
      return 1; // cooperate if there is no chance t >= maxDefects
    }

    function sum(array) {
      return array.reduce(function (a, b) { return a + b; });
    }

    // Each cooperate action contributes 1 to the sum
    var passedHistory = opponent.slice(0, t);
    var numCooperate = sum(passedHistory);
    var numDefects = passedHistory.length - numCooperate;

    if (numDefects >= maxDefects) {
      return 0; // Defect if opponent has defected at least maxDefect times
    }

    return 1; // Otherwise cooperate
  }

  return chooseAction;
}
