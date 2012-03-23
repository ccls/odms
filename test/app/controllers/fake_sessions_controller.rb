class FakeSessionsController < ApplicationController

	skip_before_filter :login_required	#, :only => :create

#	ssl_allowed	:new, :create	#	in integration testing, just skip it

	def new
		render :layout => true, :inline => <<EOF
<%= form_tag fake_session_path do %>
<%= text_field_tag :id %>
<%= text_field_tag :uid %>
<%= submit_tag 'login' %>
<% end %>
EOF
	end

	#	Solely for integration testing.
	def create
#	For some reason, if using capybara and selenium, the user is not found?
#	The user exists before the new_fake_session and after.
#	It even exists after the create?  But doesn't exist during the create?
#	Perhaps, I could directly pass the uid rather than the id and then
#		not even bother searching for it.
#	This would require modifications to both capybara and webrat tests.

#puts "in controller connection check:#{params[:id]}:"
#puts User.connection.inspect

		unless User.exists?(params[:id])
			puts "\n\nUH-OH.  User not found with id:#{params[:id]}:"
			puts "About to fail in weird ways."
			puts
		end
		user = User.find(params[:id])
#puts user.inspect

		session[:calnetuid] = user.uid
		CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)

#puts "Logged in"
		redirect_to user_path(user)


#	No user so redirect where? root?  Works here, but still can't find user later to determine if logged_in?
#		user = User.find(params[:id])
#		session[:calnetuid] = params[:uid]
#		redirect_to root_path
	end

end
