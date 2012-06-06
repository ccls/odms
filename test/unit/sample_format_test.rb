require 'test_helper'

class SampleFormatTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_not_require_attributes( :position )
	assert_should_have_many(:samples)

	test "sample format factory should create sample format" do
		assert_difference('SampleFormat.count',1) {
			sample_format = Factory(:sample_format)
			assert_match /Key\d*/,  sample_format.key
			assert_match /Desc\d*/, sample_format.description
		}
	end

	test "should return description as to_s" do
		sample_format = SampleFormat.new(:description => 'testing')
		assert_equal sample_format.description, 'testing'
		assert_equal sample_format.description, "#{sample_format}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_sample_format

end
