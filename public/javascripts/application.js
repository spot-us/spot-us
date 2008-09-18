// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Flash dismiss
$('.flash .dismiss a').livequery('click', function(event) {
  $(this).parents('.flash').slideUp();
  return false;
});

// IE PNG fix
$(document).ready(function(){ 
  $(document).pngFix(); 
});
