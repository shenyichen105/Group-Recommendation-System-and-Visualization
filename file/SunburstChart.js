var SunburstChart = {
	draw: function(id, jsondata){
		var width = 300,
		height = 300,
		radius = (Math.min(width, height) / 2) - 10;

		var formatNumber = d3.format(",d");

		var x = d3.scale.linear()
		.range([0, 2 * Math.PI]);

		var y = d3.scale.sqrt()
		.range([0, radius]);

		var tip = d3.tip()
		.attr('class', 'd3-tip')
		.offset([-10, 0])
		.html(function(d) {
		return "<p><strong><span style='font-size: 13px;'>" + d.name + "</span></strong></p> <p>" + d.value + " visits</p>";
		})

		var color = d3.scale.category20c();

		var partition = d3.layout.partition()
		.value(function(d) { return d.size; });

		var arc = d3.svg.arc()
		.startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
		.endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
		.innerRadius(function(d) { return Math.max(0, y(d.y)); })
		.outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

		var svg = d3.select(id).append("svg")
		.attr("width", width + 290)
		.attr("height", height + 50)
		.append("g")
		.attr("transform", "translate(" + 300 +  "," + (height / 2) + ")");

		svg.call(tip);
		var root = JSON.parse(jsondata);
		
		/*		
		d3.json(JSON.parse(jsondata), function(error, root) {
		if (error) throw error;
		*/

		svg.selectAll("path")
		.data(partition.nodes(root))
		.enter().append("path")
		.attr("d", arc)
		.style("fill", function(d) { return color((d.children ? d : d.parent).name); })
		.on("click", click)
		.on('mouseover', tip.show)
		.on("mousemove", function () {
		return tip
		.style("top", (d3.event.pageY + 12) + "px")
		.style("left", (d3.event.pageX + 12) + "px");})
		.on('mouseout', tip.hide)
		//});

		function click(d) {
		svg.transition()
		.duration(750)
		.tween("scale", function() {
		var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
		yd = d3.interpolate(y.domain(), [d.y, 1]),
		yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
		return function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); };
		})
		.selectAll("path")
		.attrTween("d", function(d) { return function() { return arc(d); }; });
		}

		d3.select(self.frameElement).style("height", height + "px");
	}
};