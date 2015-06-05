'use strict';
requirejs.config({
    //By default load any module IDs from js/lib
    baseUrl: 'scripts',
    //except, if the module ID starts with "app",
    //load it from the js/app directory. paths
    //config is relative to the baseUrl, and
    //never includes a ".js" extension since
    //the paths config could be for a directory.
    paths: {
        tags: 'tags',
        lib: 'lib'
    }
});
requirejs(['lib/riot', 'lib/ace/ace'], function(riot,ace) {

	window.riot = riot;
	window.ace = ace;
	console.log(ace);
	require(['lib/compiler', 'tags/elements', 'tags/pages'], function(){
		console.log('riot', riot);
		  var predefined = {
		    tagDef: '<riot-tag>\n <h3>New tag</h3>\n <script>\n \n <\/script>\n</riot-tag>',
		    tagOpts: '{"message":"New Message"}',
		    tagStyle: 'riot-tag{\n background-color:#fff;\n}'
		  };
		riot.mount('*', predefined);

		window.createExportHTMLFromTag = function(tagName,exportDefintions, exportStyle, exportOptions){
			var optionsString = JSON.stringify(JSON.parse(exportOptions));
			console.log('export options: ', optionsString);
     		return '<html><head><script src="https://cdnjs.cloudflare.com/ajax/libs/riot/2.1.0/riot+compiler.min.js"></script></head><body><style>' + exportStyle + '</style>' + exportDefintions + '<' + tagName + '></' + tagName + '><script>riot.compile(function(){var tags = riot.mount("' + tagName + '", ' + optionsString + ')})</script></body></html>';
		}
	});
    //This function is called when scripts/helper/util.js is loaded.
    //If util.js calls define(), then this function is not fired until
    //util's dependencies have loaded, and the util argument will hold
    //the module value for "helper/util".
    //window.riot = riot;
    //window.ace = ace;

});