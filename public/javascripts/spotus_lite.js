//set the iframe src onload of the widget
function setSrc(url, host){
	var spotus_lite = document.getElementById('spotus_lite');
	if (host!=''){
		spotus_lite.src = url + '?host=' + escape(host);
	} 
	return '';
}

// Resize iframe to full height
function resizeIframe(){
	height = $.cookie("spotus_iframe");
	jQuery('#spotus_lite').attr('height', height);
}

jQuery(document).ready(function($){
	spotus_lite_host = setSrc(spotus_lite_url, spotus_lite_host);
});