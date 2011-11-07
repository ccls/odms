require 'test_helper'
require 'integration_test_helper'

class NonwaiveredRafTest < ActionController::IntegrationTest

	site_administrators.each do |cu|

		test "should get new nonwaivered raf form and submit with #{cu} login" do
			pending	#	TODO
#			get form
#			fill in what are thought to be minimal fields
#			submit form
#			confirm success
		end

	end

end

__END__

webrat

  def test_trial_account_sign_up
    visit home_path
    click_link "Sign up"
    fill_in "Email", :with => "good@example.com"
    select "Free account"
    click_button "Register"
  end

