require 'test_helper'

class NumericExtensionTest < ActiveSupport::TestCase

	test "chart round should " do
skip 'pending'
#		assert_equal ????, 1.chart_round
	end

#	a leading 0 makes it octal!!!

	test "to_ssn for 12345678 should return '012-34-5678'" do
#test/unit/numeric_extension_test.rb:11: Invalid octal digit
#		assert_equal 012345678.to_ssn, '012-34-5678'
#		                      ^
		assert_equal 12345678.to_ssn, '012-34-5678'
	end

	test "to_ssn for 1234567890 should return nil as is too long" do
		assert_nil 1234567890.to_ssn
	end

end
