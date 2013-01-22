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
			/**	Все действи должны выполняются тогда, когда document будет загружен. 
				Поэтому, все действия выполняем на document.ready
			*/
			$(function () {
				/**	Создаем глобальные переменные
				*/
				var k = 1.6/1.38e-3,  
					R, Rmin, Rmax,
					dE, dEmin, dEmax,
					A, Amin, Amax,
					T, Tmin, Tmax; 	
				/**
					перемменая, которая будет хранить объекты PlotModel, 
					содержащие название функции, опредиление зависимости, 
					максимальное и минимальное значение аргумента
				*/
				var plotArray = [];
				/**
					Глобальная переменная содержащая текущий обрабатываемый PlotModel объект
				*/
				var currentPlot;
				/**
					Глобальная переменная содержащая объект большого графика 
				*/
				var plot;//main plot object

				/**
					Глобальная переменная содержащая название для префикса id маленьких графиков
				*/
				var thumbnail_id = 'overview';

				/**
					Глобальная переменная содержащая объект свойств для построения большого графика
					legend: опредиляет показывать легенду графика или нет
					series: опредиляет каким образом отрисовывать график (т.е lines - линия, points - точки)
					grid: опредиляет свойства координатной сетки графика. { hoverable: true} - указывает
					, что при наведении курсора мыши на график будет сгенерированно соответсвующее событие
					yaxis: опредиляет свойства оси y. { ticks: 10 } - указвает что на оси y будет 10 точек
					selection: опредиляет свойства выделения графика. { mode: "xy" } - указывает, что на графике можно будет выделять  поямоугольную область
				*/
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

				/**
					Глобальная переменная содержащая объект свойств для построения маленького графика
					legend: опредиляет показывать легенду графика или нет
					series: опредиляет каким образом отрисовывать график (т.е lines - линия, points - точки)
					grid: опредиляет свойства координатной сетки графика. { color: "#999" } - указывает
					, какого цвета будет сетка
					yaxis: опредиляет свойства оси y. { ticks: 3 } - указвает что на оси y будет 3 точек
					xaxis: опредиляет свойства оси x. { ticks: 4 } - указвает что на оси y будет 4 точек
			
				*/
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

				/**
					функция которая строит большой график и вешает обработчики на все необходимые события
					генерируемые графиком
				*/
				function drowBigPlot(){
					/**
						строит график в <div> с id=placeholder для currentPlot с свойствами optionsPano 
						и помежает в результате получееный объект в глобальную переменную plot
					*/
					plot = $.plot($('#placeholder'),currentPlot.getData(currentPlot.Xmin,currentPlot.Xmax), optionsPano);

					/**
						вешает обработчик на событие plotselected
					*/
					$("#placeholder").bind("plotselected", function (event, ranges) {
				        /**
				        	задает минимальный прямоугольник выделения, чтобы предотвратить бесконечное увеличение
				        */
				        if (ranges.xaxis.to - ranges.xaxis.from < 0.00001)
				            ranges.xaxis.to = ranges.xaxis.from + 0.00001;
				        if (ranges.yaxis.to - ranges.yaxis.from < 0.00001)
				            ranges.yaxis.to = ranges.yaxis.from + 0.00001;
				        
				        /**
				        	выполняет увеличение
				        	функция $.extend() соединяет объекты по совпрадающим полям
				        */
				        plot = $.plot($("#placeholder"), currentPlot.getData(ranges.xaxis.from, ranges.xaxis.to),
				                      $.extend(true, {}, optionsPano, {
				                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
				                          yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
				                      }));
				        
				    });

					/**
						вешает обработчик на событие plothover
					*/
					var previousPoint = null;
				    $("#placeholder").bind("plothover", function (event, pos, item) {
						/**
							проверяет находиться ли курсор над точкой
						*/
			            if (item) {
				            /**
				            	если находиться над точкой, и в прошлый момент времени курсор был над той же самой точкой, тогда ничего не делать. 
				            	Иначе: 	текущую точку за писать в переменную previousPoint
				            			удолить со страницы div c подсказкой
				            			получить координаты точни над которой находиться курсор
				            			нарисовать подсказку.
				            */
			                if (previousPoint != item.dataIndex) {
			                    previousPoint = item.dataIndex;
			                    
			                    $("#tooltip").remove();
			                    var x = item.datapoint[0].toFixed(2),
			                        y = item.datapoint[1].toFixed(2);
			                    
			                    showTooltip(item.pageX, item.pageY, item.series.label + " of " + x + " = " + y);
			                }
			            }
			            /**
			            	если курсор не над точкой, то удолить подсказку, обнулить переменную previousPoint
			            */
			            else {
			                $("#tooltip").remove();
			                previousPoint = null;            
			            }
				    });	
				}

				/*
					очищает контейнер для маленьких графиков, для всех объектов PlotModel рисует маленький график  
				*/
				function drowThumbnails(){
					$('.thumbnails').html('');
					var length = plotArray.length;
					for(var i=0; i<length; i++){
						drowLittlePlot(i,plotArray[i]);
					}
				}
				/*
					рисует маленький график для объекта PlotModel
				*/
				function drowLittlePlot(index, plotObject){
					/*состовляет id для div-холста*/
					var id = thumbnail_id + index;
					/*генерирует div-холст*/
					var container = '<div class="thumbnail"><div id="'+id+'" class="little_plot"></div></div>';
					/*кладет div-холст в контейнер для маленьких графиков*/
					$('.thumbnails').append(container)
					/*рисует график на холсте для plotObject со свойствами optionsThumbnail*/
					$.plot($('#'+id), plotObject.getData(plotObject.Xmin,plotObject.Xmax), optionsThumbnail);
					/*вешает обработчик на событие click для холста*/
					$('#'+id).parent().bind('click',function(){
						/*в случае клика на холст удоляется рамка со всех холстов*/
						$('.selected').removeClass('selected');
						/*добавляется рамка данному холсту*/
						$(this).addClass('selected');
						/*в глобальную переменную currentPlot записывается PlotModel объект с текущим индексом*/
						currentPlot = plotArray[index];
						/*рисуется большой график*/
						drowBigPlot();
					});
					
				}
				/*
					Обрабатывает форму с данными
				*/
				function onSubmit(e) {
					/*предотвращает стандартное развитие события*/
					e.preventDefault();
					/*создает регулярное выражение для определения числа*/
					var pattern = /(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?/;

					/*
						функция которая позваляет сохранить текстовые данные value в тег object под именем key
					*/
					function putData(object, key, value){
						/*проверяем созданно ли уже хранилище для ключа key*/
						var data = $(object).attr(key) || '';
						if(data != ''){
							data = JSON.parse(decodeURI(data));
						}else {
							/*Если не созданно, то создаем его*/
							data =[];
						}
						/*добавляем в хранилище данные  value*/
						data.push(value);
						$(object).attr(key,encodeURI(JSON.stringify(data))); 
					}
					/*
						функция которая позволяет получить текстовые данные из тега bject по ключу key
					*/
					function getData(object, key){
						var data = $(object).attr(key) || '';
						if(data != ''){
							data = JSON.parse(decodeURI(data));
						}else {
							data =[];
						}
						return data;
					}
					/*очищаем оформление формы, создаем переменную valid*/
					var valid = true;
					$('.valid').removeClass();
					$('.unvalid').removeClass();
					$('#form input').removeAttr('data-errors');

					/*
						первый этап проверки формы
						Для каждого поля ввода данных формы проверяем соответствуют ли данные числовому формату. 
						Если соответствует - то помечаем поле ввода данных как valid, иначе как unvalid и в переменную valid записываем false
					*/
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
					/*
						второй этап проверки формы
						в наборе полей ввода данных находим поля для ввода максимального значения
						и проверяем больше ли это значение чем соответсвующее ему минимальное значение.
						Если правда, тогда помечаем поле как valid. Иначе - помечаем поле как unvalid и устонавливаем переменную valid в false.
						
					*/
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
					/*
						вешает обработчик на событие mouseover который показывает 
						сообщение подсказку при навидении на некоректно заполненную область ввода данных
					*/			
					$('.unvalid').mouseover(function(e){
						/*опредиляем координаты и размеры поля ввода */
						var x = $(this).offset().left,
							y = $(this).offset().top,
							w = $(this)[0].offsetWidth,
							h = $(this)[0].offsetHeight; 
						/*получаем массив ошибок*/
						var errors = getData(this,"data-errors");
						/*генеоиоуем подсказку*/
						var message='<ul>';
						$.each(errors, function(key, value) {
							message+='<li>'+value+'</li>'; 
						});
						message+='</ul>';
						/*выводи подсказку*/
						showTooltip(x,y,message,[{'w':w,'h':h}])
						/*вешаем обработчик на событие mouseleave*/
					}).mouseleave(function(){
						/*когда курсор уходит с неправильно заполненного поля, обработчик удоляет подсказку*/
						$('#tooltip').remove();
					});

					/*
						если переменная valid == true, тогда записываем значение поллей ввода в соответствующие им глобальные переменные и выполняем success() 
					*/
					if(valid){
						R = new Number($("#const1").val());
						Rmin = new Number($("#const_min1").val());
						Rmax = new Number($("#const_max1").val());
						
						A = new Number($("#const2").val());
						Amin = new Number($("#const_min2").val());
						Amax = new Number($("#const_max2").val());
						
						dE = new Number($("#const3").val());
						dEmin = new Number($("#const_min3").val());
						dEmax = new Number($("#const_max3").val());
						
						T = new Number($("#const4").val());
						Tmin = new Number($("#const_min4").val());
						Tmax= new Number($("#const_max4").val());
						
						e.data.success();
					}
				}				

				/*
					функция которая рисует подсказку contents размером size в координатах x,y
				*/
			    function showTooltip(x, y, contents, size) {
				    /*если size не был передан, тогда присваеваем ему значение по умолчанию*/
				    var size = size || [{'h' : 25, 'w' : 204}];
				    /*создаем одласть для отображения подсказки, задаем все необходимые параметры*/
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
						/*добавляем контейнер с сообщением на страницу и показываем его пользователю за 200 милисекунд*/
					}).appendTo("body").fadeIn(200);
				}
				/*
					Иницилизирует графики
				*/
				function initPlotObjects(){
					/*очищает масив с графиками*/
					plotArray.length = 0;
					/*	
						создаем объект PlotModel, указываем правило расчта значение функции по аргументу,
						диапазаон изменения аргумента, название функции
					*/
					plotArray.push(new $.PlotModel({'label': 'R(dE)', 'numberOfPoints': 100, 'maxValue': dEmax, 'minValue': dEmin, 'method': function(x){
					 	var value = A*Math.exp(x/(k*T));
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'R(A)', 'numberOfPoints': 100, 'maxValue': Amax, 'minValue':Amin, 'method': function(x){
						var value = x*Math.exp(dE/(k*T));
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'R(T)', 'numberOfPoints': 100, 'maxValue': Tmax, 'minValue': Tmin, 'method': function(x){
						var value =  A*Math.exp(dE/(k*x));
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'dE(R)', 'numberOfPoints': 100, 'maxValue': Rmax, 'minValue': Rmin, 'method': function(x){
						var value = k*T*Math.log(A/x);
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'dE(A)', 'numberOfPoints': 100, 'maxValue': Amax, 'minValue': Amin, 'method': function(x){
						var value = k*T*Math.log(x/R);
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'dE(T)', 'numberOfPoints': 100, 'maxValue': Tmax, 'minValue': Tmin, 'method': function(x){
						var value = k*x*Math.log(A/R);
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'T(dE)', 'numberOfPoints': 100, 'maxValue': dEmax, 'minValue': dEmin, 'method': function(x){
						var value = x/(k*Math.log(A/R));
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'T(A)', 'numberOfPoints': 100, 'maxValue': Amax, 'minValue': Amin, 'method': function(x){
						var value = dE/(k*Math.log(x/R));
			        	return value;
					}}));
					plotArray.push(new $.PlotModel({'label': 'T(R)', 'numberOfPoints': 100, 'maxValue': Rmax, 'minValue': Rmin, 'method': function(x){
						var value = dE/(k*Math.log(A/x));
			        	return value;
					}}));
				}
				/*
					вешаем обработчик на нажатие кнопки на форме с данными. 
					Передаем в обработчик callback который должен выполнить обработчик в случае правильности ввода всех данных
				*/
				$('#defaultValuesForm').bind('submit', 
						{success: function(){
							/*прячет форму с данными*/
							$("#form").hide();
							/*показывает область для постраения графиков*/
							$('#pano').removeAttr('style');
							/*иницилизирует plotArray объектами PlotModel*/
							initPlotObjects();
							/*рисует маленькие графики*/
							drowThumbnails();
							/*гкнерирует событие click на первый маленький график, в результате чего строиться большой график*/
							$('.thumbnail :first').trigger('click');
						}
				},onSubmit);

				/*
					вешаем обработчик на событие click для кнопки SaveData!
				*/
				$('#saveDataButton').bind('click', function(){
					/*получаем мин и макс значения аргумента графика*/
					var min = plot.getXAxes()[0].min;
					var max = plot.getXAxes()[0].max;
					/*получаем название графика*/
					var label = currentPlot.getData(min,max)[0].label||'Error';
					/*получаем точки графика в виде строки*/
					var data = currentPlot.getData(min,max)[0].data.toString()||'0,0';
					/*создаем поля в форме для отправки на сервер точак и названия графика*/
					$('#saveDataForm').html('<input type="hidden" name="lable" value="'+label+'" >'+'<input type="hidden" name="data" value="'+data+'" >');
					/*добавляем адрес, на который должен посылаться запрос для формирования .xls файла*/
					$('#saveDataForm').attr('action','/getData');
					/*посылаем запрос на сервер*/
					$('#saveDataForm').submit();
					return false;
				});
				/*
					вешаем обработчик на кнопку Specify New Data!
				*/
				$('#newDataButton').bind('click',function(){
					/*прячем область с графиками*/
					$('#pano').hide();
					/*показываем форму для заполнения данных*/
					$('#form').show();
				})

				
			});
			</script>
			
	</body>
</html>
