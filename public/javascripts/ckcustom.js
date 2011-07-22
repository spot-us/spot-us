/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

//CKEDITOR.plugins.load( 'embed' );

CKEDITOR.editorConfig = function( config )
{
  config.PreserveSessionOnFileBrowser = true;

  // Define changes to default configuration here. For example:
  config.language = 'en';
  config.uiColor = '#e3eeef';
  config.extraPlugins = "embed"; // works only with en, ru, ua languages
  config.toolbar = 'Spotus';

  config.toolbar_Spotus =
    [
        ['PasteText','PasteFromWord','Format','Bold','Italic','Underline','Strike','TextColor',
        'NumberedList','BulletedList','Blockquote', 
        'JustifyLeft','JustifyCenter','JustifyRight','Link','Unlink',
        'Image','Embed','Source','Maximize']
    ];
  config.toolbar_Medium =
    [
        ['PasteText','PasteFromWord','Bold','Italic','Underline',
        'NumberedList','BulletedList','Image','Embed'], 
        ['JustifyLeft','JustifyCenter','JustifyRight','Link','Unlink','Image','Source']
    ];
  config.toolbar_Basic =
    [
        ['Bold','Italic','Underline',
        'NumberedList','BulletedList'], 
        ['JustifyLeft','JustifyCenter','JustifyRight','Link','Unlink','Image']
    ];

	config.toolbar_Simple =
	    [
	        ['Bold','Italic','Underline','NumberedList','BulletedList', 'Link','Unlink']
	    ];
	
	config.linkShowAdvancedTab = false;
	config.removePlugins = 'elementspath';
	config.resize_enabled = true;
};

