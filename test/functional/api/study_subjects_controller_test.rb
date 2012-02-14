require 'test_helper'

class Api::StudySubjectsControllerTest < ActionController::TestCase

	test "should get study_subjects with credentials" do
		set_credentials
		study_subject = create_study_subject
		get :index
		assert_response :success
		assert assigns(:study_subjects)
		assert assigns(:study_subjects).include?(study_subject)
	end

	test "should not get study_subjects without credentials" do
		study_subject = create_study_subject
		get :index
		assert_response 401
		assert_response :unauthorized
		#	action_controller/status_codes.rb
	end

#	test "should not gem homex study_subject without id" do
#		set_credentials
#		assert_raise(ActionController::RoutingError){
#			get :show
#		}
#	end
#
#	test "should not gem homex study_subject with invalid id" do
#		set_credentials
#		assert_raise(ActiveRecord::RecordNotFound){
#			get :show, :id => 0
#		}
#	end

protected 

	def set_credentials
		config = YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/api.yml")).result)
		@request.env['HTTP_AUTHORIZATION'
			] = ActionController::HttpAuthentication::Basic.encode_credentials(
				config[:user],config[:password])
	end

end
