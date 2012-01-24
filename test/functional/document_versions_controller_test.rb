require 'test_helper'

class DocumentVersionsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'DocumentVersion',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_document_version
	}

	def factory_attributes(options={})
		Factory.attributes_for(:document_version, {
			:document_type_id => DocumentType.random.id }.merge(options) )
	end

	assert_access_with_login({ 
		:logins => site_administrators })
	assert_no_access_with_login({ 
		:logins => non_site_administrators })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

end
