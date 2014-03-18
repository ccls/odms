class UsersController < ApplicationController

	before_filter :id_required, :only => [:edit, :show, :update, :destroy]
	before_filter :may_view_user_required, :except => [:index,:menu]
	before_filter :may_view_users_required, :only => :index

	def show
		@roles = Role.all
	end

	def index
#
#	may want to add .order('position ASC') or something
#
		@users = User.with_role_name(params[:role_name])
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
