require 'test_helper'

class GuideTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_require_unique_attribute(:action, :scope => :controller)
	assert_should_not_require_attributes( :controller )
	assert_should_not_require_attributes( :body )
	with_options :maximum => 250 do |o|
		o.assert_should_require_attribute_length( :controller )
		o.assert_should_require_attribute_length( :action )
	end

	test "should return controller and action name as to_s" do
		guide = create_guide
		assert_equal "#{guide.controller}##{guide.action}", "#{guide}"
	end

end
