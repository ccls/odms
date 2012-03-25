class FakeSessionsController < ApplicationController

	skip_before_filter :login_required	#, :only => :create

#	ssl_allowed	:new, :create	#	in integration testing, just skip it

	def new
		form = '<form accept-charset="UTF-8" action="/fake_session" method="post">' <<
			'<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>' <<
			'<input id="id" name="id" type="text" /><input name="commit" type="submit" value="login" /></form>'
		render :layout => true, :text => form
	end

	#	Solely for integration testing.
	def create
		unless User.exists?(params[:id])
			puts "\n\nUH-OH.  User not found with id:#{params[:id]}:"
			puts "About to fail in weird ways."
			puts
		end
		user = User.find(params[:id])
		session[:calnetuid] = user.uid
		CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
		redirect_to user_path(user)
	end

end
