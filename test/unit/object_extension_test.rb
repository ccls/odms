require 'test_helper'

class ObjectExtensionTest < ActiveSupport::TestCase

	test "decode state code should return 'CA' for '  ca  '" do
		assert_equal 'CA', '  ca  '.decode_state_abbrev
	end

	test "decode state code should return 'CA' for '  CA  '" do
		assert_equal 'CA', '  CA  '.decode_state_abbrev
	end

	test "decode state code should return 'CA' for 'CA'" do
		assert_equal 'CA', 'CA'.decode_state_abbrev
	end

	test "decode state code should return 'CA' for '5'" do
		assert_equal 'CA', '05'.decode_state_abbrev
	end

	test "decode state code should return 'CA' for '05'" do
		assert_equal 'CA', '05'.decode_state_abbrev
	end

	test "decode state code should return 'CA' for '105'" do
		assert_equal 'CA', '105'.decode_state_abbrev
	end

	test "decode state code should return 'CA' for 5" do
		assert_equal 'CA', 5.decode_state_abbrev
	end

	test "decode state code should return 'CA' for 105" do
		assert_equal 'CA', 105.decode_state_abbrev
	end


	test "decode county code should return 'Alameda' for '01'" do
		assert_equal 'Alameda', '01'.decode_county
	end

	test "decode county code should return 'Alameda' for '1'" do
		assert_equal 'Alameda', '1'.decode_county
	end

	test "decode county code should return 'Alameda' for 1" do
		assert_equal 'Alameda', 1.decode_county
	end

	test "decode county code should return 'Alameda' for 'Alameda'" do
		assert_equal 'Alameda', 'Alameda'.decode_county
	end

	test "decode county code should return 'Alameda' for 'ALAMEDA'" do
		assert_equal 'Alameda', 'ALAMEDA'.decode_county
	end

	test "decode county code should return 'Alameda' for '  ALAMEDA  '" do
		assert_equal 'Alameda', '  ALAMEDA  '.decode_county
	end


	test "to_ssn should return nil for nil" do
		assert_nil nil.to_ssn
	end

end
