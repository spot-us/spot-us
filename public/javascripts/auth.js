jQuery(document).ready(function($){
  var jump_to;
  $.fn.authguard = function(callback) {
    jump_to = $(this);
    if ($("#not_logged_in:visible a#sign_in").click().length == 0) {
      if (callback == "facebox")
        $.facebox({"ajax": jump_to.attr("href")});
      else
        $(document).trigger('close.facebox');
      if ($.isFunction(callback))
        callback(jump_to);
      jump_to = undefined;
      return callback === undefined;
    }
    return false;
  };

  $('a.auth').livequery('click', function() {return $(this).authguard(function(jump_to) { window.location = jump_to.attr('href'); })});

  $('form.auth, form.button-to:has(input.auth)').livequery('submit', function() {return $(this).authguard();});

  $('a.authbox').livequery('click', function() {
    return $(this).authguard('facebox');
  });

  $('a[rel*=authdrop]').livequery('click', function() {
    return $(this).authguard(function(j) {
      $.get(j.attr("href"), function(data) {
        $("#authdrop").hide().html(data).show("slow")
      });
    });
  });

  $("#facebox .content .login-boxer form").livequery(function() {
    var form = $(this);
    $(this).ajaxForm({
      complete: function(request,message) {
        if(message == "error") {
          $("#facebox .content .login-boxer").replaceWith(request.responseText);
          if (request.responseText == ' ')
            $(document).trigger('close.facebox');
        } else {
          $("#not_logged_in").hide();
          $("#logged_in").show();
          $("#sign_in_section").empty().append(request.responseText);
          if (jump_to && jump_to.attr("return_to"))
            window.location = jump_to.attr("return_to");
          else if (jump_to && jump_to.attr("action"))
            jump_to.submit();
          else if (jump_to && jump_to.attr("href"))
            jump_to.click();
          else
            $(document).trigger('close.facebox');
        }
      }
    });
  });
});
