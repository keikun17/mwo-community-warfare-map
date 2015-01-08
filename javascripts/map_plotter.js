(function() {
  var __hasProp = {}.hasOwnProperty;

  $(function() {
    var clan_factions, color, height, inner_sphere_factions, mapRatio, margin, svg, transform, transform_text, width, x, y, zoomed;
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
    inner_sphere_factions = ["Steiner", "Davion", "Kurita", "Marik", "Liao", "Rasalhague"];
    clan_factions = ["Ghost Bear", "Jade Falcon", "Wolf", "Smoke Jaguar"];
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
      var contested_planets, contested_planets_enter, d, legend, old_data, prop;
      $("#connection-status").text('Done').removeClass('label-danger').addClass("label-success");
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
          d.invader_id = old_data[prop].invading.name;
          d.invader_name = old_data[prop].invading.name;
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
      contested_planets = [];
      window.planet_names = svg.selectAll("text").data(data).enter().append("text").attr("class", 'planetname').attr("font-size", '3px').style("fill", function(d) {
        return color_mapping[d.owner_name];
      }).text(function(d) {
        var name;
        if (d.contested === 1) {
          name = ("[" + d.territories_captured + "]") + d.name;
          contested_planets.push(d);
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
      zoomListener.event(svg.transition().duration(3000));
      window.is_clan_offensive = function(d) {
        return $.inArray(d.owner_name, inner_sphere_factions) > -1 && $.inArray(d.invader_name, clan_factions) > -1;
      };
      window.is_house_offensive = function(d) {
        return $.inArray(d.owner_name, clan_factions) > -1 && $.inArray(d.invader_name, inner_sphere_factions) > -1;
      };
      window.is_house_vs_house = function(d) {
        return $.inArray(d.owner_name, inner_sphere_factions) > -1 && $.inArray(d.invader_name, inner_sphere_factions) > -1;
      };
      return $.each(contested_planets, function(index) {
        var planet, planet_string;
        planet = contested_planets[index];
        if (planet.name === 'Ohrensen') {
          window.kek = planet;
        }
        planet_string = "<li class='faction-" + (planet.owner_name.toLowerCase().replace(/\s/g, '')) + "'>[" + planet.territories_captured + "/8] " + planet.name + " (" + planet.owner_name + " vs " + planet.invader_name + ")</li>";
        if (is_clan_offensive(planet)) {
          return $('#clan_offensive').append(planet_string);
        } else if (is_house_offensive(planet)) {
          return $('#is_offensive').append(planet_string);
        } else if (is_house_vs_house(planet)) {
          return $('#petty_fight').append(planet_string);
        }
      });
    });
  });

}).call(this);
