jQuery(function(){

//	20130129 - no longer using 'is_primary'
//	jQuery('form.edit_study_subject input:checkbox.is_primary_selector').click(function(){
//		/* if primary is checked, 
//				check partial race as well as uncheck other primary
//		*/
//		if( jQuery(this).prop('checked') ){
//			jQuery('#'+jQuery(this).attr('id').replace(/is_primary/,'race_id')
//				).prop('checked',true).change();
//			jQuery('#'+jQuery(this).attr('id').replace(/is_primary/,'_destroy')
//				).prop('checked',true).change();
//
//			/* easier to uncheck all, then recheck this one */
//			jQuery('form.edit_study_subject input:checkbox.is_primary_selector'
//				).prop('checked',false);
//			jQuery(this).prop('checked',true);
//		}
//	});
//
//	jQuery('form.edit_study_subject input:checkbox.race_selector').click(function(){
//		/* if race unchecked, uncheck is_primary too */
//		if( !jQuery(this).prop('checked') ){
//			jQuery('#'+jQuery(this).attr('id').replace(/race_id/,'is_primary')
//				).prop('checked',false).change();
//			jQuery('#'+jQuery(this).attr('id').replace(/_destroy/,'is_primary')
//				).prop('checked',false).change();
//		}
//	});

	jQuery('input[type=checkbox]#other_race_code').smartShow({
		what: '#specify_other_race',
		when: function(){
			return $('#other_race_code').prop('checked'); }
	});

	jQuery('input[type=checkbox]#other__destroy').smartShow({
		what: '#specify_other_race',
		when: function(){
			return $('#other__destroy').prop('checked'); }
	});

	jQuery('input[type=checkbox]#mixed_race_code').smartShow({
		what: '#specify_mixed_race',
		when: function(){
			return $('#mixed_race_code').prop('checked'); }
	});

	jQuery('input[type=checkbox]#mixed__destroy').smartShow({
		what: '#specify_mixed_race',
		when: function(){
			return $('#mixed__destroy').prop('checked'); }
	});

});
