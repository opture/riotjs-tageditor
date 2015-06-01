<store-userauth>

	<script>
	/* global Firebase */
	 'use strict';
     var self = this;
     self.authData = {};
     self.tagName = self.root.tagName.toLowerCase();
     self.isAuthenticated = false;
     self.authHandler = function(err,authD){
     	if (err){
     		console.log('login failed!');
     	}else {
     		window.app.authData = authD;
     		self.authData = authD;
     		self.isAuthenticated = true;
     		window.app.dispatcher.trigger('user-authenticated', self.authData);
     	}
     };

     self.on('log-out', function(){
     	console.log('log out');
     	self.ref.unauth();
     });

     self.on('mount', function(){
     	console.log('mounted: ' + self.tagName);
      //Register with dispatcher.
      if (window.app.dispatcher) {
      	console.log('dspatcher is inited, just register.');
        //If appDispatcher is ready then register
        window.app.dispatcher.addStore(self);
      } else {
        //AppDispatcher not ready yet, register event to wiat for it to be ready.
        console.log('no dispatcher, wait for it to get ready');
        document.addEventListener('dispatcher-ready', function(){

          window.app.dispatcher.addStore(self);
        });
      }

       //Register with the appdispatcher.
       //window.app.dispatcher.addStore(self);
       //Reference to firebase.
       self.ref = new Firebase('https://riottagworkbench.firebaseio.com/tags/');
       //self.userRef;
       //If authenticated then listen for changes to the usertags data.
       self.authData = self.ref.getAuth();

       if (self.authData){
         //If authenticated create a user reference object.
         self.isAuthenticated = true;
         window.app.authData  = self.authData;
         console.log('authenticated');
         window.app.dispatcher.trigger('user-authenticated', self.authData);
       } else {
       	console.log('NOT authenticated');
       	self.ref.authWithOAuthPopup('google', self.authHandler);
       }
     });
     //Create a firebase reference.
	</script>
</store-userauth>