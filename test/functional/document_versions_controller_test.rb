require 'test_helper'

class DocumentVersionsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'DocumentVersion',
		:actions => [:new,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_document_version
	}

#
#
#	Skipping create due to requirements
#	Fix me
#
#

	def factory_attributes(options={})
		Factory.attributes_for(:document_version,options)
	end

	assert_access_with_login({ 
		:logins => site_administrators })
	assert_no_access_with_login({ 
		:logins => non_site_administrators })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

	assert_no_access_with_login(
		:attributes_for_create => nil,
		:method_for_create => nil,
		:actions => nil,
		:suffix => " and invalid id",
		:login => :superuser,
		:redirect => :document_versions_path,
		:edit => { :id => 0 },
		:update => { :id => 0 },
		:show => { :id => 0 },
		:destroy => { :id => 0 }
	)

	site_administrators.each do |cu|

		test "should NOT create new document_version with #{cu} login when create fails" do
			DocumentVersion.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('DocumentVersion.count',0) do
				post :create, :document_version => factory_attributes
			end
			assert assigns(:document_version)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new document_version with #{cu} login and invalid document_version" do
			DocumentVersion.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('DocumentVersion.count',0) do
				post :create, :document_version => factory_attributes
			end
			assert assigns(:document_version)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT update document_version with #{cu} login when update fails" do
			document_version = create_document_version(:updated_at => Chronic.parse('yesterday'))
			DocumentVersion.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("DocumentVersion.find(#{document_version.id}).updated_at") {
				put :update, :id => document_version.id,
					:document_version => factory_attributes
			}
			assert assigns(:document_version)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should NOT update document_version with #{cu} login and invalid document_version" do
			document_version = create_document_version(:updated_at => Chronic.parse('yesterday'))
			DocumentVersion.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			deny_changes("DocumentVersion.find(#{document_version.id}).updated_at") {
				put :update, :id => document_version.id,
					:document_version => factory_attributes
			}
			assert assigns(:document_version)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

	end

end
