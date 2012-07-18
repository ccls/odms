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

end
