require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

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

#	test "sub_menu_for Subject should return subject_sub_menu" do
#pending
#	end

	test "sub_menu_for nil should return nil" do
		response = sub_menu_for(nil)
		assert_nil response
	end

	test "birth_certificates_sub_menu for bc_requests#new" do
		self.params = { :controller => 'bc_requests', :action => 'new' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new(@content_for_side_menu).root
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
		response = HTML::Document.new(@content_for_side_menu).root
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
		response = HTML::Document.new(@content_for_side_menu).root
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
		response = HTML::Document.new(@content_for_side_menu).root
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
		response = HTML::Document.new(@content_for_side_menu).root
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
		response = HTML::Document.new(@content_for_side_menu).root
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
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', 6
#	Since removed, this link will no longer show.
#			assert_select 'a.current[href=?]', bc_validations_path
		end
	end

	test "sub_menu_for(subject) for study_subjects with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'study_subjects' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for patient with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'patients' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_patient_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for addresses with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'addresses' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for addressings with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'addressings' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for contacts with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'contacts' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for phone_numbers with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'phone_numbers' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for consents with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'consents' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_consent_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for enrollments with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'enrollments' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_enrollments_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for samples with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'samples' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_samples_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for interviews with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'interviews' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_interviews_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for events with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'events' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_events_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for documents with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'documents' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_documents_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for notes with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'notes' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
			assert_select 'a.current[href=?]', study_subject_notes_path(study_subject)
		end
	end

#	test "sub_menu_for(subject) for cases with admin login" do
	test "sub_menu_for(subject) for related_subjects with admin login" do
		login_as send(:administrator)
#		self.params = { :controller => 'cases' }
		self.params = { :controller => 'related_subjects' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
#			assert_select 'a.current[href=?]', case_path(study_subject)
			assert_select 'a.current[href=?]', related_subject_path(study_subject)
		end
	end

	%w( editor reader ).each do |cu|

		test "sub_menu_for(subject) for study_subjects with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'study_subjects' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for patient with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'patients' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_patient_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for addresses with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'addresses' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for addressings with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'addressings' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for contacts with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'contacts' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for phone_numbers with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'phone_numbers' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for consents with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'consents' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_consent_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for enrollments with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'enrollments' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_enrollments_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for samples with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'samples' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_samples_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for interviews with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'interviews' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_interviews_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for events with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'events' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current[href=?]', study_subject_events_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for documents with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'documents' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_documents_path(study_subject)
			end
		end

		test "sub_menu_for(subject) for notes with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'notes' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
				assert_select 'a.current', 0
#				assert_select 'a.current[href=?]', study_subject_notes_path(study_subject)
			end
		end

#		test "sub_menu_for(subject) for cases with #{cu} login" do
		test "sub_menu_for(subject) for related_subjects with #{cu} login" do
			login_as send(cu)
#			self.params = { :controller => 'cases' }
			self.params = { :controller => 'related_subjects' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
#				assert_select 'a.current[href=?]', case_path(study_subject)
				assert_select 'a.current[href=?]', related_subject_path(study_subject)
			end
		end

	end	#	reader and editor

	test "sub_menu_for(subject) for study_subjects without login" do
		self.params = { :controller => 'study_subjects' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for patient without login" do
		self.params = { :controller => 'patients' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_patient_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for addresses without login" do
		self.params = { :controller => 'addresses' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for addressings without login" do
		self.params = { :controller => 'addressings' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for contacts without login" do
		self.params = { :controller => 'contacts' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for phone_numbers without login" do
		self.params = { :controller => 'phone_numbers' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_contacts_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for consents without login" do
		self.params = { :controller => 'consents' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_consent_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for enrollments without login" do
		self.params = { :controller => 'enrollments' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_enrollments_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for samples without login" do
		self.params = { :controller => 'samples' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_samples_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for interviews without login" do
		self.params = { :controller => 'interviews' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_interviews_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for events without login" do
		self.params = { :controller => 'events' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', study_subject_events_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for documents without login" do
		self.params = { :controller => 'documents' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_documents_path(study_subject)
		end
	end

	test "sub_menu_for(subject) for notes without login" do
		self.params = { :controller => 'notes' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current', 0
#			assert_select 'a.current[href=?]', study_subject_notes_path(study_subject)
		end
	end

#	test "sub_menu_for(subject) for cases without login" do
	test "sub_menu_for(subject) for related_subjects without login" do
#		self.params = { :controller => 'cases' }
		self.params = { :controller => 'related_subjects' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
#			assert_select 'a.current[href=?]', case_path(study_subject)
			assert_select 'a.current[href=?]', related_subject_path(study_subject)
		end
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

