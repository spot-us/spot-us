// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){ 
	$('#equalize').equalHeights();
	$(document).pngFix();
	$('#example > ul').tabs();
});
// Flash dismiss - CARM TALK TO DESI WE ARE MISSING jslivequery.js for this
/*$('.flash .dismiss a').livequery('click', function(event) {
  $(this).parents('.flash').slideUp();
  return false;
});*/

