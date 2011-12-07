jQuery(function(){

	jQuery('a.toggle_eligibility_criteria').togglerFor('.eligibility_criteria');

	jQuery('#enrollment_is_eligible').smartShow({
		what: '.ineligible_reason_id.field_wrapper',
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

	This is complicated by the fact that the language_id may be a type=hidden field

	This seems to work in practice, but testing is proving challenging

*/
	jQuery('input[type=checkbox]#study_subject_subject_languages_attributes_2_language_id').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#study_subject_subject_languages_attributes_2_language_id').attr('checked'); }
	});
/* 
	put destroy AFTER language_id as both target the same element 
	I should try to make this not matter.
*/
	jQuery('input[type=checkbox]#study_subject_subject_languages_attributes_2__destroy').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#study_subject_subject_languages_attributes_2__destroy').attr('checked'); }
	});
//			return true; }
//			return /checked/i.test($('#study_subject_subject_languages_attributes_2_language_id').attr('checked')); }
//			return /checked/i.test($('#study_subject_subject_languages_attributes_2_language_id').attr('checked')); }
//			alert ( $('#study_subject_subject_languages_attributes_2_language_id').attr('checked') ) ;
//			return $('#study_subject_subject_languages_attributes_2_language_id').attr('checked'); }
//			return ( $('#study_subject_subject_languages_attributes_2_language_id').attr('checked') == 'checked' ) }
//			return $(this).checked() }

});
