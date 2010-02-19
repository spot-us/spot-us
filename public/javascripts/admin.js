jQuery(document).ready(function($){
	function get_fact_check_chooser(anchor) {
		var td = $(anchor).parent('td.fact_checker');
		var chooser = $.get($(anchor).attr('href'), {}, 
			function(html, status){ td.html(html); }
		);
	}
	$('td.fact_checker a.change_fact_checker').click(function(e){
		get_fact_check_chooser(this);
		return false;
	});
});