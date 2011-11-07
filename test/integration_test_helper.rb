require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

class ActionController::IntegrationTest
	include CalnetAuthenticated::TestHelper

	fixtures :all

	#	Special login_as for integration testing.
	def login_as( user=nil )
		uid = ( user.is_a?(User) ) ? user.uid : user
		if !uid.blank?
			stub_ucb_ldap_person()
			u = User.find_create_and_update_by_uid(uid)
			#	Rather than manually manipulate the session,
			#	I created a fake controller to do it.
			#	Still not using the @session provided by integration testing (open_session)
			post fake_session_path(), { :id => u.id }, { 'HTTPS' => 'on' }
			CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
		end
	end

end
