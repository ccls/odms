require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

	test "sub_menu_for Subject should" do
pending
	end

	test "sub_menu_for nil should return nil" do
		response = sub_menu_for(nil)
		assert_nil response
	end

	test "id_bar_for other object should return nil" do
		response = id_bar_for(Object)
		assert response.blank?
		assert response.nil?
	end

end
