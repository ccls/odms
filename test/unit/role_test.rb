require 'test_helper'

class RoleTest < ActiveSupport::TestCase

	assert_should_act_as_list
	assert_should_require(:name)
	assert_should_require_unique(:name)
	assert_should_habtm(:users)

	test "should create role" do
		assert_difference('Role.count',1) do
			role = create_role
			assert !role.new_record?, 
				"#{role.errors.full_messages.to_sentence}"
		end 
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_role

end
