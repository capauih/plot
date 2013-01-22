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
		<div id="pano" style="display:none">
			<h1>Main Plot:</h1>
			<div id="placeholder" style="width: 668px; height: 316px;"></div>
			
			<h1>Little Plots:</h1>
			<div class="thumbnails" style="width: 690px; height: auto;"></div>
			
			<div class="save_button">
				<input id="saveDataButton" name="button" value="Save Data!" type="button" />
				<input id="newDataButton" name="button" value="Specify New Data!" type="button" />
				
			</div> 
		</div>
		
		<div id="form">
			<form id="defaultValuesForm" action="">
			<h1>Data:</h1>
				<table>
					<thead>
						<tr>
							<th></th>
							<th>Constant:</th>
							<th>Min:</th>
							<th>Max:</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>R: </td>
							<td><input id="const1" type="text" size="30em" placeholder="const"/></td>
							<td><input id="const_min1" type="text" size="30em" placeholder="min"/></td>
							<td><input id="const_max1" type="text" size="30em" placeholder="max"/></td>
						</tr>
						<tr>
							<td>A: </td>
							<td><input id="const2" type="text" size="30em" placeholder="const"/></td>
							<td><input id="const_min2" type="text" size="30em" placeholder="min"/></td>
							<td><input id="const_max2" type="text" size="30em" placeholder="max"/></td>
						</tr>
						<tr>
							<td>dE: </td>
							<td ><input id="const3" type="text" size="30em" placeholder="const"/></td>
							<td><input id="const_min3" type="text" size="30em" placeholder="min"/></td>
							<td><input id="const_max3" type="text" size="30em" placeholder="max"/></td>
						</tr>
						<tr>
							<td>T: </td>
							<td><input id="const4" type="text" size="30em" placeholder="const"/></td>
							<td><input id="const_min4" type="text" size="30em" placeholder="min"/></td>
							<td><input id="const_max4" type="text" size="30em" placeholder="max"/></td>
						</tr>
						<tr>							
							<td></td>
							<td colspan="3" style=" text-align: center;"><button>Build!</button></td>
						</tr>
					</tbody>
				</table>
			</form>
		</div>
		
		<form id="saveDataForm" action="" method="post"></form>
		
		<script type="text/javascript">
			$(function () {
				var k = 1.38e-24,
					R, Rmin, Rmax,
					dE, dEmin, dEmax,
					A, Amin, Amax,
					T, Tmin, Tmax; 	

				var plotArray = [];//array of $.PlotModel objects

				var currentPlot;//$.PoltModel object displaied in pano

				var plot;//main plot object

				var overview;//current overview(thumbnail from set of thumbnails)

				var thumbnail_id = 'overview';
				
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
					    	lines: { show: true, lineWidth: 1 },
					    	shadowSize: 0 
					    },
					    xaxis: { ticks: 4 },
					    yaxis: { ticks: 3 },
					    grid: { color: "#999" }
				};
				
				function drowBigPlot(){
					plot = $.plot($('#placeholder'),currentPlot.getData(currentPlot.Xmin,currentPlot.Xmax), optionsPano);

					$("#placeholder").bind("plotselected", function (event, ranges) {
				        // clamp the zooming to prevent eternal zoom
				        if (ranges.xaxis.to - ranges.xaxis.from < 0.00001)
				            ranges.xaxis.to = ranges.xaxis.from + 0.00001;
				        if (ranges.yaxis.to - ranges.yaxis.from < 0.00001)
				            ranges.yaxis.to = ranges.yaxis.from + 0.00001;
				        
				        // do the zooming
				        plot = $.plot($("#placeholder"), currentPlot.getData(ranges.xaxis.from, ranges.xaxis.to),
				                      $.extend(true, {}, optionsPano, {
				                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
				                          yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
				                      }));
				        
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
				}

				function drowThumbnails(){
					$('.thumbnails').html('');
					var length = plotArray.length;
					for(var i=0; i<length; i++){
						drowLittlePlot(i,plotArray[i]);
					}
				}
				
				function drowLittlePlot(index, plotObject){
					var id = thumbnail_id + index;
					var container = '<div class="thumbnail"><div id="'+id+'" class="little_plot"></div></div>';

					$('.thumbnails').append(container)
					
					$.plot($('#'+id), plotObject.getData(plotObject.Xmin,plotObject.Xmax), optionsThumbnail);
					
					$('#'+id).parent().bind('click',function(){
						$('.selected').removeClass('selected');
						$(this).addClass('selected');
						currentPlot = plotArray[index];
						drowBigPlot();
					});
					
				}
				
				function errorMessage(message){
					var errorMess = message ||"*Incorrectly filled fields";
					errorMess = errorMess.replace(/'/g,"\"");
					return '<span class="errorMess" style="color:red; font-family:monospace">' + errorMess + '</span>';
				}
				
				function onSubmit(e) {
					e.preventDefault();

					var pattern = /(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?/;

					function putData(object, key, value){
						var data = $(object).attr(key) || '';
						if(data != ''){
							data = JSON.parse(decodeURI(data));
						}else {
							data =[];
						}
						data.push(value);
						$(object).attr(key,encodeURI(JSON.stringify(data))); 
					}

					function getData(object, key){
						var data = $(object).attr(key) || '';
						if(data != ''){
							data = JSON.parse(decodeURI(data));
						}else {
							data =[];
						}
						return data;
					}
					
					var valid = true;
					$('.valid').removeClass();
					$('.unvalid').removeClass();
					$('#form input').removeAttr('data-errors');

					$('#form input').each(function(){
						var value = $(this).val();
						if (!pattern.test(value)){
							$(this).addClass('unvalid');
							putData(this,'data-errors','Value should be numeric!');
							valid= false;
						} else{
							$(this).addClass('valid');
						}
						

						
					});

					if(valid){
						$('#form input').each(function(){
							var value = $(this).val();
							var id = $(this).attr('id');
							if(id.indexOf('max')!=-1){
								var min =$(this).parent().prev().children(0).val();
								if(min >= value){
									$(this).removeClass();
									$(this).addClass('unvalid');
									putData(this,'data-errors','Max value should be greate then min!');
									valid = false;
									
								}
							}
						});
					}
								
					$('.unvalid').mouseover(function(e){
						var x = $(this).offset().left,
							y = $(this).offset().top,
							w = $(this)[0].offsetWidth,
							h = $(this)[0].offsetHeight; 
						var errors = $(this).attr("data-errors") || '';
						if(errors != ''){
							errors= JSON.parse(decodeURI(errors));
						} else {
							errors = [];
						}
						var message='<ul>';
						$.each(errors, function(key, value) {
							message+='<li>'+value+'</li>'; 
						});
						message+='</ul>';
						showTooltip(x,y,message,[{'w':w,'h':h}])
					}).mouseleave(function(){
						$('#tooltip').remove();
					});

					if(valid){
						R = $("#const1").val();
						Rmin = $("#const_min1").val();
						Rmax = $("#const_max1").val();
						
						A = $("#const2").val();
						Amin = $("#const_min2").val();
						Amax = $("#const_max2").val();
						
						dE = $("#const3").val();
						dEmin = $("#const_min3").val();
						dEmax = $("#const_max3").val();
						
						T = $("#const4").val();
						Tmin = $("#const_min4").val();
						Tmax= $("#const_max4").val();
						e.data.success();
					}
				}				
				
			    function showTooltip(x, y, contents, size) {
				    var size = size || [{'h' : 25, 'w' : 204}];
					$('<div id="tooltip">' + contents + '</div>').css( {
						position: 'absolute',
						display: 'none',
						top: y + size[0].h,
						left: x + 0,
						border: '1px solid #fdd',
						padding: '2px',
						backgroundColor: '#fee',
						width: size[0].w + 'px',
						opacity: 0.80
					}).appendTo("body").fadeIn(200);
				}

				function initPlotObjects(){
					plotArray.length = 0;
					plotArray.push(new $.PlotModel({'label': 'R(dE)', 'numberOfPoints': 100, maxValue: dEmax, minValue: dEmin, 'method': function(x){
					 	var value = A*Math.exp(x/(k*T));
					 	console.log('1',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'R(A)', 'numberOfPoints': 100, maxValue: Amax, 'minValue':Amin, 'method': function(x){
						var value = x*Math.exp(dE/(k*T));
						//console.log('2',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'R(T)', 'numberOfPoints': 100, 'maxValue': Tmax, 'minValue': Tmin, 'method': function(x){
						var value =  A*Math.exp(dE/(k*x));
						//console.log('3',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'dE(R)', 'numberOfPoints': 100, 'maxValue': Rmax, 'minValue': Rmin, 'method': function(x){
						var value = k*T*Math.log(A/x);
			        	//console.log('4',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'dE(A)', 'numberOfPoints': 100, 'maxValue': Amax, 'minValue': Amin, 'method': function(x){
						var value = k*T*Math.log(x/R);
			        	//console.log('5',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'dE(T)', 'numberOfPoints': 100, 'maxValue': Tmax, 'minValue': Tmin, 'method': function(x){
						var value = k*x*Math.log(A/R);
			        	//console.log('6',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'T(dE)', 'numberOfPoints': 100, 'maxValue': dEmax, 'minValue': dEmin, 'method': function(x){
						var value = x/(k*Math.log(A/R));
			        	//console.log('7',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'T(A)', 'numberOfPoints': 100, 'maxValue': Amax, 'minValue': Amin, 'method': function(x){
						var value = dE/(k*Math.log(x/R));
			        	//console.log('8',value)
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'T(R)', 'numberOfPoints': 100, 'maxValue': Rmax, 'minValue': Rmin, 'method': function(x){
						var value = dE/(k*Math.log(A/x));
			        	//console.log('9',value)
			        	return value;
					}}));
				}

				$('#defaultValuesForm').bind('submit', {success: function(){
					$("#form").hide();
					$('#pano').removeAttr('style');
					initPlotObjects();
					drowThumbnails();
					$('.thumbnail :first').trigger('click');
				}},onSubmit);

				$('#saveDataButton').bind('click', function(){
					var min = plot.getXAxes()[0].min;
					var max = plot.getXAxes()[0].max;
					var label = currentPlot.getData(min,max)[0].label||'Error';
					var data = currentPlot.getData(min,max)[0].data.toString()||'0,0';
					
					$('#saveDataForm').html('<input type="hidden" name="lable" value="'+label+'" >'+'<input type="hidden" name="data" value="'+data+'" >');
					$('#saveDataForm').append();
					$('#saveDataForm').attr('action','/getData');
					$('#saveDataForm').submit();
					return false;
				});

				$('#newDataButton').bind('click',function(){
					$('#pano').hide();
					$('#form').show();
				})

				
			});
			</script>
			
	</body>
</html>
