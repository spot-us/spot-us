jQuery(document).ready(function($){
  $('#equalize').equalHeights();
  $(document).pngFix();
  $("select[name=news_item_type]").change(refreshSortOrder);
  renderUserHeader();

  if (jQuery("#category_select option:selected").val() == 'Sub-network') {
    id = jQuery("#network_select option:selected").val();
    load_categories(id);
  }
  $('a[rel*=facebox]').facebox();
  $('form[rel*=facebox]').facebox();

  $("#pitches_carousel").jCarouselLite({
    btnNext: ".next",
    btnPrev: ".prev",
    visible: 1
  });
});

jQuery("a").click(function($){
  $(".navigation a.selected").removeClass("selected");
  $(this).addClass("selected");
  return false;
});

function submitCommentToLogin() {
  form_action = jQuery('#comments_form').attr("action");
  title = jQuery('#comments_form input[name="comment[title]"]').val();
  window.frames[0].FCK.UpdateLinkedField();
  body = window.frames[0].FCK.LinkedField.value
  news_item_id = jQuery('#comments_form input[name="comment[news_item_id]"]').val();

  jQuery.facebox(function($) {
    jQuery.post(form_action, { title : title, body : body, news_item_id : news_item_id }, function(data) { jQuery.facebox(data) });
  });
}

function submitToLogin(form, type) {
  if ( type == undefined ) {
    type = "donation";
    news_item = "pitch_id";
  } else {
    type = "pledge";
    news_item = "tip_id";
  }

  form_action = jQuery('#' + form).attr("action");
  amount = jQuery('#' + form + ' input[name="' + type + '[amount]"]').val();
  news_item_id = jQuery('#' + form + ' input[name="' + type + '[' + news_item + ']"]').val();
  jQuery.facebox(function($) {
    if ( type == "donation" ) {
      jQuery.post(form_action, { amount : amount, pitch_id : news_item_id }, function(data) { jQuery.facebox(data) });
    } else {
      jQuery.post(form_action, { amount : amount, tip_id : news_item_id }, function(data) { jQuery.facebox(data) });
    }
  });
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

    
