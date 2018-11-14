'use strict';

function sticksPlot() {

  var data = [],
    ystep = 30,
    textmargin = 25,
    width = 900,
    margin = {'top': 20, 'left': 20, 'right': 100, 'bottom': 20},
    label;

  function plot(svg) {
    var n = data.length;
    var height = ystep * n + margin.top + margin.bottom;
    // var ystep = (height - margin.top - margin.bottom) / n;
    var xScale = d3.scaleLinear()
      .domain([1, 5])
      .range([0, width-margin.left-margin.right]);
    var yScale = d3.scaleLinear()
      .domain([0, n-1])
      .range([ystep, ystep * n]);

    var line = d3.line()
      .x(function (d) { return xScale(d[0]); })
      .y(function (d) { return yScale(d[1]); });

    var xAxis = d3.axisTop().scale(xScale);

    svg
      .html('')
      .attr('width', width)
      .attr('height', height);

    var g = svg
      .append('g')
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    g.append("g")
      .attr("class", "x axis")
      .call(xAxis);

    g.selectAll('g.strategy').data(data).enter()
      .append('g')
      .classed('strategy', true)
      .attr('transform', function(d, i) {
        return 'translate(0,' + yScale(i) + ')';
      })
      .each(function (d, i) {
        var g = d3.select(this);

        g.append('circle')
          .attr('cx', xScale(d['mean-payoff']))
          .attr('cy', 0)
          .attr('r', 5);

        var textX = (
          xScale(
            d['mean-payoff-ci95'] ? d['mean-payoff-ci95'][1] : d['mean-payoff'])
          + textmargin);
        g.append('text')
          .attr('x', textX)
          .attr('y', 0)
          .text(d['strategy-name']);


        if (!d['mean-payoff-ci95']) return;
        var lineData = d['mean-payoff-ci95'].map(function (x) {
          return [x, 0];
        });
        g.append('line')
          .classed('ciline', true)
          .attr('x1', xScale(d['mean-payoff-ci95'][0]))
          .attr('x2', xScale(d['mean-payoff-ci95'][1]))
          .attr('y1', 0)
          .attr('y2', 0);

        d['mean-payoff-ci95'].forEach(function (v) {
          g.append('line')
            .classed('whisker', true)
            .attr('x1', xScale(v))
            .attr('x2', xScale(v))
            .attr('y1', -ystep/4)
            .attr('y2', ystep/4);
        });
      });

    return plot;
  }

  plot.data = function (_) {
    if (!arguments.length) return data;
    data = _;
    return plot;
  }

  plot.label = function (_) {
    if (!arguments.length) return label;
    label = _;
    return plot;
  }


  return plot;

}