jQuery(document).ready(function($){
  $('#equalize').equalHeights();
  $(document).pngFix();
  $("select[name=news_item_type]").change(refreshSortOrder);
  renderUserHeader();

  if (jQuery("#category_select option:selected").val() == 'Sub-network') {
    id = jQuery("#network_select option:selected").val();
    load_categories(id);
  }
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
  var select = jQuery('select[name=sort_by]');
  var type   = jQuery('select[name=news_item_type]')
  
  jQuery.get('/news_items/sort_options', {
    sort_by: select.val(),
    news_item_type: type.val()
  }, function(html, status){
    select.html(html);
  });
};

jQuery("#network_select").live("change", function() {
    id = jQuery("#network_select option:selected").val();
    load_categories(id);
});

function load_categories(id) {
    jQuery("#category_select").empty();
    jQuery.getJSON("/networks/" + id + "/categories", function(data){
      jQuery("<option>Sub-network...</option>").attr("value", "").appendTo("#category_select");
      jQuery.each(data, function(i, category) {
        jQuery("<option>" + category.name + "</option>").attr("value", category.id).appendTo("#category_select");
      });
    });
}
