jQuery(function(){

	jQuery('form#new_address').submit(state_check);

});

var state_check = function() {
	var state = jQuery('#address_state').val()
/*
	var type  = jQuery('#address_address_type_id').val()
	if( ( state != 'CA' ) && ( type == '1' ) &&
	var type  = jQuery('#address_address_type_id option:selected').text()
	if( ( state != 'CA' ) && ( type == 'residence' ) &&
*/
	var type  = jQuery('#address_address_type option:selected').text()
	if( ( state != 'CA' ) && ( /residence/i.test(type) ) &&
		( !confirm('This address is not in CA and will make study_subject ineligible.  Do you want to continue?') ) ) {
		return false;
	}
}
