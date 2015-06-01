<store-tagcategories>
	<script>
	'use strict';
    var self = this;
    self.tagName = self.root.tagName.toLowerCase();
    self.categories = [];


  	self.on('mount', function(){
 		//Register with dispatcher.
    	if (window.app.dispatcher) {
      	//If appDispatcher is ready then register
      	window.app.dispatcher.addStore(self);
      	self.tagListener();
    	} else {
      	//AppDispatcher not ready yet, register event to wiat for it to be ready.
      	document.addEventListener('dispatcher-ready', function(){
        		window.app.dispatcher.addStore(self);
        		self.tagListener();
      	});
    	}
  	});

    self.onNewValues = function(collection){
            self.categories = [];
            //Loop over the properties and get all tagnames.
            for (var property in collection) {
              if (collection.hasOwnProperty(property)) {
                self.categories.push(property);
              }
            }
            window.app.dispatcher.trigger('tagCategories-changed', self.categories);
    };


    self.tagListener = function(){

        console.log('Register and listen for tags changes. Cause user is authenticated');
          self.catRef = new Firebase('https://riottagworkbench.firebaseio.com/tagCategories');
          //Listen to changes on the collection.
          self.catRef.on('value', function(snapshot) {
            //Trigger event when something happened.
            self.onNewValues(snapshot.val());
            //window.app.dispatcher.trigger(self.tagName + '-collection-changed', snapshot.val());
          }, function (errorObject) {
            console.log('The read failed: ' + errorObject.code);
          });
    };

 </script>
</store-tagcategories>
