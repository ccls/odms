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
#	assert_access_with_https
#	assert_no_access_with_http

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

		test "should create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_nil flash[:error]
			assert_redirected_to sample_path(assigns(:sample))
		end

		test "should NOT create with #{cu} login " <<
				"and invalid study_subject_id" do
			login_as send(cu)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => 0,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create with #{cu} login " <<
				"and invalid sample" do
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create with #{cu} login " <<
				"and save failure" do
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
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
	
		test "should find samples by sample_id and #{cu} login" do
pending	#	TODO
		end

		test "should find samples by parent sample_type and #{cu} login" do
			samples = 3.times.collect{|i| 
				Factory(:sample,:sample_type => SampleType.roots[i].children.first )}
			login_as send(cu)
			get :find, :sample_type_id => samples[1].sample_type.parent.id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by child sample_type and #{cu} login" do
			samples = 3.times.collect{|i| 
				Factory(:sample,:sample_type => SampleType.not_roots[i] )}
#				Factory(:sample,:sample_type => SampleType.roots[i].children.first )}
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
	


		test "should find samples with sent_to_subject_on as month day year and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_on => base_date + (5*i).days ) }
			login_as send(cu)
			#	Dec 1 2000
			get :find, :sent_to_subject_on => samples[1].sent_to_subject_on.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_on as MM/DD/YYYY and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_on => base_date + (5*i).days ) }
			login_as send(cu)
			#	javascript selector format
			get :find, :sent_to_subject_on => samples[1].sent_to_subject_on.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_on as YYYY-MM-DD and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_on => base_date + (5*i).days ) }
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :sent_to_subject_on => samples[1].sent_to_subject_on.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted sent_to_subject_on and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| 
				Factory(:sample,:sent_to_subject_on => base_date + (5*i).days ) }
			login_as send(cu)
			get :find, :sent_to_subject_on => 'bad monkey'
			assert_response :success
			assert_equal 3, assigns(:samples).length
		end
	

		test "should find samples with received_by_ccls_at as month day year and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_on  => base_date + (5*i-2).days,
					:collected_at        => base_date + (5*i-1).days,
					:received_by_ccls_at => base_date + (5*i).days )}
			login_as send(cu)
			#	Dec 1 2000
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as MM/DD/YYYY and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_on  => base_date + (5*i-2).days,
					:collected_at        => base_date + (5*i-1).days,
					:received_by_ccls_at => base_date + (5*i).days )}
			login_as send(cu)
			#	javascript selector format
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as YYYY-MM-DD and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_on  => base_date + (5*i-2).days,
					:collected_at        => base_date + (5*i-1).days,
					:received_by_ccls_at => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :find, :received_by_ccls_at => samples[1].received_by_ccls_at.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted received_by_ccls_at and #{cu} login" do
			base_date = Date.today-100.days
			samples = 3.times.collect{|i| Factory(:sample,
					:sent_to_subject_on  => base_date + (5*i-2).days,
					:collected_at        => base_date + (5*i-1).days,
					:received_by_ccls_at => base_date + (5*i).days )}
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
	
	
#
#	BEGIN order tests
#
		%w( reference_date ).each do |attr|

			test "should find study_subjects and order by #{attr} with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir asc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr, :dir => 'asc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir desc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr, :dir => 'desc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects).reverse
			end
	
			test "should find study_subjects and order by #{attr} invalid dir with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr, :dir => 'invalid'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end

		end

		%w( icf_master_id studyid ).each do |attr|

			test "should find study_subjects and order by #{attr} with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" ) }
				login_as send(cu)
				get :find, :order => attr
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir asc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'asc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir desc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'desc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects).reverse
			end
	
			test "should find study_subjects and order by #{attr} invalid dir with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'invalid'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end

		end

		%w( last_name ).each do |attr|

			test "should find study_subjects and order by #{attr} with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir asc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'asc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir desc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'desc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects).reverse
			end
	
			test "should find study_subjects and order by #{attr} invalid dir with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'invalid'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end

		end
