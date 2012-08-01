require 'test_helper'

class NumericExtensionTest < ActiveSupport::TestCase

	test "chart round for 0 should return 10" do
		#	10 is default for now
		assert_equal 10, 0.chart_round
		assert_equal Rational(11,10), 1.chart_round	#	11/10
		assert_equal Rational(11, 2), 5.chart_round	#	11/2
		#
		#	TODO Fix the above ( the purpose is to provide a larger ROUNDED number )
		#			Need the rational cast as otherwise 11/10 becomes 1
		#
		assert_equal 11, 10.chart_round
		assert_equal 55, 50.chart_round
		assert_equal 110, 100.chart_round
		assert_equal 550, 500.chart_round
		assert_equal 1100, 1000.chart_round
	end

#	a leading 0 makes it octal!!!

	test "to_ssn for 12345678 should return '012-34-5678'" do
#test/unit/numeric_extension_test.rb:11: Invalid octal digit
#		assert_equal 012345678.to_ssn, '012-34-5678'
#		                      ^
		assert_equal 12345678.to_ssn, '012-34-5678'
	end

	test "to_ssn should return nil for 1234567890 as is too long" do
		assert_nil 1234567890.to_ssn
	end

	test "to_ssn should return nil for 999999999 as is invalid" do
		assert_nil 999999999.to_ssn
	end

end
