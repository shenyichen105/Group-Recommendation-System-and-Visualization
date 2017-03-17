#!/Users/tseweifu/anaconda/bin/python

# Import modules for CGI handling 
import cgi, cgitb 

# Create instance of FieldStorage 
form = cgi.FieldStorage() 


# Get data from fields
userlist = []
usercount = int(form.getvalue('usercount'))


for i in range(usercount):
	userlist.append(form.getvalue('user' + str(i+1)))

import pandas as pd
import numpy as np
import operator # for sorting dict
import json
import csv

userlist = np.array(map(float, userlist))

# Data loading and cleaning
df_user = pd.read_csv("User_by_cat_ratings.csv", index_col='user_id')

df_business = pd.read_csv("business_cat_after_KNN.csv", index_col='b_id')
del df_business["Unnamed: 0"]

df_business_main = pd.read_csv("business_main.csv", index_col='b_id')

df_subuser = df_user.loc[userlist]

df_cat = pd.read_csv("category_id.csv", index_col='cat_id')

myLatitude = df_business_main.loc[1]['Latitude']
myLongitude = df_business_main.loc[1]['Longitude']

# Calculate distance
from math import radians, cos, sin, asin, sqrt
def haversine(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points 
    on the earth (specified in decimal degrees)
    """
    # convert decimal degrees to radians 
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    # haversine formula 
    dlon = lon2 - lon1 
    dlat = lat2 - lat1 
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a)) 
    km = 6367 * c
    return km

# criteria best on distance to restaurant (km)
threshold = 10
business_sub = set()
for b_id, row in df_business_main.iterrows():
    if haversine(row['Longitude'], row['Latitude'], myLongitude, myLatitude) < 10:
        business_sub.add(b_id)
    #if row['State'] == 'PA':
    #    business_sub.add(b_id)
        
# 
b_id_database = set(df_business.index)
business_rating = {}
business_rating_std = {}
for b_id in business_sub:
    if b_id not in b_id_database:
        continue
    else:
        row = df_business.loc[b_id]
        category = [ x-1 for x in row if x != 0] # -1 
        business_rating[b_id] = np.average(df_subuser.iloc[:,category])
        business_rating_std[b_id] = df_subuser.iloc[:,category].mean(axis = 1).values.std()
        category = []
        
final_list = sorted(business_rating.iteritems(), key=operator.itemgetter(1), reverse=True)[:min(10,len(business_rating))]
final_list_std = sorted(business_rating_std.iteritems(), key=operator.itemgetter(1), reverse=True)[:min(10,len(business_rating_std))]


# Radar chart
res = [b_id for (b_id, rating) in final_list]
res_cat = [x for x in np.unique(df_business.loc[res].values) if x != 0]
df_userRadar = df_user.loc[userlist][map(str,res_cat)]

nrow = df_userRadar.shape[0]
ncol = df_userRadar.shape[1]
fianl_cat = df_cat.loc[res_cat]['name'].tolist()
a = '['
ix_row = 0
for user_id, row in df_userRadar.iterrows():
    a += '['
    for ix in range(ncol):
        a = a + '{axis:' + '"' + fianl_cat[ix] + '"' + ',value:' + str(row[ix]) +'}'
        if ix != (ncol-1):
            a += ','
    a += ']'   
    
    if ix_row != (nrow-1):
        a += ','
    ix_row += 1

a += '];'

# Radar chart2_total categories
cat_ratingsorted_ix = df_user.loc[userlist].mean(axis = 0).sort_values(ascending=False).index[:20]
df_userRadar2 = df_user.loc[userlist][cat_ratingsorted_ix]

nrow = df_userRadar2.shape[0]
ncol = df_userRadar2.shape[1]
fianl_cat2 = df_cat.loc[map(int,cat_ratingsorted_ix.values.tolist())]['name'].tolist()
b = '['
ix_row = 0
for user_id, row in df_userRadar2.iterrows():
    b += '['
    for ix in range(ncol):
        b = b + '{axis:' + '"' + fianl_cat2[ix] + '"' + ',value:' + str(row[ix]) +'}'
        if ix != (ncol-1):
            b += ','
    b += ']'   
    
    if ix_row != (nrow-1):
        b += ','
    ix_row += 1

b += '];'

# Radar chart 3
res_std = [b_id for (b_id, rating) in final_list_std]
res_cat_std = [x for x in np.unique(df_business.loc[res_std].values) if x != 0]
df_userRadar_std = df_user.loc[userlist][map(str,res_cat_std)]

nrow = df_userRadar_std.shape[0]
ncol = df_userRadar_std.shape[1]
fianl_cat_std = df_cat.loc[res_cat_std]['name'].tolist()
c = '['
ix_row = 0
for user_id, row in df_userRadar_std.iterrows():
    c += '['
    for ix in range(ncol):
        c = c + '{axis:' + '"' + fianl_cat_std[ix] + '"' + ',value:' + str(row[ix]) +'}'
        if ix != (ncol-1):
            c += ','
    c += ']'   
    
    if ix_row != (nrow-1):
        c += ','
    ix_row += 1

c += '];'

writeTable = ''

for b_id, row in df_business.loc[res].iterrows():
    writeTable += '<tr>'
    writeTable += '<td>'
    writeTable += df_business_main.loc[b_id]['Name']
    writeTable += '</td>'
    
    resCatTable = df_cat.loc[[cat for cat in row if cat != 0]]['name']
    writeTable += '<td>'
    writeTable += ', '.join(resCatTable)
    writeTable += '</td>'

    writeTable += '<td>'
    writeTable += '{0:.2f}'.format(business_rating[b_id])
    writeTable += '</td>'
    writeTable += '</tr>'

writeTable_std = ''

for b_id, row in df_business.loc[res_std].iterrows():
    writeTable_std += '<tr>'
    writeTable_std += '<td>'
    writeTable_std += df_business_main.loc[b_id]['Name']
    writeTable_std += '</td>'
    
    resCatTable_std = df_cat.loc[[cat for cat in row if cat != 0]]['name']
    writeTable_std += '<td>'
    writeTable_std += ', '.join(resCatTable_std)
    writeTable_std += '</td>'

    writeTable_std += '<td>'
    writeTable_std += '{0:.2f}'.format(business_rating_std[b_id])
    writeTable_std += '</td>'
    writeTable_std += '</tr>'

#SunBurst chart
sunburst = []

df_user_all = pd.read_csv("user.csv", index_col='u_id')
df_review = pd.read_csv("review.csv")

BusinessIDdb = set(df_business_main['BusinessID'])
b_iddb = set(df_business.index.values)

for ix in range(usercount):
    u_id = userlist[ix]
    sunburst.append({"name": u_id, "children":[]})    
    UserId = df_user_all.loc[u_id]['UserID']
    
    if UserId != '#NAME?':
        for BusinessId in df_review.loc[df_review['UserID'] == UserId]['BusinessID']:
            if (BusinessId != '#NAME?') and (BusinessId in BusinessIDdb):
                
                b_id = df_business_main.loc[df_business_main['BusinessID'] == BusinessId].index[0]
                
                if b_id in b_iddb:

                    BusinessName = df_business_main.loc[b_id]['Name']

                    for cat in df_business.loc[b_id]:
                        if cat != 0:
                            
                            catName = df_cat.loc[cat]['name']
                            
                            if not(sum([catName in y for y in [x.itervalues() for x in sunburst[ix]["children"]]])):
                                sunburst[ix]["children"].append(
                                    {
                                        "name": catName,
                                        "children": [
                                            {"name": BusinessName.replace("'", ""), "size": 1}
                                        ]})
                            else:
                                for ix2 in range(len(sunburst[ix]["children"])):
                                    if sunburst[ix]["children"][ix2]["name"] == catName:
                                        if not(sum([BusinessName in y for y in [x.itervalues() for x in sunburst[ix]["children"][ix2]["children"]]])):
                                            sunburst[ix]["children"][ix2]["children"].append(
                                                {"name": BusinessName.replace("'", ""), "size": 1})
                                        else:
                                            for ix3 in range(len(sunburst[ix]["children"][ix2]["children"])):
                                                if sunburst[ix]["children"][ix2]["children"][ix3]["name"] == BusinessName:
                                                    sunburst[ix]["children"][ix2]["children"][ix3]["size"] += 1

#Scatter plot
res_std_name = []
with open('scatterdata.csv', 'wb') as f:
    w = csv.writer(f, delimiter = ',')
    w.writerows([x.split(',') for x in ['Rank,Rating,User']])
    scatter_data = sorted(business_rating_std.iteritems(), key=operator.itemgetter(1), reverse=True)[:min(20,len(business_rating_std))]
    for ix in range(len(scatter_data)):
        res_std_name.append(df_business_main.loc[scatter_data[ix][0]]['Name'])
        for ix2 in range(usercount):
            writeText = []
            b_id = scatter_data[ix][0]
            row = df_business.loc[b_id]
            category = [ x-1 for x in row if x != 0] # -1 
            ratings = df_subuser.iloc[:,category].mean(axis = 1).values[ix2]
            writeText.append(str(ix+1)+","+str(ratings)+","+str(userlist[ix2]))
            w.writerows([x.split(',') for x in writeText])

res_opinion = ""
for ix in range(len(res_std_name)-1):
    res_opinion += str(ix+1) + ". " + res_std_name[ix] + ", "
res_opinion += str(len(res_std_name)) + ". " + res_std_name[-1] + "."


print "Content-type:text/html\r\n\r\n"
print """
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
<title>Restaurant recommendation for Groups!</title>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script src="http://labratrevenge.com/d3-tip/javascripts/d3.tip.v0.6.3.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.12.0/js/bootstrap-select.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.12.0/css/bootstrap-select.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="scatter.css" charset="utf-8">
<script src="RadarChart.js"></script>
<script src="SunburstChart.js"></script>
<script src="scatter.js" charset="utf-8"></script>

<style>
    body {
        overflow: hidden;
        margin: 0;
        font-size: 14px;
        font-family: "Helvetica Neue", Helvetica;
        overflow-y:scroll;
        padding-left: 1cm;
        padding-right: 1cm;
    }

    
    table {
        font-family: arial, sans-serif;
        font-size: 13px;
        border: 1px solid black;
        border-collapse: collapse;
        width: 80%;
        padding-left: 1cm;
        padding-right: 1cm;
    }
    td, th{
        border: 1px solid black;
        text-align: left;
        padding: 8px;
    }
    tr:nth-child(even) {
        background-color: #dddddd;
    }
    p {
        padding-left: 12px;
        padding-right: 12px;
    }
    path {
        stroke: #fff;
    }

    .d3-tip {
        line-height: 1;
        font-weight: bold;
        padding-left: 12px;
        padding-right: 12px;
        background: rgba(146, 168, 209, 0.8);
        color: #ffffff;
        border-radius: 8px;
        position: absolute;
        font: 12px; 
        font-family: arial, sans-serif;
    }
</style>
</head>


<body>
    <div id="body" position:relative; width = "100%" height = "100%">
        <div class="form-group">
            <h3>Our top picks for you</h3>
        </div>

        <div class="form-group">
            <table>
            <tr>
            <th>Restaurant</th>
            <th>Category</th>
            <th>Ratings</th>
            </tr>
"""
print writeTable

print """
            </table>
        </div>

        <div class="form-group">
            <hr />
        </div>
        
        <div class="form-group">
            <h3>Let the Radar scans</h3>
        </div>
        
        <div id="chart" width = "300px" height = "300px" style="float:left"></div>
        <div id="chart2" width = "300px" height = "300px" style="float:right"></div>
        <div class="form-group">
            <p> The left-hand chart explains why we thinkg you might enojoy these restaurants; while the right-hand chart shows how similar or different you and your friends really are!</p>
            <hr />
            <h3>Look into individual visits </h3>
        </div>
"""

insertText = ""
for ix in range(usercount):
    if ix % 2 == 0:
        insertText += "<div id=\"chart" + str(ix + 3) + "\" width = \"300px\" height = \"300px\" style=\"float:left\"text-align=\"center\"><h5 align=\"center\">User " + str(int(userlist.tolist()[ix])) + "</h4></div>"
    else:
        insertText += "<div id=\"chart" + str(ix + 3) + "\" width = \"300px\" height = \"300px\" style=\"float:right\"text-align=\"center\"><h5 align=\"center\">User " + str(int(userlist.tolist()[ix]))+ "</h4></div>"

if int(usercount) % 2 != 0:
    insertText += "<div id=\"chart" + str(ix + 3 + 1) + "\" width = \"300px\" height = \"300px\" style=\"float:right\"text-align=\"center\"><svg width=\"590\" height=\"389\"></svg></div>"


print insertText

print """
        <div class="form-group">
            <p>Click on the interactive sunburst charts for detail restaurants visits!</p>
        <hr />
        </div>
        <div class="form-group">
            <h3>What if you wanna try something different - here you go</h3>
        </div>

        <div class="form-group">
            <table>
            <tr>
            <th>Restaurant</th>
            <th>Category</th>
            <th>Standard deviation</th>
            </tr>
"""
print writeTable_std

print """
            </table>
        </div>

        <div class="form-group">
            <hr />
        </div>
        
        <div class="form-group">
            <h3>How different you guys are?</h3>
        </div>
        
        <div id="chart7" width = "300px" height = "300px" style="float:left"></div>
        <div id="chart8" width = "300px" height = "300px" style="float:right"></div>
        <div class="form-group">
            <br><br>
            <p> The left-hand chart shows users' category rating for top diverse-opinioned restaurants; while the right-hand chart shows how different the ratings are on each restaurants! The restaurants ranking list is as followed: 
"""

print res_opinion

print"""
            </p>
            <hr />
        </div>

    </div>
	
 <script>
    var w = 390,
    	h = 390;

    var colorscale = d3.scale.category10();
"""
print "var d = %s" %(a)
print "var d2 = %s" %(b)
print "var d4 = %s" %(c)
print "var LegendOptions = %s;" %(str(userlist.tolist()))

print """
    //Options for the Radar chart, other than default
    var mycfg = {
      w: w,
      h: h,
      maxValue: 0.6,
      levels: 6,
      ExtraWidthX: 200
    }

    //Call function to draw the Radar chart
    //Will expect that data is in %'s
    RadarChart.draw("#chart", d, mycfg);
    RadarChart.draw("#chart2", d2, mycfg);

    ////////////////////////////////////////////
    /////////// Initiate legend ////////////////
    ////////////////////////////////////////////

    var svg = d3.select('#chart')
    	.selectAll('svg')
    	.append('svg')
    	.attr("width", w+200)
    	.attr("height", h)

    //Create the title for the legend
    var text = svg.append("text")
    	.attr("class", "title")
    	.attr('transform', 'translate(-300,15)') 
    	.attr("x", w - 50)
    	.attr("y", 10)
    	.style("font-size", "12px")
        .style("font-family", "arial, sans-serif")
    	.attr("fill", "#404040")
    	.text("User ");
    		
    //Initiate Legend	
    var legend = svg.append("g")
    	.attr("class", "legend")
    	.attr("height", 100)
    	.attr("width", 200)
    	.attr('transform', 'translate(-300,40)') 
    	;
    	//Create colour squares
    	legend.selectAll('circle')
    	  .data(LegendOptions)
    	  .enter()
    	  .append("circle")
    	  .attr("cx", w - 45)
    	  .attr("cy", function(d, i){ return i * 20;})
          .attr("r", 4)
    	  .attr("width", 10)
    	  .attr("height", 10)
    	  .style("fill", function(d, i){ return colorscale(i);})
    	  ;
    	//Create text next to squares
    	legend.selectAll('text')
    	  .data(LegendOptions)
    	  .enter()
    	  .append("text")
    	  .attr("x", w - 38)
    	  .attr("y", function(d, i){ return i * 20 + 5;})
    	  .style("font-size", "12px")
          .style("font-family", "arial, sans-serif")
    	  .attr("fill", "#737373")
    	  .text(function(d) { return d; })
    	  ;	
    </script>

    <script>
"""
for ix in range(usercount):
    print "SunburstChart.draw(\"#chart" + str(ix+3) + "\", %s);" %("'" + json.dumps(sunburst[ix]) + "'")
print """
    </script>

<script>
    var w = 390,
        h = 390;

    var colorscale = d3.scale.category10();
    //Options for the Radar chart, other than default
    var mycfg = {
      w: w,
      h: h,
      maxValue: 0.6,
      levels: 6,
      ExtraWidthX: 200
    }

    //Call function to draw the Radar chart
    //Will expect that data is in %'s
"""
#print"RadarChart.draw(\"#chart" + str(2+usercount+usercount%2+1) + "\", d4, mycfg);"
#print"ScatterPlot.draw(\"#chart" + str(2+usercount+usercount%2+2) + "\", \"scatterdata.csv\");"

print"""

    RadarChart.draw("#chart7", d4, mycfg);
    ScatterPlot.draw("#chart8", "scatterdata.csv");

    ////////////////////////////////////////////
    /////////// Initiate legend ////////////////
    ////////////////////////////////////////////

    var svg = d3.select('#chart7')
        .selectAll('svg')
        .append('svg')
        .attr("width", w+200)
        .attr("height", h)

    //Create the title for the legend
    var text = svg.append("text")
        .attr("class", "title")
        .attr('transform', 'translate(-300,15)') 
        .attr("x", w - 50)
        .attr("y", 10)
        .style("font-size", "12px")
        .style("font-family", "arial, sans-serif")
        .attr("fill", "#404040")
        .text("User ");
            
    //Initiate Legend   
    var legend = svg.append("g")
        .attr("class", "legend")
        .attr("height", 100)
        .attr("width", 200)
        .attr('transform', 'translate(-300,40)') 
        ;
        //Create colour squares
        legend.selectAll('circle')
          .data(LegendOptions)
          .enter()
          .append("circle")
          .attr("cx", w - 45)
          .attr("cy", function(d, i){ return i * 20;})
          .attr("r", 4)
          .attr("width", 10)
          .attr("height", 10)
          .style("fill", function(d, i){ return colorscale(i);})
          ;
        //Create text next to squares
        legend.selectAll('text')
          .data(LegendOptions)
          .enter()
          .append("text")
          .attr("x", w - 38)
          .attr("y", function(d, i){ return i * 20 + 5;})
          .style("font-size", "12px")
          .style("font-family", "arial, sans-serif")
          .attr("fill", "#737373")
          .text(function(d) { return d; })
          ; 
    </script>
</body>
</html>
"""



