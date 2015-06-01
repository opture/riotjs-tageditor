<store-somedata>
	<script>
	'use strict';
		var self = this;
		self.tagName = self.root.tagName.toLowerCase();
		self._data = ['Apa', 'Häst', 'Kossa'];
		self.on(self.tagName + '-add-data', function(newData){
		self._data.push(newData);
			console.log(self._data);
		});

		self.on(self.tagName + '-init', function(){
			window.app.dispatcher.trigger(self.tagName + '-collection-changed', self._data);
			console.log('some one inited med');
		});

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
	</script>
</store-somedata>