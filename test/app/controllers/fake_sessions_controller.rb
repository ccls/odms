class FakeSessionsController < ApplicationController

	skip_before_filter :login_required	#, :only => :create

	#	Solely for integration testing.
	def create
		user = User.find(params[:id])
		session[:calnetuid] = user.uid
		redirect_to user_path(user)
	end

end
