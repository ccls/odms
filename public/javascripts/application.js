jQuery(function(){

//	var root = (location.host == 'ccls.berkeley.edu')?'/odms':''
	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''
	jQuery.getScript(root + '/users/menu.js');

	jQuery('a.submitter').click(submit_form);

	jQuery('form.confirm').submit(confirm_submission);

	jQuery('a.toggle_historic_addressings').click(function(){
		jQuery('.addressings .historic').toggle()
		return false;
	});

	jQuery('a.toggle_historic_phone_numbers').click(function(){
		jQuery('.phone_numbers .historic').toggle()
		return false;
	});

/*
	jQuery('form.destroy_link_to').submit(function(){
		var message = "Destroy?  Seriously?"
		if( this.confirm && this.confirm.value ) {
			message = this.confirm.value
		}
		if( !confirm(message) ){
			return false;
		}
	});

	jQuery('p.flash').click(function(){jQuery(this).remove();});

	jQuery('.datepicker').datepicker();
*/

	jQuery('a.ajax').click(function(){
		jQuery.get(jQuery(this).attr('href')+'.js', function(data){
			jQuery('#ajax').html(data);
		});
		return false;
	});

	jQuery('form.edit_subject input:checkbox.is_primary_selector').click(function(){
		/* if primary is checked, 
				check partial race as well as uncheck other primary
		*/
		if( jQuery(this).attr('checked') ){
			var id = jQuery(this).attr('id').replace(/_is_primary/,'');
			jQuery('#'+id).attr('checked',true);

			/* easier to uncheck all, then recheck this one */
			jQuery('form.edit_subject input:checkbox.is_primary_selector').attr('checked',false);
			jQuery(this).attr('checked',true);
		}
	});

	jQuery('form.edit_subject input:checkbox.race_selector').click(function(){
		/* if race unchecked, uncheck is_primary too */
		if( !jQuery(this).attr('checked') ){
			jQuery('#'+jQuery(this).attr('id')+'_is_primary').attr('checked',false);
		}
	});


	jQuery('#subject_patient_attributes_raf_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_address_info(data[0].zip_code);
			}
		});
	});

	jQuery('#subject_addressings_attributes_0_address_attributes_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_address_info(data[0].zip_code);
			}
		});
	});

});

var submit_form = function() {
	form_id = this.id.replace(/^for_/,'');
	jQuery('form#'+form_id).submit();
	return false;
}

var confirm_submission = function(){
	if( !confirm("Please confirm that you want to save all changes. Otherwise, press 'cancel' and navigate to another page without saving.") ){
		return false;
	}
}

var update_address_info = function(zip_code) {
/*
	[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
*/
/* only copy in the values if the target is empty */
	var address_zip = jQuery('#subject_addressings_attributes_0_address_attributes_zip');
	if( address_zip && !address_zip.val() ){
		address_zip.val(zip_code.zip_code);
	}
	var address_county = jQuery('#subject_addressings_attributes_0_address_attributes_county');
	if( address_county && !address_county.val() ){
		address_county.val(zip_code.county_name);
	}
	var address_city = jQuery('#subject_addressings_attributes_0_address_attributes_city');
	if( address_city && !address_city.val() ){
		address_city.val(zip_code.city);
	}
	var address_state = jQuery('#subject_addressings_attributes_0_address_attributes_state');
	if( address_state && !address_state.val() ){
		address_state.val(zip_code.state);
	}
	var raf_zip = jQuery('#subject_patient_attributes_raf_zip');
	if( raf_zip && !raf_zip.val() ){
		raf_zip.val(zip_code.zip_code);
	}
	var raf_county = jQuery('#subject_patient_attributes_raf_county');
	if( raf_county && !raf_county.val() ){
		raf_county.val(zip_code.county_name);
	}
}
