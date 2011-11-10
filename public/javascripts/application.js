jQuery(function(){

//	var root = (location.host == 'ccls.berkeley.edu')?'/odms':''
	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''
	jQuery.getScript(root + '/users/menu.js');

/*
	a.submitter is used in basically all forms that use the "id_bar" which is not inside the form element.
		addressings new/edit
		consents edit
		enrollments new/edit
		patients new/edit
		phone_numbers new/edit
		study_subjects edit
*/
	jQuery('a.submitter').click(submit_form);

/*
	form.confirm is used on most edit forms
		addressings, consents, enrollments, patients, phone_numbers, projects, study_subjects
*/
	jQuery('form.confirm').submit(confirm_submission);

/*	
	Moved to contacts.js

	jQuery('a.toggle_historic_addressings').click(function(){
		jQuery('.addressings .historic').toggle()
		return false;
	});

	jQuery('a.toggle_historic_phone_numbers').click(function(){
		jQuery('.phone_numbers .historic').toggle()
		return false;
	});
*/

/*
	This is used in homex/app/views/samples/show.html.erb, for packages, but not in odms.

	jQuery('a.ajax').click(function(){
		jQuery.get(jQuery(this).attr('href')+'.js', function(data){
			jQuery('#ajax').html(data);
		});
		return false;
	});
*/

/*
	Moved to edit_study_subject.js

	jQuery('form.edit_study_subject input:checkbox.is_primary_selector').click(function(){

		if( jQuery(this).attr('checked') ){
			var id = jQuery(this).attr('id').replace(/_is_primary/,'');
			jQuery('#'+id).attr('checked',true);

	
			jQuery('form.edit_study_subject input:checkbox.is_primary_selector').attr('checked',false);
			jQuery(this).attr('checked',true);
		}
	});

	jQuery('form.edit_study_subject input:checkbox.race_selector').click(function(){
		
		if( !jQuery(this).attr('checked') ){
			jQuery('#'+jQuery(this).attr('id')+'_is_primary').attr('checked',false);
		}
	});

*/
});

var submit_form = function() {
	form_id = this.id.replace(/^for_/,'');
	jQuery('form#'+form_id).submit();
	return false;
}

var confirm_submission = function(){
	if( !confirm("Please confirm that you want to save all changes. Otherwise, press 'cancel' and navigate to another page without saving.") ){
		return false;
	}
}
