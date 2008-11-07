// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery(document).ready(function($){
  $('#equalize').equalHeights();
  $(document).pngFix();

  function refreshSortOrder(){
    var select = $('select[name=sort_by]');
    var type   = $('select[name=news_item_type]')
    
    $.get('/news_items/sort_options', { 
      sort_by: select.val(), 
      news_item_type: type.val()
    }, function(html, status){
      select.html(html);
    });
  };
  $("select[name=news_item_type]").change(refreshSortOrder);
  renderUserHeader();
});
// Flash dismiss - CARM TALK TO DESI WE ARE MISSING jslivequery.js for this
/*$('.flash .dismiss a').livequery('click', function(event) {
  $(this).parents('.flash').slideUp();
  return false;
});*/


jQuery("a").click(function($){
  $(".navigation a.selected").removeClass("selected");  
  // remove previous class if there is any
  $(this).addClass("selected");                                      
  // add class to the clicked link
  return false;                                                           
  // this prevents browser from following clicked link
});

function toggle_divs(div1, div2) {
  jQuery(div1).toggle();
  jQuery(div2).toggle();
}

// jQuery("#toggle_pledge_button").livequery("click", toggle_divs("#pledge_button", "#pledge_custom"));

$(function() {  
    if ($.browser.msie && parseInt($.browser.version)< 7) {  
        $("#repoters_toolbar li").hover(  
            function() {  
                $(this).addClass("sf");  
            },  
            function() {  
        $(this).removeClass("sf");  
            });  
    }  
});

function renderUserHeader() {
  if (jQuery.cookie('current_user_full_name')) {
    // we are logged in
    jQuery('#logged_in span').html(jQuery.cookie('current_user_full_name').replace(/\+/," "));
    jQuery('#logged_in').show();
  } else {
    jQuery('#not_logged_in').show();
  }
}


