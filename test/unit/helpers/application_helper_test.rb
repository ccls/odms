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

	test "sub_menu_for(subject) for related_subjects with admin login" do
		login_as send(:administrator)
		self.params = { :controller => 'related_subjects' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 12
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

		test "sub_menu_for(subject) for related_subjects with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'related_subjects' }
			study_subject = Factory(:study_subject)
			assert_nil sub_menu_for(study_subject)
			response = HTML::Document.new(@content_for_side_menu).root
			assert_select response, 'div#sidemenu' do
				assert_select 'a', 8
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

	test "sub_menu_for(subject) for related_subjects without login" do
		self.params = { :controller => 'related_subjects' }
		study_subject = Factory(:study_subject)
		assert_nil sub_menu_for(study_subject)
		response = HTML::Document.new(@content_for_side_menu).root
		assert_select response, 'div#sidemenu' do
			assert_select 'a', 8
			assert_select 'a.current[href=?]', related_subject_path(study_subject)
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
		#	I don't like using super precise matching like this, however,
		expected = %{<ul><li><a href="/users/#{@user.id}/roles/superuser" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;">Remove user role of 'superuser'</a></li>
<li><a href="/users/#{@user.id}/roles/administrator" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'administrator'</a></li>
<li><a href="/users/#{@user.id}/roles/editor" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'editor'</a></li>
<li><a href="/users/#{@user.id}/roles/reader" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'reader'</a></li>
</ul>
}
		assert_equal expected, response.to_s
	end
#<li><a href="/users/#{@user.id}/roles/interviewer" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'interviewer'</a></li>

	test "should get user_roles with administrator login" do
		@user = send(:administrator)
		login_as @user
		@roles = Role.all
		response = HTML::Document.new(user_roles).root
		#	I don't like using super precise matching like this, however,
		expected = %{<ul><li><a href="/users/#{@user.id}/roles/superuser" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'superuser'</a></li>
<li><a href="/users/#{@user.id}/roles/administrator" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;">Remove user role of 'administrator'</a></li>
<li><a href="/users/#{@user.id}/roles/editor" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'editor'</a></li>
<li><a href="/users/#{@user.id}/roles/reader" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;">Assign user role of 'reader'</a></li>
</ul>
}
		assert_equal expected, response.to_s
	end
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

	test "should respond to study_subject_id_bar" do
		assert respond_to?(:study_subject_id_bar)
	end

	test "subject_id_bar should return subject_id_bar" do
		subject = create_study_subject
		assert subject.is_a?(StudySubject)
		assert !subject.do_not_contact?
		assert_nil subject_id_bar(subject)	#	sets content_for :main
		response = HTML::Document.new(@content_for_main).root
		assert_select response, 'div#id_bar' do
			assert_select 'div.icf_master_id'
			assert_select 'div.studyid'
			assert_select 'div.full_name'
		end
		assert_select response, 'div#do_not_contact', 0
	end

	test "subject_id_bar should return subject_id_bar with do not contact" do
		subject = create_study_subject(:do_not_contact => true)
		assert subject.is_a?(StudySubject)
		assert subject.do_not_contact?
		assert_nil subject_id_bar(subject)	#	sets content_for :main
		response = HTML::Document.new(@content_for_main).root
		assert_select response, 'div#id_bar' do
			assert_select 'div.icf_master_id'
			assert_select 'div.studyid'
			assert_select 'div.full_name'
		end
		assert_select response, 'div#do_not_contact'
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

private 
	def params
		@params || {}
	end
	def params=(new_params)
		@params = new_params
	end
	def stylesheets(*args)
		#	placeholder so can call subject_id_bar and avoid
		#		NoMethodError: undefined method `stylesheets' for #<Ccls::HelperTest:0x109e8ef90>
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
