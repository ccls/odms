require 'integration_test_helper'

class PatientJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

#	patient#edit

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			study_subject = Factory(:patient).study_subject.reload
			login_as send(cu)
			page.visit edit_study_subject_patient_path(study_subject)

			assert page.has_field?('patient[other_diagnosis]', :visible => false)
#	case sensitive? yep.
			select "other", :from => 'patient[diagnosis_id]'
			assert page.has_field?('patient[other_diagnosis]', :visible => true)
			select "", :from => 'patient[diagnosis_id]'
			assert page.has_field?('patient[other_diagnosis]', :visible => false)
			select "other", :from => 'patient[diagnosis_id]'
			assert page.has_field?('patient[other_diagnosis]', :visible => true)
#	jQuery('#patient_diagnosis_id').smartShow({
#		what: 'form.edit_patient div.other_diagnosis',
#		when: function(){ 
#			return /Other/i.test( 
#				$('#patient_diagnosis_id option:selected').text() )
#		}
#	});
		end

		test "should show admit_date changed when admit_date changes" <<
				" with #{cu} login" do
			study_subject = Factory(:patient).study_subject.reload
			login_as send(cu)
			page.visit edit_study_subject_patient_path(study_subject)

			assert page.has_no_css?('div.admit_date_wrapper.changed')
			assert page.has_css?('div.admit_date_wrapper > div.warning', :visible => false)
			page.fill_in 'patient[admit_date]', :with => 'something else'
			assert page.has_css?('div.admit_date_wrapper.changed')
			assert page.has_css?('div.admit_date_wrapper > div.warning', :visible => true)
		end

#var initial_admit_date;
#function admit_date(){
#	return jQuery('#patient_admit_date').val();
#}
#function admit_date_changed(){
#	return initial_admit_date != admit_date();
#}
#jQuery(function(){
#
#	initial_admit_date = admit_date();
#	
#	jQuery('#patient_admit_date').change(function(){
#		if( admit_date_changed() ) {
#			$(this).parent().parent().addClass('changed');
#		} else {
#			$(this).parent().parent().removeClass('changed');
#		}
#	});
#
#});

	end

end
