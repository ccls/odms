require 'test_helper'

class DateExtensionTest < ActiveSupport::TestCase

	test "diff(date) should return hash" do
		assert Date.today.diff(Date.yesterday).is_a?(Hash)
	end

	test "today.diff(yesterday) should be 1 day" do
		diff = Date.today.diff(Date.yesterday)
		assert_equal 0, diff[:years]
		assert_equal 0, diff[:months]
		assert_equal 1, diff[:days]
		assert_equal 'after', diff[:relation]
	end

	test "12/31/2000.diff(1/1/2001) should be 1 day before" do
		diff = Date.parse('12/31/2000').diff(Date.parse('1/1/2001'))
		assert_equal 0, diff[:years]
		assert_equal 0, diff[:months]
		assert_equal 1, diff[:days]
		assert_equal 'before', diff[:relation]
	end

	test "1/1/2001.diff(12/31/2000) should be 1 day after" do
		diff = Date.parse('1/1/2001').diff(Date.parse('12/31/2000'))
		assert_equal 0, diff[:years]
		assert_equal 0, diff[:months]
		assert_equal 1, diff[:days]
		assert_equal 'after', diff[:relation]
	end

	test "5/5/2010.diff(10/19/2001) should be 8 years, 6 months, 17 days" do
		diff = Date.parse('5/5/2010').diff(Date.parse('10/19/2001'))
		assert_equal 8, diff[:years]
		assert_equal 6, diff[:months]
		assert_equal 17, diff[:days]
		assert_equal 'after', diff[:relation]
	end

end
