jQuery(document).ready(function($){
  	var jump_to;
	$.fn.authguard = function(callback) {
		jump_to = $(this);
		
		// making sure the return path is set as it should.
		href = jump_to.attr("href");
		if (typeof (href) == "undefined"){
			query = "";
		}else{
			query = href.split('?');
		}
		if (query.length > 1){
			return_to_query = query[1].split('&');
			return_to = return_to_query[0].split('=');
			if (return_to[0] == 'return_to'){
				jQuery.cookie('return_to', return_to[1], { 'path': "/" });
			};
		}
		
		if ($("#not_logged_in:visible a#sign_in").click().length == 0) {
			if (callback == "facebox"){
				$.facebox({"ajax": jump_to.attr("href")});
			}else{
				$(document).trigger('close.facebox');
			}
			if ($.isFunction(callback)){
				
				callback(jump_to);
			}
			jump_to = undefined;
			return callback === undefined;
		}
		return false;
	};
	
	// $("#fb_login_link").live("click",function(){
	// 	var fb_pop=window.open($(this).attr("href"),'fbpopup','height=360,width=360');
	// 	// var fb = fb_pop.document.getElementById("login_form");
	// 	// alert(fb_pop);
	// 	return false;
	// });
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

	$("#login_modal form.login").livequery(function() {
		var form = $(this);
		$('#loginError').hide();
		$(this).ajaxForm({
			complete: function(request,message) {
			if(message == "error") {
				//$("#facebox .content .login-boxer").replaceWith(request.responseText);
				if (typeof (request.getResponseHeader('error'))!=null) {
					$('#loginError').show();
					$('#flash').hide('');
				}else if (request.responseText == ' ')
					$(document).trigger('close.facebox')
				} else {
					$("#not_logged_in").hide();
					$("#logged_in").show();
					$("#sign_in_section").empty().append(request.responseText);
					if (jump_to && jump_to.attr("return_to")){
						window.location = jump_to.attr("return_to");
					} else if (jump_to && jump_to.attr("action")){
						jump_to.submit();
					} else if (jump_to && jump_to.attr("href")){
						jump_to.click();
					} else{
						$(document).trigger('close.facebox');
					}
					//renderUserHeader();
					window.reload();
					
					// not necessary when you reload the window...
					/*$("li.start_story a.authbox").removeClass("authbox").removeAttr("return_to").attr("href","/pitches/new");
					$("li.suggest_story a.authbox").removeClass("authbox").removeAttr("return_to").attr("href","/tips/new");
					if(("#assignment_admin").length > 0)
					{
					}
					if($("#flash").length > 0){
						$("#flash").html("");
					}*/
				}
			}
		}); // end ajax form
	}); // end livequery

	$("#facebox .content #fb_updater #fb_profile form").livequery(function() {
		var form = $(this);
		$(this).ajaxForm({
			complete: function(request,message) {
				if(message == "error") {
					$("#facebox .content #fb_profile").replaceWith(request.responseText);
				} else {
					$(document).trigger('close.facebox');
					renderUserHeader();
					$("li.start_story a.authbox").removeClass("authbox").removeAttr("return_to").attr("href","/start_story");
				}
			}
		});
	});
	
	$("#facebox .content #fb_updater #spotus_login form").livequery(function() {
		var form = $(this);
		$(this).ajaxForm({
			complete: function(request,message) {
				if(message == "error") {
					$("#facebox .content #spotus_login").replaceWith(request.responseText);
				} else {
					$(document).trigger('close.facebox');
					renderUserHeader();
					$("li.start_story a.authbox").removeClass("authbox").removeAttr("return_to").attr("href","/start_story");
				}
			}
		});
	});
	
	
	$('a[id*=help]').click(function() {
		jQuery.facebox({ajax:"/sections/"+$(this).attr('id')});
		return false;
	});
					
});

function showProfileForm(){
	jQuery.facebox.settings.modal = true;
	jQuery.facebox({ajax:"/myspot/profile/edit"});
}