jQuery(function(){

	jQuery('div.facet_toggle a').click(function(){
//		jQuery(this).parent().next().toggle(500);
//  added 'blind' so doesn't resize stuff and just slides in.
//	be advised that this effect temporarily wraps the target in a div until done.
		jQuery(this).parent().next().toggle('blind',500);
		jQuery(this).prev().toggleClass('ui-icon-triangle-1-e');
		jQuery(this).prev().toggleClass('ui-icon-triangle-1-s');
		return false;
	});

	jQuery( "#selected_columns, #unselected_columns" ).sortable({
		connectWith: ".selectable_columns"
	}).disableSelection();

	jQuery('form').submit(function(){
		jQuery('#selected_columns li').each(function(){
			jQuery('<input>').attr({ 
				name: 'c[]', 
				type: 'hidden', 
				value: $(this).text() 
			}).appendTo('form');
		});
	});

});
