jQuery(function(){

	jQuery('#enrollment_is_eligible').smartShow({
//		what: '.ineligible_reason_id.field_wrapper',
		what: '#subject_is_eligible',
		when: function(){ 
			return /no/i.test( 
				$('#enrollment_is_eligible option:selected').text() ) }
//				$(this).find('option:selected').text() ) }
	});

	jQuery('#enrollment_ineligible_reason_id').smartShow({
		what: '.other_ineligible_reason.field_wrapper',
		when: function(){ 
			return /other/i.test( 
				$('#enrollment_ineligible_reason_id option:selected').text() ) }
//				$(this).find('option:selected').text() ) }
	});

/*
	need consented on if consent is Yes or No
*/
	jQuery('#enrollment_consented').smartShow({
		what: '#subject_consented',
		when: function(){ 
			return /^(yes|no)/i.test( 
				$('#enrollment_consented option:selected').text() ) }
//				$(this).find('option:selected').text() ) }
	});

/*
	need refusal reason if consent is No
*/
	jQuery('#enrollment_consented').smartShow({
		what: '#subject_refused',
		when: function(){ 
			return /^no/i.test( 
				$('#enrollment_consented option:selected').text() ) }
//				$(this).find('option:selected').text() ) }
	});

	jQuery('#enrollment_refusal_reason_id').smartShow({
		what: '.other_refusal_reason.field_wrapper',
		when: function(){ 
			return /other/i.test( 
				$('#enrollment_refusal_reason_id option:selected').text() ) }
//				$(this).find('option:selected').text() ) }
	});


	jQuery('input[type=checkbox]#other_language_code').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#other_language_code').prop('checked'); }
	});

	jQuery('input[type=checkbox]#other__destroy').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#other__destroy').prop('checked'); }
	});

});
