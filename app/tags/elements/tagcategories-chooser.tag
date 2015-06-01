<tagcategories-chooser>
	<select onchange="{newValueSelected}" name="selector"><option each="{category in categories}" value="{category}" >{category}</option></select>
	<script>
		'use strict';
		var self = this;
       //self.categories = opts.categories;
     	self.on('mount', function(){
    		//Register with dispatcher.
       	if (window.app.dispatcher) {
         	//If appDispatcher is ready then register
         	window.app.dispatcher.addStore(self);
       	} else {
         	//AppDispatcher not ready yet, register event to wiat for it to be ready.
         	document.addEventListener('dispatcher-ready', function(){
           		window.app.dispatcher.addStore(self);
         	});
       	}
     	});

		self.on('tagCategories-changed', function(categories){
			self.categories = categories;
		});
		self.newValueSelected = function(){
		    c.log(self.selector.value);
			self.selected = self.selector.value;
			self.trigger('change', self.selector.value);

		};
		self.setSelected = function(selectedValue){
			self.selector.value = selectedValue;
		}
		self.getSelected = function(){
			return self.selector.value;
		}
	</script>
</tagcategories-chooser>