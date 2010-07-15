/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

/**
 * @file Paste as plain text plugin
 */

(function()
{
	// The pastetext command definition.
	var embedCmd =
	{
		exec : function( editor )
		{
		  editor.openDialog( 'embed' );
		  return;
		}
	};
  
	// Register the plugin.
	CKEDITOR.plugins.add( 'embed',
	{
		init : function( editor )
		{ 
			var commandName = 'embed';
			editor.addCommand( commandName, embedCmd );
      
			editor.ui.addButton( 'Embed',
				{
					label : editor.lang.embed.button,
					command : commandName,
					icon: this.path + "images/embed.png"
				});      
			CKEDITOR.dialog.add( commandName, CKEDITOR.getUrl( this.path + 'dialogs/embed.js' ) );
		}
		//requires : [ 'dialog' ]
	});
	
})();
