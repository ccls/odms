require 'test_helper'

class ChartsControllerTest < ActionController::TestCase

	setup :create_some_data

#
#	creating data, to push for 100% code coverage.
#
	def create_some_data
		Sunspot.remove_all!					#	isn't always necessary

#	DEPRECATION WARNING: Relation#find_in_batches with finder options is deprecated. Please build a scope and then call find_in_batches on it instead. (called from irb_binding at (irb):1)
#		StudySubject.solr_reindex
		StudySubject.find_each{|s| s.index }
		Sunspot.commit

		assert StudySubject.search.hits.empty?
		subject1 = FactoryGirl.create(:complete_case_study_subject)
		FactoryGirl.create(:sample, :study_subject => subject1,
			:sample_type => SampleType['marrowdiag'])
		subject2 = FactoryGirl.create(:complete_case_study_subject)
		FactoryGirl.create(:sample, :study_subject => subject2,
			:sample_type => SampleType['periph'])

#		StudySubject.solr_reindex
		StudySubject.find_each{|s| s.index }
		Sunspot.commit

		assert !StudySubject.search.hits.empty?
	end

	%w( samples_locations samples_projects
		samples_sample_types samples_sample_temperatures
		enrollments vital_statuses vital_statuses_pie
		subject_types subject_types_pie case_control_types
		case_control_types_pie childidwho is_eligible
		consented 
		phase_5_case_enrollment_by_month
		phase_5_case_enrollment case_enrollment blood_bone_marrow
		subject_types_by_phase vital_statuses_by_phase
		).each do |action|

#
#	case_enrollment and phase_5_case_enrollment may fail on a first
#	run due to non-existant projects which cause non-existant
#	hex_* search keys.
#

		all_test_roles.each do |cu|

			test "should get #{action} with #{cu} login" do
				login_as send(cu)
				get action, :format => 'json'
				assert_response :success
			end

		end

		test "should NOT get #{action} without login" do
			get action, :format => 'json'
			#	json requests do not redirect, apparently
			assert @response.body.blank?
			assert_response :unauthorized
		end

	end

end
