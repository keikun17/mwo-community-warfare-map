
$ ->
  margin =
    top: 20
    right: 20
    bottom: 30
    left: 40

  width = 1000 - margin.left - margin.right
  height = 1000 - margin.top - margin.bottom
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

    # Get the offset
    lowest_x = 0
    lowest_y = 0
    for own prop of data
      if (data.hasOwnProperty(prop))
        x_data = +data[prop].position.x
        if x_data < 0
          if x_data < lowest_x
            lowest_x = x_data

        y_data = +data[prop].position.y
        if y_data < 0
          if y_data < lowest_y
            lowest_y = y_data

    # Convert string data to int
    for own prop of data
      console.log prop
      if (data.hasOwnProperty(prop))
        data[prop].position.x = +data[prop].position.x + lowest_x
        # console.log data[prop].position.x
        data[prop].position.y = +data[prop].position.y + lowest_y
        # console.log data[prop].position.y

    # NOTE : Not included in the original algo
    # Convert obeject into array
    old_data = data
    data = []
    for own prop of old_data
      # console.log prop
      if (old_data.hasOwnProperty(prop))
        d = {}
        d.position = {}
        d.position.x = old_data[prop].position.x
        d.position.y = old_data[prop].position.y
        data.push(d)

    console.log data
    x.domain(d3.extent(data, (d) ->
      d.position.x
    )).nice()
    #
    y.domain(d3.extent(data, (d) ->
      d.position.y
    )).nice()

    svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis).append("text").attr("class", "label").attr("x", width).attr("y", -6).style("text-anchor", "end").text "X"
    svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("class", "label").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text "Y"
    svg.selectAll(".dot").data(data).enter().append("circle").attr("class", "dot").attr("r", 3.5).attr("cx", (d) ->
      console.log d
      x d.position.x
    ).attr("cy", (d) ->
      y d.position.y
    ).style "fill", (d) ->
      color d.species

    legend = svg.selectAll(".legend").data(color.domain()).enter().append("g").attr("class", "legend").attr("transform", (d, i) ->
      "translate(0," + i * 20 + ")"
    )

    legend.append("rect").attr("x", width - 18).attr("width", 18).attr("height", 18).style "fill", color
    legend.append("text").attr("x", width - 24).attr("y", 9).attr("dy", ".35em").style("text-anchor", "end").text (d) ->
      d
