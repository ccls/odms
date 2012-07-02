require 'test_helper'

class SamplesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Sample',
		:actions => [:edit,:update,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample
	}
	def factory_attributes(options={})
		#	Being more explicit to reflect what is actually on the form
		{
			:project_id     => Project['ccls'].id,
			:sample_type_id => Factory(:sample_type).id
		}.merge(options)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_access_with_login({    :logins => site_readers, 
		:actions => [:show] })
	assert_no_access_with_login({ :logins => non_site_readers, 
		:actions => [:show] })
	assert_no_access_without_login

	#	no study_subject_id
	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	site_editors.each do |cu|

		test "should get new sample with #{cu} login" <<
				" and study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert assigns(:sample)
		end

		test "should NOT get new sample with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create new sample and transfer with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('SampleTransfer.count',1) {
			assert_difference('Sample.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_nil flash[:error]
			assert_redirected_to sample_path(assigns(:sample))
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and invalid study_subject_id" do
			login_as send(cu)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => 0,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and invalid sample" do
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and sample save failure" do
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and invalid sample transfer" do
			login_as send(cu)
			SampleTransfer.any_instance.stubs(:valid?).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and sample transfer save failure" do
			login_as send(cu)
			SampleTransfer.any_instance.stubs(:create_or_update).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end
	
	non_site_editors.each do |cu|

		test "should NOT get new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end
	
	site_readers.each do |cu|

		test "should get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert assigns(:samples)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT get index with #{cu} login and invalid study_subject_id" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end
	
		test "should get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
			assert_template 'dashboard'
		end
	
		test "should get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_response :success
			assert_template 'find'
		end

	##################################################
	#		Begin Find Tests
	
		test "should get samples find with #{cu} login and page too high" do
			3.times{Factory(:sample)}
			login_as send(cu)
			get :find, :page => 999
			assert_not_nil flash[:warn]
			assert_equal 3, assigns(:samples).count
			assert_equal 0, assigns(:samples).length
			assert_redirected_to find_samples_path(:page => 1)
		end

		test "should find samples by sample_id and #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
#	There is no actual sampleid field. It is just id with leading zeros.
			get :find, :sampleid => samples[1].id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by parent sample_type and #{cu} login" do
			samples = 3.times.collect{|i| 
				Factory(:sample,:sample_type => SampleType.roots.all[i].children.first )}
#	BUT NO LONGER
#				Factory(:sample,:sample_type => SampleType.roots[i].children.first )}
#	OR EVEN
#				Factory(:sample,:sample_type => (SampleType.roots)[i].children.first )}
			login_as send(cu)
			get :find, :sample_type_id => samples[1].sample_type.parent.id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
#
#	I don't know why this happens now and didn't before.
#	irb(main):001:0> SampleType.roots[0]
#  SampleType Load (0.4ms)  SELECT `sample_types`.* FROM `sample_types` WHERE `sample_types`.`parent_id` IS NULL AND `sample_types`.`key` = '0' LIMIT 1
#
#	The scope is now using my [] rather than the resultant array. 
#	This wasn't the case an hour ago????
#
#	I will speculate that this may have something to do with the
#	recent rails 3.2.6 upgrade.
#
		test "should find samples by child sample_type and #{cu} login" do
			samples = 3.times.collect{|i| 
				Factory(:sample,:sample_type => SampleType.not_roots.all[i] )}
#	BUT NO LONGER
#				Factory(:sample,:sample_type => SampleType.not_roots[i] )}
#	OR EVEN
#				Factory(:sample,:sample_type => (SampleType.not_roots)[i] )}
			login_as send(cu)
			get :find, :sample_type_id => samples[1].sample_type_id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

#	i starts at 0!

		test "should find samples by first_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :first_name => "First#{i}" ) 
			}
			login_as send(cu)
			get :find, :first_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end

		test "should find samples by last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :last_name => "Last#{i}" )
			}
			login_as send(cu)
			get :find, :last_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples by maiden_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :maiden_name => "Maiden#{i}" )
			}
			login_as send(cu)
			get :find, :last_name => 'en1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end

		test "should find samples with childid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :childid => '451'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples with icf_master_id and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :icf_master_id => "345x#{i}" ) }
			login_as send(cu)
			get :find, :icf_master_id => '45x1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples with patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :patid => "345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	


		test "should find samples with sent_to_subject_at as month day year and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	Dec 1 2000
			get :find, :sent_to_subject_at => samples[1].sent_to_subject_at.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_at as MM/DD/YYYY and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	javascript selector format
			get :find, :sent_to_subject_at => samples[1].sent_to_subject_at.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_at as YYYY-MM-DD and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :sent_to_subject_at => samples[1].sent_to_subject_at.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted sent_to_subject_at and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			get :find, :sent_to_subject_at => 'bad monkey'
			assert_response :success
			assert_equal 3, assigns(:samples).length
		end
	

		test "should find samples with received_by_ccls_at as month day year and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	Dec 1 2000
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as MM/DD/YYYY and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	javascript selector format
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as YYYY-MM-DD and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted received_by_ccls_at and #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			get :find, :received_by_ccls_at => 'bad monkey'
			assert_response :success
			assert_equal 3, assigns(:samples).length
		end
	

#	I could add tons of tests for searching on multiple attributes
#	but it would get ridiculous.  I do need to add a few to test the
#	operator parameter so there will be a few here.	

		test "should find samples by first_name OR last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:first_name => "First#{i}",:last_name => "Last#{i}")}
			login_as send(cu)
			get :find, :first_name => 'st1', :last_name => 'st2', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
			assert assigns(:samples).include?(samples[2])
		end

		test "should find samples by first_name AND last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:first_name => "First#{i}",:last_name => "Last#{i}")}
			login_as send(cu)
			get :find, :first_name => 'st1', :last_name => 'st1', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by childid OR patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451', :childid => '452', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
			assert assigns(:samples).include?(samples[2])
		end

		test "should find samples by childid AND patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451', :childid => '451', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

	#		End Find Tests
	##################################################
	

	##################################################
	#		Begin Find Order Tests (only on fields in table)


		test "should find samples and order by id with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :id
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by id asc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :id, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by id desc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :id, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by received by ccls at with #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :order => :received_by_ccls_at
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by received by ccls at asc with #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :order => :received_by_ccls_at, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by received by ccls at desc with #{cu} login" do
			base_date = Date.today-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :order => :received_by_ccls_at, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by status with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample, :state => "state#{i}") }
			login_as send(cu)
			get :find, :order => :state
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by status asc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample, :state => "state#{i}") }
			login_as send(cu)
			get :find, :order => :state, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by status desc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample, :state => "state#{i}") }
			login_as send(cu)
			get :find, :order => :state, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by type with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :type
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by type asc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :type, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by type desc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :type, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by subtype with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :subtype
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by subtype asc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :subtype, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by subtype desc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :subtype, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by project with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :project
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by project asc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :project, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by project desc with #{cu} login" do
			samples = 3.times.collect{|i| Factory(:sample) }
			login_as send(cu)
			get :find, :order => :project, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

	
	#		End Find Order Tests
	##################################################

	
		test "should get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_response :success
			assert_template 'followup'
		end
	
		test "should get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_response :success
			assert_template 'reports'
		end
	
		test "should get manifest in csv with #{cu} login and no samples" do
			login_as send(cu)
			get :manifest, :format => 'csv'
			assert_response :success
			assert_template 'manifest'
			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
			assert assigns(:samples)
			assert assigns(:samples).empty?
			require 'csv'
			f = CSV.parse(@response.body)
			assert_equal 1, f.length	#	1 row, 1 header and 0 data
		end

		test "should get manifest in csv with #{cu} login and sample received before 6/1" do
			login_as send(cu)
			sample = Factory(:sample, :received_by_ccls_at => Date.parse('5/30/2012'))
			assert_not_nil sample.received_by_ccls_at
			get :manifest, :format => 'csv'
			assert_response :success
			assert_template 'manifest'
			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
			assert assigns(:samples)
			assert assigns(:samples).empty?
			require 'csv'
			f = CSV.parse(@response.body)
			assert_equal 1, f.length	#	1 rows, 1 header and 0 data
		end

		test "should get manifest in csv with #{cu} login and sample received after 6/1" do
			login_as send(cu)
			#	assuming that today is indeed after 6/1/2012
			sample = Factory(:sample, :received_by_ccls_at => Date.today )
			assert_not_nil sample.received_by_ccls_at
			get :manifest, :format => 'csv'
			assert_response :success
			assert_template 'manifest'
			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
			assert assigns(:samples)
			assert !assigns(:samples).empty?
			assert_equal 1, assigns(:samples).length
			require 'csv'
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	2 rows, 1 header and 1 data
			assert_equal f[0], %w( 
				icf_master_id
				subjectid
				sex
				sampleid
				gegl_sample_type_id
				collected_from_subject_at
				received_by_ccls_at
				storage_temperature
				sent_to_lab_at
			)
		end

		test "should show pdf with #{cu} login" do
			login_as send(cu)
			sample = Factory(:sample)
			get :show, :id => sample.id, :format => 'pdf'
			assert_response :success
			assert_template 'show'
			assert_not_nil @response.headers['Content-Type']
			assert_match /application\/pdf/, @response.headers['Content-Type']
			assert_not_nil @response.headers['Content-Disposition']
			assert_match /inline/, @response.headers['Content-Disposition']
		end
	
	end

	non_site_readers.each do |cu|

		test "should NOT get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end
	
		test "should NOT get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_redirected_to root_path
		end
	
		test "should NOT get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_redirected_to root_path
		end
	
		test "should NOT get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_redirected_to root_path
		end
	
		test "should NOT get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_redirected_to root_path
		end
	
		test "should NOT get manifest in html with #{cu} login" do
			login_as send(cu)
			get :manifest
			assert_redirected_to root_path
		end
	
		test "should NOT get manifest in csv with #{cu} login" do
			login_as send(cu)
			get :manifest, :format => 'csv'
			assert_redirected_to root_path
		end
	
	end

	test "should NOT get index without login and valid study_subject_id" do
		study_subject = Factory(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end
	
	test "should NOT get dashboard without login" do
		get :dashboard
		assert_redirected_to_login
	end
	
	test "should NOT get find without login" do
		get :find
		assert_redirected_to_login
	end
	
	test "should NOT get followup without login" do
		get :followup
		assert_redirected_to_login
	end
	
	test "should NOT get reports without login" do
		get :reports
		assert_redirected_to_login
	end
	
	test "should NOT get manifest in html without login" do
		get :manifest
		assert_redirected_to_login
	end
	
	test "should NOT get manifest in csv without login" do
		get :manifest, :format => 'csv'
		assert_redirected_to_login
	end
	
	test "should NOT get new sample without login" do
		study_subject = Factory(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new sample without login" do
		study_subject = Factory(:study_subject)
		post :create, :study_subject_id => study_subject.id,
			:sample => factory_attributes
		assert_redirected_to_login
	end

protected 

	def create_sample_with_subject(options={})
		s = Factory(:study_subject, options)
		Factory(:sample, :study_subject => s, :project => Project['ccls'])
	end

end
__END__
