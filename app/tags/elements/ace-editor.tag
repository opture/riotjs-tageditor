<ace-editor>
	<!-- Displays an ace-editor
		* @param {string} - editormode, the mode that the editor uses, defaults to html
		* @param {string} - content, the content to display in the editor.
		* @param {function} - onready, a callback to execute when editor is instantiated and ready. Calls with the editor as parameter.
	-->

	<div name="editorContainer" style="position:absolute;top:0;lefT:0;right:0;bottom:0;" show={opts.show}></div>
	<script>
	/* global ace */
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
      	//If there is a callback supplied for onready, then execute the callback with the editor as payload.
      	if (opts.onready){
      		opts.onready(self.editor);
      	}
		});

	</script>
</ace-editor>
