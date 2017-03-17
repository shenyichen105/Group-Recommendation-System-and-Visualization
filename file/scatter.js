var ScatterPlot = {
  draw: function(id, csvdata){
    var margin = { top: 50, right: 50, bottom: 90, left: 50},
        outerWidth = 590,
        outerHeight = 490,
        width = outerWidth - margin.left - margin.right,
        height = outerHeight - margin.top - margin.bottom;

    var x = d3.scale.linear()
        .range([0, width]).nice();

    var y = d3.scale.linear()
        .range([height, 0]).nice();

    var xCat = "Rank",
        yCat = "Rating",
        colorCat = "User";

    function CSVtoArray(text) {
        var re_valid = /^\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*(?:,\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*)*$/;
        var re_value = /(?!\s*$)\s*(?:'([^'\\]*(?:\\[\S\s][^'\\]*)*)'|"([^"\\]*(?:\\[\S\s][^"\\]*)*)"|([^,'"\s\\]*(?:\s+[^,'"\s\\]+)*))\s*(?:,|$)/g;
        // Return NULL if input string is not well formed CSV string.
        if (!re_valid.test(text)) return null;
        var a = [];                     // Initialize array to receive values.
        text.replace(re_value, // "Walk" the string using replace with callback.
            function(m0, m1, m2, m3) {
                // Remove backslash from \' in single quoted values.
                if      (m1 !== undefined) a.push(m1.replace(/\\'/g, "'"));
                // Remove backslash from \" in double quoted values.
                else if (m2 !== undefined) a.push(m2.replace(/\\"/g, '"'));
                else if (m3 !== undefined) a.push(m3);
                return ''; // Return empty string.
            });
        // Handle special case of empty last value.
        if (/,\s*$/.test(text)) a.push('');
        return a;
    };
    
    d3.csv(csvdata, function(data) {
      data.forEach(function(d) {
        d.Rank = +d.Rank;
        d.Rating = +d.Rating;
         });


      var xMax = d3.max(data, function(d) { return d[xCat]; }) * 1.05,
          xMin = d3.min(data, function(d) { return d[xCat]; }),
          xMin = xMin > 0 ? 0 : xMin,
          yMax = d3.max(data, function(d) { return d[yCat]; }) * 1.05,
          yMin = d3.min(data, function(d) { return d[yCat]; }),
          yMin = yMin > 0 ? 0 : yMin;

      x.domain([xMin, xMax]);
      y.domain([yMin, yMax]);

      var xAxis = d3.svg.axis()
          .scale(x)
          .orient("bottom")
          .tickSize(-height)
          .ticks(20);

      var yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .tickSize(-width);

      var color = d3.scale.category10();

      var tip = d3.tip()
          .attr("class", "d3-tip")
          .offset([-10, 0])
          .html(function(d) {
            return colorCat + ": " + d[colorCat] + "<br>" + yCat + ": " + d[yCat].toFixed(2);
          });

      var zoomBeh = d3.behavior.zoom()
          .x(x)
          .y(y)
          .scaleExtent([0, 500])
          .on("zoom", zoom);

      var svg = d3.select(id)
        .append("svg")
          .attr("width", outerWidth)
          .attr("height", outerHeight)
        .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
          .call(zoomBeh);

      svg.call(tip);

      svg.append("rect")
          .attr("width", width)
          .attr("height", height);

      svg.append("g")
          .classed("x axis", true)
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis)
        .append("text")
          .classed("label", true)
          .attr("x", width+ 20)
          .attr("y", margin.bottom - 57)
          .style("font-size", "12px")
          .style("font-family", "arial, sans-serif")
          .style("text-anchor", "end")
          .text(xCat);

      svg.append("g")
          .classed("y axis", true)
          .call(yAxis)
        .append("text")
          .classed("label", true)
          .attr("x", margin.left - 35)
          .attr("y", margin.top - 70)
          .attr("dy", ".71em")
          .style("font-size", "12px")
          .style("font-family", "arial, sans-serif")
          .style("text-anchor", "end")
          .text(yCat);

      var objects = svg.append("svg")
          .classed("objects", true)
          .attr("width", width )
          .attr("height", height);

      objects.append("svg:line")
          .classed("axisLine hAxisLine", true)
          .attr("x1", 0)
          .attr("y1", 0)
          .attr("x2", width)
          .attr("y2", 0)
          .attr("transform", "translate(0," + height + ")");

      objects.append("svg:line")
          .classed("axisLine vAxisLine", true)
          .attr("x1", 0)
          .attr("y1", 0)
          .attr("x2", 0)
          .attr("y2", height);

      objects.selectAll(".dot")
          .data(data)
        .enter().append("circle")
          .classed("dot", true)
          .attr("r", 5)
          .attr("transform", transform)
          .style("fill", function(d) { return color(d[colorCat]); })
          .on("mouseover", tip.show)
          .on("mouseout", tip.hide);
/*
      var legend = svg.selectAll(".legend")
          .data(color.domain())
        .enter().append("g")
          .classed("legend", true)
          .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

      legend.append("circle")
          .attr("r", 3.5)
          .attr("cx", width + 20)
          .attr("fill", color);

      legend.append("text")
          .attr("x", width + 26)
          .attr("dy", ".35em")
          .text(function(d) { return d; });
*/
      d3.select("input").on("click", change);

      function change() {
        xCat = "Carbs";
        xMax = d3.max(data, function(d) { return d[xCat]; });
        xMin = d3.min(data, function(d) { return d[xCat]; });

        zoomBeh.x(x.domain([xMin, xMax])).y(y.domain([yMin, yMax]));

        var svg = d3.select(id).transition();

        svg.select(".x.axis").duration(750).call(xAxis).select(".label").text(xCat);

        objects.selectAll(".dot").transition().duration(1000).attr("transform", transform);
      }

      function zoom() {
        svg.select(".x.axis").call(xAxis);
        svg.select(".y.axis").call(yAxis);

        svg.selectAll(".dot")
            .attr("transform", transform);
      }

      function transform(d) {
        return "translate(" + x(d[xCat]) + "," + y(d[yCat]) + ")";
      }
    });
  }
}