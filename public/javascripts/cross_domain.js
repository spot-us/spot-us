// Tell the parent iframe what height the iframe needs to be
function parentIframeResize(){
	var height = "";
	name = 'height';
	name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regexS = "[\\?&]"+name+"=([^&#]*)";
	var regex = new RegExp( regexS );
	var results = regex.exec( window.location.href );
	var c_domain = $.getUrlVar('domain').split('/', 1);
	var c_path = '/';
	if( typeof(results) != 'undefined' ){
		height = results[1];
		if(typeof(height)!='undefined' && parseInt(height)>0){
			$.cookie("spotus_iframe", height+'',  { expires: 1, path: c_path, domain: c_domain });
		} else {
			$.cookie("spotus_iframe", '',  { expires: 1, path: c_path, domain: c_domain });
		}
	}	
}

jQuery.extend({
  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
});

// load the document when ready
jQuery(document).ready(function($){
	parentIframeResize();
});