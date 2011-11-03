jQuery(function(){

	jQuery('.valid .is_valid #phone_number_is_valid').change(function(){
		toggle_why_invalid( ( $(this).val()!=2 && $(this).val()!=999 ) );
	});

	jQuery('.verified .is_verified #phone_number_is_verified').change(function(){
		toggle_how_verified($(this).attr('checked'));
	});

	toggle_why_invalid( 
		( $('.valid .is_valid #phone_number_is_valid').val()!=2 && 
			$('.valid .is_valid #phone_number_is_valid').val()!=999 ) );

	toggle_how_verified(
		$('.verified .is_verified #phone_number_is_verified').attr('checked'));

});
/*
	These functions have the same name for editing a phone number
	and an phone_number so if there is ever a form with both,
	be aware, BE VERY AWARE!
*/
toggle_why_invalid = function(checked) {
	/* This SHOULD be REVERSED */
	if( checked ){
		$('.why_invalid.field_wrapper').hide()
	} else {
		$('.why_invalid.field_wrapper').show()
	}
}

toggle_how_verified = function(checked) {
	if( checked ){
		$('.how_verified.field_wrapper').show()
	} else {
		$('.how_verified.field_wrapper').hide()
	}
}
