// SPOTUS setting for FCKEditor

// CHANGE FOR APPS HOSTED IN SUBDIRECTORY
FCKRelativePath = '';

// section modified image dialog without the upload and advanced tabs

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

// disable toolbar collapse
FCKConfig.ToolbarCanCollapse = false;

// silver theme was modified to fit spotus.us theme
FCKConfig.SkinPath = FCKConfig.BasePath + 'skins/silver/';

// removes formatted tags copied into the textarea
FCKConfig.RemoveFormatTags = 'b,big,code,del,dfn,em,font,i,ins,kbd,q,samp,small,span,strike,strong,sub,sup,tt,u,var';

// toolbar specific to spot.us
FCKConfig.ToolbarSets["Spotus"] = [
	['Bold','Italic','StrikeThrough','OrderedList','UnorderedList','-','Outdent','Indent','JustifyLeft','JustifyCenter','JustifyRight','JustifyFull','-','Link','Rule','Source'],
] ;