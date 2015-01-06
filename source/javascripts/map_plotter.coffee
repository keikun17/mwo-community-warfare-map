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

  color = d3.scale.category10()
  window.color_mapping =
    "Piranha Games": '#000000'
    "Steiner": '#000099'
    "Davion": '#ffcc00'
    "Kurita": '#cc0000'
    "Marik": '#990099'
    "None": '#000000'
    "Liao": '#007700'
    "Rasalhague": '#a0a0a0'
    "Ghost Bear": '#c0c0c0'
    "Jade Falcon": '#33ff33'
    "Wolf": '#994c00'
    "Smoke Jaguar": "#ffcc99"


  zoomed = ->
    # peace_planets.attr("transform", transform)
    # contested_planets.attr("transform", transform)
    d3.select('map').selectAll(".peace").attr("transform", transform)
    d3.select('map').selectAll("text.planetname").attr("transform", transform)
    # d3.select('map').selectAll(".contested").attr("transform", transform)
    d3.select('map').selectAll(".contested_group").attr("transform", transform)
    d3.select('map').selectAll(".contested_group").attr("transform", transform)

  window.zoomListener = d3.behavior.zoom()
    .x(x)
    .y(y)
    .scaleExtent([.5,10])
    .on("zoom", zoomed)

  transform = (d) ->
    if typeof(d.position) != 'undefined'
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
        data[prop].contested = +data[prop].contested
        data[prop].owner_id = +data[prop].owner.id
        data[prop].territories = data[prop].territories

    # NOTE : Not included in the original algo
    # 1. Convert obeject into array
    # 2. populate owners table
    old_data = data
    data = []
    # owners = []
    # owner_ids = []
    # owner_names = []

    for own prop of old_data
      if (old_data.hasOwnProperty(prop))
        d = {}
        d.position = {}
        d.position.x = old_data[prop].position.x
        d.position.y = old_data[prop].position.y
        d.owner_id = old_data[prop].owner.id
        d.owner_name = old_data[prop].owner.name
        d.name = old_data[prop].name
        d.contested = old_data[prop].contested
        d.territories_captured = old_data[prop].territories.filter (t) ->
            t != '0'
          .length

        # owners.push({id: d.owner_id, name: d.owner_name})
        # owner_ids.push(d.owner_id)
        # owner_names.push(d.owner_name)

        data.push(d)

    # window.owner_ids = $.unique(owner_ids)
    # window.owner_names = $.unique(owner_names)

    x.domain(d3.extent(data, (d) ->
      d.position.x
    )).nice()
    #
    y.domain(d3.extent(data, (d) ->
      d.position.y
    )).nice()


    window.planets = svg.selectAll(".dot").data(data).enter()

    chart = circularHeatChart()
      .segmentHeight(5)
      .innerRadius(20)
      .numSegments(8)
      .range(['red', 'blue'])
      .segmentLabels(['1', '2', '3','4','5','6','7','8'])


    # Planet names
    window.planet_names = svg.selectAll("text").data(data).enter()
      .append("text")
        # .attr "x", (d) ->
        #   x d.position.x
        # .attr "y", (d) ->
        #   y d.position.y
        .attr("class", 'planetname')
        .style "fill", (d) ->
          color_mapping[d.owner_name]
        .text (d) ->
          if d.contested == 1
            name = "[#{d.territories_captured}]" + d.name
          else
            name = d.name
          name
        .attr("transform", transform(d))

    # Planet dots
    window.peace_planets = planets.append("circle").filter (d) ->
        d.contested == 0
      .attr "class", 'dot peace'
      .attr("r", 3.5)
      .style "fill", (d) ->
        color_mapping[d.owner_name]
      .attr("transform", transform(d))

    window.peace_planets = planets.append("circle").filter (d) ->
        d.contested == 1
      .attr "class", 'dot contested'
      .attr("r", 3.5)
      .style "fill", (d) ->
        color_mapping[d.owner_name]
      .attr("transform", transform(d))

    window.xsvg = svg
    window.xplanets = planets

    ####### START OF WIP CONTESTED IMPLEMENTATION 

    # window.contested_data = $(data).filter (index) ->
    #   data[index].contested == 1
    #
    # # `cd` is for a unit of contested data
    # window.contested_planets = []
    # $.each contested_data, (index, cd) ->
    #   lol_data = [[69,69,69,69,69,0,0,0]]
    #   console.log cd.position.x
    #
    #   contested_planet = svg.selectAll('.keksad').data(lol_data).enter()
    #     .append('svg')
    #     .call(chart)
    #     .attr("transform", "translate(" + cd.position.x + ',' + cd.position.y + ")")
    #     .attr("transform", "translate(5,5)")
    #
    #   # contested_planet = svg.selectAll('.dot').data(lol_data).enter()
    #   #   .append('svg')
    #   #   .call(chart)
    #   #   .attr("transform", "translate(" + cd.position.x + ',' + cd.position.y + ")")
    #
    #   window.contested_planets.push contested_planet
    #
    #

    # END OF WIP

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
    zoomListener.translate([-width / 20,  -height / 20]).scale(1);
    zoomListener.event(svg.transition().duration(3000));
