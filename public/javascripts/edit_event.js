jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''





/*
	jQuery('#addressing_address_attributes_zip').change(function(){
		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
			if(data.length == 1) {
				update_city_state_county(data[0].zip_code);
			}
		});
	});
*/

});

/*
	[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
*/
/* only copy in the values if the target is empty */
/*
var update_city_state_county = function(zip_code) {
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
};
*/
