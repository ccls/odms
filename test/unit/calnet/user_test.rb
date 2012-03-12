require 'test_helper'

class Calnet::UserTest < ActiveSupport::TestCase

	assert_should_require(:uid)
	assert_should_require_unique(:uid)
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

	test "should create interviewer" do
		assert_difference 'User.count' do
			user = create_object
			user.roles << Role.find_by_name('interviewer')
			assert  user.is_interviewer?
			assert  user.may_interview?
			assert  user.may_read?
			assert !user.is_administrator?
			assert !user.may_administrate?
			assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
		end
	end

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
			assert user.may_share_document?('document')
			assert user.may_view_document?('document')

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

	test "should return non-nil mail" do
		user = create_object
		assert_not_nil user.mail
	end

#	test "should return non-nil gravatar_url" do
#		user = create_object
#		assert_not_nil user.gravatar_url
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

end
