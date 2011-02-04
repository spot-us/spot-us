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

  //config.ContextMenu = ['Generic','Anchor','Flash','Select','Textarea','Checkbox','Radio','TextField','HiddenField','ImageButton','Button','BulletedList','NumberedList','Table','Form'] ;
  
  config.height = '400px';
  config.width = '600px';
  
  //config.resize_enabled = false;
  //config.resize_maxHeight = 2000;
  //config.resize_maxWidth = 750;
  
  //config.startupFocus = true;
  
  config.extraPlugins = "embed"; // works only with en, ru, ua languages
  
  // config.toolbar = 'Easy';
  // 
  // config.toolbar_Easy =
  //   [
  //       ['Source','-','Preview','Templates'],
  //       ['Cut','Copy','Paste','PasteText','PasteFromWord',],
  //       ['Maximize','-','About'],
  //       ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
  //       ['Styles','Format'], '/',
  //       ['Bold','Italic','Underline','Strike','-','Subscript','Superscript', 'TextColor'],
  //       ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
  //       ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
  //       ['Link','Unlink','Anchor'],
  //       ['Image','Embed','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak']
  //   ];

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
	// config.resize_maxWidth = 500;
	// config.resize_minWidth = 500;
	config.removePlugins = 'elementspath';
	config.resize_enabled = false;
};

