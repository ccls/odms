Odms::Application.routes.draw do

	resource :fake_session, :only => [:new,:create]

end
__END__
ActionController::Routing::Routes.draw do |map|

	#	Add fake login controller solely for integration testing.
	map.resource :fake_session, :only => [:new,:create]

end
