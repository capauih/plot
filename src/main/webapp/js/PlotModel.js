$.extend({
	PlotModel: function(l,numberOfPoints,method){
		
		this.getData = function(x1, x2){
			var d = [];
			for (var i = 0; i <= numberOfPoints; ++i) {
	            var x = x1 + i * (x2 - x1) / numberOfPoints;
	            d.push([x, method(x)]);
	        }

	        return [
	            { label: l, data: d }
	        ];
		}
	
	}
});