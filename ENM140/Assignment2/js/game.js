'use strict';

function createOrderings(n) {
  var orderings = [];
  var ordering;
  for (var i = 0; i < n; i++) {
    ordering = [];
    ordering.push(i);
    for (var j = 0; j < i; j++) {
      ordering.push(j);
    }
    for (var j = i+1; j < n; j++) {
      ordering.push(j);
    }
    orderings.push(ordering)
  }
  return orderings;
}

function createIteratedGame(payoffFunc, nRounds, callback) {

  function playIteratedGame(strategies) {
    var orderings = createOrderings(strategies.length);
    // logger.debug("Created orderings " + orderings);

    var accumulatedPayoffs = strategies.map(function () { return 0; });

    var histories = strategies.map(function() {
      return new Uint8Array(nRounds);
    });

    // Temporary history arrays passed to users, to prevent client code from
    // changing history.
    var tempHistories = histories.map(function(history) {
      return history.slice();
    });

    var payoffs, actionProfile, action;

    // logger.debug('Starting game with ' + nRounds + ' rounds.');
    for (var roundIdx = 0; roundIdx < nRounds; roundIdx++) {
      // logger.debug('Starting round ' + roundIdx + '.');
      strategies.forEach(function (strategy, stratIdx) {

        // logger.debug('Strategy ' + stratIdx + '(' + strategy.name + ')');
        // Set up the temporary histories from the perspective of the strategy
        orderings[stratIdx].forEach(function (srcIdx, dstIdx) {
          tempHistories[dstIdx].set(histories[srcIdx]);
        });

        // Let the strategy choose an action
        var strategyArgs = tempHistories.slice();
        // logger.debug('Giving histories ' + strategyArgs);
        strategyArgs.push(roundIdx);
        try {
          action = strategy.apply(null, strategyArgs);
          // logger.debug('Strategy returned action ' + action);
          histories[stratIdx][roundIdx] = action;
          if (action !== histories[stratIdx][roundIdx]) {
            throw new Error(
              'Strategy ' + strategy.name
              + ' returned non-integer action: ' + action)
          }
        }
        catch (e) {
          throw e;
        }
      });

      // Assign payoffs
      actionProfile = histories.map(function (history) {
        return history[roundIdx];
      });
      try {
        payoffs = payoffFunc(actionProfile);
      }
      catch (e) {
        throw new Error(
          'Could not evaluate payoff with action profile ['
          + actionProfile + ']. The inner error message is "'
          + e.message + '"');
      }
      strategies.forEach(function (_, stratIdx) {
        accumulatedPayoffs[stratIdx] += payoffs[stratIdx];
      });
      if (callback !== undefined) {
        callback({
          't': roundIdx,
          'actionProfile': actionProfile,
          'payoffs': payoffs,
          'accumulatedPayoffs': accumulatedPayoffs.slice()
        });
      }
    }

    strategies.forEach(function (_, stratIdx) {
      accumulatedPayoffs[stratIdx] /= nRounds;
    });

    return accumulatedPayoffs;
  }

  return playIteratedGame;
}

function playAllPairsSymmetric(game, strategies, nRuns) {
  if (arguments.length < 3) {
    nRuns = 1;
  }
  var results = strategies.map(function () {
    return new Float32Array(strategies.length);
  });
  var payoffs, accumulatedPayoffs;
  for (var i = 0; i < strategies.length; i++) {
    for (var j = 0; j <= i; j++) {
      accumulatedPayoffs = [0, 0];
      for (var r = 0; r < nRuns; r++) {
        payoffs = game([strategies[i](), strategies[j]()]);
        accumulatedPayoffs[0] += payoffs[0];
        accumulatedPayoffs[1] += payoffs[1];
      }
      results[i][j] = accumulatedPayoffs[0] / nRuns;
      results[j][i] = accumulatedPayoffs[1] / nRuns;
    }
  }
  return results;
}


function createIPD(nRounds, mistakeProb, callback) {
  var PD_PAYOFF_MATRIX = [[1, 5], [0, 3]];
  function payoff(actionProfile) {
    return [
      PD_PAYOFF_MATRIX[actionProfile[0]][actionProfile[1]],
      PD_PAYOFF_MATRIX[actionProfile[1]][actionProfile[0]]
    ];
  }

  function mistakeWrapper(func, prob) {
      var wrapped = function () {
          var action = func.apply(null, arguments);
          if (Math.random() < prob) {
              action = 1 - action;
          }
          return action;
      }
      return wrapped;
  }

  var play = createIteratedGame(payoff, nRounds, callback);

  if (mistakeProb > 0) {
    function playWithMistakes(strategies) {
      var mistakeStrategies = strategies.map(function(strategy) {
        return mistakeWrapper(strategy, mistakeProb);
      });
      return play(mistakeStrategies);
    }
    return playWithMistakes;
  } else {
    return play;
  }
}


function sum(u) {
  return u.reduce(function (a, b) { return a + b; });
}

function dot(u, v) {
  var products = u.map(function (ui, i) {
    return ui * v[i];
  });
  return sum(products);
}


function normalize(u) {
  var uSum = sum(u);
  return u.map(function (ui) {
    return ui / uSum;
  });
}

function calcFitnesses(scoreMatrix, abundances) {
  var scores = scoreMatrix.map(function (scoreRow) {
    return dot(abundances, scoreRow);
  });
  var meanScore = dot(abundances, scores);
  var fitnesses = scores.map(function (score) { return score - meanScore; });
  return fitnesses;
}

function newAbundances(abundances, fitnesses, pressure, extinctionLimit) {
  var rawAbundances = abundances.map(function (abundance, i) {
    var proposal = abundance * (1 + fitnesses[i] * pressure);
    if (proposal >= extinctionLimit) {
      return proposal;
    } else {
      return 0;
    }
  });

  return normalize(rawAbundances);
}
