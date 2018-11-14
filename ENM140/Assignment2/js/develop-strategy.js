'use strict';

var strategies = {};

var initialCode = (
  "strategies['testStrategy'] = function () {\n" +
  "  function chooseAction(me, opponent, t) {\n" +
  "    // Tit for two tats\n" +
  "\n" +
  "    if (t <= 1) {\n" +
  "      return 1; // cooperate round 0 and 1\n" +
  "    }\n" +
  "\n" +
  "    if (opponent[t-2] == 0 && opponent[t-1] == 0) {\n" +
  "      return 0; // defect if last two opponent moves were defect\n" +
  "    }\n" +
  "\n" +
  "    return 1; // otherwise cooperate\n" +
  "  }\n" +
  "\n" +
  "  return chooseAction;\n" +
  "}\n"
  );

function setWorking (isWorking) {
  d3.select('#run-button')
  .text(isWorking ? 'Working...' : 'Run (Ctrl+Enter)')
  .attr('disabled', isWorking ? true : null);
}
function clearResults () {
  d3.select('#overview-table').html('');
  d3.select('#details-tables').html('');
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
  if (d3.select('#catchErrors').property('checked')) {
    errors.push(errHtml);
    renderErrors();
    throw e;
  } else {
    throw e;
  }
}
function renderErrors() {
  var li = d3.select('#error').selectAll('li').data(errors);

  li.enter()
  .append('li')
  .html(function (d) { return d; });

  li.exit()
  .remove();
}

var editor = CodeMirror(document.getElementById('code'), {
  lineNumbers: true,
  mode: 'javascript',
  theme: 'monokai',
  value: initialCode,
  extraKeys: {
    'Ctrl-Enter': run
  },
  tabSize: 2
});
setWorking(false);


d3.select('body').on('keypress', function () {
  if (d3.event.code === 'Enter' && d3.event.ctrlKey === true) {
    run();
  }
});


function run() {
  clearErrors();
  clearResults();
  setWorking(true);
  try {
    var code = editor.getValue();
    code += '\n//# sourceURL=temp-strategy.js';
    eval(code);
  }
  catch (e) {
    setWorking(false);
    var err = new Error('Error in strategy code: ' + e.message);
    err.stack = e.stack;
    displayError(err);
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
    try {
      test(opponents);
    }
    catch (e) {
      setWorking(false);
      displayError(e);
    }
    setWorking(false);
    setTimeout(highlight, 20);

  }

  setTimeout(runTest, 20);

}

var overviewTable = table()
.caption('Overview of results')
.columns([
  {'key': 'opponent-name', 'text': 'Opponent'},
  {'key': 'outcome', 'text': 'Outcome'},
  {'key': 'my-payoff', 'text': 'My payoff', 'fmt': d3.format(".3f")},
  {'key': 'opponent-payoff', 'text': 'Opp. payoff', 'fmt': d3.format(".3f")}
  ]);

function test(externalOpponents) {
  var opponents = {'self': strategies['testStrategy']};
  d3.entries(externalOpponents).forEach(function (d) {
    opponents[d.key] = d.value;
  });
  var s = strategies['testStrategy'];


  var mistakeRate = + document.getElementById('mistakeRate').value;
  if (! (mistakeRate >= 0 && mistakeRate <= 1)) {
    throw Error('Mistake rate must be between 0 and 1 (read ' + mistakeRate + ')');
  }

  var numRounds = + document.getElementById('numRounds').value;
  if (!Number.isInteger(numRounds) || numRounds < 1) {
    throw Error('Number of rounds must be positive integer (read ' + numRounds + ')');
  }

  var detailedHistories = {};

  function playOne(opponentEntry) {
    var detailedHistory = [];
    detailedHistories[opponentEntry.key] = detailedHistory;

    function callback(info) { detailedHistory.push(info); }
    var game = createIPD(numRounds, mistakeRate, callback);

    var opponent = opponentEntry.value;
    var payoffs = game([s(), opponent()]);
    var outcome = 'unknown';
    if (payoffs[0] > payoffs[1]) outcome = 'win';
    if (payoffs[0] < payoffs[1]) outcome = 'loss';
    if (payoffs[0] == payoffs[1]) outcome = 'tie';


    var res = {
      'opponent-name': opponentEntry.key,
      'my-payoff': payoffs[0],
      'opponent-payoff': payoffs[1],
      'outcome': outcome
    };

    return res;
  }

  function bracketed(d) {
    return '[' + d + ']';
  }


  overviewTable
  .data(d3.entries(opponents).map(playOne))
  (d3.select('#overview-table'));

  var tables = d3.select('#details-tables')
  .selectAll('table').data(d3.entries(detailedHistories));

  tables
  .enter()
  .append('table')
  .merge(tables)
  .each(function (dhEntry) {
    var opponentName = dhEntry.key;
    var detailTable = table()
    .caption('Details of iterated game vs. ' + opponentName)
    .columns([
      {'key': 't', 'text': 't'},
      {'key': 'actionProfile', 'text': 'Action profile', 'fmt': bracketed},
      {'key': 'payoffs', 'text': 'Round payoffs', 'fmt': bracketed},
      {'key': 'accumulatedPayoffs', 'text': 'Cumulative payoffs', 'fmt': bracketed}
      ])
    .data(dhEntry.value)
    (d3.select(this));
  });
}