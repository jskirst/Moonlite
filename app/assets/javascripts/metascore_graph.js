$.MB.initEvaluationGradeCharts = function(){
  // Apply the grey theme
  Highcharts.setOptions({
     colors: ["#DDDF0D", "#7798BF", "#55BF3B", "#DF5353", "#aaeeee", "#ff0066", "#eeaaee", 
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
    
  var change = { "-30": 'Familiar', "10": 'Competent', "50": 'Proficient', "90": 'Expert' };
    
  $('#metascore_graph').highcharts({
    chart: {
        type: 'column',
        marginLeft: 80,
        width: 150,
        height: 300
    },
    title: { text: '', style: { display: 'none' } },
    subtitle: { text: '', style: { display: 'none' } },
    xAxis: { labels: { enabled: false } },
    yAxis: {
        title: null,
        minRange: 100,
        min: 0,
        max: 100,
        tickInterval: 20,
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
        series: { pointWidth: 20 }
    },
    tooltip : { enabled: false },
    series: [{ showInLegend: false,  data: [80] }]
  });
}
    
