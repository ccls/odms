require 'test_helper'

#
#	Tests here have no explicit affiliation with any particular object.
#
class ApplicationTest < ActiveSupport::TestCase

	test "email options should have only to jakewendt in test" do
		assert !email_options.empty?
		assert_equal email_options[:to], "jakewendt@berkeley.edu"
	end

	test "email options should have only to jakewendt in development" do
		Rails.stubs(:env).returns('development')
		assert !email_options.empty?
		assert_equal email_options[:to], "jakewendt@berkeley.edu"
	end

	test "email options should be empty in production" do
		Rails.stubs(:env).returns('production')
		assert email_options.empty?
	end

end
