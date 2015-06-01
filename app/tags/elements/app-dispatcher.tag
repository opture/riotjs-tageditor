<app-dispatcher>
  <script>
  'use strict';
    var self = this;

    //Spi functions.
    self._RiotControlApi = ['on','one','off','trigger'];


    self.RiotControl = {
      _stores: [],
      addStore: function(store) {
        this._stores.push(store);
      }
    };


    self._RiotControlApi.forEach(function(api){

      self.RiotControl[api] = function() {

        //Make an argument array.
        var args = [].slice.call(arguments);

        //Lop over the stores and trigger the events supplied.
        this._stores.forEach(function(el){
          el[api].apply(null, args);
        });
      };

    });

    self.on('mount', function(){
      //If there is no app object.
      if (!window.app){
        window.app = {};
      }

      //Register the dispatcher with the app.
      window.app.dispatcher = self.RiotControl;
      //Emit event so everyone can start working.
      var readyEvent = new Event('dispatcher-ready');
      document.dispatchEvent(readyEvent);
    });
  </script>
</app-dispatcher>