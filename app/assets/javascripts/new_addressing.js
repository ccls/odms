jQuery(function(){

	jQuery('form#new_addressing').submit(state_check);

});

var state_check = function() {
	var state = jQuery('#addressing_address_attributes_state').val()
/*
	var type  = jQuery('#addressing_address_attributes_address_type_id').val()
	if( ( state != 'CA' ) && ( type == '1' ) &&
*/
	var type  = jQuery('#addressing_address_attributes_address_type_id option:selected').text()
	if( ( state != 'CA' ) && ( type == 'residence' ) &&
		( !confirm('This address is not in CA and will make study_subject ineligible.  Do you want to continue?') ) ) {
		return false;
	}
}
