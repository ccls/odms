jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''

	jQuery('input.zip_field').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_address_info(data[0]);
			}
		});
	});

	jQuery('#study_subject_patient_attributes_diagnosis').smartShow({
		what: 'form.raf div.other_diagnosis',
		when: function(){ 
			return /Other/i.test( 
				$('#study_subject_patient_attributes_diagnosis option:selected').text() )
		}
	});

	jQuery('#study_subject_enrollments_attributes_0_refusal_reason_id').smartShow({
		what: 'form.raf div.other_refusal_reason',
		when: function(){ 
			return /Other reason/i.test( 
				$('#study_subject_enrollments_attributes_0_refusal_reason_id option:selected').text() )
		}
	});

	jQuery('input[type=checkbox]#other_language_code').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#other_language_code').prop('checked'); }
	});


	// use class so that this works for both county fields.
	var county_fields = jQuery('input.county_field');
	var state_fields = jQuery('.csz select.state');
	// this will dump the value on page reload
	county_fields.autocomplete({ source : california_counties });
	state_fields.change(function(){
		if( $(this).val() == 'CA' ){
			county_fields.autocomplete('option', 'disabled', false );
		} else {
			county_fields.autocomplete('option', 'disabled', true );
		}
	}).change(); 

});

/* rather than pulling these from the database everytime, just hard code it. */
var california_counties = ["Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte", "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen", "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey", "Napa", "Nevada", "Orange", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito", "San Bernardino", "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo", "Santa Barbara", "Santa Clara", "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma", "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"];



var update_address_info = function(zip_code) {
/*
	[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
*/
/* only copy in the values if the target is empty */
/* zip_field and county_field for both the zip and county and raf_zip and raf_county*/
	jQuery('input.zip_field').each( function(){
		if( !$(this).val() ){
			$(this).val(zip_code.zip_code);
		}
	});
	jQuery('input.county_field').each(function(){
		if( !$(this).val() ){
			$(this).val(zip_code.county_name);
		}
	});
	jQuery('.csz input.city').each(function(){
		if( !$(this).val() ){
			$(this).val(zip_code.city);
		}
	});
	jQuery('.csz select.state').each(function(){
		if( !$(this).val() ){
			$(this).val(zip_code.state);
		}
	});
}
