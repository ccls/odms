/*
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
*/
var initial_admit_date;
function admit_date(){
	return jQuery('#patient_admit_date').val();
}
function admit_date_changed(){
	return initial_admit_date != admit_date();
}
jQuery(function(){

	initial_admit_date = admit_date();
	
	jQuery('#patient_admit_date').change(function(){
		if( admit_date_changed() ) {
			$(this).parent().parent().addClass('changed');
		} else {
			$(this).parent().parent().removeClass('changed');
		}
	});

});
