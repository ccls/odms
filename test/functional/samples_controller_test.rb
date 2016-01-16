require 'test_helper'

class SamplesControllerTest < ActionController::TestCase

	#	no study_subject_id
#	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	def factory_attributes(options={})
		#	Being more explicit to reflect what is actually on the form
		{
			:project_id     => Project['ccls'].id,
			:sample_type_id => FactoryGirl.create(:sample_type).id
		}.merge(options)
	end

	site_administrators.each do |cu|

		#       test to ensure no NESTED FORMS!!!
		#	sadly, html validation doesn't seem to do this
		test "should get samples index with samples and #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index
			assert_response :success
			assert_equal 3, assigns(:samples).length
		end

	end

	non_site_administrators.each do |cu|
	end

	site_editors.each do |cu|
	end
	
	non_site_editors.each do |cu|
	end
	
	site_readers.each do |cu|

		test "should get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
			assert_template 'dashboard'
		end
	
		test "should get find with #{cu} login" do
			login_as send(cu)
			get :index
			assert_response :success
			assert_template 'index'
		end

	##################################################
	#		Begin Find Tests
	
		test "should get samples find with #{cu} login and page too high" do
			3.times{FactoryGirl.create(:sample)}
			login_as send(cu)
			get :index, :page => 999
			assert_not_nil flash[:warn]
			assert_equal 3, assigns(:samples).count
			assert_equal 0, assigns(:samples).length
			assert_redirected_to samples_path(:page => 1)
		end

		test "should find samples by sample_id and #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
#	There is no actual sampleid field. It is just id with leading zeros.
			get :index, :sampleid => samples[1].id
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by parent sample_type and #{cu} login" do
			samples = 3.times.collect{|i| 
				FactoryGirl.create(:sample,:sample_type => SampleType.roots.to_a[i].children.first )}
#	BUT NO LONGER
#				FactoryGirl.create(:sample,:sample_type => SampleType.roots[i].children.first )}
#	OR EVEN
#				FactoryGirl.create(:sample,:sample_type => (SampleType.roots)[i].children.first )}
			login_as send(cu)
			get :index, :sample_type_id => samples[1].sample_type.parent.id
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
				FactoryGirl.create(:sample,:sample_type => SampleType.not_roots.to_a[i] )}
#	BUT NO LONGER
#				FactoryGirl.create(:sample,:sample_type => SampleType.not_roots[i] )}
#	OR EVEN
#				FactoryGirl.create(:sample,:sample_type => (SampleType.not_roots)[i] )}
			login_as send(cu)
			get :index, :sample_type_id => samples[1].sample_type_id
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
			get :index, :first_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end

		test "should find samples by last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :last_name => "Last#{i}" )
			}
			login_as send(cu)
			get :index, :last_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples by maiden_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :maiden_name => "Maiden#{i}" )
			}
			login_as send(cu)
			get :index, :last_name => 'en1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end

		test "should find samples with childid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :childid => "12345#{i}" ) }
			login_as send(cu)
			get :index, :childid => '451'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples with icf_master_id and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :icf_master_id => "345x#{i}" ) }
			login_as send(cu)
			get :index, :icf_master_id => '45x1'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	
		test "should find samples with patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject( :patid => "345#{i}" ) }
			login_as send(cu)
			get :index, :patid => '451'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert_equal assigns(:samples).first, samples[1]
		end
	


		test "should find samples with sent_to_subject_at as month day year and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				FactoryGirl.create(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	Dec 1 2000
			get :index, :sent_to_subject_at => samples[1].sent_to_subject_at.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_at as MM/DD/YYYY and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				FactoryGirl.create(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	javascript selector format
			get :index, :sent_to_subject_at => samples[1].sent_to_subject_at.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with sent_to_subject_at as YYYY-MM-DD and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				FactoryGirl.create(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :index, :sent_to_subject_at => samples[1].sent_to_subject_at.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted sent_to_subject_at and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| 
				FactoryGirl.create(:sample,:sent_to_subject_at => base_date + (5*i).days ) }
			login_as send(cu)
			get :index, :sent_to_subject_at => 'bad monkey'
			assert_response :success
			assert_equal 3, assigns(:samples).length
		end
	

		test "should find samples with received_by_ccls_at as month day year and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| FactoryGirl.create(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	Dec 1 2000
			get :index, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%b %d %Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as MM/DD/YYYY and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| FactoryGirl.create(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	javascript selector format
			get :index, :received_by_ccls_at => samples[1].received_by_ccls_at.strftime("%m/%d/%Y")
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples with received_by_ccls_at as YYYY-MM-DD and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| FactoryGirl.create(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :index, :received_by_ccls_at => samples[1].received_by_ccls_at.to_s	
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end
	
		test "should find samples ignoring poorly formatted received_by_ccls_at and #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| FactoryGirl.create(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			get :index, :received_by_ccls_at => 'bad monkey'
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
			get :index, :first_name => 'st1', :last_name => 'st2', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
			assert assigns(:samples).include?(samples[2])
		end

		test "should find samples by first_name AND last_name and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:first_name => "First#{i}",:last_name => "Last#{i}")}
			login_as send(cu)
			get :index, :first_name => 'st1', :last_name => 'st1', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

		test "should find samples by childid OR patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :index, :patid => '451', :childid => '452', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
			assert assigns(:samples).include?(samples[2])
		end

		test "should find samples by childid AND patid and #{cu} login" do
			samples = 3.times.collect{|i| 
				create_sample_with_subject(:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :index, :patid => '451', :childid => '451', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:samples).length
			assert assigns(:samples).include?(samples[1])
		end

	#		End Find Tests
	##################################################
	

	##################################################
	#		Begin Find Order Tests (only on fields in table)


		test "should find samples and order by id with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :id
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by id asc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :id, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by id desc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :id, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by received by ccls at with #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| FactoryGirl.create(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :index, :order => :received_by_ccls_at
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by received by ccls at asc with #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| FactoryGirl.create(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :index, :order => :received_by_ccls_at, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by received by ccls at desc with #{cu} login" do
			base_date = Date.current-100.days
			# spread dates out by a few days so outside date range
			samples = 3.times.collect{|i| FactoryGirl.create(:sample,
					:sent_to_subject_at        => base_date + (5*i-2).days,
					:collected_from_subject_at => base_date + (5*i-1).days,
					:received_by_ccls_at       => base_date + (5*i).days )}
			login_as send(cu)
			#	same as strftime('%Y-%m-%d')
			get :index, :order => :received_by_ccls_at, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by type with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :type
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by type asc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :type, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by type with #{cu} login and page too high" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :type, :page => 999
			assert_equal 3, assigns(:samples).count
			assert_equal 0, assigns(:samples).length
			assert_redirected_to samples_path(:page => 1, :order => :type)
		end

		test "should find samples and order by type desc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :type, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by subtype with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :subtype
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by subtype asc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :subtype, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by subtype desc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :subtype, :dir => :desc
			assert_response :success
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by subtype with #{cu} login and page too high" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :subtype, :page => 999
			assert_equal 3, assigns(:samples).count
			assert_equal 0, assigns(:samples).length
			assert_redirected_to samples_path(:page => 1, :order => :subtype)
		end

		test "should find samples and order by project with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :project
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

		test "should find samples and order by project asc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :project, :dir => :asc
			assert_response :success
			assert_equal samples, assigns(:samples)
		end

#	for some reason this isn't always true?
		test "should find samples and order by project desc with #{cu} login" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
#puts 'before'
#puts samples.collect(&:id)
			login_as send(cu)
			get :index, :order => :project, :dir => :desc
			assert_response :success
#puts 'after'
#puts assigns(:samples).collect(&:id)
			assert_equal samples, assigns(:samples).reverse
		end

		test "should find samples and order by project with #{cu} login and page too high" do
			samples = 3.times.collect{|i| FactoryGirl.create(:sample) }
			login_as send(cu)
			get :index, :order => :project, :page => 999
			assert_equal 3, assigns(:samples).count
			assert_equal 0, assigns(:samples).length
			assert_redirected_to samples_path(:page => 1, :order => :project)
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
			sample = FactoryGirl.create(:sample, :received_by_ccls_at => Date.parse('5/30/2012'))
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
			sample = FactoryGirl.create(:sample, :received_by_ccls_at => Date.current )
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

	end

	non_site_readers.each do |cu|

		test "should NOT get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_redirected_to root_path
		end
	
		test "should NOT get find with #{cu} login" do
			login_as send(cu)
			get :index
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

	#	not logged in ..
	
	test "should NOT get dashboard without login" do
		get :dashboard
		assert_redirected_to_login
	end
	
	test "should NOT get find without login" do
		get :index
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
	
protected 

	def create_sample_with_subject(options={})
		s = FactoryGirl.create(:study_subject, options)
		FactoryGirl.create(:sample, :study_subject => s, :project => Project['ccls'])
	end

end
