jQuery(function(){

	jQuery('form.edit_study_subject input:checkbox.is_primary_selector').click(function(){
		/* if primary is checked, 
				check partial race as well as uncheck other primary
		*/
		if( jQuery(this).attr('checked') ){
			var id = jQuery(this).attr('id').replace(/_is_primary/,'');
			jQuery('#'+id).attr('checked',true);

			/* easier to uncheck all, then recheck this one */
			jQuery('form.edit_study_subject input:checkbox.is_primary_selector').attr('checked',false);
			jQuery(this).attr('checked',true);
		}
	});

	jQuery('form.edit_study_subject input:checkbox.race_selector').click(function(){
		/* if race unchecked, uncheck is_primary too */
		if( !jQuery(this).attr('checked') ){
			jQuery('#'+jQuery(this).attr('id')+'_is_primary').attr('checked',false);
		}
	});

});
