jQuery(function(){

	jQuery('#addressing_is_valid').change(function(){
		toggle_why_invalid( ( $(this).val()!=2 && $(this).val()!=999 ) );
	});

  toggle_why_invalid( 
		( $('#addressing_is_valid').val()!=2 && 
			$('#addressing_is_valid').val()!=999 ) );

	jQuery('#addressing_is_verified').change(function(){
		toggle_how_verified($(this).attr('checked'));
	});

  toggle_how_verified( 
		$('#addressing_is_verified').attr('checked') );

/*

	toggle data source other

*/

});
/*
	These functions have the same name for editing a phone number
	and an addressing so if there is ever a form with both,
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
