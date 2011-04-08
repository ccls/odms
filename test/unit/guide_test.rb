#require File.dirname(__FILE__) + '/../test_helper'
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

end
