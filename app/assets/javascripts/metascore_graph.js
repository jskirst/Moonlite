$.MB.initEvaluationGradeCharts = function(){
  // Apply the grey theme
  Highcharts.setOptions({
     colors: ["#f6c881", "#7798BF", "#55BF3B", "#DF5353", "#aaeeee", "#ff0066", "#eeaaee", 
        "#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
     chart: {
        backgroundColor: {
           linearGradient: [0, 0, 0, 400],
           stops: [
              [0, 'rgb(96, 96, 96)'],
              [1, 'rgb(16, 16, 16)']
           ]
        },
        borderWidth: 0,
        borderRadius: 15,
        plotBackgroundColor: null,
        plotShadow: false,
        plotBorderWidth: 0
     },
     title: {
        style: { 
           color: '#FFF',
           font: '16px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
        }
     },
     subtitle: {
        style: { 
           color: '#DDD',
           font: '12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
        }
     },
     xAxis: {
        gridLineWidth: 0,
        lineColor: '#999',
        tickColor: '#999',
        labels: {
           style: {
              color: '#999',
              fontWeight: 'bold'
           }
        },
        title: {
           style: {
              color: '#AAA',
              font: 'bold 12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
           }            
        }
     },
     yAxis: {
        alternateGridColor: null,
        minorTickInterval: null,
        gridLineColor: 'rgba(255, 255, 255, .1)',
        lineWidth: 0,
        tickWidth: 0,
        labels: {
           style: {
              color: '#BDBDBD'
           }
        },
        title: {
           style: {
              color: '#AAA',
              font: 'bold 12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
           }            
        }
     },
     legend: {
        itemStyle: { color: '#CCC' },
        itemHoverStyle: { color: '#FFF' },
        itemHiddenStyle: { color: '#333' }
     },
     credits: { style: { right: '50px' } },
     labels: { style: { color: '#CCC' } },
     tooltip: {
        backgroundColor: {
           linearGradient: [0, 0, 0, 50],
           stops: [
              [0, 'rgba(96, 96, 96, .8)'],
              [1, 'rgba(16, 16, 16, .8)']
           ]
        },
        borderWidth: 0,
        style: { color: '#FFF' }
     },
     
     plotOptions: {
        line: { dataLabels: { color: '#CCC' }, marker: { lineColor: '#333' } },
        spline: { marker: { lineColor: '#333' } },
        scatter: { marker: { lineColor: '#333' } }
     },

     toolbar: { itemStyle: { color: '#CCC' } }
  });
    
  var change = { "265": 'Unqualified', "305": 'Novice', "345": 'Familiar', "385": 'Competent', "425": 'Advanced', "465": 'Expert' }
    
  $(".metascore_graph").each(function(){ 
    console.log($(this).attr('data-metascore'))
    var metascore = parseInt($(this).attr('data-metascore'))
    var skill_level = $(this).attr('data-skill')
    
    $(this).highcharts({
    
    chart: {
        type: 'column',
        marginLeft: 20,
        marginRight: 20,
        marginBottom: 22,
        width: 550,
        height: 52,
        inverted: true
    },
    title: { text: '', style: { display: 'none' } },
    subtitle: { text: '', style: { display: 'none' } },
    xAxis: { labels: { enabled: false }, categories: [skill_level] },
    yAxis: {
        title: null,
        min: 250,
        max: 490,
        tickInterval: 5,
        labels: {
            formatter: function() {
                var value = change[this.value];
                return value !== 'undefined' ? value : this.value;
            }
        }
    },
    credits: { enabled: false },
    exporting: { enabled: false },
    plotOptions: {
        column: { pointPadding: 0, borderWidth: 0 },
        series: { pointWidth: 10 }
    },
    tooltip : { enabled: true, positioner: function () { return { x: 415, y: 4 };}, 
        formatter: function() {
            if (this.y == 260) {
                return this.x;
            }
            else return this.x + '<br />' + this.series.name +': ' + this.y;
        }
    },
    series: [{ showInLegend: false,  name: 'MetaScore', data: [metascore] }]
  });
});
}
    
