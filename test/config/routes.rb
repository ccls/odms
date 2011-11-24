ActionController::Routing::Routes.draw do |map|

	#	Add fake login controller solely for integration testing.
	map.resource :fake_session, :only => [:new,:create]

end
