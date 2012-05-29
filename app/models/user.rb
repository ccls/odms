#	== requires
#	*	uid (unique)
#
#	== accessible attributes
#	*	sn
#	*	displayname
#	*	mail
#	*	telephonenumber
class User < ActiveRecord::Base

	has_and_belongs_to_many :roles, :uniq => true

	validates_presence_of   :uid
	validates_uniqueness_of :uid

	def role_names
		roles.collect(&:name).uniq
	end

	def self.with_role_name(role_name=nil)
		( role_name.blank? ) ? scoped :
			joins(:roles).where("roles.name".to_sym => role_name)
	end

	def deputize
		roles << Role.find_or_create_by_name('administrator')
	end

	#	The 4 common CCLS roles are ....
	def is_superuser?(*args)
		self.role_names.include?('superuser')
	end
	alias_method :is_super_user?, :is_superuser?

	def is_administrator?(*args)
		self.role_names.include?('administrator')
	end

	def is_editor?(*args)
		self.role_names.include?('editor')
	end

#	def is_interviewer?(*args)
#		self.role_names.include?('interviewer')
#	end

	def is_reader?(*args)
		self.role_names.include?('reader')
	end

	def is_user?(user=nil)
		!user.nil? && self == user
	end
	alias_method :may_be_user?, :is_user?

	def is_not_user?(user=nil)
		!is_user?(user)
	end
	alias_method :may_not_be_user?, :is_not_user?

	def may_administrate?(*args)
		(self.role_names & ['superuser','administrator']).length > 0
	end
	alias_method :may_view_permissions?,        :may_administrate?
	alias_method :may_create_user_invitations?, :may_administrate?
	alias_method :may_view_users?,              :may_administrate?
	alias_method :may_assign_roles?,            :may_administrate?

	def may_edit?(*args)
		(self.role_names & 
			['superuser','administrator','editor']
		).length > 0
	end
	alias_method :may_maintain_pages?, :may_edit?
	alias_method :may_create?,  :may_edit?
	alias_method :may_update?,  :may_edit?
	alias_method :may_destroy?, :may_edit?


#	Add tests for may_interview and may_read
	def may_interview?(*args)
		(self.role_names & 
			['superuser','administrator','editor']
#			['superuser','administrator','editor','interviewer']
		).length > 0
	end

#	This is pretty lame as all current roles can read
	def may_read?(*args)
		(self.role_names & 
			['superuser','administrator','editor','reader']
#			['superuser','administrator','editor','interviewer','reader']
		).length > 0
	end
	alias_method :may_view?, :may_read?

	def may_view_user?(user=nil)
		self.is_user?(user) || self.may_administrate?
	end

#	def may_share_document?(document=nil)
#		document && ( 
#			self.is_administrator? ||
#			( document.owner && self == document.owner ) 
#		)
#	end
#
#	def may_view_document?(document=nil)
#		document
#	end

	#	Find or Create a user from a given uid, and then 
	#	proceed to update the user's information from the 
	#	UCB::LDAP::Person.find_by_uid(uid) response.
	#	
	#	Returns: user
	def self.find_create_and_update_by_uid(uid)
		user = self.find_or_create_by_uid(uid)
		person = UCB::LDAP::Person.find_by_uid(uid) 
		user.update_attributes!({
			:displayname     => person.displayname,
			:sn              => person.sn.first,
#			:mail            => person.mail.first || '',	#	why did I add the ||'' ?
			:mail            => person.mail.first,
			:telephonenumber => person.telephonenumber.first
		}) unless person.nil?
		user
	end

	def to_s
		displayname
	end

	# Controllers solely accessible by administrators.
	#	( multi-line arrays, like this one, usually don't test as 
	#	100% coverage.  Not sure exactly why, but it doesn't.
	%w(	abstracts address_types birth_data 
			birth_datum_updates birth_records
			contexts data_sources diagnoses document_types
			document_versions follow_up_types 
			hospitals icf_master_ids icf_master_trackers
			icf_master_tracker_updates ineligible_reasons 
			instruments instrument_types instrument_versions 
			interview_methods interview_outcomes languages 
			odms_exceptions
			operational_event_types organizations
			people phone_types project_outcomes
			races refusal_reasons 
			sample_formats sample_outcomes sample_temperatures
			sample_types sections subject_relationships subject_types 
			tracing_statuses units vital_statuses ).each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_read_#{resource}?".to_sym,    :may_administrate?
		alias_method "may_edit_#{resource}?".to_sym,    :may_administrate?
		alias_method "may_update_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_destroy_#{resource}?".to_sym, :may_administrate?
	end

	# Controllers accessible by editors and administrators.
	%w(	contacts guides interviews patients ).each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_edit?
		alias_method "may_read_#{resource}?".to_sym,    :may_edit?
		alias_method "may_edit_#{resource}?".to_sym,    :may_edit?
		alias_method "may_update_#{resource}?".to_sym,  :may_edit?
		alias_method "may_destroy_#{resource}?".to_sym, :may_edit?
	end

	# Controllers accessible dependent on action and role.
	#	As is. Readers and editors can read, but only admins can modify.
	%w(	events ).each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_read_#{resource}?".to_sym,    :may_read?
		alias_method "may_edit_#{resource}?".to_sym,    :may_administrate?
		alias_method "may_update_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_destroy_#{resource}?".to_sym, :may_administrate?
	end

	# Controllers accessible dependent on action and role.
	#	As is. Readers can read, and editors and admins can modify.
	%w(	addressings addresses consents documents enrollments 
			home_exposures notes phone_numbers projects samples 
			study_subjects ).each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_create?
		alias_method "may_read_#{resource}?".to_sym,    :may_read?
		alias_method "may_edit_#{resource}?".to_sym,    :may_edit?
		alias_method "may_update_#{resource}?".to_sym,  :may_update?
		alias_method "may_destroy_#{resource}?".to_sym, :may_destroy?
	end

end
