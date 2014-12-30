class Notification < ActionMailer::Base

	default :from => "notifyccls@berkeley.edu",
		:to   => (( Rails.env.production? ) ? 
			["jakewendt@berkeley.edu", "notifyccls@berkeley.edu"] : ['jakewendt@berkeley.edu'] )
	
	#
	#	Really important NOTE...
	#
	#	These methods are usually chained ...
	#
	#		Notification.demo.deliver_now
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
		@study_subject = study_subject
		@hospital = Hospital.find_by_organization_id(@study_subject.organization_id)

		mail subject: "[CCLS Patient Notification Received] Identifier: #{@study_subject.icf_master_id_to_s}"
	end

	def plain(content="No body given",options={})
		defaults = {
			:subject => "ODMS: No subject given"
		}.merge(options)
		@content = content	#	BEFORE last 'mail' method call
		mail defaults
	end

	def updates_from_icf_master_tracker(changed,options={})
		@changed = changed
		defaults = {
			:subject => "ODMS: updates_from_icf_master_tracker"
		}.merge(options)
		mail defaults
	end

	def updates_from_bc_info(bc_info_file,bc_infos,options={})
		@bc_info_file = bc_info_file
		@bc_infos     = bc_infos
		defaults = {
			:subject => "ODMS: updates_from_bc_info #{File.basename(bc_info_file)}"
		}.merge(options)
		mail defaults
	end

	def updates_from_birth_data(birth_data_file,birth_data,options={})
		@birth_data_file = birth_data_file
		@birth_data  = birth_data
		defaults = {
			:subject => "ODMS: updates_from_birth_data #{File.basename(birth_data_file)}"
		}.merge(options)
		mail defaults
	end

	def demo
		mail to: "jakewendt@berkeley.edu"
		mail subject: "ODMS: DEMO EMAIL"
	end

end
