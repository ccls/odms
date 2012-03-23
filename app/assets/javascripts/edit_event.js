jQuery(function(){

	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''

	$('select#category').change(function(){
		$.get(root + '/operational_event_types/options.js?category=' + $(this).val(), 
			/* data will be a list of options for select */
			function(data){
				$('select#operational_event_operational_event_type_id').html(data);
			}
		);
	});

/*

	Assuming that I'll need to add some type of trigger for "specify" unless
	it will always be available.

*/

});
