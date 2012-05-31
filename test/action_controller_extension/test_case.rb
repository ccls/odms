module ActionControllerExtension::TestCase

	def assert_layout(layout)
		layout = "layouts/#{layout}" unless layout.match(/^layouts/)
		assert_equal layout, @response.layout
	end

end	#	module ActionControllerExtension::TestCase
ActionController::TestCase.send(:include,
	ActionControllerExtension::TestCase)
