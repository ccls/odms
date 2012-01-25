require 'test_helper'

class LiveBirthDatasControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'LiveBirthData',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_live_birth_data
	}
	#	LiveBirthData have no attributes other than the csv_file
	#	so need to add the updated_at to force a difference
	#	on update.
	def factory_attributes(options={})
		Factory.attributes_for(:live_birth_data,{
			:updated_at => Time.now }.merge(options))
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	site_administrators.each do |cu|

		test "should create with csv_file attachment and #{cu} login" do
			login_as send(cu)
			test_file_name = "live_birth_data_test_file"
			File.open(test_file_name,'w'){|f|f.puts 'testing'}
			assert_difference('LiveBirthData.count',1) {
				post :create, :live_birth_data => {
					:csv_file => File.open(test_file_name)
				}
			}
			assert_not_nil assigns(:live_birth_data).csv_file_file_name
			assert_not_nil assigns(:live_birth_data).csv_file_file_name
			assert_equal   assigns(:live_birth_data).csv_file_file_name, test_file_name
			assert_not_nil assigns(:live_birth_data).csv_file_content_type
			assert_not_nil assigns(:live_birth_data).csv_file_file_size
			assert_not_nil assigns(:live_birth_data).csv_file_updated_at
			#	explicit destroy to remove attachment
			assigns(:live_birth_data).destroy	
			#	explicit delete to remove test file
			File.delete(test_file_name)	
		end

#	should I allow editting the file?

		test "should update with csv_file attachment and #{cu} login" do
			login_as send(cu)
			live_birth_data = Factory(:live_birth_data)
			assert_nil live_birth_data.csv_file_file_name
			test_file_name = "live_birth_data_test_file"
			File.open(test_file_name,'w'){|f|f.puts 'testing'}
			assert_difference('LiveBirthData.count',0) {
				put :update, :id => live_birth_data.id, :live_birth_data => {
					:csv_file => File.open(test_file_name)
				}
			}
			live_birth_data.reload
			assert File.exists?(live_birth_data.csv_file.path)
			assert_not_nil live_birth_data.csv_file_file_name
			assert_equal   live_birth_data.csv_file_file_name, test_file_name
			assert_not_nil live_birth_data.csv_file_content_type
			assert_not_nil live_birth_data.csv_file_file_size
			assert_not_nil live_birth_data.csv_file_updated_at
			#	explicit destroy to remove attachment
			live_birth_data.destroy	
			#	explicit delete to remove test file
			File.delete(test_file_name)	
		end

#	should I allow destroying?

		test "should destroy with csv_file attachment and #{cu} login" do
			login_as send(cu)
			test_file_name = "live_birth_data_test_file"
			File.open(test_file_name,'w'){|f|f.puts 'testing'}
			live_birth_data = Factory(:live_birth_data,
				:csv_file => File.open(test_file_name) )
			assert File.exists?(live_birth_data.csv_file.path)
			assert_difference('LiveBirthData.count',-1) {
				delete :destroy, :id => live_birth_data.id
			}
			assert !File.exists?(live_birth_data.csv_file.path)
			#	explicit delete to remove test file
			File.delete(test_file_name)	
		end





		test "should parse with #{cu} login" do
			login_as send(cu)
			create_case_for_live_birth_data
			live_birth_data = create_test_file_and_live_birth_data
			assert_difference('CandidateControl.count',1){
				post :parse, :id => live_birth_data.id
			}
			cleanup_live_birth_data_and_test_file(live_birth_data)
		end

	end

	non_site_administrators.each do |cu|

		test "should not parse with #{cu} login" do
			login_as send(cu)
			create_case_for_live_birth_data
			live_birth_data = create_test_file_and_live_birth_data
			assert_difference('CandidateControl.count',0){
				post :parse, :id => live_birth_data.id
			}
			cleanup_live_birth_data_and_test_file(live_birth_data)
		end

	end

	test "should not parse without login" do
		create_case_for_live_birth_data
		live_birth_data = create_test_file_and_live_birth_data
		assert_difference('CandidateControl.count',0){
			post :parse, :id => live_birth_data.id
		}
		cleanup_live_birth_data_and_test_file(live_birth_data)
	end




protected

	def create_test_file_and_live_birth_data
		create_test_file
		live_birth_data = Factory(:live_birth_data,
			:csv_file => File.open(test_file_name) )
		assert_not_nil live_birth_data.csv_file_file_name
		live_birth_data
	end

	def cleanup_live_birth_data_and_test_file(live_birth_data)
		#	explicit destroy to remove attachment
		live_birth_data.destroy	
#		assert !File.exists?(live_birth_data.csv_file.path)
		#	explicit delete to remove test file
		File.delete(test_file_name)	
		assert !File.exists?(test_file_name)
	end

	def create_case_for_live_birth_data
		icf_master_id = Factory(:icf_master_id,:icf_master_id => '1234FAKE')
		study_subject = Factory(:complete_case_study_subject)
		study_subject.assign_icf_master_id
		assert_equal '1234FAKE', study_subject.icf_master_id
		study_subject
	end

	def create_test_file
		File.open(test_file_name,'w'){|f|f.puts %{masterid,ca_co_status,biomom,biodad,date,mother_full_name,mother_maiden_name,father_full_name,child_full_name,child_dobm,child_dobd,child_doby,child_gender,birthplace_country,birthplace_state,birthplace_city,mother_hispanicity,mother_hispanicity_mex,mother_race,mother_race_other,father_hispanicity,father_hispanicity_mex,father_race,father_race_other
1234FAKE,case,1,,1/18/2012,Jane Smith,Jones,John Smith,Jimmy Smith,1,6,2009,M,United States,CA,Bakersfield,2,2,1,,2,2,1,
#{control[:masterid]},#{control[:ca_co_status]},#{control[:biomom]},#{control[:biodad]},#{control[:date]},#{control[:mother_full_name]},#{control[:mother_maiden_name]},#{control[:father_full_name]},#{control[:child_full_name]},#{control[:child_dobm]},#{control[:child_dobd]},#{control[:child_doby]},#{control[:child_gender]},#{control[:birthplace_country]},#{control[:birthplace_state]},#{control[:birthplace_city]},#{control[:mother_hispanicity]},#{control[:mother_hispanicity_mex]},#{control[:mother_race]},#{control[:mother_race_other]},#{control[:father_hispanicity]},#{control[:father_hispanicity_mex]},#{control[:father_race]},#{control[:father_race_other]}} }
#1234FAKE,control,1,,,Jill Johnson,Jackson,Jack Johnson,Michael Johnson,1,6,2009,M,United States,CA,Oakland,2,2,1,,2,2,1,} }
	end

	#	broke it down like this so that can access and compare the attributes
	def control
		{	:masterid => '1234FAKE',
			:ca_co_status => 'control',
			:biomom => 1,
			:biodad => nil,
			:date => nil,
			:mother_full_name => 'Jill Johnson',
			:mother_maiden_name => 'Jackson',
			:father_full_name => 'Jack Johnson',
			:child_full_name => 'Michael Johnson',
			:child_dobm => 1,
			:child_dobd => 6,
			:child_doby => 2009,
			:child_gender => 'M',
			:birthplace_country => 'United States',
			:birthplace_state => 'CA',
			:birthplace_city => 'Oakland',
			:mother_hispanicity => 2,
			:mother_hispanicity_mex => 2,
			:mother_race => 1,
			:mother_race_other => nil,
			:father_hispanicity => 2,
			:father_hispanicity_mex => 2,
			:father_race => 1,
			:father_race_other => nil }
	end

#	def turn_off_paperclip_logging
#		#	Is there I way to silence the paperclip output?  Yes...
#		Paperclip.options[:log] = false
#		#	Is there I way to capture the paperclip output for comparison?  Don't know.
#	end

	def test_file_name
		"live_birth_data_test_file.csv"
	end

end
