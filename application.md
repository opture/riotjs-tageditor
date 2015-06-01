This will be cleaned later.
For now its just good to keep some ideas apart.

App startup cycle.

The base app-tag creates a global variable called riotApp.
The dispatcher tag should register its dispatcher in that object. (riotApp.dispatcher)

Dispatcher.
the app-dispatcher emits a "dispatcher-ready" event on the document and not through itself.
This should be the only "global" that affects the stores.

When this happens, the stores should emit events to register
"regiter-store", and include themselves as the payload.

Event chain...

Lots of tags get mounted, some views, some stores, some model tags.
The app-base tag will mount the app-dispatcher, and when the app-dispatcher mounts...
event -> 'dispatcher-ready'
store -> 'register-store'
riotcontrol -> 'registered-with-dispatcher' on store.



<app-dispatcher>
	<script>

		var self = this;
		self._RiotControlApi = ['on','one','off','trigger'];
		self.RiotControl = {
	 		_stores: [],
	 		addStore: function(store) {
   			this._stores.push(store)
   			store.trigger('registered-with-dispatcher');
	 		}
		};

		self._RiotControlApi.forEach(function(api){
 			self.RiotControl[api] = function() {
		   	//console.log('some api shit: ' + api);
		   	var args = [].slice.call(arguments)
		   	this._stores.forEach(function(el){
		     		//console.log(api + ' on store ', el);
		       	el[api].apply(null, args)
	     		});
		 	}
		});


		self.on('mount', function(){
	 		window.appDispatcher = self.RiotControl;
		 	console.log(self.root.parentNode.tagName);
		 	var readyEvent = new Event('dispatcher-ready');

		 	document.dispatchEvent(readyEvent);
		 	self.root.parentNode._tag.trigger('dispatcherReady');
		 	self.RiotControl.addStore(self);
		});

		self.on('register-store', function(store){
			self.RiotControl.addStore(store);
		})
  </script>
</app-dispatcher>



<store-tag>
	<script>
		var self = this;

		//Register with dispatcher and remove eventlistener if there is one.
		self.registerWithDispatcher(){
			window.riotApp.trigger('register-store', self);
			window.removeEventListener('dispatcher-ready',self.registerWithDispatcher)
		};

		//On mount event.
		this.on('mount', function(){
			//Check if the riotApp is registrered.
			if (window.riotApp){
				//Register myself as a store.
				self.registerWithDispatcher();
			}else{
				//The dispatcher isnt ready just yet, listen for when its done.
				window.addEventListener('dispatcher-ready',self.registerWithDispatcher);
			}
		});

		self.on('registered-with-dispatcher', function(){
			//Finally the store is ready to do some work...
		});
	</script>
</store-tag>
