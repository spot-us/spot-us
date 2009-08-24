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

jQuery(document).ajaxComplete(function(options, r) {
    var notice;
    var dismiss = "<span class=\"dismiss\"><a href=\"\"><img src=\"/images/close_square.png\" alt=\"Dismiss\" /></span>";
    jQuery.each(["Success", "Notice", "Error"], function() {
      if(notice = r.getResponseHeader("X-Flash-" + this)) {
        jQuery("#flash").append(jQuery("<div/>").addClass(this.toLowerCase()).html(dismiss + "<p>" + notice + "</p>"));
      }
    });
});

function processLoginForm(){
	pw   = jQuery('#passwordField').val();
	pw_e = encode64(pw);
	//alert(pw);
	//alert(pw_e);
	jQuery('#passwordField').val(pw_e);
}



// This code was written by Tyler Akins and has been placed in the
// public domain.  It would be nice if you left this header intact.
// Base64 code from Tyler Akins -- http://rumkin.com

var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

function encode64(input) {
   var output = "";
   var chr1, chr2, chr3;
   var enc1, enc2, enc3, enc4;
   var i = 0;

   do {
      chr1 = input.charCodeAt(i++);
      chr2 = input.charCodeAt(i++);
      chr3 = input.charCodeAt(i++);

      enc1 = chr1 >> 2;
      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
      enc4 = chr3 & 63;

      if (isNaN(chr2)) {
         enc3 = enc4 = 64;
      } else if (isNaN(chr3)) {
         enc4 = 64;
      }

      output = output + keyStr.charAt(enc1) + keyStr.charAt(enc2) + 
         keyStr.charAt(enc3) + keyStr.charAt(enc4);
   } while (i < input.length);
   
   return output;
}

function decode64(input) {
   var output = "";
   var chr1, chr2, chr3;
   var enc1, enc2, enc3, enc4;
   var i = 0;

   // remove all characters that are not A-Z, a-z, 0-9, +, /, or =
   input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

   do {
      enc1 = keyStr.indexOf(input.charAt(i++));
      enc2 = keyStr.indexOf(input.charAt(i++));
      enc3 = keyStr.indexOf(input.charAt(i++));
      enc4 = keyStr.indexOf(input.charAt(i++));

      chr1 = (enc1 << 2) | (enc2 >> 4);
      chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
      chr3 = ((enc3 & 3) << 6) | enc4;

      output = output + String.fromCharCode(chr1);

      if (enc3 != 64) {
         output = output + String.fromCharCode(chr2);
      }
      if (enc4 != 64) {
         output = output + String.fromCharCode(chr3);
      }
   } while (i < input.length);

   return output;
}

