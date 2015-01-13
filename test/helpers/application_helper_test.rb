require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

	# needed to include field_wrapper and _wrapped_spans
	include CommonLib::ActionViewExtension::Base

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

	test "medical_records_sub_menu for medical_record_requests#new" do
		self.params = { :controller => 'medical_record_requests', :action => 'new' }
		assert medical_records_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, Abstracted, 
			#		All Incomplete, Completed, All Complete
			assert_select 'a', :count => 9
			assert_select 'a.current[href=?]', new_medical_record_request_path
		end
	end

	test "medical_records_sub_menu for medical_record_requests#index" do
		self.params = { :controller => 'medical_record_requests', :action => 'index' }
		assert medical_records_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, Abstracted, 
			#		All Incomplete, Completed, All Complete
			assert_select 'a', :count => 9
			assert_select 'a.current[href=?]', medical_record_requests_path
		end
	end

	%w( active completed waitlist pending abstracted complete incomplete ).each do |status|

		test "medical_records_sub_menu for medical_record_requests#index?status=#{status}" do
			self.params = { :controller => 'medical_record_requests', 
				:action => 'index', :status => status }
			assert medical_records_sub_menu.nil?
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				#	New, Pending, All, Active, Waitlist, Abstracted, 
				#		All Incomplete, Completed, All Complete
				assert_select 'a', :count => 9
				assert_select 'a.current[href=?]', medical_record_requests_path(:status => status)
			end
		end

	end

	test "medical_records_sub_menu for bogus controller" do
		self.params = { :controller => 'bogus' }
		assert medical_records_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, Abstracted, 
			#		All Incomplete, Completed, All Complete
			assert_select 'a', :count => 9
			assert_select 'a.current', :count => 0
		end
	end


	test "blood_spots_sub_menu for blood_spot_requests#new" do
		self.params = { :controller => 'blood_spot_requests', :action => 'new' }
		assert blood_spots_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, All Incomplete, 
			#		Completed, Unavailable, All Complete
			assert_select 'a', :count => 9
			assert_select 'a.current[href=?]', new_blood_spot_request_path
		end
	end

	test "blood_spots_sub_menu for blood_spot_requests#index" do
		self.params = { :controller => 'blood_spot_requests', :action => 'index' }
		assert blood_spots_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, All Incomplete, 
			#		Completed, Unavailable, All Complete
			assert_select 'a', :count => 9
			assert_select 'a.current[href=?]', blood_spot_requests_path
		end
	end

	%w( active completed waitlist pending unavailable incomplete complete ).each do |status|

		test "blood_spots_sub_menu for blood_spot_requests#index?status=#{status}" do
			self.params = { :controller => 'blood_spot_requests', 
				:action => 'index', :status => status }
			assert blood_spots_sub_menu.nil?
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				#	New, Pending, All, Active, Waitlist, All Incomplete, 
				#		Completed, Unavailable, All Complete
				assert_select 'a', :count => 9
				assert_select 'a.current[href=?]', blood_spot_requests_path(:status => status )
			end
		end

	end

	test "blood_spots_sub_menu for bogus controller" do
		self.params = { :controller => 'bogus' }
		assert blood_spots_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, All Incomplete, 
			#		Completed, Unavailable, All Complete
			assert_select 'a', :count => 9
			assert_select 'a.current', :count => 0
		end
	end




	test "birth_certificates_sub_menu for bc_requests#new" do
		self.params = { :controller => 'bc_requests', :action => 'new' }
		assert birth_certificates_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, All Incomplete, Completed, All Complete
			assert_select 'a', :count => 8
			assert_select 'a.current[href=?]', new_bc_request_path
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index" do
		self.params = { :controller => 'bc_requests', :action => 'index' }
		assert birth_certificates_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, All Incomplete, Completed, All Complete
			assert_select 'a', :count => 8
			assert_select 'a.current[href=?]', bc_requests_path
		end
	end

	%w( active completed waitlist pending complete incomplete ).each do |status|

		test "birth_certificates_sub_menu for bc_requests#index?status=#{status}" do
			self.params = { :controller => 'bc_requests', 
				:action => 'index', :status => status }
			assert birth_certificates_sub_menu.nil?
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				#	New, Pending, All, Active, Waitlist, All Incomplete, Completed, All Complete
				assert_select 'a', :count => 8
				assert_select 'a.current[href=?]', bc_requests_path(:status => status )
			end
		end

	end

	test "birth_certificates_sub_menu for bogus controller" do
		self.params = { :controller => 'bogus' }
		assert birth_certificates_sub_menu.nil?
		response = content_for(:side_menu).to_html_document
		assert_select response, '#sidemenu' do
			#	New, Pending, All, Active, Waitlist, All Incomplete, Completed, All Complete
			assert_select 'a', :count => 8
			assert_select 'a.current', :count => 0
		end
	end


	#
	#	The subject_side_menu content is dependent on the user role.
	#	The odms_main_menu content is also dependent on the user role.
	#	user_roles too.
	#

	controllers_and_current_links = {
		'rafs'                    => 'raf_path',
		'patients'                => 'study_subject_patient_path',
		'birth_records'           => 'study_subject_birth_records_path',
		'addresses'               => 'study_subject_contacts_path',
		'contacts'                => 'study_subject_contacts_path',
		'phone_numbers'           => 'study_subject_contacts_path',
		'consents'                => 'study_subject_consent_path',
		'enrollments'             => 'study_subject_enrollments_path',
		'samples'                 => 'study_subject_samples_path',
		'interviews'              => 'study_subject_interviews_path',
		'events'                  => 'study_subject_events_path',
		'related_subjects'        => 'study_subject_related_subjects_path',
		'abstracts'               => 'study_subject_abstracts_path',
		'study_subject_abstracts' => 'study_subject_abstracts_path',
		'study_subjects'          => 'study_subject_path'
	}

	site_administrators.each do |cu|

		controllers_and_current_links.each do |k,v|

			test "subject_side_menu for #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:case_study_subject)
				assert_nil subject_side_menu(study_subject)
				response = content_for(:side_menu).to_html_document
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 16
					assert_select 'a.current', :count => 1
					assert_select 'a.current[href=?]', send(v,study_subject)
					assert_first_prev_next_last
				end
			end

		end
	
		test "odms_main_menu should return main menu with #{cu} login" do
			login_as send(cu)
			response = odms_main_menu.to_html_document
			assert_select response, 'div#mainmenu', :count => 1 do
				#	Home, Subjects, Interviews, Samples, Data Transfers, Admin
				assert_select 'div.menu_item', :count => 6
				assert_select( 'div.menu_item.home' ){
					assert_select( 'a', :text => 'Home' )
					assert_select( 'div.sub_menu a', :count => 0 ) }
				assert_select( 'div.menu_item.study_subjects' ){
					assert_select( 'a', :text => 'Subjects' )
					assert_select( 'div.sub_menu a', :count => 6 ) }
				assert_select( 'div.menu_item.interviews' ){
					assert_select( 'a', :text => 'Interviews' )
					assert_select( 'div.sub_menu a', :count => 0 ) }
				assert_select( 'div.menu_item.samples' ){
					assert_select( 'a', :text => 'Samples' )
					assert_select( 'div.sub_menu a', :count => 3 ) }
				assert_select( 'div.menu_item.data_transfers' ){
					assert_select( 'a', :text => 'Data Transfers' )
					assert_select( 'div.sub_menu a', :count => 4 ) }
				assert_select( 'div.menu_item.admin' ){
					assert_select( 'a', :text => 'Admin' )
					assert_select( 'div.sub_menu a', :count => 0 ) }
			end
			assert_select( response, "form#icf_master_id_form" ){
				assert_select( "label", :text => "ICF Master ID:" )
				assert_select( "input[type=text][name=icf_master_id]" )
				assert_select( "input[type=submit][value=go]" ) }
		end

		test "should get user_roles with #{cu} login" do
			@user = send(cu)
			login_as @user
			@roles = Role.all
			response = user_roles.to_html_document
			assert_select response, 'form.button_to', :count => 5
		end

	end



	test "odms_main_menu should return main menu with exporter login" do
		login_as send(:exporter)
		response = odms_main_menu.to_html_document
		assert_select response, 'div#mainmenu', :count => 1 do
			#	Home, Subjects, Interviews, Data Transfers NOT ( Samples, Admin)
			assert_select 'div.menu_item', :count => 4
		end
	end

	test "odms_main_menu should return main menu with editor login" do
		login_as send(:editor)
		response = odms_main_menu.to_html_document
		assert_select response, 'div#mainmenu', :count => 1 do
			#	Home, Subjects, Interviews, Data Transfers NOT ( Samples, Admin)
			assert_select 'div.menu_item', :count => 4
		end
	end

	test "odms_main_menu should return main menu with reader login" do
		login_as send(:reader)
		response = odms_main_menu.to_html_document
		assert_select response, 'div#mainmenu', :count => 1 do
			#	Home, Subjects, Interviews, NOT ( Samples, Data Transfers, Admin)
			assert_select 'div.menu_item', :count => 3
		end
	end

	non_site_administrators.each do |cu|
		#
		#	The same, except less links in the menu and therefore possibly no 'current'
		#
		controllers_and_current_links.each do |k,v|

			test "subject_side_menu for case subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:case_study_subject)
				assert_nil subject_side_menu(study_subject)
				response = content_for(:side_menu).to_html_document
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 14
					if %w( birth_records interviews ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
					assert_first_prev_next_last
				end
			end

			test "subject_side_menu for control subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:control_study_subject)
				assert_nil subject_side_menu(study_subject)
				response = content_for(:side_menu).to_html_document
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 11
					if %w( birth_records interviews rafs
						abstracts study_subject_abstracts patients ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
					assert_first_prev_next_last
				end
			end

			test "subject_side_menu for mother subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:mother_study_subject)
				assert_nil subject_side_menu(study_subject)
				response = content_for(:side_menu).to_html_document
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 11
					if %w( birth_records interviews rafs
						abstracts study_subject_abstracts patients ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
					assert_first_prev_next_last
				end
			end

			test "subject_side_menu for subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:study_subject)
				assert_nil subject_side_menu(study_subject)
				response = content_for(:side_menu).to_html_document
				assert_select response, 'ul#sidemenu' do |s|
					assert_select 'a', :count => 11
					if %w( birth_records interviews rafs
						abstracts study_subject_abstracts patients ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
					assert_first_prev_next_last
				end
			end

		end	#	controllers_and_current_links.each do |k,v|
	
		test "subject_side_menu for case subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:case_study_subject)
			assert_nil subject_side_menu(study_subject)
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 14
				assert_select 'a.current', :count => 0
				assert_first_prev_next_last
			end
		end

		test "subject_side_menu for control subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:control_study_subject)
			assert_nil subject_side_menu(study_subject)
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 11
				assert_select 'a.current', :count => 0
				assert_first_prev_next_last
			end
		end

		test "subject_side_menu for mother subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:mother_study_subject)
			assert_nil subject_side_menu(study_subject)
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 11
				assert_select 'a.current', :count => 0
				assert_first_prev_next_last
			end
		end

		test "subject_side_menu for subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:study_subject)
			assert_nil subject_side_menu(study_subject)
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 11
				assert_select 'a.current', :count => 0
				assert_first_prev_next_last
			end
		end

		test "should not get user_roles with #{cu} login" do
			@user = send(cu)
			login_as @user
			@roles = Role.all
			assert user_roles.to_s.blank?
		end

	end	#	non_site_administrators.each do |cu|

#	WITHOUT LOGIN (ONLY REAL IN TESTING AS CONTROLLERS STOP THIS)

	controllers_and_current_links.each do |k,v|

		test "subject_side_menu for case subject and #{k} without login" do
			self.params = { :controller => k }
			study_subject = FactoryGirl.create(:case_study_subject)
			assert_nil subject_side_menu(study_subject)
			response = content_for(:side_menu).to_html_document
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 14
				if %w( birth_records interviews ).include?(k)
					#	not shown to non-admins
					assert_select 'a.current', :count => 0
				else
					assert_select 'a.current[href=?]', send(v,study_subject)
				end
				assert_first_prev_next_last
			end
		end

	end	#	controllers_and_current_links.each do |k,v|

	test "odms_main_menu should return main menu without login" do
		response = odms_main_menu.to_html_document
		assert_select response, 'div#mainmenu', :count => 1 do
			#	Home, Subjects, Interviews, NOT ( Samples, Admin)
			assert_select 'div.menu_item', :count => 3
		end
	end

	
#	user_roles

	test "should respond to user_roles" do
		assert respond_to?(:user_roles)
	end

#	sort_link

	test "should respond to sort_link" do
		assert respond_to?(:sort_link)
	end

	test "should return div with link to sort column name" do
		#	NEED controller and action as method calls link_to which requires them
		self.params = { :controller => 'users', :action => 'index' }
		response = sort_link('name').to_html_document
		assert_select response, 'div', :count => 1 do
			assert_select 'a', :text => 'name', :count => 1
			assert_select 'span', :count => 0
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" with missing image" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name' }
		self.stubs(:sort_up_image).returns('somefilethatshouldnotexist')
		response = sort_link('name').to_html_document
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :text => 'name', :count => 1
			assert_select '.up.arrow', :count => 1
			assert_select 'span.up.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name' }
		response = sort_link('name').to_html_document
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :text => 'name', :count => 1
			assert_select '.up.arrow', :count => 1
			assert_select 'img.up.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'asc' with missing image" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'asc' }
		self.stubs(:sort_down_image).returns('somefilethatshouldnotexist')
		response = sort_link('name').to_html_document
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :text => 'name', :count => 1
			assert_select '.down.arrow', :count => 1
			assert_select 'span.down.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'asc'" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'asc' }
		response = sort_link('name').to_html_document
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :text => 'name', :count => 1
			assert_select '.down.arrow', :count => 1
			assert_select 'img.down.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'desc' with missing image" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'desc' }
		self.stubs(:sort_up_image).returns('somefilethatshouldnotexist')
		response = sort_link('name').to_html_document
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :text => 'name', :count => 1
			assert_select '.up.arrow', :count => 1
			assert_select 'span.up.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'desc'" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'desc' }
		response = sort_link('name').to_html_document
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :text => 'name', :count => 1
			assert_select '.up.arrow', :count => 1
			assert_select 'img.up.arrow', :count => 1
		end
	end

#	subject_id_bar

	test "should respond to subject_id_bar" do
		assert respond_to?(:subject_id_bar)
	end

	test "subject_id_bar should return subject_id_bar with study_subject" do
		subject = FactoryGirl.create(:study_subject)
		assert subject.is_a?(StudySubject)
		response = subject_id_bar(subject).to_html_document
		assert_select response, 'div#id_bar' do
			assert_select 'div.icf_master_id'
			assert_select 'div.studyid'
			assert_select 'div.full_name'
		end
	end

	test "subject_id_bar should NOT return subject_id_bar without study_subject" do
		assert subject_id_bar(nil).to_s.blank?
	end

#	do_not_contact

	test "should respond to do_not_contact" do
		assert respond_to?(:do_not_contact)
	end

	test "do_not_contact should return do_not_contact if do not contact" do
		subject = FactoryGirl.create(:study_subject,:do_not_contact => true)
		assert subject.is_a?(StudySubject)
		assert subject.do_not_contact?
		response = do_not_contact(subject).to_html_document
		assert_select response, 'div#do_not_contact', :count => 1,
			:text => "Study Subject requests no further contact with Study."
	end

	test "do_not_contact should NOT return do_not_contact if NOT do not contact" do
		subject = FactoryGirl.create(:study_subject,:do_not_contact => false)
		assert  subject.is_a?(StudySubject)
		assert !subject.do_not_contact?
		assert do_not_contact(subject).to_s.blank?
	end

	test "do_not_contact should NOT return do_not_contact if nil subject" do
		assert do_not_contact(nil).to_s.blank?
	end


#	ineligible

	test "should respond to ineligible" do
		assert respond_to?(:ineligible)
	end

	test "ineligible should return ineligible if subject is not eligible" do
		subject = create_study_subject(:enrollments_attributes => [
			{ :project_id => Project['ccls'].id, :is_eligible => YNDK[:no],
				:ineligible_reason => FactoryGirl.create(:ineligible_reason) }
		])
		assert subject.is_a?(StudySubject)
		assert subject.ineligible?
		response = ineligible(subject).to_html_document
		assert_select response, 'div#ineligible', :count => 1,
			:text => "Study Subject is not eligible."
	end

	test "ineligible should NOT return ineligible if subject is eligible" do
		subject = create_study_subject(:enrollments_attributes => [
			{ :project_id => Project['ccls'].id, :is_eligible => YNDK[:yes] }
		])
		assert  subject.is_a?(StudySubject)
		assert !subject.ineligible?
		assert ineligible(subject).to_s.blank?
	end

	test "ineligible should NOT return ineligible if nil subject" do
		assert ineligible(nil).to_s.blank?
	end


#	refused

	test "should respond to refused" do
		assert respond_to?(:refused)
	end

	test "refused should return refused if subject did not consent" do
		subject = create_study_subject(:enrollments_attributes => [
			{ :project_id => Project['ccls'].id, :consented => YNDK[:no],
				:refusal_reason => FactoryGirl.create(:refusal_reason),
				:consented_on => Date.current }
		])
		assert subject.is_a?(StudySubject)
		assert subject.refused?
		response = refused(subject).to_html_document
		assert_select response, 'div#refused', :count => 1,
			:text => "Study Subject refused consent."
	end

	test "refused should NOT return refused if subject did consent" do
		subject = create_study_subject(:enrollments_attributes => [
			{ :project_id => Project['ccls'].id, :consented => YNDK[:yes],
				:consented_on => Date.current }
		])
		assert  subject.is_a?(StudySubject)
		assert !subject.refused?
		assert refused(subject).to_s.blank?
	end

	test "refused should NOT return refused if nil subject" do
		assert refused(nil).to_s.blank?
	end


#	replicated

	test "should respond to replicated" do
		assert respond_to?(:replicated)
	end

	test "replicated should return Yes if replication_id present" do
		subject = FactoryGirl.create(:study_subject,:replication_id => 1)
		assert  subject.is_a?(StudySubject)
		assert !subject.replicates.empty?
		response = replicated(subject).to_html_document
		assert_select response, 'div#replicated', :count => 1,
			:text => "Study Subject has possible replicants."
	end

	test "replicated should return blank if replication_id not present" do
		subject = FactoryGirl.create(:study_subject)
		assert subject.is_a?(StudySubject)
		assert subject.replicates.empty?
		assert replicated(subject).to_s.blank?
	end

	test "replicated should return blank if nil subject" do
		assert refused(nil).to_s.blank?
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
	def request
		 ActionController::TestRequest.new
	end
	def assert_first_prev_next_last
		assert_select( 'li > div' ){
			assert_select 'a', :count => 1, :text => 'first'
			assert_select 'a', :count => 1, :text => 'prev'
			assert_select 'a', :count => 1, :text => 'next'
			assert_select 'a', :count => 1, :text => 'last'
		}
	end
end

__END__
