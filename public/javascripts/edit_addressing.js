jQuery(function(){

/*

	Consider using the inner text rather than value for clarity?

	Also, consider renaming javascript functions to include model name for clarity?

	As these use dom ids, there can be only one.

*/
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

	jQuery('#addressing_data_source_id').change(function(){
		toggle_data_source_other( 

$(this).find('option:selected').text() match 'Other'

        var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''


>>> $('#phone_number_data_source_id').find('option:selected').text()

>>> $('#phone_number_data_source_id option:selected').text()

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
