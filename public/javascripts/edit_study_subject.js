jQuery(function(){

	jQuery('form.edit_study_subject input:checkbox.is_primary_selector').click(function(){
		/* if primary is checked, 
				check partial race as well as uncheck other primary
		*/
		if( jQuery(this).attr('checked') ){
//		var id = jQuery(this).attr('id').replace(/_is_primary/,'');
//		jQuery('#'+id).attr('checked',true);
// could be race_id or _destroy ????  Change these to use common class?
			jQuery('#'+jQuery(this).attr('id').replace(/is_primary/,'race_id')
				).attr('checked',true).change();
			jQuery('#'+jQuery(this).attr('id').replace(/is_primary/,'_destroy')
				).attr('checked',true).change();

			/* easier to uncheck all, then recheck this one */
			jQuery('form.edit_study_subject input:checkbox.is_primary_selector'
				).attr('checked',false);
			jQuery(this).attr('checked',true);
		}
	});

	jQuery('form.edit_study_subject input:checkbox.race_selector').click(function(){
		/* if race unchecked, uncheck is_primary too */
		if( !jQuery(this).attr('checked') ){
//			jQuery('#'+jQuery(this).attr('id')+'_is_primary').attr('checked',false);
			jQuery('#'+jQuery(this).attr('id').replace(/race_id/,'is_primary')
				).attr('checked',false).change();
			jQuery('#'+jQuery(this).attr('id').replace(/_destroy/,'is_primary')
				).attr('checked',false).change();
		}
	});

	jQuery('input[type=checkbox]#other_race_id').smartShow({
		what: '#specify_other_race',
		when: function(){
			return $('#other_race_id').attr('checked'); }
	});

	jQuery('input[type=checkbox]#other__destroy').smartShow({
		what: '#specify_other_race',
		when: function(){
			return $('#other__destroy').attr('checked'); }
	});

});
