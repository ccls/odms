require 'csv'
require 'test_helper'

class Sunspot::SubjectsControllerTest < ActionController::TestCase

#
#	Only run these test if the sunspot/solr server is running.
#	Otherwise, it can get ugly.
#
if StudySubject.respond_to?(:solr_search)

	setup :sanitize_index

	site_readers.each do |cu|

		test "should search with #{cu} login" do
			login_as send(cu)
			get :index
			assert_found_nothing
		end



		test "should search by fulltext subjectid with subject and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :q => study_subject.subjectid
			assert_found_one( study_subject )
		end

		test "should find sole subject ignoring blank param race and #{cu} login and ignore operator AND" do
			login_as send(cu)
			study_subject = build_and_index_subject
			study_subject.races << Race[:white]
			StudySubject.solr_reindex
			get :index, :races => [''], "races_op" => 'AND'
			assert_found_one( study_subject )
		end

		test "should find sole subject with matching param race and #{cu} login and ignore operator AND" do
			login_as send(cu)
			study_subject = build_and_index_subject
			study_subject.races << Race[:white]
			study_subject.races << Race[:black]
			StudySubject.solr_reindex
			get :index, :races => ['White, Non-Hispanic','Black / African American'], "races_op" => 'AND'
			assert_found_one( study_subject )
		end

		test "should find sole subject with matching param race and #{cu} login and ignore operator OR" do
			login_as send(cu)
			study_subject = build_and_index_subject
			study_subject.races << Race[:white]
			study_subject.races << Race[:black]
			StudySubject.solr_reindex
			get :index, :races => ['White, Non-Hispanic','Black / African American'], "races_op" => 'OR'
			assert_found_one( study_subject )
		end





		test "should search with subject and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index
			assert_found_one( study_subject )
		end

		test "should search by subject_type and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :subject_type => [study_subject.subject_type.to_s]
			assert_found_one( study_subject )
		end

		test "should search by wrong subject_type and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :subject_type => ['WRONG']
			assert_found_nothing
		end

		test "should search by empty subject_type and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :subject_type => []
			assert_found_one( study_subject )
		end

		test "should search by blank subject_type and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :subject_type => ''
			assert_found_one( study_subject )
		end

		test "should search by vital_status and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
#			get :index, :vital_status => [study_subject.vital_status.to_s]
			get :index, :vital_status => [study_subject.vital_status]	#	the to_s isn't really needed now
			assert_found_one( study_subject )
		end

		test "should search by wrong vital_status and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :vital_status => ['WRONG']
			assert_found_nothing
		end

		test "should search by empty vital_status and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :vital_status => []
			assert_found_one( study_subject )
		end

		test "should search by blank vital_status and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :vital_status => ''
			assert_found_one( study_subject )
		end

#		test "should search with project facet and #{cu} login" do
#			login_as send(cu)
#			get :index, :projects => [Project['ccls'].to_s]
#pending
#		end
#
#		test "should search with project and consented facet and #{cu} login" do
#			login_as send(cu)
#			get :index, :projects => [Project['ccls'].to_s],
#				:"hex_#{Project['ccls'].to_s.unpack('H*').first}:consented" => 'Yes'
#pending
#		end
#
#		test "should search with project and is_eligible facet and #{cu} login" do
#			login_as send(cu)
#			get :index, :projects => [Project['ccls'].to_s],
#				:"hex_#{Project['ccls'].to_s.unpack('H*').first}:is_eligible" => 'Yes'
#pending
#		end

		test "should search with invalid facet and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			#	will ignore anything unexpected, I hope
			get :index, :fake_facet => 'fake_value', :format => 'csv'
			assert_found_one( study_subject )
		end

		test "should search with columns and #{cu} login" do
			study_subject = build_and_index_subject.reload
			login_as send(cu)
			columns = ['icf_master_id','subject_type']
			get :index, :c => columns, :format => 'csv'
			assert_found_one( study_subject )
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	1 rows, 1 header and 1 data
			assert_equal f[0], columns
			assert_equal f[1], ["",study_subject.subject_type.to_s]
		end

		test "should search with invalid columns and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			columns = ['apple','orange']
			get :index, :c => columns, :format => 'csv'
			assert_found_one( study_subject )
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	1 rows, 1 header and 1 data
			assert_equal f[0], columns
#			assert_equal f[1], ["",""]
			assert_equal f[1], ["UNKNOWN COLUMN", "UNKNOWN COLUMN"]
		end


		test "should search with studyid order and #{cu} login" do
			study_subjects = [build_and_index_subject(:studyid => 'apples')]
			study_subjects << build_and_index_subject(:studyid => 'oranges')
			login_as send(cu)
			get :index, :order => 'studyid', :format => 'csv'
			assert_found_these( study_subjects )
		end

		test "should search with studyid order and asc dir and #{cu} login" do
			study_subjects = [build_and_index_subject(:studyid => 'apples')]
			study_subjects << build_and_index_subject(:studyid => 'oranges')
			login_as send(cu)
			get :index, :order => 'studyid', :dir => 'asc', :format => 'csv'
			assert_found_these( study_subjects )
		end

		test "should search with studyid order and desc dir and #{cu} login" do
			study_subjects = [build_and_index_subject(:studyid => 'apples')]
			study_subjects << build_and_index_subject(:studyid => 'oranges')
			login_as send(cu)
			get :index, :order => 'studyid', :dir => 'desc', :format => 'csv'
			assert_found_these( study_subjects.reverse )
		end


		test "should search with pagination and #{cu} login" do
			study_subjects = [build_and_index_subject]
			study_subjects << build_and_index_subject
			login_as send(cu)
			get :index, :per_page => 1
			assert_found_one( study_subjects.first )
		end

		test "should search with pagination and page 1 and #{cu} login" do
			study_subjects = [build_and_index_subject]
			study_subjects << build_and_index_subject
			login_as send(cu)
			get :index, :per_page => 1, :page => 1
			assert_found_one( study_subjects.first )
		end

		test "should search with pagination and page 2 and #{cu} login" do
			study_subjects = [build_and_index_subject]
			study_subjects << build_and_index_subject
			login_as send(cu)
			get :index, :per_page => 1, :page => 2
			assert_found_one( study_subjects.last )
		end


		test "should search with csv output and #{cu} login" do
			study_subject = build_and_index_subject
			login_as send(cu)
			get :index, :format => 'csv'
			assert_found_one( study_subject )
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;/)
#			assert assigns(:samples)
#			assert assigns(:samples).empty?
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	1 rows, 1 header and 1 data
			assert_equal f[0], StudySubject.sunspot_default_column_names
#id,case_icf_master_id,mother_icf_master_id,icf_master_id,subject_type,vital_status,sex,dob,first_name,last_name
#1085,,,,Desc10,living,M,05/26/1971,,
		end


		test "should not search if solr is down and #{cu} login" do
			StudySubject.stubs(:solr_search).raises(Errno::ECONNREFUSED)
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_equal flash[:error], "Solr seems to be down for the moment."
			assert_redirected_to root_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT search with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	#	Not logged in ...

	test "should NOT search without login" do
		get :index
		assert_redirected_to_login
	end
	
	all_test_roles.each do |cu|

		test "should redirect to root if sunspot wasn't started first with #{cu} login" do
			login_as send(cu)
			StudySubject.stubs(:methods).returns([])
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

end	#	if StudySubject.respond_to?(:solr_search)

protected

	def sanitize_index
		Sunspot.remove_all!					#	isn't always necessary
		StudySubject.solr_reindex
		assert StudySubject.search.hits.empty?
	end

	def build_and_index_subject(options={})
		study_subject = FactoryGirl.create(:study_subject,options)
		StudySubject.solr_reindex
		assert !StudySubject.search.hits.empty?
		return study_subject
	end

	def assert_found_one(subject)
		assert_found_these([subject])
		assert_equal( subject, assigns(:search).hits.first.instance )
		assert_equal( subject, assigns(:search).results.first )
	end

	def assert_found_these(subjects)
		assert_nil flash[:error]
		assert_response :success
		assert_template 'index'
		assert assigns(:search)
		assert_equal subjects.length, assigns(:search).hits.length

		assert_equal subjects, assigns(:search).results
		assert_equal subjects, assigns(:search).hits.collect(&:instance)

	end

	def assert_found_nothing
		assert_nil flash[:error]
		assert_response :success
		assert_template 'index'
		assert assigns(:search)
		assert_equal 0, assigns(:search).results.length
		assert_equal 0, assigns(:search).hits.length
	end

end
