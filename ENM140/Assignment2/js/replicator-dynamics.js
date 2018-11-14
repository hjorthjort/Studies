'use strict';

function setWorking (isWorking) {
  d3.select('#prep-button')
  .text(isWorking ? 'Working...' : 'Precompute')
  .attr('disabled', isWorking ? true : null);
}
var isPrepped;
var isRunning;
var strategyNames;
var scoreMatrix, abundances, fitnesses, selectionPressure, extinctionLimit;
var abundanceHistory;
var t;
var lineColors;
var abundanceCeil;
var errors = [];
function clearErrors () {
  errors = [];
  renderErrors();
}
function clearResults () {
  d3.select('#results-plot').html('');
  d3.select('#results-table').html('');
}
function clearAll() {
  setPrepped(false);
  setRunning(false);
  setWorking(false);
  clearResults();
  clearErrors();
}
function setRunButton() {
  d3.select('#toggle-run-button')
    .attr('disabled', isPrepped ? null : true)
    .text(isRunning ? 'Pause (Ctrl+Enter)' : 'Run (Ctrl+Enter)');
}
function setPrepped(value) {
  isPrepped = value;
  setRunButton();
}
function setRunning(value) {
  isRunning = value;
  d3.select('#rewind-button')
    .attr('disabled', (isPrepped && !isRunning) ? null : true);
  setRunButton();
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

clearAll();


d3.select('body').on('keypress', function () {
  if (d3.event.code === 'Enter' && d3.event.ctrlKey === true) {
    toggleRun();
  }
});

function mean(arr) {
  return sum(arr) / arr.length;
}

function rewind() {
  if (!isPrepped) return;

  t = 0;
  abundances = normalize(strategyNames.map(function () { return 1; }));
  abundanceCeil = Math.max.apply(null, abundances) * 1.1;
  abundanceHistory = abundances.map(function (v) { return new Float32Array(); });
  pushAbundance(abundances);
  fitnesses = calcFitnesses(scoreMatrix, abundances);

  var hueScale = d3.scaleLinear().domain([0, abundances.length]).range([0, 360]);
  var sat = 1.5;
  var lum = 0.3;
  lineColors = abundances.map(function (_, i) {
    var hue = hueScale(i);
    return d3.cubehelix(hue, sat, lum);
  });

  drawFigure();
  drawTable();
}

var includedStrategies, game;

function doPrepWork() {
  clearAll();

  var re = new RegExp(document.getElementById('regex').value);

  includedStrategies = d3.entries(strategies).filter(function(d) {
    return re.test(d.key);
  });

  strategyNames = includedStrategies.map(function (d) { return d.key; });
  includedStrategies = includedStrategies.map(function (d) { return d.value; });


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

  extinctionLimit = + document.getElementById('extinctionLimit').value;
  if (! (extinctionLimit >= 0)) {
    throw Error('Extinction limit must be >= 0 (read ' + extinctionLimit + ')');
  }

  selectionPressure = + document.getElementById('selectionPressure').value;
  if (! (selectionPressure >= 0)) {
    throw Error('Selection pressure must be >= 0 (read ' + selectionPressure + ')');
  }

  game = createIPD(numRounds, mistakeRate);
  scoreMatrix = playAllPairsSymmetric(game, includedStrategies, numReps);

  setPrepped(true);
  rewind();
}

function pushAbundance(arr) {
  var desiredLength = Math.pow(2, Math.ceil(Math.log2(t+1)));
  if (abundanceHistory[0].length < desiredLength) {
    arr.forEach(function (_, i) {
      var oldHistory = abundanceHistory[i];
      abundanceHistory[i] = new Float32Array(desiredLength);
      abundanceHistory[i].set(oldHistory);
    });
  }
  arr.forEach(function (v, i) {
    abundanceHistory[i][t] = v;
  });
}

function prep() {
  clearAll();
  try {
    setWorking(true);
    doPrepWork();
  }
  catch (e) {
    displayError(e);
  }
  finally {
    setWorking(false);
  }
}

var resultsTable = table()
  .caption('Current status')
  .columns(
    [
    {'key': 'strategy-name', 'text': 'Strategy'},
    {'key': 'fitness', 'text': 'Fitness', 'fmt': d3.format('.3f')},
    {'key': 'abundance', 'text': 'Abundance', 'fmt': d3.format('.3f')},
    {'key': 'extinct', 'text': 'Extinct'},
    ]);

function drawTable() {
  var data = strategyNames.map(function (name, i) {
    return {
      'strategy-name': name,
      'fitness': fitnesses[i],
      'abundance': abundances[i],
      'extinct': abundances[i] < extinctionLimit,
    };
  });
  data.sort(function (r1, r2) { return r2.abundance - r1.abundance; });
  resultsTable.data(data)
    (d3.select('#results-table'));
}

function drawFigure() {
  var data = strategyNames.map(function (name, i) {
    return {
      'strategy-name': name,
      'abundance-history': abundanceHistory[i].slice(0,t),
      'abundance': abundances[i],
      'color': lineColors[i],
      'extinct': abundances[i] < extinctionLimit,
    };
  });

  var margin = {top: 20, bottom: 70, left: 70, right: 200};
  var height = 700,
    width = 1000;
  var y = d3.scaleLinear()
    .domain([0, abundanceCeil])
    .range([height-margin.top-margin.bottom, 0]);
  var x = d3.scaleLinear()
    .domain([0, data[0]['abundance-history'].length-1])
    // .domain([0, t])
    .range([0, width-margin.left-margin.right]);

  var xAxis = d3.axisBottom().scale(x);
  var yAxis = d3.axisLeft().scale(y);


  var line = d3.line()
    .x(function(d, i) { return x(i); })
    .y(function(d) { return y(d); });


  var svg = d3.select('#results-plot')
    .attr('height', height)
    .attr('width', width);

  var g = svg.selectAll('g').data([0]);

  g.enter()
    .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  var yAxisContainer = g.selectAll('g.yaxis').data([0]);
  yAxisContainer.enter().append('g')
    .classed('yaxis', true);

  yAxisContainer.call(yAxis);



  var xAxisContainer = g.selectAll('g.xaxis').data([0]);
  xAxisContainer.enter().append('g')
    .classed('xaxis', true)
    .attr('transform', 'translate(0,' + (height - margin.top - margin.bottom) + ')');

  xAxisContainer.call(xAxis);


  var namesContainer = g.selectAll('g.names').data([0]);
  namesContainer.enter().append('g')
    .classed('names', true);

  var names = namesContainer.selectAll('text').data(data);

  names.enter()
    .append('text')
    .attr('x', width-margin.right)

  names
    .attr('y', function (d) { return y(d['abundance']); })
    .text(function (d) { return d['extinct'] ? '' : d['strategy-name']; });

  var paths = g.selectAll('path.abundance-history').data(data);
  paths
    .attr('d', function (d) { return line(d['abundance-history']); });

  paths.enter()
    .append('path')
    .classed('abundance-history', true)
    .style('stroke', function (d) { return d['color']; })

}

function takeStep() {
  t += 1;
  fitnesses = calcFitnesses(scoreMatrix, abundances);
  abundances = newAbundances(abundances, fitnesses, selectionPressure, extinctionLimit);
  abundanceCeil = Math.max(abundanceCeil, Math.max.apply(null, abundances));
  pushAbundance(abundances);
}

function toggleRun() {
  if (!isPrepped) return;
  setRunning(!isRunning);
  if (!isRunning) return;

  var timer = d3.timer(function() {
    if (isRunning) {
      takeStep();
      drawTable();
      if (t % 10 == 0) drawFigure();
    } else {
      timer.stop();
    }
  }, 20);
}

