require 'test_helper'

class StudySubjectSunspotTest < ActiveSupport::TestCase

	if StudySubject.respond_to?(:solr_search)

		test "should search" do
			Sunspot.remove_all!					#	isn't always necessary
			StudySubject.solr_reindex
			assert StudySubject.search.hits.empty?
			FactoryGirl.create(:study_subject)
			StudySubject.solr_reindex
			assert !StudySubject.search.hits.empty?
		end

	else
#
#	Sunspot wasn't running when test started
#
	end

	%w( sunspot_columns
		sunspot_orderable_columns
		sunspot_string_columns
		sunspot_nulled_string_columns
		sunspot_time_columns
		sunspot_date_columns
		sunspot_integer_columns
		sunspot_long_columns
		sunspot_boolean_columns
		sunspot_double_columns
		sunspot_float_columns
		sunspot_default_columns
		sunspot_available_columns
		).each do |column|
		test "should return array for sunspot class method #{column}" do
			assert StudySubject.send(column).is_a?(Array)
		end
#		sunspot_unindexed_columns
	end
#		sunspot_dynamic_columns

	%w( case_icf_master_id mother_icf_master_id
			father_ssn mother_ssn hospital hospital_key diagnosis
			ccls_enrollment ccls_consented ccls_is_eligible
			ccls_assigned_for_interview_on ccls_interview_completed_on
			patient_was_ca_resident_at_diagnosis
			patient_was_previously_treated
			patient_was_under_15_at_dx
			interviewed
			).each do |meth|

		test "should respond to custom method #{meth}" do
			subject = FactoryGirl.create(:study_subject)
			assert subject.respond_to?(meth)	#hmm.  subject responds to meth?
			#	subject.diagnosis
		end

	end

	test "interviewed should be true when ccls enrollment interview_completed_on set" do
		subject = FactoryGirl.create(:study_subject)
		e = subject.ccls_enrollment
		assert !subject.interviewed
		assert_nil e.interview_completed_on
		e.update_attribute(:interview_completed_on, Date.current)
		assert  subject.reload.interviewed
		assert_not_nil e.interview_completed_on
	end

end
