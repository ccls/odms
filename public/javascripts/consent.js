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
 28 #<div class='subject_language creator'><div id='other_language'><input name="study_subject[subject_languages_attributes][2][language_id]" type="hidden"     value="" /><input id="study_subject_subject_languages_attributes_2_language_id" name="study_subject[subject_languages_attributes][2][language_id]" typ    e="checkbox" value="3" />
 29 #<label for="study_subject_subject_languages_attributes_2_language_id">Other (not eligible)</label>
 30 #<div id='specify_other_language'><label for="study_subject_subject_languages_attributes_2_other">specify:</label>
 31 #<input id="study_subject_subject_languages_attributes_2_other" name="study_subject[subject_languages_attributes][2][other]" size="12" type="text" />
 32 #</div></div></div>
 33 #</div>

	while '2' is currently fixed, may want to change this to something more descriptive, like

	$("div.subject_language.creator > #other_language input[type=checkbox]")
would also like to use 'this' in the when function, but haven't implemented it just yet.
*/
// regardless of whether the first jquery selector matches anything something may be hidden based on the when function

/*

	This is complicated by the fact that the language_id may be a type=hidden field

*/
	jQuery('#study_subject_subject_languages_attributes_2_language_id').smartShow({
		what: '#specify_other_language',
		when: function(){
			return $('#study_subject_subject_languages_attributes_2_language_id').attr('checked'); }
	});
//			return true; }
//			return /checked/i.test($('#study_subject_subject_languages_attributes_2_language_id').attr('checked')); }
//			return /checked/i.test($('#study_subject_subject_languages_attributes_2_language_id').attr('checked')); }
//			alert ( $('#study_subject_subject_languages_attributes_2_language_id').attr('checked') ) ;
//			return $('#study_subject_subject_languages_attributes_2_language_id').attr('checked'); }
//			return ( $('#study_subject_subject_languages_attributes_2_language_id').attr('checked') == 'checked' ) }
//			return $(this).checked() }

});
