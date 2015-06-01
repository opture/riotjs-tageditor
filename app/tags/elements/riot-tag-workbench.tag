<riot-tag-workbench>
  <app-dispatcher></app-dispatcher>
  <store-somedata></store-somedata>
  <store-usertags></store-usertags>
  <store-userauth id="userAuth"></store-userauth>

    <div style="display:flex;flex-flow:row nowrap">
      <div id="iphone4">&nbsp;</div>
      <div id="iphone5"></div>
      <div id="ipad"></div>
      <div id="console"></div>
    </div>
    <div id="container">
      <div id="editors">

        <div id="tagDefContainer" class="editorContainers" show={showTagEditor}></div>
        <div id="tagStyleContainer" class="editorContainers" show={showStyleEditor}></div>
        <div id="tagOptsContainer" class="editorContainers" show={showJsonEditor}></div>

      </div>
      <div id="toolbar">
        <select onchange="{selectTag}" name="tagSelector"><option each={tagname in tagNames}>{tagname}</option></select>
        <button onclick="{ renderTag }" type="button" title="Compile and display on screen">
          <img src="../images/cycle.svg" style="height:1rem;padding:0;margin:0;" />
        </button>
        <button onclick="{ exportTag }" type="button" title="Save">
          <img src="../images/save.svg" style="height:1rem;padding:0;margin:0;" />
        </button>
        <button onclick="{ toggleTagEditor }" type="button" title="{ showTagEditor ? 'Hide tageditor' : 'Show tageditor'}">
          <img src="../images/tag.svg" />
        </button>
        <button onclick="{ toggleStyleEditor }" type="button" title="{ showStyleEditor ? 'Hide styles' : 'Show styles'}">
          <img src="../images/news.svg" />
        </button>
        <button onclick="{ toggleJsonEditor }" type="button" title="{ showJsonEditor ? 'Hide tag options' : 'Show tag options'}">
          <img src="../images/database.svg" />
        </button>
        <button onclick="{ clearAll }" type="button" title="Clear all code from the editors.">
          <img src="../images/cross.svg" />
        </button>
        <select name="referenceTags"><option each={tagname in tagNames}>{tagname}</option></select>
        <button onclick="{ addTagReferences }" type="button" title="Include other tags.">
          <img src="../images/plus.svg" />
        </button>
        <button onclick="{ logOut }" type="button" title="Log out.">
          <img src="../images/cross.svg" />
        </button>
      </div>
    </div>
    <script>
    var self = this;
    self.showTagEditor = true;
    self.showStyleEditor = true;
    self.showJsonEditor = true;

    this.getTagNames = function(){
      $.get('https://riottagworkbench.firebaseio.com/tags.json', function(data){
        console.log(data);
      });
    }
    self.clearAll = function(){
      //Clear all the editors.
      self.tagEditor.setValue('', -1);
      self.jsonEditor.setValue('', -1);
      self.styleEditor.setValue('', -1);

      //Set the selected tag to none.
      self.tagSelector.selectedIndex = 0;
    };

    self.currentTagReferences = {};

    self.logOut = function(){
      window.app.dispatcher.trigger('log-out', null);
    }

    self.addTagReferences = function(tagName){
      var refTagOpts = self.tagCollection[self.referenceTags.value];
      var refTag = riot.compile(refTagOpts.tagDef);
      self.currentTagReferences[refTagOpts.tagName] = '';
      console.log(self.currentTagReferences);
    }

    /** Loops over the referenced tags and compiles all of them.
      */
    self.compileReferences = function(){
      console.log('compile references');
      //Compiles all the references for the selected tag.
      //Loop over the keys in the tagrefs object, this is to avoid firebase issue with arrays.
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {
          c.log('compile ref: ' + property);
          //Get the tag from the tags collection.
          opts = self.tagCollection[property];

          //Compile the tag.
          riot.compile(opts.tagDef);

          //
        }
      }
    }
    self.mountReferences = function(){
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {

          opts = self.tagCollection[property];

          var nestedTagsList = document.getElementsByTagName(opts.tagName);

          for (var x=0; x<nestedTagsList.length;x++){
            //nestedTagsList[x]._tag.unmount(true);
            //nestedTagsList[x]._tag.opts = opts.tagOpts;
          }
          //riot.mount(opts.tagName, opts.tagOpts);
        }
      }
    }
    /** Loops over the referenced tags and concatenates a string with all the styling for the tags.
      * @return {string} - String containing all the css styles for all referenced tags.
      */
    self.getReferencedStyles = function(){
      var concatenatedStyles = '';
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {

          opts = self.tagCollection[property];

          //Compile the tag.
          concatenatedStyles += opts.tagStyle;
        }
      }
      return concatenatedStyles;
    }
    self.renderTag = function(e){
      e.preventDefault();

      //Ref to tagdefintion element.
      var tagSource = this.tagDef;

      //Ref to tagOptions element.
      var tagOptions = this.tagOpts;

      //Ref to tagStyle element.
      var tagStyle = this.tagStyle;

      //Object to hold the options for the tag.
      var tagOptionsObject = {};
      var setOptions = false;

      //Parse the tagname.
      var tagName = self.tagEditor.getValue().substring(self.tagEditor.getValue().indexOf('<')+1, self.tagEditor.getValue().indexOf('>'));

      self.currentTagReferences = {}; //reset the references.
      self.createReferences(tagName, self.tagEditor.getValue());

      //Consider it to be an object and parse it to javascript.
      var jsonValue  = self.jsonEditor.getValue();
      if (jsonValue){
        tagOptionsObject = JSON.parse(jsonValue);
        setOptions = true;
      }

      //Compile the references
      self.compileReferences();

      //Compile the tag.
      var newTag = riot.compile(self.tagEditor.getValue());



      //Create element and append to view.
      var newTagEl = document.createElement(tagName);
      //this.workbench.innerHTML = '';
      //this.workbench.appendChild(newTagEl);
      this.iphone4.innerHTML = '';
      this.iphone5.innerHTML = '';
      this.ipad.innerHTML = '';

      this.iphone4.appendChild(document.createElement(tagName));
      this.iphone5.appendChild(document.createElement(tagName));
      this.ipad.appendChild(document.createElement(tagName));
      //Inject style.
      var styleTags = this.root.getElementsByTagName('style');
      if (styleTags.length > 0) {
        this.root.removeChild(styleTags[0]);
      }

      //Inject the style in this tag. (Scoped to this element, so the user is able to change the look of the editors also...)
      this.root.insertAdjacentHTML('afterbegin', '<style scoped>' + self.getReferencedStyles() +  self.styleEditor.getValue() + '</style>');

      //Mount the tag.
      if (setOptions){
        riot.mount(tagName, tagOptionsObject);
      }else{
        riot.mount(tagName);
      }
      //self.mountReferences();

    }
    self.storeTag = function(uid){

      var tagName = self.tagEditor.getValue().substring(self.tagEditor.getValue().indexOf('<')+1, self.tagEditor.getValue().indexOf('>'));
      self.createReferences(tagName, self.tagEditor.getValue());
      if (confirm('This will overwrite previously saved tags\nwith the same name: ' + tagName + '\n\nAre you sure?')){
        var exportObject = {
          tagName: tagName,
          tagDef: self.tagEditor.getValue(),
          tagOpts: self.jsonEditor.getValue(),
          tagStyle: self.styleEditor.getValue(),
          tagRefs: self.currentTagReferences || {}
        }
        console.log(exportObject);

        window.app.dispatcher.trigger('add-new-tag', exportObject);

      }
    };
    self.createReferences = function(tagName, tagHtml){
      //Loop over the current html and get the tagnames from all the tags.


      //Create a fakeDiv to find possible references to tags.
      var fakeDiv = document.createElement('div');

      fakeDiv.insertAdjacentHTML('afterbegin', tagHtml);

      //Loop over all the currently loaded customtags and create references to them if they exist in the tag.
      self.tagNames.forEach(function(customTagName){

        //Find the tag in the html and add it to references.
        var customElementList = fakeDiv.getElementsByTagName(customTagName);
        //If one or more exist and its not the current tag, then add reference.
        if (customElementList.length && customTagName !== tagName){
          self.currentTagReferences[customTagName] = '';
          //Make a recursive calll and test for references in this tag.
          opts = self.tagCollection[customTagName];
          self.createReferences(opts.tagName, opts.tagDef);
        }

      });
    }

    exportTag(e){

      var authData = self.userAuth._tag.authData;
      if (authData){
        //Store to the users id.

        self.storeTag(authData.uid);
      }else{
        //Make the user login.
        ref.authWithOAuthPopup("google", function(error, authData) {
          if (error) {
            console.log("Login Failed!", error);
          } else {
            console.log("Authenticated successfully with payload:", authData);
            userRef = new Firebase('https://riottagworkbench.firebaseio.com/tags/usersTags/' + authData.uid);
            self.storeTag(authData.uid);
          }
        });
      }
    };


    selectTag(e){
      console.log(e.target.value);
      opts = self.tagCollection[e.target.value];
      opts = opts || {};
      //Editors dont get their values set if they are hidden.
      //Needs improvement, but until then, just show all the editors so their values get set.
      self.showTagEditor = true;
      self.showStyleEditor = true;
      self.showJsonEditor = true;

      //Set the editors values from store.
      //self.tagCodeEditor._tag.trigger('set-content',  opts.tagDef ? opts.tagDef : '' );
      self.tagEditor.setValue(opts.tagDef ? opts.tagDef : '', -1);
      self.jsonEditor.setValue(opts.tagOpts ? opts.tagOpts : '', -1);
      self.styleEditor.setValue(opts.tagStyle ? opts.tagStyle : '', -1);
      self.currentTagReferences = opts.tagRefs;
      console.log('references');
      console.log(self.currentTagReferences);
      console.log(opts.tagRefs);

      self.renderTag(e);
    }

    //Display or hide the tageditor
    toggleTagEditor(e){
      self.showTagEditor = !self.showTagEditor;
    };

    //Display or hide the styles editor
    toggleStyleEditor(e){
      self.showStyleEditor = !self.showStyleEditor;
    };

    //Display or hide the moch data editor.
    toggleJsonEditor(e){
      self.showJsonEditor = !self.showJsonEditor;
    }
    document.addEventListener('dispatcher-ready', function(){
      window.app.dispatcher.addStore(self);
      console.log('dispatcherReady');
      self.on('tagnames-changed', function(tagNames){
        console.log('tagnames changed');
        self.tagNames = tagNames;
        self.update();
      });
      self.on('usertags-changed', function(tagsCollection){
        self.tagCollection = tagsCollection;
        self.update();
      });
    });

    self.on('store-userauth-collection-changed', function(){
      console.log('data changed');
    });




    this.on('mount', function(){
      self.tagEditor = ace.edit("tagDefContainer");
      self.tagEditor.setTheme("ace/theme/monokai");
      self.tagEditor.getSession().setMode("ace/mode/html");
      self.tagEditor.setValue(opts.tagDef);
      self.tagEditor.setOption("showPrintMargin", false);

      self.jsonEditor = ace.edit("tagOptsContainer");
      self.jsonEditor.setTheme("ace/theme/monokai");
      self.jsonEditor.getSession().setMode("ace/mode/json");
      self.jsonEditor.setOption("showPrintMargin", false);
      self.jsonEditor.setValue(opts.tagOpts);

      self.styleEditor = ace.edit("tagStyleContainer");
      self.styleEditor.setTheme("ace/theme/monokai");
      self.styleEditor.getSession().setMode("ace/mode/css");
      self.styleEditor.setOption("showPrintMargin", false);
      self.styleEditor.setValue(opts.tagStyle);

      self.update();

    });
    </script>
</riot-tag-workbench>