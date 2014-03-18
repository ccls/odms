require 'test_helper'

class StudySubjectSunspotTest < ActiveSupport::TestCase

	if StudySubject.respond_to?(:solr_search)

		test "should search" do
			Sunspot.remove_all!					#	isn't always necessary

#			StudySubject.solr_reindex
#	DEPRECATION WARNING: Relation#find_in_batches with finder options is deprecated. Please build a scope and then call find_in_batches on it instead. (called from irb_binding at (irb):1)
			StudySubject.find_each{|a|a.index}
			Sunspot.commit

			assert StudySubject.search.hits.empty?
			FactoryGirl.create(:study_subject)

#			StudySubject.solr_reindex
#	DEPRECATION WARNING: Relation#find_in_batches with finder options is deprecated. Please build a scope and then call find_in_batches on it instead. (called from irb_binding at (irb):1)
			StudySubject.find_each{|a|a.index}
			Sunspot.commit

			assert !StudySubject.search.hits.empty?
		end

	else
#
#	Sunspot wasn't running when test started
#
	end

	%w( case_icf_master_id mother_icf_master_id
			hospital hospital_key diagnosis
			ccls_enrollment 
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
		assert !subject.ccls_enrollment.try(:interview_completed_on).present?
		assert_nil e.interview_completed_on
		e.update_attribute(:interview_completed_on, Date.current)
		assert  subject.reload.ccls_enrollment.try(:interview_completed_on).present?
		assert_not_nil e.interview_completed_on
	end


	test "should text search on entire first name" do
		subject = FactoryGirl.create(:study_subject, :first_name => "xyz123zyx")
		Sunspot.commit
		search = StudySubject.search { fulltext 'xyz123zyx' }
		assert search.results.include?(subject)
	end

	test "should text search on first chars of first name" do
		subject = FactoryGirl.create(:study_subject, :first_name => "xyz123zyx")
		Sunspot.commit
		search = StudySubject.search { fulltext 'xyz' }
		assert search.results.include?(subject)
	end

	test "should text search on middle chars of first name" do
		subject = FactoryGirl.create(:study_subject, :first_name => "xyz123zyx")
		Sunspot.commit
		search = StudySubject.search { fulltext 'z123z' }
		assert search.results.include?(subject)
	end

	test "should text search on last chars of first name" do
		subject = FactoryGirl.create(:study_subject, :first_name => "xyz123zyx")
		Sunspot.commit
		search = StudySubject.search { fulltext 'zyx' }
		assert search.results.include?(subject)
	end

end
