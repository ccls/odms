require 'test_helper'

class Sunspot::SubjectsControllerTest < ActionController::TestCase

#
#	Only run these test if the sunspot/solr server is running.
#	Otherwise, it can get ugly.
#
if StudySubject.respond_to?(:solr_search)

	setup :sanitize_index

	site_administrators.each do |cu|

		test "should search with #{cu} login" do
			login_as send(cu)
			get :index
			assert_found_nothing
		end

		test "should search with subject and #{cu} login" do
			study_subject = Factory(:study_subject)
			StudySubject.solr_reindex
			assert !StudySubject.search.hits.empty?
			login_as send(cu)
			get :index
			assert_found_one( study_subject )
		end

		test "should search by subject_type and #{cu} login" do
			study_subject = Factory(:study_subject)
			StudySubject.solr_reindex
			assert !StudySubject.search.hits.empty?
			login_as send(cu)
			get :index, :subject_type => [study_subject.subject_type.to_s]
			assert_found_one( study_subject )
		end

		test "should search by wrong subject_type and #{cu} login" do
			study_subject = Factory(:study_subject)
			StudySubject.solr_reindex
			assert !StudySubject.search.hits.empty?
			login_as send(cu)
			get :index, :subject_type => ['WRONG']
			assert_found_nothing
		end

		test "should search by vital_status and #{cu} login" do
			study_subject = Factory(:study_subject)
			StudySubject.solr_reindex
			assert !StudySubject.search.hits.empty?
			login_as send(cu)
			get :index, :vital_status => [study_subject.vital_status.to_s]
			assert_found_one( study_subject )
		end

		test "should search by wrong vital_status and #{cu} login" do
			study_subject = Factory(:study_subject)
			StudySubject.solr_reindex
			assert !StudySubject.search.hits.empty?
			login_as send(cu)
			get :index, :vital_status => ['WRONG']
			assert_found_nothing
		end



		test "should search with project facet and #{cu} login" do
pending
		end

		test "should search with invalid facet and #{cu} login" do
pending
		end

		test "should search with columns and #{cu} login" do
pending
		end

		test "should search with invalid columns and #{cu} login" do
pending
		end

		test "should search with order and #{cu} login" do
pending
		end

		test "should search with pagination and #{cu} login" do
pending
		end

		test "should search with csv output and #{cu} login" do
			study_subject = Factory(:study_subject)
			StudySubject.solr_reindex
			assert !StudySubject.search.hits.empty?
			login_as send(cu)
			get :index, :format => 'csv'
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;/)
#			assert assigns(:samples)
#			assert assigns(:samples).empty?
			require 'csv'
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	1 rows, 1 header and 0 data
#id,case_icf_master_id,mother_icf_master_id,icf_master_id,subject_type,vital_status,sex,dob,first_name,last_name
#1085,,,,Desc10,living,M,05/26/1971,,
		end

	end

	non_site_administrators.each do |cu|

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

	def assert_found_one(subject)
		assert_nil flash[:error]
		assert_response :success
		assert_template 'index'
		assert assigns(:search)
		assert_equal 1, assigns(:search).hits.length
		assert_equal( subject, assigns(:search).hits.first.instance )
		assert_equal( subject, assigns(:search).results.first )
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
