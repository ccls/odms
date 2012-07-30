jQuery(function(){
	jQuery( "#sortable1, #sortable2" ).sortable({
		connectWith: ".connectedSortable"
	}).disableSelection();

	jQuery('form').submit(function(){
		jQuery('#sortable1 li').each(function(){
			$('<input>').attr({ 
				name: 'columns[]', 
				type: 'hidden', 
				value: $(this).text() }).appendTo('form');
		});
	});
});
