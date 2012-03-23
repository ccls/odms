module ActionControllerExtension::Routing

	def self.included(base)
		base.extend ClassMethods
	end

	module ClassMethods

#		def assert_route
#		end

		def assert_no_route(verb,action,args={})
			test "#{brand}no route to #{verb} #{action} #{args.inspect}" do
#
#	Apparently, when using the asset pipeline, this routing error
#	will not get raised.  I don't know why just yet.  The request
#	will actually get passed to the controller without regard
#	for whether the route exists.
#	Some get kicked to the Calnet login screen.
#	Some raise AbstractController::ActionNotFound
#
#	rake routes doesn't list the route
#
#	Perhaps its is better to just search for the route?
#
pending	#	TODO
#puts "#{[verb,action,args].join(', ')}"
#
#	wrap this in a condition?
#

#	if Rails.application.config.assets.enabled
#		pending
#	else

#				assert_raise(ActionController::RoutingError){
#					send(verb,action,args)
#
#	Before asset pipeline, it never made it this far ...
#
#Processing by AddressingsController#destroy as HTML
#Guessed service url: "http://test.host/assets"
#Generated login url: https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2Ftest.host%2Fassets
#Redirecting to "https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2Ftest.host%2Fassets"
#Redirected to https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2Ftest.host%2Fassets
#Filter chain halted as :login_required rendered or redirected
#Completed 302 Found in 3ms (ActiveRecord: 0.5ms)
#
#	It just raised the error ...
#		ActionController::RoutingError: No route matches 
#			{:controller=>"addressings", :action=>"destroy"}
#
#
#
#				}
#
#Rails.application.routes.recognize_path(
#	'/addressings',{:method => verb})
#
#
#	actually I'd want an assert_not_recognizes, but it doesn't exist
#
#assert_recognizes({:controller => 'addressings', :action => action}.merge(args),
#	{:method => verb})
#assert_recognizes({:controller => 'addressings', :action => :destroy},
#	{:method => :delete})

			end
		end

	end	# module ClassMethods
end	#	module ActionControllerExtension::Routing
ActionController::TestCase.send(:include, 
	ActionControllerExtension::Routing)
