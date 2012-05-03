require 'test_helper'

class SomeModel
	attr_accessor :dob_before_type_cast	#	for date_text_field validation
	attr_accessor :yes_or_no, :yndk, :dob, :sex, :name
	attr_accessor :int_field
	def initialize(*args,&block)
		yield self if block_given?
	end
	def yes_or_no?
		!!yes_or_no
	end
end


#
#	Paths are no longer known in helper tests as of rails 3?
#	That makes most of these tests fail.
#	Actually, now for some reason they work??? (20120411)
#



class ApplicationHelperTest < ActionView::TestCase

	setup :enable_content_for_usage
	def enable_content_for_usage
#
# the following raises NoMethodError: undefined method `append' for nil:NilClass ????
# I really don't understand.  I use content_for in other places just like this?
# Actually, the other tests may be failing before the content_for call
#
# what is nil? This works in reality, but not in testing
# wouldn't be surprised if this is controller related.
#
#   in rails 3, there is something called "@view_flow"
# 
# adding '_prepare_context' before the call fixes the nil, but then there's another error
#
# NoMethodError: undefined method `encoding_aware?' for nil:NilClass
#    test/unit/helpers/action_view_base_helper_test.rb:340:in `new'
#
# don't use @content_for_head anymore.  Just use content_for(:head)
#

#	Is this the best way?  Doubt it, but it works.

		_prepare_context	#	need this to set @view_flow so content_for works
	end

	test "odms_main_menu should return main menu without login" do
		response = HTML::Document.new(odms_main_menu).root
		assert_select response, 'div#mainmenu', 1 do
			#	Home, Subjects, Samples
			assert_select 'div.menu_item', 3
		end
	end

	test "odms_main_menu should return main menu with reader login" do
		login_as send(:reader)
		response = HTML::Document.new(odms_main_menu).root
		assert_select response, 'div#mainmenu', 1 do
			#	Home, Subjects, Samples
			assert_select 'div.menu_item', 3
		end
	end

	test "odms_main_menu should return main menu with editor login" do
		login_as send(:editor)
		response = HTML::Document.new(odms_main_menu).root
		assert_select response, 'div#mainmenu', 1 do
			#	Home, Subjects, Samples
			assert_select 'div.menu_item', 3
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


	test "birth_certificates_sub_menu for bc_requests#new" do
		self.params = { :controller => 'bc_requests', :action => 'new' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current[href=?]', new_bc_request_path
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index" do
		self.params = { :controller => 'bc_requests', :action => 'index' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current[href=?]', bc_requests_path
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=active" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'active' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'active')
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=complete" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'complete' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'complete')
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=waitlist" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'waitlist' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'waitlist')
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=pending" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'pending' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'pending')
		end
	end



	test "birth_certificates_sub_menu for bc_validations" do
		self.params = { :controller => 'bc_validations' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
#	Since removed, this link will no longer show.
#			assert_select 'a.current[href=?]', bc_validations_path
		end
	end


#subject_side_menu

	test "subject_side_menu for study_subjects with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'study_subjects' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_path(study_subject)
		end
	end

	test "subject_side_menu for patient with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'patients' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_patient_path(study_subject)
		end
	end

	test "subject_side_menu for addresses with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'addresses' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for addressings with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'addressings' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for contacts with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'contacts' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for phone_numbers with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'phone_numbers' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for consents with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'consents' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_consent_path(study_subject)
		end
	end

	test "subject_side_menu for enrollments with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'enrollments' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_enrollments_path(study_subject)
		end
	end

	test "subject_side_menu for samples with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'samples' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_samples_path(study_subject)
		end
	end

	test "subject_side_menu for interviews with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'interviews' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_interviews_path(study_subject)
		end
	end

	test "subject_side_menu for events with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'events' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_events_path(study_subject)
		end
	end

	test "subject_side_menu for documents with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'documents' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_documents_path(study_subject)
		end
	end

	test "subject_side_menu for notes with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'notes' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_notes_path(study_subject)
		end
	end

	test "subject_side_menu for related_subjects with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'related_subjects' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', related_subject_path(study_subject)
		end
	end

	test "subject_side_menu for abstracts with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'abstracts' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_abstracts_path(study_subject)
		end
	end

	test "subject_side_menu for study_subject_abstracts with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'study_subject_abstracts' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_abstracts_path(study_subject)
		end
	end

	test "subject_side_menu for abstract/diagnoses with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'abstract/diagnoses' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_abstracts_path(study_subject)
		end
	end

	%w( editor reader ).each do |cu|

		test "subject_side_menu for study_subjects with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'study_subjects' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_path(study_subject)
			end
		end

		test "subject_side_menu for patient with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'patients' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_patient_path(study_subject)
			end
		end

		test "subject_side_menu for addresses with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'addresses' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "subject_side_menu for addressings with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'addressings' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "subject_side_menu for contacts with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'contacts' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "subject_side_menu for phone_numbers with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'phone_numbers' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "subject_side_menu for consents with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'consents' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_consent_path(study_subject)
			end
		end

		test "subject_side_menu for enrollments with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'enrollments' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_enrollments_path(study_subject)
			end
		end

		test "subject_side_menu for samples with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'samples' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_samples_path(study_subject)
			end
		end

		test "subject_side_menu for interviews with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'interviews' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_interviews_path(study_subject)
			end
		end

		test "subject_side_menu for events with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'events' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_events_path(study_subject)
			end
		end

		test "subject_side_menu for documents with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'documents' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_documents_path(study_subject)
			end
		end

		test "subject_side_menu for notes with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'notes' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_notes_path(study_subject)
			end
		end

		test "subject_side_menu for related_subjects with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'related_subjects' }
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', related_subject_path(study_subject)
			end
		end

		test "subject_side_menu for abstracts with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'abstracts' }
			controller = AbstractsController.new
			study_subject = Factory(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_abstracts_path(study_subject)
			end
		end

	end	#	reader and editor

	test "subject_side_menu for study_subjects without login" do
		self.params = { :controller => 'study_subjects' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_path(study_subject)
		end
	end

	test "subject_side_menu for patient without login" do
		self.params = { :controller => 'patients' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_patient_path(study_subject)
		end
	end

	test "subject_side_menu for addresses without login" do
		self.params = { :controller => 'addresses' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for addressings without login" do
		self.params = { :controller => 'addressings' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for contacts without login" do
		self.params = { :controller => 'contacts' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for phone_numbers without login" do
		self.params = { :controller => 'phone_numbers' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "subject_side_menu for consents without login" do
		self.params = { :controller => 'consents' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_consent_path(study_subject)
		end
	end

	test "subject_side_menu for enrollments without login" do
		self.params = { :controller => 'enrollments' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_enrollments_path(study_subject)
		end
	end

	test "subject_side_menu for samples without login" do
		self.params = { :controller => 'samples' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_samples_path(study_subject)
		end
	end

	test "subject_side_menu for interviews without login" do
		self.params = { :controller => 'interviews' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_interviews_path(study_subject)
		end
	end

	test "subject_side_menu for events without login" do
		self.params = { :controller => 'events' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_events_path(study_subject)
		end
	end

	test "subject_side_menu for documents without login" do
		self.params = { :controller => 'documents' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_documents_path(study_subject)
		end
	end

	test "subject_side_menu for notes without login" do
		self.params = { :controller => 'notes' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_notes_path(study_subject)
		end
	end

	test "subject_side_menu for related_subjects without login" do
		self.params = { :controller => 'related_subjects' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', related_subject_path(study_subject)
		end
	end

	test "subject_side_menu for abstracts without login" do
		self.params = { :controller => 'abstracts' }
		study_subject = Factory(:study_subject)
		response = HTML::Document.new( subject_side_menu(study_subject) ).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_abstracts_path(study_subject)
		end
	end



#	user_roles

	test "should respond to user_roles" do
		assert respond_to?(:user_roles)
	end

	test "should get user_roles with superuser login" do
		@user = send(:superuser)
		login_as @user
		@roles = Role.all
		response = HTML::Document.new(user_roles).root
		assert_select response, 'form.button_to', 4
	end

	test "should get user_roles with administrator login" do
		@user = send(:administrator)
		login_as @user
		@roles = Role.all
		response = HTML::Document.new(user_roles).root
		assert_select response, 'form.button_to', 4
	end

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

#	sort_link

	test "should respond to sort_link" do
		assert respond_to?(:sort_link)
	end

	test "should return div with link to sort column name" do
		#	NEED controller and action as method calls link_to which requires them
		self.params = { :controller => 'users', :action => 'index' }
		response = HTML::Document.new(sort_link('name')).root
		#	<div class=""><a href="/users?dir=asc&amp;order=name">name</a></div>
		assert_select response, 'div', 1 do
			assert_select 'a', 1
			assert_select 'span', 0
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" with missing image" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name' }
		self.stubs(:sort_up_image).returns('somefilethatshouldnotexist')
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#		<span class="up arrow">&uarr;</span></div>
		assert_select response, 'div.sorted', 1 do
			assert_select 'a', 1
			assert_select '.up.arrow', 1
			assert_select 'span.up.arrow', 1
		end
	end

	test "should return div with link to sort column name with order set to name" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name' }
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sortable name sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#	<img class="up arrow" src="/images/sort_up.png?1320424344" alt="Sort_up" /></div>
		assert_select response, 'div.sorted', 1 do
			assert_select 'a', 1
			assert_select '.up.arrow', 1
			assert_select 'img.up.arrow', 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'asc' with missing image" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'asc' }
		self.stubs(:sort_down_image).returns('somefilethatshouldnotexist')
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#		<span class="down arrow">&uarr;</span></div>
		assert_select response, 'div.sorted', 1 do
			assert_select 'a', 1
			assert_select '.down.arrow', 1
			assert_select 'span.down.arrow', 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'asc'" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'asc' }
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sortable name sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#	<img class="down arrow" src="/images/sort_down.png?1320424344" alt="Sort_up" /></div>
		assert_select response, 'div.sorted', 1 do
			assert_select 'a', 1
			assert_select '.down.arrow', 1
			assert_select 'img.down.arrow', 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'desc' with missing image" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'desc' }
		self.stubs(:sort_up_image).returns('somefilethatshouldnotexist')
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#		<span class="up arrow">&uarr;</span></div>
		assert_select response, 'div.sorted', 1 do
			assert_select 'a', 1
			assert_select '.up.arrow', 1
			assert_select 'span.up.arrow', 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'desc'" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'desc' }
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sortable name sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#	<img class="up arrow" src="/images/sort_up.png?1320424344" alt="Sort_up" /></div>
		assert_select response, 'div.sorted', 1 do
			assert_select 'a', 1
			assert_select '.up.arrow', 1
			assert_select 'img.up.arrow', 1
		end
	end

#	subject_id_bar

	test "should respond to subject_id_bar" do
		assert respond_to?(:subject_id_bar)
	end

	test "subject_id_bar should return subject_id_bar with study_subject" do
		subject = Factory(:study_subject)
		assert subject.is_a?(StudySubject)
		response = HTML::Document.new( subject_id_bar(subject)	).root
		assert_select response, 'div#id_bar' do
			assert_select 'div.icf_master_id'
			assert_select 'div.studyid'
			assert_select 'div.full_name'
		end
	end

	test "subject_id_bar should NOT return subject_id_bar without study_subject" do
		response = HTML::Document.new( subject_id_bar(nil)	).root
		#	#<HTML::Node:0x10539a778 @position=0, @line=0, @children=[], @parent=nil>
		assert response.to_s.blank?
		assert_select response, 'div#id_bar', 0
	end

#	do_not_contact

	test "should respond to do_not_contact" do
		assert respond_to?(:do_not_contact)
	end

	test "do_not_contact should return do_not_contact if do not contact" do
		subject = Factory(:study_subject,:do_not_contact => true)
		assert subject.is_a?(StudySubject)
		assert subject.do_not_contact?
		response = HTML::Document.new( do_not_contact(subject) ).root
		assert_select response, 'div#do_not_contact', 1
	end

	test "do_not_contact should NOT return do_not_contact if NOT do not contact" do
		subject = Factory(:study_subject,:do_not_contact => false)
		assert  subject.is_a?(StudySubject)
		assert !subject.do_not_contact?
		response = HTML::Document.new( do_not_contact(subject) ).root
		assert_select response, 'div#do_not_contact', 0
		assert response.to_s.blank?
	end

#	do_not_contact MUST be true or false (no nil)
#	test "do_not_contact should NOT return do_not_contact if nil do not contact" do
#		subject = Factory(:study_subject,:do_not_contact => nil)
#		assert  subject.is_a?(StudySubject)
#		assert_nil subject.do_not_contact
#		response = HTML::Document.new( do_not_contact(subject) ).root
#		assert_select response, 'div#do_not_contact', 0
#		assert response.blank?
#	end

	test "do_not_contact should NOT return do_not_contact if nil subject" do
		response = HTML::Document.new( do_not_contact(nil) ).root
		assert_select response, 'div#do_not_contact', 0
		assert response.to_s.blank?
	end

#	required

	test "required(text) should" do
		response = HTML::Document.new(required('something')).root
		#"<span class='required'>something</span>"
		assert_select response, 'span.required', 'something', 1
	end

#	req

	test "req(text) should" do
		response = HTML::Document.new(req('something')).root
		#"<span class='required'>something</span>"
		assert_select response, 'span.required', 'something', 1
	end


	test "adna(1) should return 'Agree'" do
		assert_equal 'Agree', adna(1)
	end

	test "adna(2) should return 'Do Not Agree'" do
		assert_equal 'Do Not Agree', adna(2)
	end

	test "adna(555) should return 'N/A'" do
		assert_equal "N/A", adna(555)
	end

	test "adna(999) should return 'Don't Know'" do
		assert_equal "Don't Know", adna(999)
	end

	test "adna(0) should return '&nbsp;'" do
		assert_equal "&nbsp;", adna(0)
	end

	test "adna() should return '&nbsp;'" do
		assert_equal "&nbsp;", adna()
	end

	test "yndk(1) should return 'Yes'" do
		assert_equal 'Yes', yndk(1)
	end

	test "yndk(2) should return 'No'" do
		assert_equal 'No', yndk(2)
	end

	test "yndk(3) should return '&nbsp;'" do
		assert_equal '&nbsp;', yndk(3)
	end

	test "yndk(888) should return '&nbsp;'" do
		assert_equal "&nbsp;", yndk(888)
	end

	test "yndk(999) should return 'Don't Know'" do
		assert_equal "Don't Know", yndk(999)
	end

	test "yndk() should return '&nbsp;'" do
		assert_equal "&nbsp;", yndk()
	end

	test "ynodk(1) should return 'Yes'" do
		assert_equal 'Yes', ynodk(1)
	end

	test "ynodk(2) should return 'No'" do
		assert_equal 'No', ynodk(2)
	end

	test "ynodk(3) should return 'Other'" do
		assert_equal 'Other', ynodk(3)
	end

	test "ynodk(888) should return '&nbsp;'" do
		assert_equal "&nbsp;", ynodk(888)
	end

	test "ynodk(999) should return 'Don't Know'" do
		assert_equal "Don't Know", ynodk(999)
	end

	test "ynodk() should return '&nbsp;'" do
		assert_equal "&nbsp;", ynodk()
	end

	test "ynrdk(1) should return 'Yes'" do
		assert_equal 'Yes', ynrdk(1)
	end

	test "ynrdk(2) should return 'No'" do
		assert_equal 'No', ynrdk(2)
	end

	test "ynrdk(3) should return '&nbsp;'" do
		assert_equal '&nbsp;', ynrdk(3)
	end

	test "ynrdk(888) should return 'Refused'" do
		assert_equal "Refused", ynrdk(888)
	end

	test "ynrdk(999) should return 'Don't Know'" do
		assert_equal "Don't Know", ynrdk(999)
	end

	test "ynrdk() should return '&nbsp;'" do
		assert_equal "&nbsp;", ynrdk()
	end

	test "posneg(1) should return 'Positive'" do
		assert_equal 'Positive', posneg(1)
	end

	test "posneg(2) should return 'Negative'" do
		assert_equal 'Negative', posneg(2)
	end

	test "posneg() should return '&nbsp;'" do
		assert_equal "&nbsp;", posneg()
	end

	test "unwrapped _wrapped_adna_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			_wrapped_adna_spans(:some_model, :int_field)).root
		assert_select response, 'span.label', 'int_field', 1
		assert_select response, 'span.value', '&nbsp;', 1
	end

	test "wrapped_adna_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			wrapped_adna_spans(:some_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', 1 do
			assert_select 'label', 0
			assert_select 'span.label', 'int_field', 1
			assert_select 'span.value', '&nbsp;', 1
		end
	end

	test "unwrapped _wrapped_yndk_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			_wrapped_yndk_spans(:some_model, :int_field)).root
		assert_select response, 'span.label', 'int_field', 1
		assert_select response, 'span.value', '&nbsp;', 1
	end

	test "wrapped_yndk_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			wrapped_yndk_spans(:some_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', 1 do
			assert_select 'label', 0
			assert_select 'span.label', 'int_field', 1
			assert_select 'span.value', '&nbsp;', 1
		end
	end

	test "unwrapped _wrapped_ynrdk_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			_wrapped_ynrdk_spans(:some_model, :int_field)).root
		assert_select response, 'span.label', 'int_field', 1
		assert_select response, 'span.value', '&nbsp;', 1
	end

	test "wrapped_ynrdk_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			wrapped_ynrdk_spans(:some_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', 1 do
			assert_select 'label', 0
			assert_select 'span.label', 'int_field', 1
			assert_select 'span.value', '&nbsp;', 1
		end
	end

	test "unwrapped _wrapped_ynodk_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			_wrapped_ynodk_spans(:some_model, :int_field)).root
		assert_select response, 'span.label', 'int_field', 1
		assert_select response, 'span.value', '&nbsp;', 1
	end

	test "wrapped_ynodk_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			wrapped_ynodk_spans(:some_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', 1 do
			assert_select 'label', 0
			assert_select 'span.label', 'int_field', 1
			assert_select 'span.value', '&nbsp;', 1
		end
	end

	test "unwrapped _wrapped_pos_neg_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			_wrapped_pos_neg_spans(:some_model, :int_field)).root
		assert_select response, 'span.label', 'int_field', 1
		assert_select response, 'span.value', '&nbsp;', 1
	end

	test "wrapped_pos_neg_spans" do
		@some_model = SomeModel.new
		response = HTML::Document.new(
			wrapped_pos_neg_spans(:some_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', 1 do
			assert_select 'label', 0
			assert_select 'span.label', 'int_field', 1
			assert_select 'span.value', '&nbsp;', 1
		end
	end

	test "flasher" do
		response = HTML::Document.new(
			flasher
		).root
#<p class="flash" id="notice">Hello There</p>
#<noscript>
#<p id="noscript" class="flash">Javascript is required for this site to be fully functional.</p>
#</noscript>
		assert_select response, 'p#notice.flash'
		assert_select response, 'noscript' do
			assert_select 'p#noscript.flash'
		end
	end

	test "javascripts" do
		assert_nil @javascripts
		javascripts('myjavascript')
		assert @javascripts.include?('myjavascript')
		assert_equal 1, @javascripts.length
		javascripts('myjavascript')
		assert_equal 1, @javascripts.length
		#<script src="/javascripts/myjavascript.js" type="text/javascript"></script>
		response = HTML::Document.new( content_for(:head) ).root
		assert_select response, 'script[src=/javascripts/myjavascript.js]'
	end

	test "stylesheets" do
		assert_nil @stylesheets
		stylesheets('mystylesheet')
		assert @stylesheets.include?('mystylesheet')
		assert_equal 1, @stylesheets.length
		stylesheets('mystylesheet')
		assert_equal 1, @stylesheets.length
		#<link href="/stylesheets/mystylesheet.css" media="screen" rel="stylesheet" type="text/css" />
		response = HTML::Document.new( content_for(:head) ).root
		assert_select response, 'link[href=/stylesheets/mystylesheet.css]'
	end

	test "field_wrapper" do
		response = HTML::Document.new(
			field_wrapper('mymethod') do
				'Yield'
			end).root
#<div class="mymethod field_wrapper">
#Yield
#</div><!-- class='mymethod' -->
		assert_select response, 'div.mymethod.field_wrapper'
	end

	test "wrapped_spans without options" do
		@user = SomeModel.new
		response = HTML::Document.new(
			wrapped_spans(:user, :name)).root
#<div class="name field_wrapper">
#<span class="label">name</span>
#<span class="value">&nbsp;</span>
#</div><!-- class='name' -->
		assert_select response, 'div.name.field_wrapper', 1 do
			assert_select 'label', 0
			assert_select 'span.label', 1
			assert_select 'span.value', 1
		end
	end

	test "wrapped_date_spans blank" do
		@user = SomeModel.new
		response = HTML::Document.new(
			wrapped_date_spans(:user, :dob)).root
#<div class="dob date_spans field_wrapper">
#<span class="label">dob</span>
#<span class="value">&nbsp;</span>
#</div><!-- class='dob date_spans' -->
		assert_select response, 'div.dob.date_spans.field_wrapper' do
			assert_select 'label', 0
			assert_select 'span.label','dob',1
			assert_select 'span.value','&nbsp;',1
		end
	end

	test "wrapped_date_spans Dec 5, 1971" do
		@user = SomeModel.new{|u| u.dob = Date.parse('Dec 5, 1971')}
		response = HTML::Document.new(
			wrapped_date_spans(:user, :dob)).root
#<div class="dob date_spans field_wrapper">
#<span class="label">dob</span>
#<span class="value">12/05/1971</span>
#</div><!-- class='dob date_spans' -->
		assert_select response, 'div.dob.date_spans.field_wrapper' do
			assert_select 'label', 0
			assert_select 'span.label','dob',1
			assert_select 'span.value','12/05/1971',1
		end
	end

	test "wrapped_yes_or_no_spans blank" do
		@user = SomeModel.new
		response = HTML::Document.new(
			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
#<div class="yes_or_no field_wrapper">
#<span class="label">yes_or_no</span>
#<span class="value">no</span>
#</div><!-- class='yes_or_no' -->
		assert_select response, 'div.yes_or_no.field_wrapper' do
			assert_select 'label', 0
			assert_select 'span.label','yes_or_no',1
			assert_select 'span.value','No',1
		end
	end

	test "wrapped_yes_or_no_spans true" do
		@user = SomeModel.new{|u| u.yes_or_no = true }
		response = HTML::Document.new(
			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
#<div class="yes_or_no field_wrapper">
#<span class="label">yes_or_no</span>
#<span class="value">yes</span>
#</div><!-- class='yes_or_no' -->
		assert_select response, 'div.yes_or_no.field_wrapper' do
			assert_select 'label', 0
			assert_select 'span.label','yes_or_no',1
			assert_select 'span.value','Yes',1
		end
	end

	test "wrapped_yes_or_no_spans false" do
		@user = SomeModel.new(:yes_or_no => false)
		response = HTML::Document.new(
			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
#<div class="yes_or_no field_wrapper">
#<span class="label">yes_or_no</span>
#<span class="value">no</span>
#</div><!-- class='yes_or_no' -->
		assert_select response, 'div.yes_or_no.field_wrapper' do
			assert_select 'label', 0
			assert_select 'span.label','yes_or_no',1
			assert_select 'span.value','No',1
		end
	end




#	abstract_pages

	test "should respond abstract_pages" do
		assert respond_to?(:abstract_pages)
pending	#	TODO add some real tests for this
	end

#	edit_link

	test "should respond edit_link" do
		assert respond_to?(:edit_link)
pending	#	TODO add some real tests for this
	end







private 
	def params
		@params || {}
	end
	def params=(new_params)
		@params = new_params
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
	def flash
		{:notice => "Hello There"}
	end
#	delegate :flash, :to => :controller
	def request
#	only needed for ... to avoid "no method env for nil" error
#141       if request.env["HTTP_REFERER"] =~ /study_subjects\/find\?/
		 ActionController::TestRequest.new
	end

#	#	fake the funk for controller as well. (for the subject_side_menu tests)
#	def controller
#		@controller
#	end
#	def controller=(new_controller)
#		@controller = new_controller
#	end
end

__END__
