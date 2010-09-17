$(document).ready(function() {

  t = $('table.sort');
  
  $('#filter').keyup(function() {
    $.uiTableFilter(t, this.value);
    calculate_totals();
  });
  
  $('table.sort').tablesorter({
    sortList: [[0,0]],
    cssAsc: 'ascending',
    cssDesc: 'descending',
    widthFixed: true
  });
  
  
  // Need to get the cov and code totals to be weighted, if possible, to
  // the number of lines as in the ruby.
  function calculate_totals(col) {
    var sum = 0;
    var rows = [];
    
    var lines = 0;
    var loc = 0;
    var ran = 0;
    $('table.sort tbody tr').each(function(i) {
      if ($(this).css("display") != "none") {
        rows += $(this);
        
        $(this).children('td.lines').each(function(j) {
          lines += parseFloat($(this).text());
        });
        $(this).children('td.loc').each(function(j) {
          loc += parseFloat($(this).text());
        });
        $(this).children('td.ran').each(function(j) {
          ran += parseFloat($(this).text());
        });
      }
    });
    var count = rows.length/15; // gets actual number of rows
    
    $('table.sort tfoot td.lines').text(lines);
    $('table.sort tfoot td.loc').text(loc);
    $('table.sort tfoot td.ran').text(ran);
    if (lines > 0) {
      $('table.sort tfoot td.cov').text((ran/lines*100).toFixed(2) + '%');
      $('table.sort tfoot td.code').text((ran/loc*100).toFixed(2) + '%');
    } else {
      $('table.sort tfoot td.cov').text('0.00%');
      $('table.sort tfoot td.code').text('0.00%');
    }
  }

});