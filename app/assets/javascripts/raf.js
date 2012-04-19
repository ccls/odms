jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''

	jQuery('#study_subject_patient_attributes_raf_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
/*
				update_city_state_county(data[0].zip_code);
	in rails 3, doesn't include first key so trying without
*/
				update_address_info(data[0]);
			}
		});
	});

	jQuery('#study_subject_addressings_attributes_0_address_attributes_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
/*
				update_address_info(data[0].zip_code);
	in rails 3, doesn't include first key so trying without
*/
				update_address_info(data[0]);
			}
		});
	});

/*
	jQuery('#study_subject_patient_attributes_diagnosis_id').smartShow({
		what: 'form.raf div.other_diagnosis',
		when: function(){ 
			return /Other/i.test( 
				$('#study_subject_patient_attributes_diagnosis_id option:selected').text() )
		}
	});
*/

	jQuery('#study_subject_enrollments_attributes_0_refusal_reason_id').smartShow({
		what: 'form.raf div.other_refusal_reason',
		when: function(){ 
			return /Other reason/i.test( 
				$('#study_subject_enrollments_attributes_0_refusal_reason_id option:selected').text() )
		}
	});

	jQuery('input[type=checkbox]#other_language_id').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#other_language_id').attr('checked'); }
	});




	// use class so that this works for both county fields.
	var county_fields = jQuery('.county_field');
	var state_field = jQuery(
		'#study_subject_addressings_attributes_0_address_attributes_state');
	// this will dump the value on page reload
	county_fields.autocomplete({ source : california_counties });
	state_field.change(function(){
		if( $(this).val() == 'CA' ){
			county_fields.autocomplete('option', 'disabled', false );
		} else {
			county_fields.autocomplete('option', 'disabled', true );
		}
	}).change(); 

});

/* rather than pulling these from the database everytime, just hard code it. */
var california_counties = ["Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte", "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "LAKE", "Lassen", "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey", "Napa", "NEVADA", "ORANGE", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito", "San Bernardino", "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo", "Santa Barbara", "Santa Clara", "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma", "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"];



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
