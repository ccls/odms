jQuery(function(){
/*

	Consider using the inner text rather than value for clarity?

	Also, consider renaming javascript functions to include model name for clarity?

	As these use dom ids, there can be only one.

*/
	jQuery('#phone_number_is_valid').change(function(){
		toggle_why_invalid( ( $(this).val()!=2 && $(this).val()!=999 ) );
	});
	toggle_why_invalid( 
		( $('#phone_number_is_valid').val()!=2 && 
			$('#phone_number_is_valid').val()!=999 ) );

	jQuery('#phone_number_is_verified').change(function(){
		toggle_how_verified($(this).attr('checked'));
	});
	toggle_how_verified(
		$('#phone_number_is_verified').attr('checked'));

	jQuery('#phone_number_data_source_id').change(function(){
		toggle_data_source_other( $(this).find('option:selected').text() );
	});
	toggle_data_source_other( 
		$('#phone_number_data_source_id option:selected').text() );

});
/*
	These functions have the same name for editing a phone number
	and an phone_number so if there is ever a form with both,
	be aware, BE VERY AWARE!
*/
toggle_why_invalid = function(valid) {
	/* This SHOULD be REVERSED */
	if( valid ){
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

toggle_data_source_other = function( selected_source ) {
	if( /Other Source/.test( selected_source ) ){
		$('.data_source_other.field_wrapper').show()
	} else {
		$('.data_source_other.field_wrapper').hide()
	}
}
