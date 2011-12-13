jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''

	jQuery('select#category').change(function(){
		jQuery.get(root + '/operational_event_types/options.js?category=' + jQuery(this).val(), 
			function(data){
				$('select#operational_event_operational_event_type_id').html(data);
			}
		);
	});

});
