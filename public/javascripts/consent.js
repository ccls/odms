jQuery(function(){

	jQuery('a.toggle_eligibility_criteria').togglerFor('.eligibility_criteria');

	jQuery('#enrollment_is_eligible').smartShow({
//		what: '.ineligible_reason_id.field_wrapper',
		what: '#subject_is_eligible',
		when: function(){ 
			return /no/i.test( 
				$('#enrollment_is_eligible option:selected').text() ) }
//				$(this).find('option:selected').text() ) }
	});

	jQuery('#enrollment_ineligible_reason_id').smartShow({
		what: '.ineligible_reason_specify.field_wrapper',
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

/*

	While this will certainly work, '2' is not particularly descriptive.
	I need to devise a way to make this more clearly, and flexibly, 'other'

*/
	jQuery('input[type=checkbox]#study_subject_subject_languages_attributes_2_language_id').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#study_subject_subject_languages_attributes_2_language_id').attr('checked'); }
	});

	jQuery('input[type=checkbox]#study_subject_subject_languages_attributes_2__destroy').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#study_subject_subject_languages_attributes_2__destroy').attr('checked'); }
	});

});
