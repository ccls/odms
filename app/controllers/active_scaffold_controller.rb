class ActiveScaffoldController < ApplicationController

	before_filter :may_administrate_required
	layout 'active_scaffold'

	ActiveScaffold.set_defaults do |config|
		config.ignore_columns.add [:created_at, :updated_at, :lock_version]
		config.actions = [:show,:list]
	end

end
