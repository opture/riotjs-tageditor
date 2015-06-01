
<store-usertags>

  <script>
    var self = this;
    self.tagName = self.root.tagName.toLowerCase();
    self.userTags = [];
    self.tagNames = [];

    self.onNewValues = function(collection){
            self.tagsCollection = collection;
            //Loop over the properties and get all tagnames.
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
          //Listen to changes on the collection.
          self.userRef.on("value", function(snapshot) {
            //Trigger event when something happened.
            self.onNewValues(snapshot.val())
            //window.app.dispatcher.trigger(self.tagName + '-collection-changed', snapshot.val());
          }, function (errorObject) {
            console.log("The read failed: " + errorObject.code);
          });
    }

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
      // if (!Object.keys(newTagDef.tagRefs).length){
      //   newTagDef.tagRefs = null;
      // }
      var tagRef = self.userRef.child(newTagDef.tagName);
      tagRef.set(newTagDef);
    });
  </script>
</store-usertags>