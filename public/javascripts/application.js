String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

jQuery(document).ready(function($){	
	socialNotifier();
	$('#equalize').equalHeights();
	$(document).pngFix();
	$("select[name=news_item_type]").change(refreshSortOrder);
	renderUserHeader();

	if (jQuery("#category_select option:selected").val() == 'Sub-network') {
		id = jQuery("#network_select option:selected").val();
		load_categories(id);
	}
	
	if($("#button_status").length > 0) {
		$(".show_status, .donate_buttons a.authbox").hover(function(){
			$("#button_status").html($(this).attr("alt"));
		},function(){
			$("#button_status").html("&nbsp");
		});
		$(".earn_credits, .donate_buttons a.authbox").hover(function(){
			$("#button_status").addClass("align-right");
		},function(){
			$("#button_status").removeClass("align-right");
		});
	}
	$('a[rel*=facebox]').facebox();
	$('form[rel*=facebox]').facebox();
	$('a[href*=/get_external_url]').facebox();
	$(".primary_button").hover(function(){
		$("#" + $(this).attr("id") + "_status").fadeIn(100);
	}, function(){
		$("#" + $(this).attr("id") + "_status").fadeOut(200);
	});

	$(".tab").click(function(){
		if ($(this).parent().parent().attr('id')!='tabHeaderPitch'){
			$(this).parent().parent().parent().find(".tab_panel").hide();
			$("." + $(this).attr("id")).show();
			$(this).parent().parent().find(".tab").removeClass("active").parent().removeClass("active");
			$(this).addClass("active").parent().addClass("active");
			return false;
		}
	});

	$("#show_suggest_city").click(function(){
		$.facebox($("#suggest_city").html());
		return false;
	});
	
	$('img.supporter').error(function(){
		$(this).attr('src', '/images/default_avatar.png');
	});
	
	/* Hover */
	jQuery("a[id*=hoverAnchor],li[id*=hoverAnchor],h3[id*=hoverAnchor]").hover(function(){
        $(this).addClass("hover");
        containerName = this.id.replace('hoverAnchor', '');
		pos = $(this).position();
		from_top = 14;
		containerNameArr = containerName.split('-');
		if (containerNameArr.length > 1){
			containerName = containerNameArr[0];
			from_top = 28;
			if (containerNameArr.length>2){
				if(containerNameArr[2]=="large"){
					from_top = 42;
				}
			}
		}
		$("#hoverContainer"+containerName).css( { "left": (pos.left) + "px", "top": pos.top+from_top + "px" } );
		$("#hoverContainer"+containerName).fadeIn();
    }, function(){
		containerName = this.id.replace('hoverAnchor', '');
        $(this).removeClass("hover");
        containerNameArr = containerName.split('-');
		if (containerNameArr.length > 1){
			containerName = containerNameArr[0];
		}
		$("#hoverContainer"+containerName).hide();
    });

	jQuery("ul[id*=hoverContainer]").hover(function(){
        containerName = this.id.replace('hoverContainer', '');
		$("#hoverAnchor"+containerName).addClass("hover");
		$(this).show();
    }, function(){
		containerName = this.id.replace('hoverContainer', '');
		$("#hoverAnchor"+containerName).removeClass("hover");
        $(this).fadeOut();
    });

	jQuery("span[id*=toggleEmail]").click(function(){
		containerName = this.id.replace('toggle', '');
		$("#list"+containerName).slideToggle(200);
	});
	
});

function socialNotifier(){
	if( jQuery.cookie('social_notifier') != null ) {
	    jQuery.facebox(jQuery("#social_notifier_wrapper").html());
		jQuery("#share_by_email").live("click",function(){
			jQuery(this).next().slideToggle(200);
			return false;
		});
		jQuery("#email_notify").live("submit",function(){
			var form = jQuery(this);
			var ta = form.find("textarea");
			var notice = form.find("#email_result");
			var query_params = form.serialize();
			notice.html("sending...");
			ta.attr("disabled", true);
			var emails = ta.attr("value");
			if(emails.length > 500) {
				alert("That's just too much email for us to handle at once.");
				return false;
			}
			if (email_validate(emails) == false){
				alert('One or more email is not valid. Please try again.');
				ta.attr("disabled", false);
				notice.html("");
				return false;
			}
			jQuery.post(form.attr("action"), query_params, function(data){
				ta.attr("value", "");
				notice.html(data);
				ta.attr("disabled", false);
			});
			return false;
		});
	}
	
}

function email_validate(emails) {
	var email_list;
	if(emails.indexOf(",") > -1){
		email_list = emails.split(",");
	} else {
		email_list = new Array(emails);
	}
	for (i=0;i<email_list.length;i++) {
	   	var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
	   	if(reg.test(email_list[i].trim()) == false) {
	      	return false;
	   	}
	}
	return true;
}

function slideWidget(name){
	if (name=='spotus_lite_widget'){
		jQuery('#simple_widget:visible').slideToggle(200);
		jQuery('#spotus_lite_widget').slideToggle(200);
	} else if (name=='simple_widget') {
		jQuery('#spotus_lite_widget:visible').slideToggle(200);
		jQuery('#simple_widget').slideToggle(400);		
	}
	return false;
}

// save the state using the helper html file
function resizePipe(host){
	var height = document.body.scrollHeight;
	var pipe = document.getElementById('helpframe');
	pipe.src = host+'/helper.html?height='+height+'&cacheb='+Math.random();
}

/* Simple tabbing function */
function selectTab(container, id){
	header = container.find('ul');
	// header.find('li').removeClass('active').parent().addClass('active');
	// header.find(id+'_tab').addClass('active').parent().addClass('active');
	// $('#'+container).find('div').hide();
	// $('#'+container).find(id+'_content').show();
	return false;
}

function clear_text(name, text){
	if (jQuery("#"+name).attr('value')==text){
		jQuery("#"+name).attr('value', '');
		jQuery("#"+name).removeClass("gray_text");
	}
	return false;
}

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



function getTotalAmounts(recalc_spot_donation){
	//alert($(this).attr("id"));
	// return false;
	owe_amount = 0;
	credit = 0;
	total_amount = 0;
	jQuery('input[id*=donation_amounts]').each(function() {
		owe_amount += parseFloat(this.value);
	});	
	jQuery('input[id*=credit_pitch_amounts]').each(function() {
		owe_amount += parseFloat(this.value);
	});
	
	if(jQuery('#spotus_credit_amount').length > 0) {
		credit = parseFloat(jQuery('#spotus_credit_amount').html().replace(',', '')) || 0;
	}
	else
	{
		credit = 0;
	}
	amount_to_pay = 1.05*owe_amount - credit;
	if(recalc_spot_donation && owe_amount > 0){
		jQuery('#spotus_donation').attr("value",formatAsMoney(owe_amount/20));
		jQuery('#spotus_donation_hidden').attr("value",formatAsMoney(owe_amount/20));
	}
	else if (recalc_spot_donation)
	{
		jQuery('#spotus_donation').attr("value","0.00");
		jQuery('#spotus_donation_hidden').attr("value","0.00");
	}

	spot_us_support = parseFloat(jQuery('#spotus_donation').val()) || 0;
	total_amount = parseFloat(owe_amount)+parseFloat(spot_us_support)-parseFloat(credit);
	
	if (total_amount<=0) {
		jQuery('#purchase').hide();
		jQuery('#apply_credits').show();
		total_amount=0;
	} else {
		jQuery('#purchase').show();
		jQuery('#apply_credits').hide();
	}

	jQuery('#spotus_total_amount').html('$'+formatAsMoney(total_amount));

}



function formatAsMoney(mnt) {
    mnt -= 0;
    mnt = (Math.round(mnt*100))/100;
    return (mnt == Math.floor(mnt)) ? mnt + '.00' 
              : ( (mnt*10 == Math.floor(mnt*10)) ? 
                       mnt + '0' : mnt);
}

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
	var dismiss = "<span class=\"dismiss\"><a href=\"\"><img src=\"http://www.spot.us/images/close_square.png\" alt=\"Dismiss\" /></span>";
	// switched from append to html call to prevent stacking  
	jQuery.each(["Success", "Notice", "Error"], function() {
		if(notice = r.getResponseHeader("X-Flash-" + this)) {
			jQuery("#flash").html(jQuery("<div/>").addClass(this.toLowerCase()).html(dismiss + "<p>" + notice + "</p>"));
		}
	});
});

function processLoginForm(){
	pw   = jQuery('#passwordField').val();
	pw_e = encode64(pw);
	jQuery('#passwordHiddenField').val(pw_e);
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
