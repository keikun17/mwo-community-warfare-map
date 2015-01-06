(function() {
  $(function() {
    var chart, data, height, mapRatio, margin, svg, width, x, y;
    margin = {
      top: 0,
      left: 0,
      bottom: 0,
      right: 0
    };
    width = parseInt(d3.select('#map-container').style('width'));
    width = width - margin.left - margin.right;
    mapRatio = .5;
    height = width * mapRatio;
    x = d3.scale.linear().domain([-width / 2, width / 2]).range([0, width]);
    y = d3.scale.linear().domain([-height / 2, height / 2]).range([height, 0]);
    data = [[1, 1, 1, 1, 1, 1, 0, 0]];
    console.log(x.domain());
    console.log(y.domain());
    svg = d3.select("planet").append("svg").attr("width", width).attr("height", height).append("g").attr('transform', "translate(50,50)");
    chart = circularHeatChart().segmentHeight(5).innerRadius(20).numSegments(8).range(['white', 'blue']).segmentLabels(['1', '2', '3', '4', '5', '6', '7', '8']);
    return window.circle = svg.selectAll('.dot').data(data).enter().append('svg').call(chart);
  });

}).call(this);
