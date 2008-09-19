// SPOTUS setting for FCKEditor

// CHANGE FOR APPS HOSTED IN SUBDIRECTORY
FCKRelativePath = '';

// section modified image dialog

FCKConfig.LinkDlgHideTarget     = true ;
FCKConfig.LinkDlgHideAdvanced   = true ;
FCKConfig.ImageDlgHideLink      = true ;
FCKConfig.ImageDlgHideAdvanced  = true ;
FCKConfig.FlashDlgHideAdvanced  = true ;

FCKConfig.LinkBrowser   = false ;
FCKConfig.ImageBrowser  = false ;
FCKConfig.FlashBrowser  = false ;
FCKConfig.LinkUpload    = false ;
FCKConfig.ImageUpload   = false ;
FCKConfig.FlashUpload   = false ;

// DON'T CHANGE THESE
// FCKConfig.LinkBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Connector='+FCKRelativePath+'/fckeditor/command';
// FCKConfig.ImageBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=Image&Connector='+FCKRelativePath+'/fckeditor/command';
// FCKConfig.FlashBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=Flash&Connector='+FCKRelativePath+'/fckeditor/command';
// 
// FCKConfig.LinkUploadURL = FCKRelativePath+'/fckeditor/upload';
// FCKConfig.ImageUploadURL = FCKRelativePath+'/fckeditor/upload?Type=Image';
// FCKConfig.FlashUploadURL = FCKRelativePath+'/fckeditor/upload?Type=Flash';
// FCKConfig.SpellerPagesServerScript = FCKRelativePath+'/fckeditor/check_spelling';
// FCKConfig.AllowQueryStringDebug = false;
// FCKConfig.SpellChecker = 'SpellerPages';

// ONLY CHANGE BELOW HERE
FCKConfig.SkinPath = FCKConfig.BasePath + 'skins/silver/';
FCKConfig.RemoveFormatTags = 'b,big,code,del,dfn,em,font,i,ins,kbd,q,samp,small,span,strike,strong,sub,sup,tt,u,var';

FCKConfig.ToolbarSets["Simple"] = [
	['Source','-','-','Templates'],
	['Cut','Copy','Paste','PasteWord','-','Print','SpellCheck'],
	['Undo','Redo','-','Find','Replace','-','SelectAll'],
	'/',
	['Bold','Italic','Underline','StrikeThrough','-','Subscript','Superscript'],
	['OrderedList','UnorderedList','-','Outdent','Indent'],
	['JustifyLeft','JustifyCenter','JustifyRight','JustifyFull'],
	['Link','Unlink'],
	'/',
	['Image','Table','Rule','Smiley'],
	['FontName','FontSize'],
	['TextColor','BGColor'],
	['-','About']
] ;
FCKConfig.ToolbarSets["Spotus"] = [
	['Bold','Italic','OrderedList','UnorderedList','-','Outdent','Indent','JustifyLeft','JustifyCenter','JustifyRight','JustifyFull','-','Link','Rule','Source'],
] ;