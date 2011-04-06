require 'test_helper'

class PackageHelperTest < ActionView::TestCase

	test "tracks_for requires valid package" do
		assert_raise(NoMethodError){
			tracks_for(nil)
		}
	end

	test "tracks_for should return div#tracks" do
		package = Factory(:package)
		response = HTML::Document.new(tracks_for(package)).root
		assert_select response, 'div#tracks', 1
	end

	test "tracks_for should not have tracks in div#tracks" do
		package = Factory(:package)
		response = HTML::Document.new(tracks_for(package)).root
		assert_select response, 'div#tracks', 1 do
			assert_select 'div.track', 0
			assert_select 'div.row', 1
		end
	end

	test "tracks_for should have tracks in div#tracks" do
		package = Factory(:track).trackable.reload
		response = HTML::Document.new(tracks_for(package)).root
		assert_select response, 'div#tracks', 1 do
			assert_select 'div.track', 1
		end
	end

end
