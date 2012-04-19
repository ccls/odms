require 'test_helper'

class ContextTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object

	attributes = %w( position notes )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :notes, :maximum => 65000 )
	assert_should_act_as_list
	assert_should_have_many(:units)

	test "explicit Factory context test" do
		assert_difference('Context.count',1) {
			context = Factory(:context)
			assert_match /Key\d*/, context.key
			assert_match /Desc\d*/, context.description
		}
	end

	test "should return description as to_s" do
		context = Context.new(:description => 'testing')
		assert_equal context.description, 'testing'
		assert_equal context.description, "#{context}"
	end

	test "should have many context_contextables" do
		context = Factory(:context)
		assert context.context_contextables.empty?
	end

	test "should have many data_sources" do
		context = Factory(:context)
		assert context.data_sources.empty?
	end

	test "should have many languages" do
		context = Factory(:context)
		assert context.languages.empty?
	end

	test "should have many diagnoses" do
		context = Factory(:context)
		assert context.diagnoses.empty?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_context

end
