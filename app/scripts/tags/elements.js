riot.tag('ace-editor', ' <div name="editorContainer" style="position:absolute;top:0;lefT:0;right:0;bottom:0;" show="{opts.show}"></div>', function(opts) {
	
		'use strict';
		var self = this;
		self.displayEditor = true;
		self.editorMode = opts.mode || 'html';

		self.on('mount', function(){
			console.log('editormode', self.editorMode);
      	self.editor = ace.edit(self.editorContainer);
      	self.editor.setTheme('ace/theme/monokai');
      	self.editor.getSession().setMode('ace/mode/' + self.editorMode);
      	self.editor.setValue(opts.content, -1);
      	self.editor.setOption('showPrintMargin', false);

      	self.root.getValue = function(){
   	 		return self.editor.getValue();
      	};

      	self.root.setValue = function(content, pos){
   	 		return self.editor.getValue(content, pos);
      	};
      	if (opts.onready){
      		opts.onready(self.editor);
      	}
		});

	
});

riot.tag('app-dispatcher', '', function(opts) {
  'use strict';
    var self = this;
    self._RiotControlApi = ['on','one','off','trigger'];


    self.RiotControl = {
      _stores: [],
      addStore: function(store) {
        this._stores.push(store);
      }
    };


    self._RiotControlApi.forEach(function(api){

      self.RiotControl[api] = function() {
        var args = [].slice.call(arguments);
        this._stores.forEach(function(el){
          el[api].apply(null, args);
        });
      };

    });

    self.on('mount', function(){
      if (!window.app){
        window.app = {};
      }
      window.app.dispatcher = self.RiotControl;
      var readyEvent = new Event('dispatcher-ready');
      document.dispatchEvent(readyEvent);
    });
  
});
riot.tag('insignia-tag-description-with-references', '<div each="{tag, i in tags}"><h1 if="{i==1}">References</h1><insignia-tag-description tag="{tag}"></insignia-tag-description></div>', function(opts) {
    this.tags = opts.tags;

});
riot.tag('insignia-tag-description', '<h2>{tag.tagName} - <span>{tag.tagCategory}</span></h2><h3>Tag Definition</h3><code><pre>{tag.tagDef}</pre></code><h3>Tag Css</h3><code><pre>{tag.tagStyle}</pre></code><h3>Tag Options</h3><code><pre>{tag.tagOpts}</pre></code>', function(opts) {
    this.tag = opts.tag;

});

riot.tag('store-customtags', '', function(opts) {


});
riot.tag('store-somedata', '', function(opts) {
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
			if (window.app.dispatcher) {
			  window.app.dispatcher.addStore(self);
			} else {
			  document.addEventListener('dispatcher-ready', function(){
			    window.app.dispatcher.addStore(self);
			  });
			}

		});
	
});
riot.tag('store-tagcategories', '', function(opts) {
	'use strict';
    var self = this;
    self.tagName = self.root.tagName.toLowerCase();
    self.categories = [];


  	self.on('mount', function(){
    	if (window.app.dispatcher) {
      	window.app.dispatcher.addStore(self);
      	self.tagListener();
    	} else {
      	document.addEventListener('dispatcher-ready', function(){
        		window.app.dispatcher.addStore(self);
        		self.tagListener();
      	});
    	}
  	});

    self.onNewValues = function(collection){
            self.categories = [];
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
          self.catRef.on('value', function(snapshot) {
            self.onNewValues(snapshot.val());
          }, function (errorObject) {
            console.log('The read failed: ' + errorObject.code);
          });
    };

 
});

riot.tag('store-userauth', '', function(opts) {
	
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
      if (window.app.dispatcher) {
      	console.log('dspatcher is inited, just register.');
        window.app.dispatcher.addStore(self);
      } else {
        console.log('no dispatcher, wait for it to get ready');
        document.addEventListener('dispatcher-ready', function(){

          window.app.dispatcher.addStore(self);
        });
      }
       self.ref = new Firebase('https://riottagworkbench.firebaseio.com/tags/');
       self.authData = self.ref.getAuth();

       if (self.authData){
         self.isAuthenticated = true;
         window.app.authData  = self.authData;
         console.log('authenticated');
         window.app.dispatcher.trigger('user-authenticated', self.authData);
       } else {
       	console.log('NOT authenticated');
       	self.ref.authWithOAuthPopup('google', self.authHandler);
       }
     });
	
});

riot.tag('store-usertags', '', function(opts) {
    var self = this;
    self.tagName = self.root.tagName.toLowerCase();
    self.userTags = [];
    self.tagNames = [];

    self.onNewValues = function(collection){
            self.tagsCollection = collection;
            self.tagNames= ['- My Tags -'];
            for (var property in collection) {
              if (collection.hasOwnProperty(property)) {
                self.tagNames.push(property);
              }
            }
            window.tagsCollection = self.tagsCollection;
            window.app.dispatcher.trigger('tagnames-changed', self.tagNames);
            window.app.dispatcher.trigger('usertags-changed', self.tagsCollection);

            document.querySelector('riot-tag-workbench')._tag.trigger('newTags');
    };

    self.tagListener = function(authData){

        console.log('Register and listen for tags changes. Cause user is authenticated');
          self.userRef = new Firebase('https://riottagworkbench.firebaseio.com/tags/usersTags/' + authData.uid);
          self.userRef.on("value", function(snapshot) {
            self.onNewValues(snapshot.val())
          }, function (errorObject) {
            console.log("The read failed: " + errorObject.code);
          });
    }

    self.on('mount', function(){
      if (window.app.dispatcher) {
        window.app.dispatcher.addStore(self);
      } else {
        document.addEventListener('dispatcher-ready', function(){
          window.app.dispatcher.addStore(self);
        });
      }
      if (window.app.authData){
        self.tagListener(window.app.authData);
      }else{
        self.one('user-authenticated', function(authData){
          self.tagListener(authData);
        });
      }
    });

    self.on('add-new-tag', function(newTagDef){
      console.log('actually storing: ', newTagDef);
      var tagRef = self.userRef.child(newTagDef.tagName);
      tagRef.set(newTagDef);
    });
  
});
riot.tag('tagcategories-chooser', '<select onchange="{newValueSelected}" name="selector"><option each="{category in categories}" value="{category}" >{category}</option></select>', function(opts) {
		'use strict';
		var self = this;
     	self.on('mount', function(){
       	if (window.app.dispatcher) {
         	window.app.dispatcher.addStore(self);
       	} else {
         	document.addEventListener('dispatcher-ready', function(){
           		window.app.dispatcher.addStore(self);
         	});
       	}
     	});

		self.on('tagCategories-changed', function(categories){
			self.categories = categories;
			self.selected = self.selector.value || self.categories[0];
		});
		self.newValueSelected = function(){
		    c.log(self.selector.value);
			self.selected = self.selector.value;
			self.trigger('change', self.selector.value);
			if (opts.onselected){
				opts.onselected(self.selector.value);
			}

		};
		self.setSelected = function(selectedValue){
			self.selector.value = selectedValue;
			if (opts.onselected){
				opts.onselected(self.selector.value);
			}
		}
		self.getSelected = function(){
			return self.selector.value;
		}
	
});
