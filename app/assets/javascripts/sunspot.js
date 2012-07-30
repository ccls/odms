jQuery(function(){

	jQuery('div.facet_toggle a').click(function(){
		jQuery(this).parent().next().toggle(500);
		jQuery(this).prev().toggleClass('ui-icon-triangle-1-e');
		jQuery(this).prev().toggleClass('ui-icon-triangle-1-s');
		return false;
	});

	jQuery( "#sortable1, #sortable2" ).sortable({
		connectWith: ".connectedSortable"
	}).disableSelection();

	jQuery('form').submit(function(){
		jQuery('#sortable1 li').each(function(){
			jQuery('<input>').attr({ 
				name: 'columns[]', 
				type: 'hidden', 
				value: $(this).text() 
			}).appendTo('form');
		});
	});
});
