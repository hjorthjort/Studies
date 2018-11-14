function table() {

  var columns = [],
    data = [],
    caption,
    operation;

  function table(sel) {
    sel.html('');
    if (caption !== undefined) {
      sel.append('caption').text(caption);
    }
    sel.append('thead').append('tr').selectAll('td').data(columns)
      .enter()
      .append('td')
      .attr('class', function (d) {
        return d.hasOwnProperty('className') ? d.className : d.key;
      })
      .text(function (d) {
        return d.hasOwnProperty('text') ? d.text : d.key;
      });

    sel.append('tbody').selectAll('tr').data(data)
      .enter()
      .append('tr')
      .each(function (rowData) {
        var tr = d3.select(this);
        tr.selectAll('td').data(columns)
          .enter()
          .append('td')
          .attr('class', function (d) {
            return d.hasOwnProperty('className') ? d.className : d.key;
          })
          .text(function (d) {
            if (d.hasOwnProperty('fmt')) return d.fmt(rowData[d.key]);
            return rowData[d.key];
          })
          .each(function (d) {
            if (d.hasOwnProperty('operation')) {
              var tdSelection = d3.select(this);
              d['operation'](tdSelection, rowData, d.key);
            }
          });
      });
    return table;
  }

  table.columns = function (_) {
    if (!arguments.length) return columns;
    columns = _;
    columns = columns.map(function (d) {
      if (typeof d === 'string') return {'key': d};
      return d;
    });
    return table;
  }

  table.data = function (_) {
    if (!arguments.length) return data;
    data = _;
    return table;
  }

  table.caption = function (_) {
    if (!arguments.length) return caption;
    caption = _;
    return table;
  }


  return table;

}