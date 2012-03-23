jQuery(function(){

//	var root = (location.host == 'ccls.berkeley.edu')?'/odms':''
/*
	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''
	jQuery.getScript(root + '/users/menu.js');
*/

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
		consent.js
		edit_addressing.js
		edit_patient.js
		edit_phone_number.js
		raf.js
*/
(function ($){  
	$.fn.smartShow = function (inoptions) {
		var defaults = {
//			this: this,	// I'd really like to enable the ability to use 'this' in the when functions
			what: 'some css selector string',
			when: function(){ /* some function that returns true or false */ }
		};
		var options = $.extend(defaults, inoptions);
		var _smart_toggle = function () {
			if( options.when() ){
				$(options.what).show();
			} else {
				$(options.what).hide();
			};
		};
		return this.each(function () {  
			/* do initial toggle, then bind to change event. */
			_smart_toggle();	
			$(this).change(function(){ _smart_toggle(); });
		});  
	};  
})(jQuery);




/* BELOW WAS COMMON_LIB.JS */

jQuery(function(){

/* 
	'clicking' a submit button apparently skips the 'submit' method 
		which then skips the destroy confirmation, so we need to explicitly
		catch the click and manually submit to trigger the confirmation.
*/
	jQuery('form.destroy_link_to input[type=submit]').click(function(){
		jQuery(this).parents('form').submit();
		return false;
	});

	jQuery('form.destroy_link_to').submit(function(){
		var message = "Destroy?  Seriously?"
		if( this.confirm && this.confirm.value ) {
			message = this.confirm.value
		}
		if( !confirm(message) ){
			return false;
		}
	});

/*	Don't do this anymore. */
/*
	jQuery('p.flash').click(function(){$(this).remove();});
*/

	if( typeof jQuery('.datepicker').datepicker == 'function' ){
		jQuery('.datepicker').datepicker();
	}

	jQuery('form a.submit.button').siblings('input[type=submit]').hide();

	jQuery('form a.submit.button').click(function(){
		if( jQuery(this).next('input[type=submit]').length > 0 ){
			jQuery(this).next().click();
		} else {
			jQuery(this).parents('form').submit();
		}
		return false;
	});

});


jQuery(window).resize(function(){
	resize_text_areas()
});

jQuery(window).load(function(){
/*
	This MUST be in window/load, not the normal document/ready,
	for Google Chrome to get correct values
*/
	resize_text_areas()
});

function resize_text_areas() {
/*
	jQuery('textarea.autosize').each(function(){
*/
	jQuery('.autosize').each(function(){
		new_width = $(this).parent().innerWidth() +
			$(this).parent().position().left -
			$(this).position().left -
			parseInt($(this).css('margin-left')) -
			parseInt($(this).css('margin-right')) -
			parseInt($(this).css('padding-left')) -
			parseInt($(this).css('padding-right')) -
			parseInt($(this).css('border-left-width')) -
			parseInt($(this).css('border-right-width') )
		$(this).css('width',new_width-10)	/* take 10 more for good measure */
	})
}

