$ ->

  margin =
    top: 0
    left: 0
    bottom: 0
    right: 0

  width = parseInt(d3.select('#map-container').style('width'))
  width = width - margin.left - margin.right
  mapRatio = .5
  height = width * mapRatio;

  x = d3.scale.linear().domain([-width / 2, width / 2]).range([0,width])
  y = d3.scale.linear().domain([-height / 2, height / 2]).range([height,0])

  data = [[30,50]]

  console.log x.domain()
  console.log y.domain()

  svg = d3.select("planet").append("svg")
      .attr("width", width)
      .attr("height", height)
    .append("g")

  svg.append("rect")
      .attr("class", "overlay")
      .attr("width", width)
      .attr("width", height)

  window.circle = svg.selectAll('.dot').data(data).enter()
    .append("circle")
      .attr("class", "dot")
      .attr("r", 5)
      .style('fill', '#ffcc00')
      .attr "transform", (d) ->
        console.log 'test'
        "translate(" + d[0] + ',' +  d[1] + ")"





