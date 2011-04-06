require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

	test "mdy should return mdy date with date" do
		response = mdy(Date.parse('Dec 31, 1999'))
		assert_match '12/31/1999', response
	end

	test "mdy should return nbsp with nil date" do
		response = mdy(nil)
		assert_match '&nbsp;', response
	end

	test "y_n_dk should return 'Yes' with 1" do
		response = y_n_dk(1)
		assert_match 'Yes', response
	end

	test "y_n_dk should return 'No' with 2" do
		response = y_n_dk(2)
		assert_match 'No', response
	end

	test "y_n_dk should return 'Don\'t Know' with 999" do
		response = y_n_dk(999)
		assert_match "Don't Know", response
	end

	test "y_n_dk should return 'nbsp' with other" do
		response = y_n_dk(nil)
		assert_match '&nbsp;', response
	end


	test "sub_menu_for Subject should" do
pending
	end

	test "sub_menu_for Interview should" do
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

	test "followup_sub_menu should not have a .current without matching controller" do
		response = followup_sub_menu
		assert response.blank?
		assert response.nil?
#		puts @content_for_main
#<div id='submenu'>
#<a href="/followup/subjects">manage by subject</a>
#<a href="/followup/gift_cards">manage by cards</a>
#</div><!-- submenu -->
		html = HTML::Document.new(@content_for_main).root
		assert_select html, 'div#submenu', 1 do
			assert_select 'a', 2
			assert_select 'a.current', 0
		end
	end

end
