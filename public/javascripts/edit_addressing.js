jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''

	jQuery('#addressing_address_attributes_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_city_state_county(data[0].zip_code);
			}
		});
	});

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

	jQuery('#addressing_data_source_id').change(function(){
		toggle_data_source_other( $(this).find('option:selected').text() );
	});
	toggle_data_source_other( 
		$('#addressing_data_source_id option:selected').text() );

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

toggle_data_source_other = function( selected_source ) {
	if( /Other Source/.test( selected_source ) ){
		$('.data_source_other.field_wrapper').show()
	} else {
		$('.data_source_other.field_wrapper').hide()
	}
}

update_city_state_county = function(zip_code) {
/*
	[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
*/
/* only copy in the values if the target is empty */
	var address_county = jQuery('#addressing_address_attributes_county');
	if( address_county && !address_county.val() ){
		address_county.val(zip_code.county_name);
	}
	var address_city = jQuery('#addressing_address_attributes_city');
	if( address_city && !address_city.val() ){
		address_city.val(zip_code.city);
	}
	var address_state = jQuery('#addressing_address_attributes_state');
	if( address_state && !address_state.val() ){
		address_state.val(zip_code.state);
	}
}
