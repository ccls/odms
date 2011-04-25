require 'test_helper'

class SubjectsHelperTest < ActionView::TestCase

	test "should respond to sort_link" do
		assert respond_to?(:sort_link)
	end

	test "should respond to subject_id_bar" do
		assert respond_to?(:subject_id_bar)
	end

	test "should respond to select_subject_races" do
		assert respond_to?(:select_subject_races)
	end

	test "should show subject race selector" do
		subject = create_subject
		response = select_subject_races(subject)
		assert_not_nil response
pending
		puts response
	end

end
