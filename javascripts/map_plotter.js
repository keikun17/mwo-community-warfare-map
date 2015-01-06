(function() {
  var __hasProp = {}.hasOwnProperty;

  $(function() {
    var color, height, mapRatio, margin, svg, transform, transform_text, width, x, y, zoomed;
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
    color = d3.scale.category10();
    window.color_mapping = {
      "Piranha Games": '#000000',
      "Steiner": '#000099',
      "Davion": '#ffcc00',
      "Kurita": '#cc0000',
      "Marik": '#990099',
      "None": '#000000',
      "Liao": '#007700',
      "Rasalhague": '#a0a0a0',
      "Ghost Bear": '#c0c0c0',
      "Jade Falcon": '#33ff33',
      "Wolf": '#994c00',
      "Smoke Jaguar": "#ffcc99"
    };
    zoomed = function() {
      d3.select('map').selectAll(".peace").attr("transform", transform);
      d3.select('map').selectAll("text.planetname").attr("transform", transform_text);
      d3.select('map').selectAll(".contested_group").attr("transform", transform);
      return d3.select('map').selectAll(".contested_group").attr("transform", transform);
    };
    window.zoomListener = d3.behavior.zoom().x(x).y(y).scaleExtent([.5, 10]).on("zoom", zoomed);
    transform = function(d) {
      if (typeof d.position !== 'undefined') {
        return "translate(" + x(d.position.x) + "," + y(d.position.y) + ")";
      }
    };
    transform_text = function(d) {
      if (typeof d.position !== 'undefined') {
        return "translate(" + x(d.position.x) + "," + y(d.position.y) + (") scale(" + d3.event.scale + ")");
      }
    };
    svg = d3.select("map").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")").call(zoomListener).append("g");
    svg.append("rect").attr("class", "overlay").attr("width", width).attr("height", height);
    return d3.json("https://static.mwomercs.com/data/cw/mapdata.json", function(error, data) {
      var contested_planets_enter, d, legend, old_data, prop;
      delete data.generated;
      for (prop in data) {
        if (!__hasProp.call(data, prop)) continue;
        if (data.hasOwnProperty(prop)) {
          data[prop].position.x = +data[prop].position.x;
          data[prop].position.y = +data[prop].position.y;
          data[prop].contested = +data[prop].contested;
          data[prop].owner_id = +data[prop].owner.id;
          data[prop].territories = data[prop].territories;
        }
      }
      old_data = data;
      data = [];
      for (prop in old_data) {
        if (!__hasProp.call(old_data, prop)) continue;
        if (old_data.hasOwnProperty(prop)) {
          d = {};
          d.position = {};
          d.position.x = old_data[prop].position.x;
          d.position.y = old_data[prop].position.y;
          d.owner_id = old_data[prop].owner.id;
          d.owner_name = old_data[prop].owner.name;
          d.name = old_data[prop].name;
          d.contested = old_data[prop].contested;
          d.territories_captured = old_data[prop].territories.filter(function(t) {
            return t !== '0';
          }).length;
          data.push(d);
        }
      }
      x.domain(d3.extent(data, function(d) {
        return d.position.x;
      })).nice();
      y.domain(d3.extent(data, function(d) {
        return d.position.y;
      })).nice();
      window.planets = svg.selectAll(".dot").data(data).enter();
      window.planet_names = svg.selectAll("text").data(data).enter().append("text").attr("class", 'planetname').attr("font-size", '3px').style("fill", function(d) {
        return color_mapping[d.owner_name];
      }).text(function(d) {
        var name;
        if (d.contested === 1) {
          name = ("[" + d.territories_captured + "]") + d.name;
        } else {
          name = d.name;
        }
        return name;
      }).attr("transform", transform(d));
      window.peace_planets = planets.append("circle").filter(function(d) {
        return d.contested === 0;
      }).attr("class", 'dot peace').attr("r", 3.5).style("fill", function(d) {
        return color_mapping[d.owner_name];
      }).attr("transform", transform(d));
      contested_planets_enter = planets.append("g").filter(function(d) {
        return d.contested === 1;
      }).attr("class", 'contested_group').attr("transform", transform(d));
      contested_planets_enter.append("circle").attr("class", 'dot contested').attr("r", 3.5).style("fill", function(d) {
        return color_mapping[d.owner_name];
      });
      legend = svg.selectAll(".legend").data(color.domain()).enter().append("g").attr("class", "legend").attr("transform", function(d, i) {
        return "translate(0," + i * 20 + ")";
      });
      zoomListener.translate([-width / 20, -height / 20]).scale(1);
      return zoomListener.event(svg.transition().duration(3000));
    });
  });

}).call(this);
