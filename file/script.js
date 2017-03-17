var w = 500,
	h = 500;

var colorscale = d3.scale.category10();

//Legend titles
var LegendOptions = [29609.0, 116757.0,44141.0,99929.0]; // user list

//Data
var d = [[{axis:"Sandwiches",value:3.02116219428},{axis:"Chinese",value:4.9408496732},{axis:"Japanese",value:3.1729745672},{axis:"Barbeque",value:4.9408496732},{axis:"Steakhouses",value:3.07071016234}],[{axis:"Sandwiches",value:4.84841269841},{axis:"Chinese",value:4.53777858146},{axis:"Japanese",value:4.84841269841},{axis:"Barbeque",value:4.84841269841},{axis:"Steakhouses",value:4.84841269841}],[{axis:"Sandwiches",value:4.65917559806},{axis:"Chinese",value:3.9925089314},{axis:"Japanese",value:4.16334939301},{axis:"Barbeque",value:4.9925089314},{axis:"Steakhouses",value:4.32584226473}],[{axis:"Sandwiches",value:5.0},{axis:"Chinese",value:4.46375122202},{axis:"Japanese",value:5.0},{axis:"Barbeque",value:5.0},{axis:"Steakhouses",value:4.51174405456}]];

//Options for the Radar chart, other than default
var mycfg = {
  w: w,
  h: h,
  maxValue: 0.6,
  levels: 6,
  ExtraWidthX: 300
}

//Call function to draw the Radar chart
//Will expect that data is in %'s
RadarChart.draw("#chart", d, mycfg);

////////////////////////////////////////////
/////////// Initiate legend ////////////////
////////////////////////////////////////////

var svg = d3.select('#body')
	.selectAll('svg')
	.append('svg')
	.attr("width", w+300)
	.attr("height", h)

//Create the title for the legend
var text = svg.append("text")
	.attr("class", "title")
	.attr('transform', 'translate(50,20)') 
	.attr("x", w - 70)
	.attr("y", 10)
	.attr("font-size", "12px")
	.attr("fill", "#404040")
	.text("User: ");
		
//Initiate Legend	
var legend = svg.append("g")
	.attr("class", "legend")
	.attr("height", 100)
	.attr("width", 200)
	.attr('transform', 'translate(50,40)') 
	;
	//Create colour squares
	legend.selectAll('rect')
	  .data(LegendOptions)
	  .enter()
	  .append("rect")
	  .attr("x", w - 65)
	  .attr("y", function(d, i){ return i * 20;})
	  .attr("width", 10)
	  .attr("height", 10)
	  .style("fill", function(d, i){ return colorscale(i);})
	  ;
	//Create text next to squares
	legend.selectAll('text')
	  .data(LegendOptions)
	  .enter()
	  .append("text")
	  .attr("x", w - 52)
	  .attr("y", function(d, i){ return i * 20 + 9;})
	  .attr("font-size", "11px")
	  .attr("fill", "#737373")
	  .text(function(d) { return d; })
	  ;	