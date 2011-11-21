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
	Gonna try to be more object oriented and also use jquery plugin stuff
*/
/*
	possibly things like ...

	jQuery('a.submitter').formSubmitter();
	jQuery('a.toggle_eligibility_criteria').togglerFor('.eligibility_criteria');

*/

(function ($){  
	/* 
		My first jquery plugin. Used from ...
			public/javascripts/consent.js
			public/javascripts/contacts.js
	*/
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
	used in 
		edit_addressing.js

*/
(function ($){  
	$.fn.smartShow = function (inoptions) {
		var defaults = {
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
			$(this).change(function(){
				_smart_toggle();
			});
		});  
	};  
})(jQuery);


/*
http://asciicasts.com/episodes/261-testing-javascript-with-jasmine
var CreditCard = {  
  cleanNumber: function(number) {  
    return number.replace(/[- ]/g, "");  
  },  
    
  validNumber: function(number) {  
    var total = 0;  
    number = this.cleanNumber(number);  
    for (var i=number.length-1; i >= 0; i--) {  
      var n = parseInt(number[i]);  
      if ((i+number.length) % 2 == 0) {  
        n = n*2 > 9 ? n*2 - 9 : n*2;  
      }  
      total += n;  
    };  
    return total % 10 == 0;  
  }  
}  
    (function ($){  
      $.fn.validateCreditCardNumber = function () {  
        return this.each(function () {  
          $(this).blur(function () {  
            if (!CreditCard.validNumber(this.value)) {  
              $("#" + this.id + "_error").text("Invalid credit card number.");  
            }  
            else {  
              $("#" + this.id + "_error").text("");  
            }  
          });  
        });  
      };  
    })(jQuery);  
*/
