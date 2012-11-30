jQuery(function(){
/*
	jQuery('#phone_number_is_valid').smartShow({
		what: '.why_invalid.field_wrapper',
		when: function(){ 
*/
			/* as 'no' matches both "No" and "Don't Know", only need one condition! */
/*
			return /no/i.test($('#phone_number_is_valid option:selected').text()); }
	});

	jQuery('#phone_number_is_verified').smartShow({
		what: '.how_verified.field_wrapper',
		when: function(){ 
			return $('#phone_number_is_verified').attr('checked'); }
	});
*/
	jQuery('#phone_number_data_source_id').smartShow({
		what: '.other_data_source.field_wrapper',
		when: function(){ 
			return /Other Source/.test( 
				$('#phone_number_data_source_id option:selected').text() ) }
	});

});
