jQuery(function(){
/*
	jQuery('#sample_sent_to_lab_on').change(function(){
		toggle_location( $(this).val() );
	});
	toggle_location( $('#sample_sent_to_lab_on').val() );
*/
});

toggle_location = function(date) {
	if( date ){
		$('.location_id.field_wrapper').css('visibility','visible')
	} else {
		$('.location_id.field_wrapper').css('visibility','hidden')
	}
}
