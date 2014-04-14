#	== requires
#	*	uid (unique)
#
#	== accessible attributes
#	*	sn
#	*	displayname
#	*	mail
#	*	telephonenumber
class User < ActiveRecord::Base

	attr_accessible :uid, :sn, :displayname, :mail, :telephonenumber

	has_and_belongs_to_many :roles, -> { uniq }

	validations_from_yaml_file

	def role_names
		roles.collect(&:name).uniq
	end

	def self.with_role_name(role_name=nil)
		( role_name.blank? ) ? all :
			joins(:roles).where(Role.arel_table[:name].eq(role_name))
	end

	def deputize
		roles << Role.find_or_create_by(name: 'administrator')
	end

	#	The 4 common CCLS roles are ....
	def is_superuser?(*args)
		self.role_names.include?('superuser')
	end
	alias_method :is_super_user?, :is_superuser?

	def is_administrator?(*args)
		self.role_names.include?('administrator')
	end

	def is_exporter?(*args)
		self.role_names.include?('exporter')
	end

	def is_editor?(*args)
		self.role_names.include?('editor')
	end

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

	def may_export?(*args)
		(self.role_names & 
			['superuser','administrator','exporter']
		).length > 0
	end

	def may_edit?(*args)
		(self.role_names & 
			['superuser','administrator','exporter','editor']
		).length > 0
	end
	alias_method :may_maintain_pages?, :may_edit?
	alias_method :may_create?,  :may_edit?
	alias_method :may_update?,  :may_edit?
	alias_method :may_destroy?, :may_administrate?


	#	This is pretty lame as all current roles can read
	#	Could simply check the role_names not empty?
	#	Of course this forces the role to be legitimate
	def may_read?(*args)
		(self.role_names & 
			['superuser','administrator','exporter','editor','reader']
		).length > 0
	end
	alias_method :may_view?, :may_read?

	def may_view_user?(user=nil)
		self.is_user?(user) || self.may_administrate?
	end

	#	Find or Create a user from a given uid, and then 
	#	proceed to update the user's information from the 
	#	UCB::LDAP::Person.find_by_uid(uid) response.
	#	
	#	Returns: user
	def self.find_create_and_update_by_uid(uid)
		user = self.find_or_create_by(uid: uid)
		person = UCB::LDAP::Person.find_by_uid(uid) 
		user.update_attributes!({
			:displayname     => person.displayname,
			:sn              => person.sn.first,
			:mail            => person.mail.first,
			:telephonenumber => person.telephonenumber.first
		}) unless person.nil?
		user
	end

	def to_s
		displayname
	end

	#	by using the config file to define these, I should get coverage to 100%
	@@permissions = YAML::load(ERB.new(IO.read(File.expand_path(
			File.join(Rails.root,'config/user_permissions.yml')))).result)

	@@permissions['superuser_resources'].each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :is_superuser?
		alias_method "may_read_#{resource}?".to_sym,    :is_superuser?
		alias_method "may_update_#{resource}?".to_sym,  :is_superuser?
		alias_method "may_destroy_#{resource}?".to_sym, :is_superuser?
	end

	@@permissions['administrator_resources'].each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_read_#{resource}?".to_sym,    :may_administrate?
		alias_method "may_update_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_destroy_#{resource}?".to_sym, :may_administrate?
	end

	@@permissions['editor_resources'].each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_edit?
		alias_method "may_read_#{resource}?".to_sym,    :may_edit?
		alias_method "may_update_#{resource}?".to_sym,  :may_edit?
		alias_method "may_destroy_#{resource}?".to_sym, :may_edit?
	end

	# Controllers accessible dependent on action and role.
	#	As is. Readers and editors can read, but only admins can modify.
	%w( events ).each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_read_#{resource}?".to_sym,    :may_read?
		alias_method "may_update_#{resource}?".to_sym,  :may_administrate?
		alias_method "may_destroy_#{resource}?".to_sym, :may_administrate?
	end

	@@permissions['crud_resources'].each do |resource|
		alias_method "may_create_#{resource}?".to_sym,  :may_create?
		alias_method "may_read_#{resource}?".to_sym,    :may_read?
		alias_method "may_update_#{resource}?".to_sym,  :may_update?
		alias_method "may_destroy_#{resource}?".to_sym, :may_destroy?
	end

end
