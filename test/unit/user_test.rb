require 'test_helper'

class UserTest < ActiveSupport::TestCase

	#	test both sides of the coin by starting with all of the attributes
	#	could be a challenge since all things aren't black and white
	attributes = %w( uid sn displayname mail telephonenumber )
	required   = %w( uid )
	unique     = %w( uid )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
	assert_should_require_unique( unique )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes )

	assert_should_habtm(:roles)

	test "should create user" do
		assert_difference 'User.count' do
			user = create_object
			assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
			assert !user.may_administrate?
		end
	end

	test "should create reader" do
		assert_difference 'User.count' do
			user = create_object
			user.roles << Role.find_by_name('reader')
			assert  user.is_reader?
			assert  user.may_read?
			assert !user.is_administrator?
			assert !user.may_administrate?
			assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
		end
	end

#	test "should create interviewer" do
#		assert_difference 'User.count' do
#			user = create_object
#			user.roles << Role.find_by_name('interviewer')
#			assert  user.is_interviewer?
#			assert  user.may_interview?
#			assert  user.may_read?
#			assert !user.is_administrator?
#			assert !user.may_administrate?
#			assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
#		end
#	end

	test "should create editor" do
		assert_difference 'User.count' do
			user = create_object
			user.roles << Role.find_by_name('editor')
			assert  user.is_editor?
			assert  user.may_edit?
			assert  user.may_interview?
			assert  user.may_read?
			assert !user.is_administrator?
			assert !user.may_administrate?
			assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
		end
	end

	test "should create administrator" do
		assert_difference 'User.count' do
			user = create_object
			user.roles << Role.find_by_name('administrator')
			assert  user.is_administrator?
			assert  user.may_edit?
			assert  user.may_interview?
			assert  user.may_read?
			assert  user.may_administrate?

			assert user.may_view_permissions?
			assert user.may_create_user_invitations?
			assert user.may_view_users?
			assert user.may_assign_roles?
			assert user.may_maintain_pages?
			assert user.may_view_user?
			assert user.is_user?(user)
			assert user.may_be_user?(user)
#			assert user.may_share_document?('document')
#			assert user.may_view_document?('document')

			assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
		end
	end

	test "should create superuser" do
		assert_difference 'User.count' do
			user = create_object
			user.roles << Role.find_by_name('superuser')
			assert  user.is_superuser?
			assert  user.is_super_user?
			assert  user.may_administrate?
			assert  user.may_edit?
			assert  user.may_interview?
			assert  user.may_read?
			assert  user.may_administrate?
			assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
		end
	end

	test "should deputize to create administrator" do
		u = create_object
		assert !u.role_names.include?('administrator')
		u.deputize
		assert  u.role_names.include?('administrator')
	end

#	test "should return non-nil mail" do			#	why is mail so special?
#		user = create_object
#		assert_not_nil user.mail
#	end

	test "should respond to roles" do
		user = create_object
		assert user.respond_to?(:roles)
	end

	test "should have many roles" do
		u = create_object
		assert_equal 0, u.roles.length
		roles = Role.all
		assert roles.length > 0
		roles.each do |role|
			assert_difference("User.find(#{u.id}).role_names.length") {
			assert_difference("User.find(#{u.id}).roles.length") {
				u.roles << role
			} }
		end
	end

	test "should return displayname as to_s" do
		object = create_object(:displayname => "Mr Test")
		assert_equal object.displayname, "Mr Test"
		assert_equal object.displayname, "#{object}"
	end

	test "should find users by role name" do
		admin  = send(:administrator)
		editor = send(:editor)
		reader = send(:reader)
		all_users = User.with_role_name()
		assert_equal 3, all_users.length
		admins  = User.with_role_name(:administrator)
		assert_equal 1, admins.length
		assert admins.include?(admin)
		editors = User.with_role_name(:editor)
		assert_equal 1, editors.length
		assert editors.include?(editor)
		readers = User.with_role_name(:reader)
		assert_equal 1, readers.length
		assert readers.include?(reader)
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_user

end
