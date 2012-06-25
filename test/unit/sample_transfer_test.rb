require 'test_helper'

class SampleTransferTest < ActiveSupport::TestCase

	assert_should_belong_to :sample
	assert_should_belong_to( :source_org, :destination_org, 
		:class_name => 'Organization' )

	assert_should_require_attribute_length( :status, :maximum => 250 )
	assert_should_require_attribute_length( :notes, :maximum => 65000 )

end
