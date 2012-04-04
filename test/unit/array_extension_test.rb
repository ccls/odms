require 'test_helper'

class ArrayExtensionTest < ActiveSupport::TestCase

#	#	to_boolean / to_b / true? / false?
#	test "should be true with all true" do
#		assert [true, 'true', 1, '1', 't'].to_boolean
##		assert [true, 'true', 1, '1', 't'].to_b
##
##		assert  [true, 'true', 1, '1', 't'].true?
##		assert ![true, 'true', 1, '1', 't'].false?
#	end
#
#	test "should be false with one false" do
#		assert ![true, 'true', 1, '1', 't', 'f'].to_boolean
##		assert ![true, 'true', 1, '1', 't', 'f'].to_b
##
##		assert [true, 'true', 1, '1', 't', 'f'].true?
##		assert [true, 'true', 1, '1', 't', 'f'].false?
#	end
#
#	test "should be false when empty" do
#		assert ![].to_boolean
##		assert ![].to_b
##		assert ![].true?
##		assert ![].false?
#	end

#	#	true_xor_false?
#	test "should be true_xor_false? with only true" do
#		assert [true].true_xor_false?
#		assert ['true'].true_xor_false?
#		assert [1].true_xor_false?
#		assert ['1'].true_xor_false?
#		assert ['t'].true_xor_false?
#	end
#
#	test "should be true_xor_false? with only false" do
#		assert [false].true_xor_false?
#		assert ['false'].true_xor_false?
#		assert [0].true_xor_false?
#		assert ['0'].true_xor_false?
#		assert ['f'].true_xor_false?
#	end
#
#	test "should not be true_xor_false? with both true and false" do
#		assert ![true,false].true_xor_false?
#		assert !['true','false'].true_xor_false?
#		assert ![1,0].true_xor_false?
#		assert !['1','0'].true_xor_false?
#		assert !['t','f'].true_xor_false?
#	end

end
