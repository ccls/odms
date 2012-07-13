require 'test_helper'

class NotificationTest < ActionMailer::TestCase

	test "raf_submitted" do
		mail = Notification.raf_submitted
		assert_equal "TEST EMAIL - disregard", mail.subject
		assert_equal ["magee@berkeley.edu"], mail.to
		assert_equal ["notifyccls@berkeley.edu"], mail.from
		assert_equal ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"], mail.cc
		assert_match "Test email from ODMS RAF data entry. Please disregard.", 
			mail.body.encoded
	end

end
