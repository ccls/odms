require 'test_helper'

class GuideTest < ActiveSupport::TestCase

	assert_should_create_default_object

	#	scope'll probably muck this up.
	assert_should_require_unique_attribute(:action, :scope => :controller)
	assert_should_not_require_attributes( :controller )
	assert_should_not_require_attributes( :body )

#	attributes = %w( body action controller )
#	required   = %w( action )
#	unique     = %w( action )
#	assert_should_require( required )
#	assert_should_not_require( attributes - required )
#	assert_should_not_require_unique( attributes - unique )

	assert_should_require_attribute_length( :controller, :action,
		:maximum => 250 )
	assert_should_require_attribute_length( :body, :maximum => 65000 )

	test "should return controller and action name as to_s" do
		guide = FactoryBot.create(:guide)
		assert_equal "#{guide.controller}##{guide.action}", "#{guide}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_guide

end
