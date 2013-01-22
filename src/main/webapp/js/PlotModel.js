$.extend({
	PlotModel: function(object){
		this.getData = function(x1, x2){
			var d = [];
			for (var i = 0; i <= object.numberOfPoints; ++i) {
	            var x = x1 + i * (x2 - x1) / object.numberOfPoints;
	            d.push([x, object.method(x)]);
	        }

	        return [
	            { label: object.label, data: d }
	        ];
		}
		
		this.Xmin = object.minValue;
		
		this.Xmax = object.maxValue;
		
	
	}
});