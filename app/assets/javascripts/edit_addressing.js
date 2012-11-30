jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''

	jQuery('#addressing_address_attributes_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_city_state_county(data[0]);
			}
		});
	});
/*
	jQuery('#addressing_is_valid').smartShow({
		what: '.why_invalid.field_wrapper',
		when: function(){ 
*/
			/* as 'no' matches both "No" and "Don't Know", only need one condition! */
/*
			return /no/i.test($('#addressing_is_valid option:selected').text()); }
	});

	jQuery('#addressing_is_verified').smartShow({
		what: '.how_verified.field_wrapper',
		when: function(){ 
			return $('#addressing_is_verified').attr('checked'); }
	});
*/
	jQuery('#addressing_data_source_id').smartShow({
		what: '.other_data_source.field_wrapper',
		when: function(){ 
			return /Other Source/.test( 
				$('#addressing_data_source_id option:selected').text() ) }
	});

/*
	This ONLY changes if is residence first and then current
	is changed to no.  It also does not uncheck the box if changed
	back to yes.  The value is probably kept and checkbox is still
	hidden if address fails validation,
	and then kicks back to edit.  Made ruby handle better.
*/
	jQuery('#addressing_current_address').smartShow({
		what: 'div.moved > div.subject_moved',
		when: function(){
			return ( /^no$/i.test( 
				$('#addressing_current_address option:selected').text() ) &&
				/residence/i.test( 
					$('#addressing_address_attributes_address_type_id option:selected').text() ) ) }
	});

	var county_field = jQuery('#addressing_address_attributes_county');
	var state_field = jQuery('#addressing_address_attributes_state');
	// this will dump the value on page reload
	county_field.autocomplete({ source : california_counties });
	state_field.change(function(){
		if( $(this).val() == 'CA' ){
			county_field.autocomplete('option', 'disabled', false );
		} else {
			county_field.autocomplete('option', 'disabled', true );
		}
	}).change(); 

});

/* rather than pulling these from the database everytime, just hard code it. */
var california_counties = ["Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte", "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen", "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey", "Napa", "Nevada", "Orange", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito", "San Bernardino", "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo", "Santa Barbara", "Santa Clara", "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma", "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"];

var update_city_state_county = function(zip_code) {
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
		// changing the val does not trigger the change event
		// so do it manually.
		address_state.change();
	}
};
