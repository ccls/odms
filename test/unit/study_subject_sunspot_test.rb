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


	test "should respond to case_icf_master_id" do
		subject = Factory(:study_subject)
		assert subject.respond_to?(:case_icf_master_id)
		subject.case_icf_master_id
	end

	test "should respond to mother_icf_master_id" do
		subject = Factory(:study_subject)
		assert subject.respond_to?(:mother_icf_master_id)
		subject.mother_icf_master_id
	end

	test "should respond to father_ssn" do
		subject = Factory(:study_subject)
		assert subject.respond_to?(:father_ssn)
		subject.father_ssn
	end

	test "should respond to mother_ssn" do
		subject = Factory(:study_subject)
		assert subject.respond_to?(:mother_ssn)
		subject.mother_ssn
	end

	test "should respond to hospital" do
		subject = Factory(:study_subject)
		assert subject.respond_to?(:hospital)
		subject.hospital
	end

	test "should respond to hospital_key" do
		subject = Factory(:study_subject)
		assert subject.respond_to?(:hospital_key)
		subject.hospital_key
	end

	test "should respond to diagnosis" do
		subject = Factory(:study_subject)
		assert subject.respond_to?(:diagnosis)
		subject.diagnosis
	end

end
