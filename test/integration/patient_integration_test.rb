require 'integration_test_helper'

class PatientIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other_language]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other_language]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_editors.each do |cu|

#	patient#edit

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			study_subject = Factory(:patient).study_subject.reload
			login_as send(cu)
			visit edit_study_subject_patient_path(study_subject)

			assert !find_field('patient[other_diagnosis]').visible?
#	case sensitive? yep.
			select "other", :from => 'patient[diagnosis_id]'
			assert find_field('patient[other_diagnosis]').visible?
			select "", :from => 'patient[diagnosis_id]'
			assert !find_field('patient[other_diagnosis]').visible?
			select "other", :from => 'patient[diagnosis_id]'
			assert find_field('patient[other_diagnosis]').visible?
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
			visit edit_study_subject_patient_path(study_subject)

			assert has_no_css?('div.admit_date_wrapper.changed')
			assert has_css?('div.admit_date_wrapper > div.warning', :visible => false)
			fill_in 'patient[admit_date]', :with => 'something else'
			assert has_css?('div.admit_date_wrapper.changed')
			assert has_css?('div.admit_date_wrapper > div.warning', :visible => true)
		end

	end

end
