
$ ->
  margin =
    top: 20
    right: 20
    bottom: 30
    left: 40

  width = 3000 - margin.left - margin.right
  height = 3000 - margin.top - margin.bottom
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
  d3.json "javascripts/mapdata.json", (error, data) ->
    delete data.generated;
    window._mapdata = data

    # Convert string data to int
    for own prop of data
      # console.log prop
      if (data.hasOwnProperty(prop))
        console.log('')
        data[prop].position.x = +data[prop].position.x
        data[prop].position.y = +data[prop].position.y
        data[prop].owner_id = +data[prop].owner.id

    # NOTE : Not included in the original algo
    # 1. Convert obeject into array
    # 2. populate owners table
    old_data = data
    data = []
    owners = []
    for own prop of old_data
      # console.log prop
      if (old_data.hasOwnProperty(prop))
        d = {}
        d.position = {}
        d.position.x = old_data[prop].position.x
        d.position.y = old_data[prop].position.y
        d.owner_id = old_data[prop].owner.id
        d.owner_name = old_data[prop].owner.name
        d.name = old_data[prop].name
        owners.push({id: d.owner_id, name: d.owner_name})

        data.push(d)

    window.owners = owners

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
    svg.selectAll(".dot").data(data).enter().append("circle").attr("class", "dot").attr("r", 1.5).attr("cx", (d) ->
      console.log d
      x d.position.x
    ).attr("cy", (d) ->
      y d.position.y
    ).style "fill", (d) ->
      color d.owner_id


    svg.selectAll("text").data(data).enter().append("text").attr("x", (d) ->
      console.log d
      x d.position.x
    ).attr("y", (d) ->
      y d.position.y
    ).style("fill", (d) ->
      color d.owner_id
    ).text( (d) ->
      d.name
    )

    legend = svg.selectAll(".legend").data(color.domain()).enter().append("g").attr("class", "legend").attr("transform", (d, i) ->
      "translate(0," + i * 20 + ")"
    )

    legend.append("rect").attr("x", width - 18).attr("width", 18).attr("height", 18).style "fill", color
    legend.append("text").attr("x", width - 24).attr("y", 9).attr("dy", ".35em").style("text-anchor", "end").text (d) ->
      d
