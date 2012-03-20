class UsersController < ApplicationController

	before_filter :id_required, :only => [:edit, :show, :update, :destroy]
	before_filter :may_view_user_required, :except => [:index,:menu]
	before_filter :may_view_users_required, :only => :index

	def show
		@roles = Role.all
	end

	def index
#	Only a role_name is every passed here an no one really uses it.
#		@users = User.search(params)
#	Nevertheless a Rails 3 version
#User.joins(:roles).where("roles.name = 'reader'")
#		@users = if params[:role_name] && !params[:role_name].blank?
##			User.joins(:roles).where("roles.name = ?",params[:role_name])
#			User.joins(:roles).where("roles.name".to_sym => params[:role_name])
#		else
#			User.all
#		end

		#	Doing it this way seems cleaner, but a bit honky?
		#	be nice if there were ! versions of these methods.
		users = ActiveRecord::Relation.new(User,User.arel_table)
		if params[:role_name] && !params[:role_name].blank?
#			users = users.joins(:roles).where("roles.name".to_sym => params[:role_name])
			users = users.with_role_name(params[:role_name])
		end
		@users = users
	end

	def destroy
		@user.destroy
		redirect_to users_path
	end

protected

	def id_required
		if !params[:id].blank? and User.exists?(params[:id])
			@user = User.find(params[:id])
		else
			access_denied("user id required!", users_path)
		end
	end

end
__END__

Build a query ...


x=ActiveRecord::Relation.new(User,User.arel_table)
x.class
=> ActiveRecord::Relation
>> x = x.joins(:roles)
x.where('roles.name'.to_sym => 'administrator')

