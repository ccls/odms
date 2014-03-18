require 'csv'
require 'test_helper'

class Sunspot::SamplesControllerTest < ActionController::TestCase

#
#	Only run these test if the sunspot/solr server is running.
#	Otherwise, it can get ugly.
#
if Sample.respond_to?(:solr_search)

	setup :sanitize_index

	site_readers.each do |cu|

		test "should search with #{cu} login" do
			login_as send(cu)
			get :index
			assert_found_nothing
		end

		test "should search with sample and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			get :index
			assert_found_one( sample )
		end

		test "should search by sample and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			get :index, :subject_type => [sample.subject_type]
			assert_found_one( sample )
		end

		test "should search by wrong subject_type and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			get :index, :subject_type => ['WRONG']
			assert_found_nothing
		end

		test "should search by empty subject_type and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			get :index, :subject_type => []
			assert_found_one( sample )
		end

		test "should search by blank subject_type and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			get :index, :subject_type => ''
			assert_found_one( sample )
		end

		test "should search with invalid facet and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			#	will ignore anything unexpected, I hope
			get :index, :fake_facet => 'fake_value', :format => 'csv'
			assert_found_one( sample )
		end

		test "should search with columns and #{cu} login" do
			sample = build_and_index_sample.reload
			login_as send(cu)
			columns = ['icf_master_id','subject_type']
			get :index, :c => columns, :format => 'csv'
			assert_found_one( sample )
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	1 rows, 1 header and 1 data
			assert_equal f[0], columns
#			assert_equal f[1], [nil,sample.subject_type]	#	this worked, now it doesn't? always confused.
			assert_equal f[1], ['',sample.subject_type]
		end

		test "should search with invalid columns and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			columns = ['apple','orange']
			get :index, :c => columns, :format => 'csv'
			assert_found_one( sample )
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	1 rows, 1 header and 1 data
			assert_equal f[0], columns
#			assert_equal f[1], [nil,nil]
			assert_equal f[1], ["UNKNOWN COLUMN", "UNKNOWN COLUMN"]
		end


		test "should search with pagination and #{cu} login" do
			samples = [build_and_index_sample]
			samples << build_and_index_sample
			login_as send(cu)
			get :index, :per_page => 1
			assert_found_one( samples.first )
		end

		test "should search with pagination and page 1 and #{cu} login" do
			samples = [build_and_index_sample]
			samples << build_and_index_sample
			login_as send(cu)
			get :index, :per_page => 1, :page => 1
			assert_found_one( samples.first )
		end

		test "should search with pagination and page 2 and #{cu} login" do
			samples = [build_and_index_sample]
			samples << build_and_index_sample
			login_as send(cu)
			get :index, :per_page => 1, :page => 2
			assert_found_one( samples.last )
		end


		test "should search with csv output and #{cu} login" do
			sample = build_and_index_sample
			login_as send(cu)
			get :index, :format => 'csv'
			assert_found_one( sample )
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;/)
#			assert assigns(:samples)
#			assert assigns(:samples).empty?
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	1 rows, 1 header and 1 data
			assert_equal f[0], Sample.sunspot_default_column_names
#id,case_icf_master_id,mother_icf_master_id,icf_master_id,subject_type,vital_status,sex,dob,first_name,last_name
#1085,,,,Desc10,living,M,05/26/1971,,
		end


		test "should not search if solr is down and #{cu} login" do
			Sample.stubs(:solr_search).raises(Errno::ECONNREFUSED)
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
			Sample.stubs(:methods).returns([])
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

end	#	if Sample.respond_to?(:solr_search)

protected

	def sanitize_index
		Sunspot.remove_all!					#	isn't always necessary

#		Sample.solr_reindex
#	DEPRECATION WARNING: Relation#find_in_batches with finder options is deprecated. Please build a scope and then call find_in_batches on it instead.
		Sample.find_each{|a|a.index}
		Sunspot.commit

		assert Sample.search.hits.empty?
	end

	def build_and_index_sample(options={})
		sample = FactoryGirl.create(:sample,options)

#		Sample.solr_reindex
#	DEPRECATION WARNING: Relation#find_in_batches with finder options is deprecated. Please build a scope and then call find_in_batches on it instead.
		Sample.find_each{|a|a.index}
		Sunspot.commit

		assert !Sample.search.hits.empty?
		return sample
	end

	def assert_found_one(sample)
		assert_found_these([sample])
		assert_equal( sample, assigns(:search).hits.first.instance )
		assert_equal( sample, assigns(:search).results.first )
	end

	def assert_found_these(samples)
		assert_nil flash[:error]
		assert_response :success
		assert_template 'index'
		assert assigns(:search)
		assert_equal samples.length, assigns(:search).hits.length

		assert_equal samples, assigns(:search).results
		assert_equal samples, assigns(:search).hits.collect(&:instance)

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
