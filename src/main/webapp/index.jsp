<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<link href="/css/layout.css" rel="stylesheet" type="text/css">
		<!--[if lte IE 8]><script language="javascript" type="text/javascript" src="/js/excanvas.min.js"></script><![endif]-->
		<script language="javascript" type="text/javascript" src="/js/jquery.js"></script>
		<script language="javascript" type="text/javascript" src="/js/jquery.flot.js"></script>
		<script language="javascript" type="text/javascript" src="/js/jquery.flot.selection.js"></script>
		<script language="javascript" type="text/javascript" src="/js/PlotModel.js"></script>
		<script language="javascript" type="text/javascript" src="/js/main.js"></script>
		<title>Flot Home Page</title>
	</head>
	<body>
		<h1>Flot Examples</h1>
		<div id="pano">
			<div id="placeholder" style="width: 664px; height: 316px;"></div>
		</div>
		<div class="thumbnails" style="width: 664px">
			<div>
				<div id="overview"></div>
			</div>
			<div id="overview2" style="width: 166px; height: 100px;"></div>
			<div id="overview3" style="width: 166px; height: 100px;"></div>
			<div id="overview4" style="width: 166px; height: 100px;"></div>
			<div id="overview5" style="width: 166px; height: 100px;" ></div>
		</div>
		<script type="text/javascript">
			$(function () {
				
				var currentPlot = new $.PlotModel("sin(x)", 100, function(x){
					var A , dE, T, k;
					return Math.sin(x);
			        //return A*Math.exp(x/(k*T));
				});
				
				var R_of_dE_where_TA_const = [],
					R_of_A_where_TdE_const = [],
					R_of_T_where_AdE_const = []; 

				var T_of_dE_where_AR_const = [],
					T_of_R_where_AdE_const = [],
					T_of_A_where_RdE_const = [];

				var dE_of_T_where_AR_const = [],
					dE_of_R_where_TA_const = [],
					dE_of_A_where_RT_const = [];
				

			    var optionsPano = {
			            legend: { show: true },
			            series: {
			                lines: { show: true },
			                points: { show: true }
			            },
			            grid: { hoverable: true},
			            yaxis: { ticks: 10 },
			            selection: { mode: "xy" }
			     };

			     var optionsThumbnail = {
			    		legend: { 
				    		show: false 
				    	},
					    series: {
					    	lines: { 
						    	show: true, 
						    	lineWidth: 1 
						    	},
					    	shadowSize: 0 
					    	},
					    xaxis: { ticks: 4 },
					    yaxis: { ticks: 3, min: -2, max: 2 },
					    grid: { color: "#999" },
					    selection: { mode: "xy" }
				};
			    
			    var plot = $.plot($('#placeholder'),currentPlot.getData(0,10), optionsPano);

			    var overview = $.plot($("#overview"), currentPlot.getData(0,10), optionsThumbnail); 

			   	$.plot($("#overview2"), currentPlot.getData(0,10), optionsThumbnail); 

			   	$.plot($("#overview3"), currentPlot.getData(0,10), optionsThumbnail); 
			   	
			   	$.plot($("#overview4"), currentPlot.getData(0,10), optionsThumbnail); 

			   	$.plot($("#overview5"), currentPlot.getData(0,10), optionsThumbnail); 
			    
			   	
			    $("#overview").bind("plotselected", function (event, ranges) {
			    	plot.setSelection(ranges);
			    }); 

			    function showTooltip(x, y, contents) {
			        $('<div id="tooltip">' + contents + '</div>').css( {
			            position: 'absolute',
			            display: 'none',
			            top: y + 5,
			            left: x + 5,
			            border: '1px solid #fdd',
			            padding: '2px',
			            'background-color': '#fee',
			            opacity: 0.80
			        }).appendTo("body").fadeIn(200);
			    }

			    $("#placeholder").bind("plotselected", function (event, ranges) {
			        // clamp the zooming to prevent eternal zoom
			        if (ranges.xaxis.to - ranges.xaxis.from < 0.00001)
			            ranges.xaxis.to = ranges.xaxis.from + 0.00001;
			        if (ranges.yaxis.to - ranges.yaxis.from < 0.00001)
			            ranges.yaxis.to = ranges.yaxis.from + 0.00001;
			        
			        // do the zooming
			        plot = $.plot($("#placeholder"), currentPlot.getData(ranges.xaxis.from, ranges.xaxis.to),
			                      $.extend(true, {}, options, {
			                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
			                          yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
			                      }));
			        
			        // don't fire event on the overview to prevent eternal loop
			        overview.setSelection(ranges, true);
			    });

			    var previousPoint = null;
			    $("#placeholder").bind("plothover", function (event, pos, item) {

		            if (item) {
		                if (previousPoint != item.dataIndex) {
		                    previousPoint = item.dataIndex;
		                    
		                    $("#tooltip").remove();
		                    var x = item.datapoint[0].toFixed(2),
		                        y = item.datapoint[1].toFixed(2);
		                    
		                    showTooltip(item.pageX, item.pageY, item.series.label + " of " + x + " = " + y);
		                }
		            }
		            else {
		                $("#tooltip").remove();
		                previousPoint = null;            
		            }
			    });		    
			});
			</script>
	</body>
</html>
