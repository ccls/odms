class Notification < ActionMailer::Base
	default from: "notifyccls@berkeley.edu"

#
#	Really important NOTE...
#
#	These methods are usually chained ...
#
#		Notification.demo.deliver
#
#	which means that they should return a mail object.
#	Normally it does.  However, if you set a variable to be
#	used in the template, but don't call a "mail" method after
#	it, the template will NOT include this.  Surprise!
#	So make sure that the LAST thing in these methods is
#	a mail command.  I don't think it matters which.
#


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

	def plain(content="No body given",options={})
		defaults = {
			:to => ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"],
			:subject => "ODMS: No subject given"
		}.merge(options)
		@content = content	#	BEFORE last 'mail' method call
		mail defaults
	end

	def updates_from_icf_master_tracker(changed,options={})
		@changed = changed
		defaults = {
			:to => ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"],
			:subject => "ODMS: updates_from_icf_master_tracker"
		}.merge(options)
		mail defaults
	end

	def updates_from_bc_info(bc_info_file,study_subjects,options={})
		@bc_info_file   = bc_info_file
		@study_subjects = study_subjects
		defaults = {
			:to => ["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"],
			:subject => "ODMS: updates_from_bc_info"
		}.merge(options)
		mail defaults
	end

	def demo
		mail to: "jakewendt@berkeley.edu"
		mail subject: "ODMS: DEMO EMAIL"
	end

end
