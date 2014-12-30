
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
  window.color_mapping =
    "Piranha Games": '#000000'
    "Steiner": '#000099'
    "Davion": '#ffff66'
    "Kurita": '#cc0000'
    "Marik": '#990099'
    "None": '#000000'
    "Liao": '#003300'
    "Rasalhague": '#a0a0a0'
    "Ghost Bear": '#c0c0c0'
    "Jade Falcon": '#00ff00'
    "Wolf": '#994c00'
    "Smoke Jaguar": "#ffcc99"



  xAxis = d3.svg.axis().scale(x).orient("bottom")
  yAxis = d3.svg.axis().scale(y).orient("left")
  svg = d3.select("body").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")
  d3.json "https://static.mwomercs.com/data/cw/mapdata.json", (error, data) ->
    delete data.generated;
    window._mapdata = data

    # Convert string data to int
    for own prop of data
      if (data.hasOwnProperty(prop))
        data[prop].position.x = +data[prop].position.x
        data[prop].position.y = +data[prop].position.y
        data[prop].owner_id = +data[prop].owner.id

    # NOTE : Not included in the original algo
    # 1. Convert obeject into array
    # 2. populate owners table
    old_data = data
    data = []
    owners = []
    owner_ids = []
    owner_names = []

    for own prop of old_data
      if (old_data.hasOwnProperty(prop))
        d = {}
        d.position = {}
        d.position.x = old_data[prop].position.x
        d.position.y = old_data[prop].position.y
        d.owner_id = old_data[prop].owner.id
        d.owner_name = old_data[prop].owner.name
        d.name = old_data[prop].name
        owners.push({id: d.owner_id, name: d.owner_name})
        owner_ids.push(d.owner_id)
        owner_names.push(d.owner_name)

        data.push(d)

    window.owner_ids = $.unique(owner_ids)
    window.owner_names = $.unique(owner_names)

    x.domain(d3.extent(data, (d) ->
      d.position.x
    )).nice()
    #
    y.domain(d3.extent(data, (d) ->
      d.position.y
    )).nice()

    # Planet dots
    # svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis).append("text").attr("class", "label").attr("x", width).attr("y", -6).style("text-anchor", "end").text "X"
    # svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("class", "label").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text "Y"
    svg.selectAll(".dot").data(data).enter().append("circle").attr("class", "dot").attr("r", 1.5).attr("cx", (d) ->
      x d.position.x
    ).attr("cy", (d) ->
      y d.position.y
    ).style "fill", (d) ->
      color_mapping[d.owner_name]

    # Planet names
    svg.selectAll("text").data(data).enter().append("text").attr("x", (d) ->
      x d.position.x
    ).attr("y", (d) ->
      y d.position.y
    ).style("fill", (d) ->
      color_mapping[d.owner_name]
    ).text( (d) ->
      d.name
    )

    legend = svg.selectAll(".legend").data(color.domain()).enter().append("g").attr("class", "legend").attr("transform", (d, i) ->
      "translate(0," + i * 20 + ")"
    )

    legend.append("rect").attr("x", width - 18).attr("width", 18).attr("height", 18).style "fill", color
    legend.append("text").attr("x", width - 24).attr("y", 9).attr("dy", ".35em").style("text-anchor", "end").text (d) ->
      d
