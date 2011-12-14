jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''

	jQuery('#study_subject_patient_attributes_raf_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_address_info(data[0].zip_code);
			}
		});
	});

	jQuery('#study_subject_addressings_attributes_0_address_attributes_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_address_info(data[0].zip_code);
			}
		});
	});

	jQuery('#study_subject_patient_attributes_diagnosis_id').smartShow({
		what: 'form.raf div.other_diagnosis',
		when: function(){ 
			return /Other/i.test( 
				$('#study_subject_patient_attributes_diagnosis_id option:selected').text() )
		}
	});

/*

	While this will certainly work, '2' is not particularly descriptive.
	I need to devise a way to make this more clearly, and flexibly, 'other'

*/
/*
	jQuery('input[type=checkbox]#study_subject_subject_languages_attributes_2_language_id').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#study_subject_subject_languages_attributes_2_language_id').attr('checked'); }
	});
*/
	jQuery('input[type=checkbox]#other_language_id').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#other_language_id').attr('checked'); }
	});

});

var update_address_info = function(zip_code) {
/*
	[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
*/
/* only copy in the values if the target is empty */
	var address_zip = jQuery('#study_subject_addressings_attributes_0_address_attributes_zip');
	if( address_zip && !address_zip.val() ){
		address_zip.val(zip_code.zip_code);
	}
	var address_county = jQuery('#study_subject_addressings_attributes_0_address_attributes_county');
	if( address_county && !address_county.val() ){
		address_county.val(zip_code.county_name);
	}
	var address_city = jQuery('#study_subject_addressings_attributes_0_address_attributes_city');
	if( address_city && !address_city.val() ){
		address_city.val(zip_code.city);
	}
	var address_state = jQuery('#study_subject_addressings_attributes_0_address_attributes_state');
	if( address_state && !address_state.val() ){
		address_state.val(zip_code.state);
	}
	var raf_zip = jQuery('#study_subject_patient_attributes_raf_zip');
	if( raf_zip && !raf_zip.val() ){
		raf_zip.val(zip_code.zip_code);
	}
	var raf_county = jQuery('#study_subject_patient_attributes_raf_county');
	if( raf_county && !raf_county.val() ){
		raf_county.val(zip_code.county_name);
	}
}
