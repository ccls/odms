class Notification < ActionMailer::Base
	default from: "notifyccls@berkeley.edu"

	# Subject can be set in your I18n file at config/locales/en.yml
	# with the following lookup:
	#
	#	 en.notifications.raf_submitted.subject
	#
	def raf_submitted(study_subject)
#		@greeting = "Hi"
		@study_subject = study_subject

		mail to: "notifyccls@berkeley.edu"
		mail cc: ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"]
		mail subject: "TEST [CCLS Patient Notification Received] Identifier: #{@study_subject.icf_master_id_to_s}"
	end

	def demo
		mail to: "jakewendt@berkeley.edu"
		mail subject: "TEST EMAIL"
	end

end
