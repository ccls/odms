jQuery(function(){

	jQuery('button#select_all').click(function(){
		jQuery("div.subject input[type='checkbox']").attr('checked','checked');
	});

	jQuery('button#deselect_all').click(function(){
		jQuery("div.subject input[type='checkbox']").attr('checked','');
	});

});
