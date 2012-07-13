class Notification < ActionMailer::Base
	default from: "notifyccls@berkeley.edu"

	# Subject can be set in your I18n file at config/locales/en.yml
	# with the following lookup:
	#
	#	 en.notifications.raf_submitted.subject
	#
	def raf_submitted
#		@greeting = "Hi"

		mail to: "magee@berkeley.edu"
		mail cc: ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"]
		mail subject: "TEST EMAIL - disregard"
	end
end
