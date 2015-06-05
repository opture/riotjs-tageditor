<riot-tag-workbench>
  <app-dispatcher></app-dispatcher>
  <store-somedata></store-somedata>
  <store-usertags></store-usertags>
  <store-tagcategories></store-tagcategories>
  <store-userauth id="userAuth"></store-userauth>

    <div style="display:flex;flex-flow:row nowrap">
      <!-- <div id="iphone4">&nbsp;</div> -->
      <!-- <div id="iphone5"></div> -->
      <div id="ipad"></div>
      <div id="console"></div>
    </div>
    <div id="container">
      <div id="editors">
        <ace-editor name="tagEditor" style="position:relative;" onready="{setTagDefinitionValue}" class="editorContainers" mode="html" show={showTagEditor}>
        </ace-editor>
        <ace-editor name="jsonEditor" style="position:relative;" onready="{setTagStyleValue}" class="editorContainers" mode="css" show={showStyleEditor}>
        </ace-editor>
        <ace-editor name="styleEditor" style="position:relative;" onready="{setTagOptionsValue}" class="editorContainers" mode="json" show={showJsonEditor}>
        </ace-editor>
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
        <tagcategories-chooser name="tagCategories" onselected="{setTagCategory}"></tagcategories-chooser>
        <button onclick="{ downloadTag }" type="button" title="Download tag">
          <img src="../images/download.svg" />
        </button>
        <button onclick="{ showHelp }" type="button" title="Help">
          <img src="../images/help-with-circle.svg" />
        </button>
      </div>
    </div>
    <script>
    'use strict';
    var self = this;
    self.showTagEditor = true;
    self.showStyleEditor = true;
    self.showJsonEditor = true;

    // this.getTagNames = function(){
    //   $.get('https://riottagworkbench.firebaseio.com/tags.json', function(data){
    //     console.log(data);
    //   });
    // }
    self.setTagCategory = function(category){
      console.log('callback on category change');
      self.tagCategory = category;
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
      //Fetch the description for the current tag.
      var refTagOpts = self.tagCollection[self.referenceTags.value];

      //Create references
      self.createReferences(refTagOpts.tagName, refTagOpts.tagDef);
      console.log('tagrefs',self.currentTagReferences);

      //Create elements that we can use to render the document.
      var exportContainer = document.createElement('div');

      //Append styling to the tag.
      var styleTag = document.createElement('style');
      styleTag.innerHTML =  self.tagCollection['insignia-tag-description'].tagStyle;

      //Create element to hold the data.
      var tagDescriptionElement = document.createElement('insignia-tag-description-with-references');

      //The style is added.
      exportContainer.appendChild(styleTag);

      //Add the requested element first.
      var tagsToDisplay = [];
      tagsToDisplay.push(refTagOpts);




      // //Loop over the references and append to a long long string.
      // for (var x = 0; x<self.currentTagReferences.length;x++){
      //   var opts = self.tagCollection[currentTagReferences[x]];

      // }

      //Loop over the keys in the tagrefs object, this is to avoid firebase issue with arrays.
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {
          //Get the tag from the tags collection.
          opts = self.tagCollection[property];
          tagsToDisplay.push(opts);

        }
      }

      //Add the description for the requested element.
      exportContainer.appendChild(tagDescriptionElement);

      document.body.appendChild(exportContainer);
      var THEtag = riot.mount('insignia-tag-description-with-references',{tags:tagsToDisplay} );




      var divText = exportContainer.outerHTML;
      var myWindow = window.open('','','width=900,height=700');
      var doc = myWindow.document;
      doc.open();
      doc.write(divText);
      doc.close();
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

          //Concatenate styles.
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
      //this.iphone4.innerHTML = '';
      //this.iphone5.innerHTML = '';
      this.ipad.innerHTML = '';

      //this.iphone4.appendChild(document.createElement(tagName));
      //this.iphone5.appendChild(document.createElement(tagName));
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
      console.log(self.tagCategory);
      var tagDefVal = self.tagEditor.getValue();
      //Get the name as the name between opening and closing first tag.
      var tagName = tagDefVal.substring(tagDefVal.indexOf('<')+1, tagDefVal.indexOf('>'));
      //Find and create a list of references for the tagItem.
      self.createReferences(tagName, tagDefVal);

      //if (confirm('This will overwrite previously saved tags\nwith the same name: ' + tagName + '\n\nAre you sure?')){
        var exportObject = {
          tagName: tagName,
          tagDef: tagDefVal,
          tagOpts: self.jsonEditor.getValue(),
          tagStyle: self.styleEditor.getValue(),
          tagRefs: self.currentTagReferences || {},
          tagCategory: self.tagCategory
        }

        //Call and let the store handle the backend.
        window.app.dispatcher.trigger('add-new-tag', exportObject);

      //}
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
    downloadTag(e){
      var exportDefintions = '';
      var exportStyle = '';
      var tagDefVal = self.tagEditor.getValue();


      //Get the name as the name between opening and closing first tag.
      var tagName = tagDefVal.substring(tagDefVal.indexOf('<')+1, tagDefVal.indexOf('>'));
      //Create references
      self.createReferences(tagName, tagDefVal);
      console.log('tagrefs',self.currentTagReferences);

      // //Loop over the references and append to a long long string.
      // for (var x = 0; x<self.currentTagReferences.length;x++){
      //   var opts = self.tagCollection[currentTagReferences[x]];

      // }

      //Loop over the keys in the tagrefs object, this is to avoid firebase issue with arrays.
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {
          //Get the tag from the tags collection.
          opts = self.tagCollection[property];

          //Compile the tag.
          exportDefintions += '\n\<script type="riot\/tag"\>' + opts.tagDef + '\<\/script\>';
          exportStyle += '\n' + opts.tagStyle;

        }
      }

      exportDefintions += '\<script type=\"riot/tag\"\>' + tagDefVal + '\<\/script\>';
      exportStyle += '\n' + self.styleEditor.getValue();
        // var exportObject = {
        //   tagName: tagName,
        //   tagDef: tagDefVal,
        //   tagOpts: self.jsonEditor.getValue(),
        //   tagStyle: self.styleEditor.getValue(),
        //   tagRefs: self.currentTagReferences || {},
        //   tagCategory: self.tagCategory
        // };
        var exportContainer = document.createElement('div');
        var codeTag = document.createElement('code');
        var preTag =  document.createElement('pre');
        var stringTOExport = window.createExportHTMLFromTag(tagName, exportDefintions, exportStyle, self.jsonEditor.getValue());
        console.log(stringTOExport);
        preTag.innerText = stringTOExport;
        codeTag.appendChild(preTag);
        exportContainer.appendChild(codeTag);
      var divText = exportContainer.outerHTML;
      var myWindow = window.open('','','width=900,height=700');
      var doc = myWindow.document;
      doc.open();
      doc.write(divText);
      doc.close();



    };

    self.selectTag = function(e){
      console.log(e.target.value);
          var tagDefVal = self.tagEditor.getValue();
          //Get the name as the name between opening and closing first tag.
          var tagName = tagDefVal.substring(tagDefVal.indexOf('<')+1, tagDefVal.indexOf('>'));

      if (confirm('Click OK to save ' + tagName + ' in its current state.\n\nOr click cancel to discard the changes.')){

          //Find and create a list of references for the tagItem.
          self.createReferences(tagName, tagDefVal);

        var exportObject = {
          tagName: tagName,
          tagDef: tagDefVal,
          tagOpts: self.jsonEditor.getValue(),
          tagStyle: self.styleEditor.getValue(),
          tagRefs: self.currentTagReferences || {},
          tagCategory: self.tagCategory
        }

        //Call and let the store handle the backend.
        window.app.dispatcher.trigger('add-new-tag', exportObject);

      }

      var opts = self.tagCollection[e.target.value];
      opts = opts || {};
      //Editors dont get their values set if they are hidden.
      //Needs improvement, but until then, just show all the editors so their values get set.
      self.showTagEditor = true;
      self.showStyleEditor = true;
      self.showJsonEditor = true;

      //Set the editors values from store.
      //self.tagCodeEditor._tag.trigger('set-content',  opts.tagDef ? opts.tagDef : '' );
      // self.currentTagDefinition = opts.tagDef;
      // self.currentTagCss = opts.tagStyle;
      // self.currentTagOptions = opts.tagOpts;

      self.tagEditor.setValue(opts.tagDef ? opts.tagDef : '', -1);
      self.jsonEditor.setValue(opts.tagOpts ? opts.tagOpts : '', -1);
      self.styleEditor.setValue(opts.tagStyle ? opts.tagStyle : '', -1);

      self.currentTagReferences = opts.tagRefs;
      self.tagCategories._tag.setSelected(opts.tagCategory);
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


    self.setTagDefinitionValue = function(editor){
      self.tagEditor = editor;
      editor.setValue(opts.tagDef, -1);
    };

    self.setTagStyleValue = function(editor){
      self.styleEditor = editor;
      editor.setValue(opts.tagStyle, -1);
    };
    self.setTagOptionsValue = function(editor){
      self.jsonEditor = editor;
      editor.setValue(opts.tagOpts, -1);
    };

    this.on('mount', function(){

    });
    self.showHelp = function(){
      var overlay = document.createElement('div');
      var helpPage = document.createElement('help-page');
      overlay.style.position = 'absolute';
      overlay.style.top = '0';
      overlay.style.left = '0';
      overlay.style.right = '0';
      overlay.style.bottom = '0';
      overlay.style.background = 'rgba(255,255,255,0.5)';
      overlay.style.zIndex = '12';
      overlay.appendChild(helpPage);
      document.body.appendChild(overlay);
      riot.mount('help-page');
      var divText = overlay.outerHTML;
      overlay.parentNode.removeChild(overlay);

      var myWindow = window.open('','','width=900,height=700');
      var doc = myWindow.document;
      doc.open();
      doc.write(divText);
      doc.close();
    }
    </script>
</riot-tag-workbench>