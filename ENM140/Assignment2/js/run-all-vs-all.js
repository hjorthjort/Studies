'use strict';

function setWorking (isWorking) {
  d3.select('#run-button')
  .text(isWorking ? 'Working...' : 'Run (Ctrl+Enter)')
  .attr('disabled', isWorking ? true : null);
}
function clearResults () {
  d3.select('#results-table').html('');
}
var errors = [];
function clearErrors () {
  errors = [];
  renderErrors();
}
function replaceAll (str, search, replacement) {
  var re = new RegExp(search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), 'g');
  return str.replace(re, replacement);
}
function textToHtml(s) {
  return [
    {'src': '<', 'dst': '&lt;'},
    {'src': '>', 'dst': '&gt;'},
    {'src': '\n', 'dst': '<br/>'},
    {'src': ' ', 'dst': '&nbsp;'}
  ].reduce(function (val, replacement) {
      var a = replaceAll(val, replacement.src, replacement.dst);
      return a;
    }, s);
}
function displayError (e) {
  var errHtml = '<b>' + e.message + '</b>';
  if (e.stack != undefined) errHtml += '</br>' + textToHtml(e.stack);

  errors.push(errHtml);
  renderErrors();
  throw e;
}
function renderErrors() {
  var li = d3.select('#error').selectAll('li').data(errors);

  li.enter()
  .append('li')
  .html(function (d) { return d; });

  li.exit()
  .remove();
}

setWorking(false);


d3.select('body').on('keypress', function () {
  if (d3.event.code === 'Enter' && d3.event.ctrlKey === true) {
    run();
  }
});


function run() {

  clearErrors();
  clearResults();

  try {
    setWorking(true);
    runTest();
  }
  catch (e) {
    displayError(e);
  }
  finally {
    setWorking(false);
  }

  function highlight() {
    d3.select('#results')
    .transition()
    .duration(50)
    .style('background-color', '#ece')
    .transition()
    .duration(300)
    .style('background-color', '#eee');
  }

  function runTest() {
    var re = new RegExp(document.getElementById('regex').value);

    var includedStrategies = d3.entries(strategies).filter(function(d) {
      return re.test(d.key);
    });

    var mistakeRate = + document.getElementById('mistakeRate').value;
    if (! (mistakeRate >= 0 && mistakeRate <= 1)) {
      throw Error('Mistake rate must be between 0 and 1 (read ' + mistakeRate + ')');
    }

    var numRounds = + document.getElementById('numRounds').value;
    if (!Number.isInteger(numRounds) || numRounds < 1) {
      throw Error('Number of rounds must be positive integer (read ' + numRounds + ')');
    }

    var numReps = + document.getElementById('numReps').value;
    if (!Number.isInteger(numReps) || numReps < 1) {
      throw Error('Number of runs must be positive integer (read ' + numReps + ')');
    }

    setTimeout(highlight, 20);

    function mean(arr) {
      return sum(arr) / arr.length;
    }

    function std(arr) {
      var mu = mean(arr);
      var squareDiffs = arr.map(function(v) { return (v - mu) * (v - mu); });
      return Math.sqrt(sum(squareDiffs) / squareDiffs.length)
    }
    function ci95 (vals) {
      if (vals.length <= 1) return null;
      var mu = mean(vals);
      var sigma = std(vals);
      var z = 1.96;
      var d = z * sigma / Math.sqrt(vals.length);
      return [mu-d, mu+d];
    }

    function makeResultTable(strategies, game, numReps) {
      if (arguments.length < 3) {
        numReps = 1;
      }
      var playerPerspectives = [0, 1];

      var runs = Array();

      for (var r = 0; r < numReps; r++ ) {
        runs[r] = playerPerspectives.map(function () {
          return strategies.map(function () {
            return new Array(strategies.length);
          });
        });

        // looping the lower left half of the matrix, including diagonals
        strategies.forEach(function (s1, i) {
          strategies.slice(0, i+1).forEach(function (s2, j) {
            var payoffs = game([s1.value(), s2.value()]);

            // row i in the 1st matrix holds the payoffs of strategy i
            // vs the opponents
            runs[r][0][j][i] = payoffs[1];
            runs[r][0][i][j] = payoffs[0];

            // row i in the 2nd matrix holds the payoffs of the opponents
            // vs strategy i
            runs[r][1][j][i] = payoffs[0];
            runs[r][1][i][j] = payoffs[1];
          });
        });
      }
      var meanResults = playerPerspectives.map(function (_, pIdx) {
        return strategies.map(function (s1, i) {
          return runs.map(function (run) {
            return mean(run[pIdx][i]);
          });
        });
      });

      var tables = {
        'mean': {'func': mean},
        'std': {'func': std},
        'ci95': {'func': ci95},
      };
      d3.entries(tables).forEach(function (ts) {
        ts.value['values'] = meanResults.map(function (d, pIdx) {
          return d.map(function (d, i) {
            return ts.value.func(d);
          });
        });
      });

      return strategies.map(function (s, i) {
        return {
          'strategy-name': s.key,
          'mean-payoff': tables['mean']['values'][0][i],
          'mean-payoff-ci95': tables['ci95']['values'][0][i],
          'mean-opponent-payoff': tables['mean']['values'][1][i],
          'mean-opponent-payoff-ci95': tables['ci95']['values'][1][i],
        };
      });
    }

    function fmtCI(v) {
      if (!v) return '-';
      var v = v.map(d3.format('.3f'));
      return '[' + v[0] + ', ' + v[1] + ']';
    }

    var resultsTable = table()
      .caption('Results (' + document.getElementById('regex').value + ')')
      .columns([
        {'key': 'strategy-name', 'text': 'Strategy'},
        {'key': 'mean-payoff', 'text': 'Mean payoff', 'fmt': d3.format(".3f")},
        {'key': 'mean-payoff-ci95', 'text': '95% CI', 'fmt': fmtCI},
        {'key': 'mean-opponent-payoff', 'text': 'Mean opp. payoff', 'fmt': d3.format(".3f")},
        {'key': 'mean-opponent-payoff-ci95', 'text': '95% CI', 'fmt': fmtCI},
        ]);


    var game = createIPD(numRounds, mistakeRate);
    var data = makeResultTable(includedStrategies, game, numReps);
    data.sort(function (r1, r2) {
      return r2['mean-payoff'] - r1['mean-payoff'];
    });
    resultsTable.data(data);
    resultsTable(d3.select('#results-table'));

    console.log(data);
    sticksPlot().data(data)(d3.select('#results-plot'));
  }


}
