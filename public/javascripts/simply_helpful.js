jQuery(function(){

/*
	This is no longer used.

	jQuery('button.link').click(function(){
		window.location.href = $(this).find('span.href').text();
	});
*/

	jQuery('form.destroy_link_to').submit(function(){
		var message = "Destroy?  Seriously?"
		if( this.confirm && this.confirm.value ) {
			message = this.confirm.value
		}
		if( !confirm(message) ){
			return false;
		}
	});

	jQuery('p.flash').click(function(){$(this).remove();});

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

