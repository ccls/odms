namespace :app do
namespace :users do

	desc "Load some default users with roles to application"
	task :add_default => :environment do
		puts "Adding users"
		admin_uids = []
		admin_uids.push(859908)	#	Jake
		admin_uids.push(228181)	#	Magee
		editor_uids = []
		editor_uids.push(930799)	#	Pagan
		editor_uids.push(721353)	#	Nadia
		editor_uids.push(979072)	#	Jennifer

		( admin_uids + editor_uids ).each do |uid|
			puts " - Adding user with uid:#{uid}:"
			ENV['uid'] = "#{uid}"
			Rake::Task["app:users:add_by_uid"].invoke
			Rake::Task["app:users:add_by_uid"].reenable
		end
		
		admin_uids.each do |uid|
			puts " - Assigning administrator role to user with uid:#{uid}:"
			ENV['uid'] = "#{uid}"
			Rake::Task["app:users:assign_administrator_by_uid"].invoke
			Rake::Task["app:users:assign_administrator_by_uid"].reenable
		end
		editor_uids.each do |uid|
			puts " - Assigning editor role to user with uid:#{uid}:"
			ENV['uid'] = "#{uid}"
			Rake::Task["app:users:assign_editor_by_uid"].invoke
			Rake::Task["app:users:assign_editor_by_uid"].reenable
		end
	end

	desc "Add user by UID"
	task :add_by_uid => :environment do
		puts
		env_uid_required
		if !User.exists?(:uid => ENV['uid'])
			puts "No user found with uid=#{ENV['uid']}. Adding..."
			User.find_create_and_update_by_uid(ENV['uid'])
		else
			puts "User with uid #{ENV['uid']} already exists."
		end
		puts
	end

	desc "Assign administrator role to user by UID"
	task :assign_administrator_by_uid => :environment do
		puts
		env_uid_required
		assign_user_role(ENV['uid'],'administrator')
		puts
	end

	desc "Assign editor role to user by UID"
	task :assign_editor_by_uid => :environment do
		puts
		env_uid_required
		assign_user_role(ENV['uid'],'editor')
		puts
	end

end	#	namespace :users do
end	#	namespace :app do

def env_uid_required
	if ENV['uid'].blank?
		puts
		puts "User's CalNet UID required."
		puts "Usage: rake #{$*} uid=INTEGER"
		puts
		exit
	end
end
def assign_user_role(user_uid,role_name)
	require 'acts_as_list'
	if !User.exists?(:uid => user_uid)
		puts "No user found with uid=#{user_uid}. Adding..."
		User.find_create_and_update_by_uid(user_uid)
	else
		puts "User with uid #{user_uid} already exists."
	end
	user = User.find_by_uid(user_uid)
	role = Role.find_by_name(role_name)

#	This should've loaded environment and the gems so I don't understand?
#	Explicitly added ... 
#	require 'acts_as_list'
#	just cause its easier?

#undefined local variable or method `acts_as_list' for #<Class:0x105390688>
#/Library/Ruby/Gems/1.8/gems/activerecord-2.3.14/lib/active_record/base.rb:1998:in `method_missing_without_paginate'
#/Library/Ruby/Gems/1.8/gems/will_paginate-2.3.16/lib/will_paginate/finder.rb:170:in `method_missing'
#/Users/jakewendt/github_repo/ccls/odms/app/models/role.rb:29

#/Users/jakewendt/github_repo/ccls/odms/lib/tasks/users.rake:85:in `assign_user_role'

	if role.nil?
		puts
		puts "No Role found with role name:#{role_name}:"
		puts "Did you load the fixtures?"
		puts "rake app:update should do that for you."
	else
		puts "Adding role ..."
		user.roles << role
		puts "User roles:#{user.role_names}:"
	end
end
