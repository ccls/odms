require 'test_helper'

class StringExtensionTest < ActiveSupport::TestCase

	test "namerize should capitalize uppercase word" do
		name = "APPLE"
		assert_equal "Apple", name.namerize
	end

	test "namerize should capitalize lowercase word" do
		name = "apple"
		assert_equal "Apple", name.namerize
	end

	test "namerize should capitalize multiple uppercase words" do
		name = "APPLE AND ORANGE"
		assert_equal "Apple And Orange", name.namerize
	end

	test "namerize should capitalize multiple lowercase words" do
		name = "apple and orange"
		assert_equal "Apple And Orange", name.namerize
	end

	test "namerize should capitalize hyphenated words preserving hyphen" do
		name = "APPLE-AND-ORANGE"
		assert_equal "Apple-And-Orange", name.namerize
	end

	test "namerize should capitalize apostropheated words preserving apostrophes" do
		name = "APPLE AND O'RANGE"
		assert_equal "Apple And O'Range", name.namerize
	end


	test "to_ssn should return nil for ''" do
		assert_nil ''.to_ssn
	end

	test "to_ssn should return nil for 'NONE'" do
		assert_nil 'NONE'.to_ssn
	end

	test "to_ssn should return nil for 'WITHHELD'" do
		assert_nil 'WITHHELD'.to_ssn
	end

	test "to_ssn should return nil for 'UNKNOWN'" do
		assert_nil 'UNKNOWN'.to_ssn
	end

	test "to_ssn should return '012-34-5678' for '012345678'" do
		assert_equal '012-34-5678', '012345678'.to_ssn
	end

	test "to_ssn should return '012-34-5678' for '  012345678  '" do
		assert_equal '012-34-5678', '  012345678  '.to_ssn
	end

	test "to_ssn should return '012-34-5678' for '  012-34-5678  '" do
		assert_equal '012-34-5678', '  012-34-5678  '.to_ssn
	end

end
