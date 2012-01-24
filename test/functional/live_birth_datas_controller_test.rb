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

	end

end
