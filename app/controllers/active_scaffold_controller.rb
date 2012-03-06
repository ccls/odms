class ActiveScaffoldController < ApplicationController

	before_filter :may_administrate_required
	layout 'active_scaffold'

	ActiveScaffold.set_defaults do |config|
		config.ignore_columns.add [:created_at, :updated_at, :lock_version]
		config.actions = [:show,:list,:nested,:search]
#	vendor/plugins/active_scaffold/lib/active_scaffold/actions/
#field_search, nested, subform, create, list, search, update, delete, live_search, show
	end

protected

	#	used many times, so define as a class method.
	def self.as_yndk_select
#	This should work.
#		[['-select-',nil]] + YNDK.selector_options
		[['-select-',nil],["Yes",  1], ["No", 2],["Don't Know",999]]
	end

#	def self.user_uid_select
#		[['-select-',nil]] + User.all.collect{|u|[u.displayname ,u.uid]}
#	end

end
