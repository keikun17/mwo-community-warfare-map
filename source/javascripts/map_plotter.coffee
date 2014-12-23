
$ ->
  margin =
    top: 20
    right: 20
    bottom: 30
    left: 40

  width = 960 - margin.left - margin.right
  height = 500 - margin.top - margin.bottom
  x = d3.scale.linear().range([
    0
    width
  ])
  y = d3.scale.linear().range([
    height
    0
  ])
  color = d3.scale.category10()
  xAxis = d3.svg.axis().scale(x).orient("bottom")
  yAxis = d3.svg.axis().scale(y).orient("left")
  svg = d3.select("body").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")
  d3.json "javascripts/smalldata.json", (error, data) ->
    delete data.generated;
    console.log "data is"
    console.log data

    window.data = data

    data

    # Convert string data to int
    for own prop of data
      console.log prop
      if (data.hasOwnProperty(prop))
        data[prop].position.x = +data[prop].position.x
        data[prop].position.y = +data[prop].position.y

    x.domain(d3.extent(data, (d) ->
      d.position.x
    )).nice()
    #
    y.domain(d3.extent(data, (d) ->
      d.position.y
    )).nice()


