require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

	test "odms_main_menu should return main menu without login" do
		response = HTML::Document.new(odms_main_menu).root
		assert_select response, 'div#mainmenu', 1 do
			#	Home, Subjects, Interviews, Samples
			assert_select 'div.menu_item', 4
		end
	end

	test "odms_main_menu should return main menu with reader login" do
		login_as send(:reader)
		response = HTML::Document.new(odms_main_menu).root
		assert_select response, 'div#mainmenu', 1 do
			#	Home, Subjects, Interviews, Samples
			assert_select 'div.menu_item', 4
		end
	end

	test "odms_main_menu should return main menu with editor login" do
		login_as send(:editor)
		response = HTML::Document.new(odms_main_menu).root
		assert_select response, 'div#mainmenu', 1 do
			#	Home, Subjects, Interviews, Samples
			assert_select 'div.menu_item', 4
		end
	end

	test "odms_main_menu should return main menu with administrator login" do
		login_as send(:administrator)
		response = HTML::Document.new(odms_main_menu).root
		assert_select response, 'div#mainmenu', 1 do
			#	Home, Subjects, Interviews, Samples, Admin
			assert_select 'div.menu_item', 5
		end
	end

#	test "administrator_menu should return admin link" do
#		response = HTML::Document.new(administrator_menu).root
#		assert_select response, 'div.menu_item', 1 do
#			assert_select "a[href=?]", "/admin"
#		end
#	end

#	test "id_bar_for subject should return subject_id_bar" do
#		subject = create_subject
#		assert subject.is_a?(Subject)
#		#	subject_id_bar(subject,&block) is in subjects_helper.rb
#		assert_nil id_bar_for(subject)	#	sets content_for :main
#		response = HTML::Document.new(@content_for_main).root
#		assert_select response, 'div#id_bar' do
#			assert_select 'div.childid'
#			assert_select 'div.studyid'
#			assert_select 'div.full_name'
#			assert_select 'div.controls'
#		end
#	end

	test "id_bar_for other object should return nil" do
		response = id_bar_for(Object)
		assert response.blank?
		assert response.nil?
	end

	test "sub_menu_for Subject should return subject_sub_menu" do
pending
	end

	test "sub_menu_for nil should return nil" do
		response = sub_menu_for(nil)
		assert_nil response
	end

	test "birth_certificates_sub_menu for bc_requests#new should" do
		self.params = { :controller => 'bc_requests', :action => 'new' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current', 1 do
				assert_select "[href=?]", new_bc_request_path
			end
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index should" do
		self.params = { :controller => 'bc_requests', :action => 'index' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current', 1 do
				assert_select "[href=?]", bc_requests_path
			end
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=active should" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'active' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current', 1 do
				assert_select "[href=?]", bc_requests_path(:status => 'active')
			end
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=complete should" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'complete' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current', 1 do
				assert_select "[href=?]", bc_requests_path(:status => 'complete')
			end
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=waitlist should" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'waitlist' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current', 1 do
				assert_select "[href=?]", bc_requests_path(:status => 'waitlist')
			end
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=pending should" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'pending' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current', 1 do
				assert_select "[href=?]", bc_requests_path(:status => 'pending')
			end
		end
	end

	test "birth_certificates_sub_menu for bc_validations should" do
		self.params = { :controller => 'bc_validations' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
#	Since removed, this link will no longer show.
#			assert_select 'a.current', 1 do
#				assert_select "[href=?]", bc_validations_path
#			end
		end
	end

	test "subject_sub_menu(subject) should" do
pending
	end

private 

#	"fake" controller methods

	def params
		@params || {}
	end
	def params=(new_params)
		@params = new_params
	end
	def stylesheets(*args)
		#	placeholder so can call subject_id_bar and avoid
		#		NoMethodError: undefined method `stylesheets' for #<ApplicationHelperTest:0x106049140>
	end
	def login_as(user)
		@current_user = user
	end
	def current_user	
		@current_user
	end
	def logged_in?
		!current_user.nil?
	end

end

__END__

		assert_select response, "input.race_selector", 6 do
			assert_select "#?", /race_\d/
			assert_select "[type=checkbox]"
			assert_select "[value=1]"
			assert_select "[name=?]", /subject\[subject_races_attributes\[\d\]\]\[race_id\]/
		end

