riot.tag('riot-tag-workbench', '<app-dispatcher></app-dispatcher><store-somedata></store-somedata><store-usertags></store-usertags><store-tagcategories></store-tagcategories><store-userauth id="userAuth"></store-userauth><div style="display:flex;flex-flow:row nowrap">   <div id="ipad"></div><div id="console"></div></div><div id="container"><div id="editors"><ace-editor name="tagEditor" style="position:relative;" onready="{setTagDefinitionValue}" class="editorContainers" mode="html" show="{showTagEditor}"></ace-editor><ace-editor name="jsonEditor" style="position:relative;" onready="{setTagStyleValue}" class="editorContainers" mode="css" show="{showStyleEditor}"></ace-editor><ace-editor name="styleEditor" style="position:relative;" onready="{setTagOptionsValue}" class="editorContainers" mode="json" show="{showJsonEditor}"></ace-editor></div><div id="toolbar"><select onchange="{selectTag}" name="tagSelector"><option each="{tagname in tagNames}">{tagname}</option></select><button onclick="{renderTag}" type="button" title="Compile and display on screen"><img src="../images/cycle.svg" style="height:1rem;padding:0;margin:0;"></button><button onclick="{exportTag}" type="button" title="Save"><img src="../images/save.svg" style="height:1rem;padding:0;margin:0;"></button><button onclick="{toggleTagEditor}" type="button" title="{showTagEditor ? \'Hide tageditor\' : \'Show tageditor\'}"><img src="../images/tag.svg"></button><button onclick="{toggleStyleEditor}" type="button" title="{showStyleEditor ? \'Hide styles\' : \'Show styles\'}"><img src="../images/news.svg"></button><button onclick="{toggleJsonEditor}" type="button" title="{showJsonEditor ? \'Hide tag options\' : \'Show tag options\'}"><img src="../images/database.svg"></button><button onclick="{clearAll}" type="button" title="Clear all code from the editors."><img src="../images/cross.svg"></button><select name="referenceTags"><option each="{tagname in tagNames}">{tagname}</option></select><button onclick="{addTagReferences}" type="button" title="Include other tags."><img src="../images/plus.svg"></button><button onclick="{logOut}" type="button" title="Log out."><img src="../images/cross.svg"></button><tagcategories-chooser name="tagCategories" onselected="{setTagCategory}"></tagcategories-chooser><button onclick="{downloadTag}" type="button" title="Download tag"><img src="../images/download.svg"></button><button onclick="{showHelp}" type="button" title="Help"><img src="../images/help-with-circle.svg"></button></div></div>', function(opts) {
    'use strict';
    var self = this;
    self.showTagEditor = true;
    self.showStyleEditor = true;
    self.showJsonEditor = true;
    self.setTagCategory = function(category){
      console.log('callback on category change');
      self.tagCategory = category;
    }
    self.clearAll = function(){
      self.tagEditor.setValue('', -1);
      self.jsonEditor.setValue('', -1);
      self.styleEditor.setValue('', -1);
      self.tagSelector.selectedIndex = 0;
    };

    self.currentTagReferences = {};

    self.logOut = function(){
      window.app.dispatcher.trigger('log-out', null);
    }

    self.addTagReferences = function(tagName){
      var refTagOpts = self.tagCollection[self.referenceTags.value];
      self.createReferences(refTagOpts.tagName, refTagOpts.tagDef);
      console.log('tagrefs',self.currentTagReferences);
      var exportContainer = document.createElement('div');
      var styleTag = document.createElement('style');
      styleTag.innerHTML =  self.tagCollection['insignia-tag-description'].tagStyle;
      var tagDescriptionElement = document.createElement('insignia-tag-description-with-references');
      exportContainer.appendChild(styleTag);
      var tagsToDisplay = [];
      tagsToDisplay.push(refTagOpts);
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {
          opts = self.tagCollection[property];
          tagsToDisplay.push(opts);

        }
      }
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

    
    self.compileReferences = function(){
      console.log('compile references');
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {
          c.log('compile ref: ' + property);
          opts = self.tagCollection[property];
          riot.compile(opts.tagDef);
        }
      }
    }
    self.mountReferences = function(){
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {

          opts = self.tagCollection[property];

          var nestedTagsList = document.getElementsByTagName(opts.tagName);

          for (var x=0; x<nestedTagsList.length;x++){
          }
        }
      }
    }
    
    self.getReferencedStyles = function(){
      var concatenatedStyles = '';
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {

          opts = self.tagCollection[property];
          concatenatedStyles += opts.tagStyle;
        }
      }
      return concatenatedStyles;
    }
    self.renderTag = function(e){
      e.preventDefault();
      var tagSource = this.tagDef;
      var tagOptions = this.tagOpts;
      var tagStyle = this.tagStyle;
      var tagOptionsObject = {};
      var setOptions = false;
      var tagName = self.tagEditor.getValue().substring(self.tagEditor.getValue().indexOf('<')+1, self.tagEditor.getValue().indexOf('>'));

      self.currentTagReferences = {}; //reset the references.
      self.createReferences(tagName, self.tagEditor.getValue());
      var jsonValue  = self.jsonEditor.getValue();
      if (jsonValue){
        tagOptionsObject = JSON.parse(jsonValue);
        setOptions = true;
      }
      self.compileReferences();
      var newTag = riot.compile(self.tagEditor.getValue());
      var newTagEl = document.createElement(tagName);
      this.ipad.innerHTML = '';
      this.ipad.appendChild(document.createElement(tagName));
      var styleTags = this.root.getElementsByTagName('style');
      if (styleTags.length > 0) {
        this.root.removeChild(styleTags[0]);
      }
      this.root.insertAdjacentHTML('afterbegin', '<style scoped>' + self.getReferencedStyles() +  self.styleEditor.getValue() + '</style>');
      if (setOptions){
        riot.mount(tagName, tagOptionsObject);
      }else{
        riot.mount(tagName);
      }

    }
    self.storeTag = function(uid){
      console.log(self.tagCategory);
      var tagDefVal = self.tagEditor.getValue();
      var tagName = tagDefVal.substring(tagDefVal.indexOf('<')+1, tagDefVal.indexOf('>'));
      self.createReferences(tagName, tagDefVal);
        var exportObject = {
          tagName: tagName,
          tagDef: tagDefVal,
          tagOpts: self.jsonEditor.getValue(),
          tagStyle: self.styleEditor.getValue(),
          tagRefs: self.currentTagReferences || {},
          tagCategory: self.tagCategory
        }
        window.app.dispatcher.trigger('add-new-tag', exportObject);
    };
    self.createReferences = function(tagName, tagHtml){
      var fakeDiv = document.createElement('div');

      fakeDiv.insertAdjacentHTML('afterbegin', tagHtml);
      self.tagNames.forEach(function(customTagName){
        var customElementList = fakeDiv.getElementsByTagName(customTagName);
        if (customElementList.length && customTagName !== tagName){
          self.currentTagReferences[customTagName] = '';
          opts = self.tagCollection[customTagName];
          self.createReferences(opts.tagName, opts.tagDef);
        }

      });
    }


    this.exportTag = function(e) {

      var authData = self.userAuth._tag.authData;
      if (authData){

        self.storeTag(authData.uid);
      }else{
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
    }.bind(this);
    this.downloadTag = function(e) {
      var exportDefintions = '';
      var exportStyle = '';
      var tagDefVal = self.tagEditor.getValue();
      var tagName = tagDefVal.substring(tagDefVal.indexOf('<')+1, tagDefVal.indexOf('>'));
      self.createReferences(tagName, tagDefVal);
      console.log('tagrefs',self.currentTagReferences);
      for (var property in self.currentTagReferences) {
        if (self.currentTagReferences.hasOwnProperty(property)) {
          opts = self.tagCollection[property];
          exportDefintions += '\n\<script type="riot\/tag"\>' + opts.tagDef + '\<\/script\>';
          exportStyle += '\n' + opts.tagStyle;

        }
      }

      exportDefintions += '\<script type=\"riot/tag\"\>' + tagDefVal + '\<\/script\>';
      exportStyle += '\n' + self.styleEditor.getValue();
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



    }.bind(this);

    self.selectTag = function(e){
      console.log(e.target.value);
          var tagDefVal = self.tagEditor.getValue();
          var tagName = tagDefVal.substring(tagDefVal.indexOf('<')+1, tagDefVal.indexOf('>'));

      if (confirm('Click OK to save ' + tagName + ' in its current state.\n\nOr click cancel to discard the changes.')){
          self.createReferences(tagName, tagDefVal);

        var exportObject = {
          tagName: tagName,
          tagDef: tagDefVal,
          tagOpts: self.jsonEditor.getValue(),
          tagStyle: self.styleEditor.getValue(),
          tagRefs: self.currentTagReferences || {},
          tagCategory: self.tagCategory
        }
        window.app.dispatcher.trigger('add-new-tag', exportObject);

      }

      var opts = self.tagCollection[e.target.value];
      opts = opts || {};
      self.showTagEditor = true;
      self.showStyleEditor = true;
      self.showJsonEditor = true;

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
    this.toggleTagEditor = function(e) {
      self.showTagEditor = !self.showTagEditor;
    }.bind(this);
    this.toggleStyleEditor = function(e) {
      self.showStyleEditor = !self.showStyleEditor;
    }.bind(this);
    this.toggleJsonEditor = function(e) {
      self.showJsonEditor = !self.showJsonEditor;
    }.bind(this);
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
    
});
