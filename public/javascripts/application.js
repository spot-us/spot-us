jQuery(document).ready(function($){
  $('#equalize').equalHeights();
  $(document).pngFix();
  $("select[name=news_item_type]").change(refreshSortOrder);
  renderUserHeader();

  $('#login').livequery(function(){
    $(this).click(function(){
      var login_li = $(this).parent('li');
      var fields_li = $('<li id="login_fields" class="no-pipe">');
      login_li.after(fields_li);
      $('#login_fields').load('/session/new');
      return false;
    });
  });

  $('#login_close').livequery(function(){
    $(this).css('cursor','pointer');
    $(this).click(function(){
      $('#login_fields').remove();
    });
  });
});

jQuery("a").click(function($){
  $(".navigation a.selected").removeClass("selected");
  $(this).addClass("selected");
  return false;
});

function toggle_divs(div1, div2) {
  jQuery(div1).toggle();
  jQuery(div2).toggle();
}

$(function() {
  if ($.browser.msie && parseInt($.browser.version)< 7) {
    $("#reporters_toolbar li").hover(
      function() { $(this).addClass("sf"); },
      function() { $(this).removeClass("sf"); }
    );
  }
});

function renderUserHeader() {
  if (jQuery.cookie('current_user_full_name')) {
    // we are logged in
    jQuery('#logged_in span').html(decodeURI(jQuery.cookie('current_user_full_name').replace(/\+/g," ")));
    if (jQuery.cookie('balance_text')) {
      jQuery('#current_balance_line').html(decodeURI(jQuery.cookie('balance_text').replace(/\+/g," ")));
    }
    jQuery('#logged_in').show();
  } else {
    jQuery('#not_logged_in').show();
  }
}

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

