require 'integration_test_helper'

class PatientIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

#	patient#edit

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			study_subject = Factory(:patient).study_subject.reload
			login_as send(cu)
			visit edit_study_subject_patient_path(study_subject)

			assert !find_field('patient[other_diagnosis]').visible?
			#	case sensitive? yep.
			select "other diagnosis", :from => 'patient[diagnosis_id]'
			assert find_field('patient[other_diagnosis]').visible?
			select "", :from => 'patient[diagnosis_id]'
			assert !find_field('patient[other_diagnosis]').visible?
			select "other diagnosis", :from => 'patient[diagnosis_id]'
			assert find_field('patient[other_diagnosis]').visible?
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
