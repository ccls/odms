var initial_diagnosis_date;
function diagnosis_date(){
	return jQuery('#patient_diagnosis_date').val();
}
function diagnosis_date_changed(){
	return initial_diagnosis_date != diagnosis_date();
}
jQuery(function(){

	initial_diagnosis_date = diagnosis_date();
	
	jQuery('#patient_diagnosis_date').change(function(){
		if( diagnosis_date_changed() ) {
			$(this).parent().addClass('changed');
		} else {
			$(this).parent().removeClass('changed');
		}
	});

});
