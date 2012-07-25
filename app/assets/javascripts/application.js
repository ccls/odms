jQuery(function(){

/*
	form.confirm is used on most edit forms
		addressings, consents, enrollments, patients, phone_numbers, projects, study_subjects
*/
	jQuery('form.confirm').submit(confirm_submission);

	jQuery('a.toggler').toggler();



        jQuery('div.facet_toggle a').click(function(){
                jQuery(this).parent().next().toggle(500);
                jQuery(this).prev().toggleClass('ui-icon-triangle-1-e');
                jQuery(this).prev().toggleClass('ui-icon-triangle-1-s');
                return false;
        });

});

/*

	I don't think that this is used anymore.

var submit_form = function() {
	form_id = this.id.replace(/^for_/,'');
	jQuery('form#'+form_id).submit();
	return false;
};
*/

var confirm_submission = function(){
	if( !confirm("Please confirm that you want to save all changes. Otherwise, press 'cancel' and navigate to another page without saving.") ){
		return false;
	}
};

/*
	This toggler gets the toggleds from the togglers classes.

	A tag with a class including 'toggles_something' will, when clicked,
	toggle the tag with the id of 'something'.  The class can include
	multiple toggle targets.  I've enabled this with simply ...

		jQuery('a.toggler').toggler();

	I'd like to replace my uses of togglerFor with this.
	
	Currently used in ...
		birth_datum_update#show
		icf_master_tracker_update#show
		consent#show
		consent#edit
		contacts#index
*/
(function ($){  
	$.fn.toggler = function () {  
		/*
			If toggled selector  is blank, or doesn't exist,
				nothing happens.
		*/
		return this.each(function () {  
			$(this).click(function(){
				$($(this).attr('class').split(/\s+/)).each( function(){
					if( /^toggles_/.test(this) ){
						toggled = this.replace(/^toggles_/,'#');
						$(toggled).toggle()
					}
				});
				return false;
			});
		});  
	};  
})(jQuery);  


/* 


	This should no longer be being used.

	Used in ...
*/
		/*
			If 'toggled_selector' is blank, or doesn't exist,
				nothing happens.
		*/
/*
(function ($){  
	$.fn.togglerFor = function (toggled_selector) {  
		return this.each(function () {  
			$(this).click(function(){
				$(toggled_selector).toggle()
				return false;
			});
		});  
	};  
})(jQuery);  
*/


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

/* try to make sure that the format here is the same in the ruby helper */
	if( typeof jQuery('.datetimepicker').datetimepicker == 'function' ){
		jQuery('.datetimepicker').datetimepicker({
		});
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

