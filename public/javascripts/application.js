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
		var address_zip = jQuery('#subject_addressings_attributes_0_address_attributes_zip');
		/* only copy in the value of the target is empty */
		if( address_zip && !address_zip.val() ){
			address_zip.val(jQuery(this).val());
		}
	});

	jQuery('#subject_patient_attributes_raf_county_id').change(function(){
		var address_county = jQuery('#subject_addressings_attributes_0_address_attributes_county');
		if( address_county && !address_county.val() ){
/*
	This is still incomplete as we'll probably use county_id and not just county
*/
			address_county.val(jQuery(this).find('option:selected').text());
		}
	});

/*



	NOTE that there are now 2 "change" event calls for this element.
		it will probably cause some grief, so we'll need to figure this out.



*/

	jQuery('#subject_patient_attributes_raf_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
//[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
			if(data.length == 1) {
				var raf_zip = jQuery('#subject_patient_attributes_raf_zip');
				if( raf_zip ){
					raf_zip.val(data[0].zip_code.zip_code);
				}
//	zip_codes outside of CA aren't listed
				var raf_county_id = jQuery('#subject_patient_attributes_raf_county_id');
				if( raf_county_id ){
					raf_county_id.val(data[0].zip_code.county_id);
				}
			}
		});
	});

	jQuery('#subject_addressings_attributes_0_address_attributes_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
//[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
			if(data.length == 1) {
				var address_zip = jQuery('#subject_addressings_attributes_0_address_attributes_zip');
				if( address_zip ){
					address_zip.val(data[0].zip_code.zip_code);
				}
				var address_county = jQuery('#subject_addressings_attributes_0_address_attributes_county');
				if( address_county && !address_county.val() ){
					address_county.val(data[0].zip_code.county_name);
				}
				var address_city = jQuery('#subject_addressings_attributes_0_address_attributes_city');
				if( address_city && !address_city.val() ){
					address_city.val(data[0].zip_code.city);
				}
				var address_state = jQuery('#subject_addressings_attributes_0_address_attributes_state');
				if( address_state && !address_state.val() ){
					address_state.val(data[0].zip_code.state);
				}
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
