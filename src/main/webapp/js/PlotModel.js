$.extend({
	PlotModel: function(l,precision,method){
		
		this.getData = function(x1, x2){
			var d = [];
			for (var i = 0; i <= precision; ++i) {
	            var x = x1 + i * (x2 - x1) / precision;
	            d.push([x, method(x)]);
	        }

	        return [
	            { label: l, data: d }
	        ];
		}
	
	}
});