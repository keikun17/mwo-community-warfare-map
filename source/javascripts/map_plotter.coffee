$ ->
  # margin =
  #   top: 20
  #   right: 20
  #   bottom: 30
  #   left: 40
  #
  # width = 960 - margin.left - margin.right
  # height = 600 - margin.top - margin.bottom

  margin =
    top: 10
    left: 10
    bottom: 10
    right: 10

  width = parseInt(d3.select('#map-container').style('width'))
  width = width - margin.left - margin.right
  mapRatio = .5
  height = width * mapRatio;

  x = d3.scale.linear().domain([-width / 2, width / 2]).range([0,width])
  y = d3.scale.linear().domain([-height / 2, height / 2]).range([height,0])

  color = d3.scale.category10()
  window.color_mapping =
    "Piranha Games": '#000000'
    "Steiner": '#000099'
    "Davion": '#ffcc00'
    "Kurita": '#cc0000'
    "Marik": '#990099'
    "None": '#000000'
    "Liao": '#003300'
    "Rasalhague": '#a0a0a0'
    "Ghost Bear": '#c0c0c0'
    "Jade Falcon": '#b22222'
    "Wolf": '#994c00'
    "Smoke Jaguar": "#ffcc99"


  zoomed = ->
    circle.attr("transform", transform);
    planet_names.attr("transform", transform);

  window.zoomListener = d3.behavior.zoom()
    .x(x)
    .y(y)
    .scaleExtent([.5,500])
    .on("zoom", zoomed)

  transform = (d) ->
    "translate(" + x(d.position.x) + "," + y(d.position.y) + ")"

  svg = d3.select("map").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    .call(zoomListener)
    .append("g")

  svg.append("rect")
      .attr("class", "overlay")
      .attr("width", width)
      .attr("height", height)

  d3.json "https://static.mwomercs.com/data/cw/mapdata.json", (error, data) ->
    delete data.generated;

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
    window.circle = svg.selectAll(".dot").data(data).enter()
      .append("circle")
        .attr("class", "dot")
        .attr("r", 1.5)
        # .attr "cx", (d) ->
        #   x d.position.x
        # .attr "cy", (d) ->
        #   y d.position.y
        .style "fill", (d) ->
          color_mapping[d.owner_name]
        .attr("transform", transform(d))



    # Planet names
    window.planet_names = svg.selectAll("text").data(data).enter()
      .append("text")
        # .attr "x", (d) ->
        #   x d.position.x
        # .attr "y", (d) ->
        #   y d.position.y
        .style "fill", (d) ->
          color_mapping[d.owner_name]
        .text (d) ->
          d.name
        .attr("transform", transform(d))

    legend = svg.selectAll(".legend").data(color.domain()).enter().append("g").attr("class", "legend").attr("transform", (d, i) ->
      "translate(0," + i * 20 + ")"
    )

    legend.append("rect").attr("x", width - 18).attr("width", 18).attr("height", 18).style "fill", color
    legend.append("text").attr("x", width - 24).attr("y", 9).attr("dy", ".35em").style("text-anchor", "end").text (d) ->
      d

    # # Coordinates label
    # xAxis = d3.svg.axis().scale(x).orient("bottom")
    # yAxis = d3.svg.axis().scale(y).orient("left")
    # svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis).append("text").attr("class", "label").attr("x", width).attr("y", -6).style("text-anchor", "end").text "X"
    # svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("class", "label").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text "Y"

    # Default zoom
    zoomListener.translate([-width / 2, -height / 2]).scale(2);
    zoomListener.event(svg.transition().duration(3000));
