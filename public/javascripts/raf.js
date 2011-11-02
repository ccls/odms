jQuery(function(){

	jQuery('#study_subject_patient_attributes_diagnosis_id').change(function(){
		toggle_specify_other_diagnosis( $(this).val() );
	});

	toggle_specify_other_diagnosis( 
		$('#study_subject_patient_attributes_diagnosis_id').val() );

});

toggle_specify_other_diagnosis = function(diagnosis) {

	/* 3 is the id for Diagnosis['other'] */

	if( diagnosis == 3 ){	
		$('form.raf div.other_diagnosis').show()
	} else {
		$('form.raf div.other_diagnosis').hide()
	}
}
