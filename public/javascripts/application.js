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

In the ODMS layout, this no longer exists.  Just HomeX.

	jQuery('a.submitter').click(submit_form);
*/

/*
	form.confirm is used on most edit forms
		addressings, consents, enrollments, patients, phone_numbers, projects, study_subjects
*/
	jQuery('form.confirm').submit(confirm_submission);

});

var submit_form = function() {
	form_id = this.id.replace(/^for_/,'');
	jQuery('form#'+form_id).submit();
	return false;
};

var confirm_submission = function(){
	if( !confirm("Please confirm that you want to save all changes. Otherwise, press 'cancel' and navigate to another page without saving.") ){
		return false;
	}
};

/* 
	Used in ...
		consent.js
		contacts.js
*/
(function ($){  
	$.fn.togglerFor = function (toggled_selector) {  
		/*
			If 'toggled_selector' is blank, or doesn't exist,
				nothing happens.
		*/
		return this.each(function () {  
			$(this).click(function(){
				$(toggled_selector).toggle()
				return false;
			});
		});  
	};  
})(jQuery);  


/*
	Used in ...
		edit_addressing.js
*/
(function ($){  
	$.fn.smartShow = function (inoptions) {
		var defaults = {
//			this: this,
			what: 'some css selector string',
			when: function(){ /* some function that returns true or false */ }
		};
		var options = $.extend(defaults, inoptions);
		var _smart_toggle = function () {
//alert('smart toggling');
			if( options.when() ){
//alert('showing '+options.what);
				$(options.what).show();
			} else {
//alert('hiding '+options.what);
				$(options.what).hide();
			};
		};
		return this.each(function () {  
			/* do initial toggle, then bind to change event. */
			_smart_toggle();	
			$(this).change(function(){
				_smart_toggle();
			});
		});  
	};  
})(jQuery);
