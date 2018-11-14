var errors = [];
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
}
function renderErrors() {
  var li = d3.select('#error').selectAll('li').data(errors);

  li.enter()
  .append('li')
  .html(function (d) { return d; });

  li.exit()
  .remove();
}


function testPair(game, a, b) {
  var result = {'success': true, 'error': '-'};
  try {
    var payoffs = game([a(), b()]);

    [a, b].forEach(function (strategy, i) {
      var p = payoffs[i];
      if (!(p >= 0 && p <= 5)) {
        throw Error('Unexpected payoff ' + p + ' for strategy ' + strategy);
      }
    });
  }
  catch (e) {
    displayError(e);
    result = {'success': false, 'error': e.message};
  }
  return result;
}

function getTestResults() {
  var results = d3.cross(
    d3.entries(strategies),
    d3.entries(opponents),
    function (strategy, opponent) {
      var numRounds, mistakeRate;
      var sn = strategy['key'];
      if (sn.endsWith('10a') || sn.endsWith('10b') || sn.endsWith('10c')) {
        mistakeRate = 0;
        numRounds = 10;
      } else if (sn.endsWith('200a') || sn.endsWith('200b') || sn.endsWith('200c')) {
        mistakeRate = 0;
        numRounds = 200;
      } else if (sn.endsWith('200mistakes')) {
        mistakeRate = 0.02;
        numRounds = 200;
      } else {
        throw Error('unexpected strategy name ' + strategy['key']);
      }

      var game = createIPD(numRounds, mistakeRate);
      var result = testPair(game, strategy['value'], opponent['value']);
      result['strategy-name'] = strategy['key'];
      result['opponent-name'] = opponent['key'];

      return result;
    });

  return results;
}

var expectedSuffixes = [
  '10a',
  '10b',
  '10c',
  '200a',
  '200b',
  '200c',
  '200mistakes'
  ];

try {
  // console.log(re);
  var cids = d3.set(d3.keys(strategies).map(function (key) {
    var re = /([a-z]+)(10|200)[a-z]+/;
    var cid = re.exec(key);
    if (cid == null || cid.length < 2) {
      throw Error('could not find cid in strategy named ' + key);
    } else {
      cid = cid[1];
    }
    return cid;
  }));
  cids.each(function (cid) {
    expectedSuffixes.forEach(function (suffix) {
      var stratName = cid + suffix;
      var func = strategies[stratName];
      if (func === undefined) {
        throw Error('could not find expected strategy ' + stratName);
      }
    });
  });

  var results = getTestResults();
  var setClass = function (td, rowData, key) {
    td.classed(rowData['success'] ? 'test-passed' : 'test-failed' , true);
  }
  var resultTable = table()
    .caption('Test runs')
    .columns([
      {'key': 'strategy-name', 'text': 'Strategy', 'operation': setClass},
      {'key': 'opponent-name', 'text': 'Opponent', 'operation': setClass},
      {'key': 'success', 'text': 'Success', 'operation': setClass},
      {'key': 'error', 'text': 'Error', 'operation': setClass},
      ])
    .data(getTestResults())
    (d3.select('#results-table'));
}
catch (e) {
  displayError(e);
  throw e;
}
