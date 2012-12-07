require 'test_helper'

class StudySubjectSunspotTest < ActiveSupport::TestCase

	if StudySubject.respond_to?(:solr_search)

		test "should search" do
			Sunspot.remove_all!					#	isn't always necessary
			StudySubject.solr_reindex
			assert StudySubject.search.hits.empty?
			Factory(:study_subject)
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
		sunspot_boolean_columns
		sunspot_double_columns
		sunspot_default_columns
		sunspot_available_columns
		sunspot_dynamic_columns
		).each do |column|
		test "should return array for sunspot class method #{column}" do
			assert StudySubject.send(column).is_a?(Array)
		end
	end

	%w( case_icf_master_id mother_icf_master_id
			father_ssn mother_ssn hospital hospital_key diagnosis
			ccls_enrollment ccls_consented ccls_is_eligible
			ccls_assigned_for_interview_on ccls_interview_completed_on
			patient_was_ca_resident_at_diagnosis
			patient_was_previously_treated
			patient_was_under_15_at_dx
			).each do |meth|

		test "should respond to custom method #{meth}" do
			subject = Factory(:study_subject)
			assert subject.respond_to?(meth)	#hmm.  subject responds to meth?
			#	subject.diagnosis
		end

	end

end
