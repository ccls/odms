require 'test_helper'

class UsersControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'User',
		:actions => [:destroy,:index,:show],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :factory_create
	}

	def factory_attributes
		Factory.attributes_for(:user)
	end
	def factory_create
		Factory(:user)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	#	use full role names as used in one test method
	site_administrators.each do |cu|
	
		test "should filter users index by role with #{cu} login" do
			some_other_user = send(cu)
			login_as send(cu)
			get :index, :role_name => cu
			assert assigns(:users).length >= 2
			assigns(:users).each do |u|
				assert u.role_names.include?(cu)
			end
			assert_nil flash[:error]
			assert_response :success
		end
	
		test "should ignore empty role_name with #{cu} login" do
			some_other_user = admin
			login_as send(cu)
			get :index, :role_name => ''
			assert assigns(:users).length >= 2
			assert_nil flash[:error]
			assert_response :success
		end
	
		test "should ignore invalid role with #{cu} login" do
			login_as send(cu)
			get :index, :role_name => 'suffocator'
	#		assert_not_nil flash[:error]
			assert_response :success
		end
	
	end
	
	all_test_roles.each do |cu|
	
		test "should NOT get user info with invalid id with #{cu} login" do
			login_as send(cu)
			get :show, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to users_path
		end
	
		test "should get #{cu} info with self login" do
			u = send(cu)
			login_as u
			get :show, :id => u.id
			assert_response :success
			assert_not_nil assigns(:user)
			assert_equal u, assigns(:user)
		end
	
	end

end


__END__


implement user_roles helper tests here




#	test "should get user_roles with superuser login" do
#pending
#		@user = send(:superuser)
#		login_as @user
#		@roles = Role.all
#		response = HTML::Document.new(user_roles).root
#		#	I don't like using super precise matching like this, however,
##		expected = %{<ul><li><a href="/users/#{@user.id}/roles/superuser" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;">Remove user role of 'superuser'</a></li>
##<li><a href="/users/#{@user.id}/roles/administrator" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'administrator'</a></li>
##<li><a href="/users/#{@user.id}/roles/editor" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'editor'</a></li>
##<li><a href="/users/#{@user.id}/roles/reader" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'reader'</a></li>
##</ul>
##}
#		expected = %{<ul><li><form class="button_to" method="post" action="/users/#{@user.id}/roles/superuser"><div><input name="_method" value="delete" type="hidden" /><input value="Remove user role of 'superuser'" type="submit" /></div></form></li>
#<li><form class="button_to" method="post" action="/users/#{@user.id}/roles/administrator"><div><input name="_method" value="put" type="hidden" /><input value="Assign user role of 'administrator'" type="submit" /></div></form></li>
#<li><form class="button_to" method="post" action="/users/#{@user.id}/roles/editor"><div><input name="_method" value="put" type="hidden" /><input value="Assign user role of 'editor'" type="submit" /></div></form></li>
#<li><form class="button_to" method="post" action="/users/#{@user.id}/roles/reader"><div><input name="_method" value="put" type="hidden" /><input value="Assign user role of 'reader'" type="submit" /></div></form></li>
#</ul>
#}
#		assert_equal expected, response.to_s
#	end
##<li><a href="/users/#{@user.id}/roles/interviewer" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'interviewer'</a></li>
#
#	test "should get user_roles with administrator login" do
#pending
#		@user = send(:administrator)
#		login_as @user
#		@roles = Role.all
#		response = HTML::Document.new(user_roles).root
#		#	I don't like using super precise matching like this, however,
##		expected = %{<ul><li><a href="/users/#{@user.id}/roles/superuser" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'superuser'</a></li>
##<li><a href="/users/#{@user.id}/roles/administrator" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;">Remove user role of 'administrator'</a></li>
##<li><a href="/users/#{@user.id}/roles/editor" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'editor'</a></li>
##<li><a href="/users/#{@user.id}/roles/reader" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'reader'</a></li>
##</ul>
##}
#			expected = %{<ul><li><form class="button_to" method="post" action="/users/#{@user.id}/roles/superuser"><div><input name="_method" value="put" type="hidden" />
#<input value="Assign user role of 'superuser'" type="submit" /></div></form></li>
#<li><form class=\"button_to\" method=\"post\" action=\"/users/#{@user.id}/roles/administrator"><div><input name="_method" value="delete" type="hidden" /><input value="Remove user role of 'administrator'" type="submit" /></div></form></li>
#<li><form class="button_to" method="post" action="/users/#{@user.id}/roles/editor"><div><input name="_method" value="put" type="hidden" /><input value="Assign user role of 'editor'" type="submit" /></div></form></li>
#<li><form class="button_to" method="post" action="/users/#{@user.id}/roles/reader"><div><input name="_method" value="put" type="hidden" /><input value="Assign user role of 'reader'" type="submit" /></div></form></li>
#</ul>
#}
#		assert_equal expected, response.to_s
#	end
#<li><a href="/users/#{@user.id}/roles/interviewer" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'interviewer'</a></li>

#	test "should not get user_roles with interviewer login" do
#		@user = send(:interviewer)
#		login_as @user
#		@roles = Role.all
#		response = HTML::Document.new(user_roles).root
#		assert response.to_s.blank?
#	end

	test "should not get user_roles with editor login" do
		@user = send(:editor)
		login_as @user
		@roles = Role.all
		response = HTML::Document.new(user_roles).root
		assert response.to_s.blank?
	end

	test "should not get user_roles with reader login" do
		@user = send(:reader)
		login_as @user
		@roles = Role.all
		response = HTML::Document.new(user_roles).root
		assert response.to_s.blank?
	end


