require 'test_helper'

#	Use a class that is unique to this test!
class AppModel
	attr_accessor :dob_before_type_cast	#	for date_text_field validation
	attr_accessor :yes_or_no, :yndk, :dob, :sex, :name
	attr_accessor :int_field
	def initialize(*args,&block)
		yield self if block_given?
	end
	def yes_or_no?
		!!yes_or_no
	end
	def self.human_attribute_name(attribute,options={})
		attribute	#	just return the attribute
	end
end

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

	test "birth_certificates_sub_menu for bc_requests#new" do
		self.params = { :controller => 'bc_requests', :action => 'new' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, '#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', :count => 6
			assert_select 'a.current[href=?]', new_bc_request_path
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index" do
		self.params = { :controller => 'bc_requests', :action => 'index' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, '#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', :count => 6
			assert_select 'a.current[href=?]', bc_requests_path
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=active" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'active' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, '#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', :count => 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'active')
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=complete" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'complete' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, '#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', :count => 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'complete')
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=waitlist" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'waitlist' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, '#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', :count => 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'waitlist')
		end
	end

	test "birth_certificates_sub_menu for bc_requests#index?status=pending" do
		self.params = { :controller => 'bc_requests', :action => 'index', :status => 'pending' }
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, '#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', :count => 6
			assert_select 'a.current[href=?]', bc_requests_path(:status => 'pending')
		end
	end

	test "birth_certificates_sub_menu for bogus controller" do
		self.params = { :controller => 'bogus' }
#
#	birth_certificates_sub_menu still uses content_for(:side_menu)
#	perhaps stop doing this?
#
		assert birth_certificates_sub_menu.nil?
		response = HTML::Document.new( content_for(:side_menu) ).root
		assert_select response, '#sidemenu' do
			#	New, Pending, Validation, All, Active, Waitlist, Complete
			#	assert_select 'a', 7
			#	New, Pending, All, Active, Waitlist, Complete
			assert_select 'a', :count => 6
#			assert_select 'a.current[href=?]', bc_requests_path(:status => 'pending')
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
		'addressings'             => 'study_subject_contacts_path',
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
#		# 1 of many abstract sub-pages
#		'abstract/diagnoses'      => 'study_subject_abstracts_path',
		'study_subjects'          => 'study_subject_path'
	}

	site_administrators.each do |cu|

		controllers_and_current_links.each do |k,v|

			test "subject_side_menu for #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:case_study_subject)
				response = HTML::Document.new( subject_side_menu(study_subject) ).root
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 16
					assert_select 'a.current', :count => 1
					assert_select 'a.current[href=?]', send(v,study_subject)
				end
			end

		end
	
		test "odms_main_menu should return main menu with #{cu} login" do
			login_as send(cu)
			response = HTML::Document.new(odms_main_menu).root
			assert_select response, 'div#mainmenu', :count => 1 do
				#	Home, Subjects, Interviews, Samples, Data Transfers, Admin
				assert_select 'div.menu_item', :count => 6
			end
		end

		test "should get user_roles with #{cu} login" do
			@user = send(cu)
			login_as @user
			@roles = Role.all
			response = HTML::Document.new(user_roles).root
			assert_select response, 'form.button_to', :count => 5
		end

	end



		test "odms_main_menu should return main menu with exporter login" do
			login_as send(:exporter)
			response = HTML::Document.new(odms_main_menu).root
			assert_select response, 'div#mainmenu', :count => 1 do
				#	Home, Subjects, Interviews, Data Transfers NOT ( Samples, Admin)
				assert_select 'div.menu_item', :count => 4
			end
		end

		test "odms_main_menu should return main menu with editor login" do
			login_as send(:editor)
			response = HTML::Document.new(odms_main_menu).root
			assert_select response, 'div#mainmenu', :count => 1 do
				#	Home, Subjects, Interviews, Data Transfers NOT ( Samples, Admin)
				assert_select 'div.menu_item', :count => 4
			end
		end

		test "odms_main_menu should return main menu with reader login" do
			login_as send(:reader)
			response = HTML::Document.new(odms_main_menu).root
			assert_select response, 'div#mainmenu', :count => 1 do
				#	Home, Subjects, Interviews, NOT ( Samples, Data Transfers, Admin)
				assert_select 'div.menu_item', :count => 3
			end
		end

#	20130510 - don't know why this didn't happen before, but
#		I removed the notes and documents links and changed #sidemenu
#		from a div to a ul.  Now rather than having 2 less a tags,
#		there are 2 more, because the first,prev,next,last a tags
#		are being counted? x-2+4=x+2



	non_site_administrators.each do |cu|
#
#	The same, except less links in the menu and therefore possibly no 'current'
#
		controllers_and_current_links.each do |k,v|

			test "subject_side_menu for case subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:case_study_subject)
				response = HTML::Document.new( subject_side_menu(study_subject) ).root
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 14
					if %w( birth_records interviews ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
				end
			end

			test "subject_side_menu for control subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:control_study_subject)
				response = HTML::Document.new( subject_side_menu(study_subject) ).root
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 11
					if %w( birth_records interviews rafs
						abstracts study_subject_abstracts patients ).include?(k)
#						abstracts study_subject_abstracts abstract/diagnoses patients ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
				end
			end

			test "subject_side_menu for mother subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:mother_study_subject)
				response = HTML::Document.new( subject_side_menu(study_subject) ).root
				assert_select response, '#sidemenu' do
					assert_select 'a', :count => 11
					if %w( birth_records interviews rafs
						abstracts study_subject_abstracts patients ).include?(k)
#						abstracts study_subject_abstracts abstract/diagnoses patients ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
				end
			end

			test "subject_side_menu for subject and #{k} with #{cu} login" do
				login_as send(cu)
				self.params = { :controller => k }
				study_subject = FactoryGirl.create(:study_subject)
				response = HTML::Document.new( subject_side_menu(study_subject) ).root
				assert_select response, '#sidemenu' do |s|
					assert_select 'a', :count => 11
					if %w( birth_records interviews rafs
						abstracts study_subject_abstracts patients ).include?(k)
#						abstracts study_subject_abstracts abstract/diagnoses patients ).include?(k)
						#	not shown to non-admins
						assert_select 'a.current', :count => 0
					else
						assert_select 'a.current[href=?]', send(v,study_subject)
					end
				end
			end

		end
	
		test "subject_side_menu for case subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:case_study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 14
				assert_select 'a.current', :count => 0
			end
		end

		test "subject_side_menu for control subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:control_study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 11
				assert_select 'a.current', :count => 0
			end
		end

		test "subject_side_menu for mother subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:mother_study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 11
				assert_select 'a.current', :count => 0
			end
		end

		test "subject_side_menu for subject and bogus controller with #{cu} login" do
			login_as send(cu)
			self.params = { :controller => 'bogus' }
			study_subject = FactoryGirl.create(:study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 11
				assert_select 'a.current', :count => 0
			end
		end

		test "should not get user_roles with #{cu} login" do
			@user = send(cu)
			login_as @user
			@roles = Role.all
			response = HTML::Document.new(user_roles).root
			assert response.to_s.blank?
		end

	end	#	reader and editor

#	WITHOUT LOGIN (ONLY REAL IN TESTING AS CONTROLLERS STOP THIS)

	controllers_and_current_links.each do |k,v|

		test "subject_side_menu for case subject and #{k} without login" do
			self.params = { :controller => k }
			study_subject = FactoryGirl.create(:case_study_subject)
			response = HTML::Document.new( subject_side_menu(study_subject) ).root
			assert_select response, '#sidemenu' do
				assert_select 'a', :count => 14
				if %w( birth_records interviews ).include?(k)
					#	not shown to non-admins
					assert_select 'a.current', :count => 0
				else
					assert_select 'a.current[href=?]', send(v,study_subject)
				end
			end
		end

	end

	test "odms_main_menu should return main menu without login" do
		response = HTML::Document.new(odms_main_menu).root
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
		response = HTML::Document.new(sort_link('name')).root
		#	<div class=""><a href="/users?dir=asc&amp;order=name">name</a></div>
		assert_select response, 'div', :count => 1 do
			assert_select 'a', :count => 1
			assert_select 'span', :count => 0
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
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :count => 1
			assert_select '.up.arrow', :count => 1
			assert_select 'span.up.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name' }
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sortable name sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#	<img class="up arrow" src="/images/sort_up.png?1320424344" alt="Sort_up" /></div>
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :count => 1
			assert_select '.up.arrow', :count => 1
			assert_select 'img.up.arrow', :count => 1
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
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :count => 1
			assert_select '.down.arrow', :count => 1
			assert_select 'span.down.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'asc'" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'asc' }
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sortable name sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#	<img class="down arrow" src="/images/sort_down.png?1320424344" alt="Sort_up" /></div>
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :count => 1
			assert_select '.down.arrow', :count => 1
			assert_select 'img.down.arrow', :count => 1
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
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :count => 1
			assert_select '.up.arrow', :count => 1
			assert_select 'span.up.arrow', :count => 1
		end
	end

	test "should return div with link to sort column name with order set to name" <<
			" and dir set to 'desc'" do
		self.params = { :controller => 'users', :action => 'index', 
			:order => 'name', :dir => 'desc' }
		response = HTML::Document.new(sort_link('name')).root
		#	<div class="sortable name sorted"><a href="/users?dir=asc&amp;order=name">name</a>
		#	<img class="up arrow" src="/images/sort_up.png?1320424344" alt="Sort_up" /></div>
		assert_select response, 'div.sorted', :count => 1 do
			assert_select 'a', :count => 1
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
		assert_select response, 'div#id_bar', :count => 0
	end

#	do_not_contact

	test "should respond to do_not_contact" do
		assert respond_to?(:do_not_contact)
	end

	test "do_not_contact should return do_not_contact if do not contact" do
		subject = FactoryGirl.create(:study_subject,:do_not_contact => true)
		assert subject.is_a?(StudySubject)
		assert subject.do_not_contact?
		response = HTML::Document.new( do_not_contact(subject) ).root
		assert_select response, 'div#do_not_contact', :count => 1
	end

	test "do_not_contact should NOT return do_not_contact if NOT do not contact" do
		subject = FactoryGirl.create(:study_subject,:do_not_contact => false)
		assert  subject.is_a?(StudySubject)
		assert !subject.do_not_contact?
		response = HTML::Document.new( do_not_contact(subject) ).root
		assert_select response, 'div#do_not_contact', :count => 0
		assert response.to_s.blank?
	end

#	do_not_contact MUST be true or false (no nil)
#	test "do_not_contact should NOT return do_not_contact if nil do not contact" do
#		subject = FactoryGirl.create(:study_subject,:do_not_contact => nil)
#		assert  subject.is_a?(StudySubject)
#		assert_nil subject.do_not_contact
#		response = HTML::Document.new( do_not_contact(subject) ).root
#		assert_select response, 'div#do_not_contact', :count => 0
#		assert response.blank?
#	end

	test "do_not_contact should NOT return do_not_contact if nil subject" do
		response = HTML::Document.new( do_not_contact(nil) ).root
		assert_select response, 'div#do_not_contact', :count => 0
		assert response.to_s.blank?
	end

##	required
#
#	test "required(text) should" do
#		response = HTML::Document.new(required('something')).root
#		#"<span class='required'>something</span>"
#		assert_select response, 'span.required', :text => 'something', :count => 1
#	end
#
##	req
#
#	test "req(text) should" do
#		response = HTML::Document.new(req('something')).root
#		#"<span class='required'>something</span>"
#		assert_select response, 'span.required', :text => 'something', :count => 1
#	end


	test "padk(1) should return 'Present'" do
		assert_equal 'Present', padk(1)
	end

	test "padk(2) should return 'Absent'" do
		assert_equal 'Absent', padk(2)
	end

	test "padk(999) should return 'Don't Know'" do
		assert_equal "Don't Know", padk(999)
	end

	test "padk(0) should return '&nbsp;'" do
		assert_equal "&nbsp;", padk(0)
	end

	test "padk() should return '&nbsp;'" do
		assert_equal "&nbsp;", padk()
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

	test "ynordk(1) should return 'Yes'" do
		assert_equal 'Yes', ynordk(1)
	end

	test "ynordk(2) should return 'No'" do
		assert_equal 'No', ynordk(2)
	end

	test "ynordk(3) should return 'Other'" do
		assert_equal 'Other', ynordk(3)
	end

	test "ynordk(888) should return 'Refused'" do
		assert_equal "Refused", ynordk(888)
	end

	test "ynordk(999) should return 'Don't Know'" do
		assert_equal "Don't Know", ynordk(999)
	end

	test "ynordk() should return '&nbsp;'" do
		assert_equal "&nbsp;", ynordk()
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

	test "unwrapped _wrapped_padk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			_wrapped_padk_spans(:app_model, :int_field)).root
		assert_select response, 'span.label', :text => 'int_field', :count => 1
		assert_select response, 'span.value', :text => '&nbsp;', :count => 1
	end

	test "wrapped_padk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			wrapped_padk_spans(:app_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', :count => 1 do
			assert_select 'label', :count => 0
			assert_select 'span.label', :text => 'int_field', :count => 1
			assert_select 'span.value', :text => '&nbsp;', :count => 1
		end
	end

	test "unwrapped _wrapped_adna_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			_wrapped_adna_spans(:app_model, :int_field)).root
		assert_select response, 'span.label', :text => 'int_field', :count => 1
		assert_select response, 'span.value', :text => '&nbsp;', :count => 1
	end

	test "wrapped_adna_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			wrapped_adna_spans(:app_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', :count => 1 do
			assert_select 'label', :count => 0
			assert_select 'span.label', :text => 'int_field', :count => 1
			assert_select 'span.value', :text => '&nbsp;', :count => 1
		end
	end

	test "unwrapped _wrapped_yndk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			_wrapped_yndk_spans(:app_model, :int_field)).root
		assert_select response, 'span.label', :text => 'int_field', :count => 1
		assert_select response, 'span.value', :text => '&nbsp;', :count => 1
	end

	test "wrapped_yndk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			wrapped_yndk_spans(:app_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', :count => 1 do
			assert_select 'label', :count => 0
			assert_select 'span.label', :text => 'int_field', :count => 1
			assert_select 'span.value', :text => '&nbsp;', :count => 1
		end
	end

	test "unwrapped _wrapped_ynrdk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			_wrapped_ynrdk_spans(:app_model, :int_field)).root
		assert_select response, 'span.label', :text => 'int_field', :count => 1
		assert_select response, 'span.value', :text => '&nbsp;', :count => 1
	end

	test "wrapped_ynrdk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			wrapped_ynrdk_spans(:app_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', :count => 1 do
			assert_select 'label', :count => 0
			assert_select 'span.label', :text => 'int_field', :count => 1
			assert_select 'span.value', :text => '&nbsp;', :count => 1
		end
	end

	test "unwrapped _wrapped_ynodk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			_wrapped_ynodk_spans(:app_model, :int_field)).root
		assert_select response, 'span.label', :text => 'int_field', :count => 1
		assert_select response, 'span.value', :text => '&nbsp;', :count => 1
	end

	test "wrapped_ynodk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			wrapped_ynodk_spans(:app_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', :count => 1 do
			assert_select 'label', :count => 0
			assert_select 'span.label', :text => 'int_field', :count => 1
			assert_select 'span.value', :text => '&nbsp;', :count => 1
		end
	end

	test "unwrapped _wrapped_ynordk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			_wrapped_ynordk_spans(:app_model, :int_field)).root
		assert_select response, 'span.label', :text => 'int_field', :count => 1
		assert_select response, 'span.value', :text => '&nbsp;', :count => 1
	end

	test "wrapped_ynordk_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			wrapped_ynordk_spans(:app_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', :count => 1 do
			assert_select 'label', :count => 0
			assert_select 'span.label', :text => 'int_field', :count => 1
			assert_select 'span.value', :text => '&nbsp;', :count => 1
		end
	end

	test "unwrapped _wrapped_pos_neg_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			_wrapped_pos_neg_spans(:app_model, :int_field)).root
		assert_select response, 'span.label', :text => 'int_field', :count => 1
		assert_select response, 'span.value', :text => '&nbsp;', :count => 1
	end

	test "wrapped_pos_neg_spans" do
		@app_model = AppModel.new
		response = HTML::Document.new(
			wrapped_pos_neg_spans(:app_model, :int_field)).root
		assert_select response, 'div.int_field.field_wrapper', :count => 1 do
			assert_select 'label', :count => 0
			assert_select 'span.label', :text => 'int_field', :count => 1
			assert_select 'span.value', :text => '&nbsp;', :count => 1
		end
	end

#	test "flasher" do
#		response = HTML::Document.new(
#			flasher
#		).root
##<p class="flash" id="notice">Hello There</p>
##<noscript>
##<p id="noscript" class="flash">Javascript is required for this site to be fully functional.</p>
##</noscript>
##<p class="flash notice">Hello There</p>
##<noscript>
##<p id="noscript" class="flash">Javascript is required for this site to be fully functional.</p>
##</noscript>
##		assert_select response, 'p#notice.flash'
#		assert_select response, 'p.notice.flash'
#		assert_select response, 'noscript' do
#			assert_select 'p#noscript.flash'
#		end
#	end
#
#	test "javascripts" do
#		assert_nil @javascripts
#		javascripts('myjavascript')
#		assert @javascripts.include?('myjavascript')
#		assert_equal 1, @javascripts.length
#		javascripts('myjavascript')
#		assert_equal 1, @javascripts.length
#		#<script src="/javascripts/myjavascript.js" type="text/javascript"></script>
#		response = HTML::Document.new( content_for(:head) ).root
#		assert_select response, 'script[src=/javascripts/myjavascript.js]'
#	end
#
#	test "stylesheets" do
#		assert_nil @stylesheets
#		stylesheets('mystylesheet')
#		assert @stylesheets.include?('mystylesheet')
#		assert_equal 1, @stylesheets.length
#		stylesheets('mystylesheet')
#		assert_equal 1, @stylesheets.length
#		#<link href="/stylesheets/mystylesheet.css" media="screen" rel="stylesheet" type="text/css" />
#		response = HTML::Document.new( content_for(:head) ).root
#		assert_select response, 'link[href=/stylesheets/mystylesheet.css]'
#	end
#
#	test "field_wrapper" do
#		response = HTML::Document.new(
#			field_wrapper('mymethod') do
#				'Yield'
#			end).root
##<div class="mymethod field_wrapper">
##Yield
##</div><!-- class='mymethod' -->
#		assert_select response, 'div.mymethod.field_wrapper'
#	end
#
#	test "wrapped_spans without options" do
#		@user = AppModel.new
#		response = HTML::Document.new(
#			wrapped_spans(:user, :name)).root
##<div class="name field_wrapper">
##<span class="label">name</span>
##<span class="value">&nbsp;</span>
##</div><!-- class='name' -->
#		assert_select response, 'div.name.field_wrapper', :count => 1 do
#			assert_select 'label', :count => 0
#			assert_select 'span.label', :count => 1
#			assert_select 'span.value', :count => 1
#		end
#	end
#
#	test "wrapped_date_spans blank" do
#		@user = AppModel.new
#		response = HTML::Document.new(
#			wrapped_date_spans(:user, :dob)).root
##<div class="dob date_spans field_wrapper">
##<span class="label">dob</span>
##<span class="value">&nbsp;</span>
##</div><!-- class='dob date_spans' -->
#		assert_select response, 'div.dob.date_spans.field_wrapper' do
#			assert_select 'label', :count => 0
#			assert_select 'span.label', :text => 'dob', :count => 1
#			assert_select 'span.value', :text => '&nbsp;', :count => 1
#		end
#	end
#
#	test "wrapped_date_spans Dec 5, 1971" do
#		@user = AppModel.new{|u| u.dob = Date.parse('Dec 5, 1971')}
#		response = HTML::Document.new(
#			wrapped_date_spans(:user, :dob)).root
##<div class="dob date_spans field_wrapper">
##<span class="label">dob</span>
##<span class="value">12/05/1971</span>
##</div><!-- class='dob date_spans' -->
#		assert_select response, 'div.dob.date_spans.field_wrapper' do
#			assert_select 'label', :count => 0
#			assert_select 'span.label', :text => 'dob', :count => 1
#			assert_select 'span.value', :text => '12/05/1971', :count => 1
#		end
#	end
#
#	test "wrapped_yes_or_no_spans blank" do
#		@user = AppModel.new
#		response = HTML::Document.new(
#			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
##<div class="yes_or_no field_wrapper">
##<span class="label">yes_or_no</span>
##<span class="value">no</span>
##</div><!-- class='yes_or_no' -->
#		assert_select response, 'div.yes_or_no.field_wrapper' do
#			assert_select 'label', :count => 0
#			assert_select 'span.label', :text => 'yes_or_no', :count => 1
#			assert_select 'span.value', :text => 'No', :count => 1
#		end
#	end
#
#	test "wrapped_yes_or_no_spans true" do
#		@user = AppModel.new{|u| u.yes_or_no = true }
#		response = HTML::Document.new(
#			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
##<div class="yes_or_no field_wrapper">
##<span class="label">yes_or_no</span>
##<span class="value">yes</span>
##</div><!-- class='yes_or_no' -->
#		assert_select response, 'div.yes_or_no.field_wrapper' do
#			assert_select 'label', :count => 0
#			assert_select 'span.label', :text => 'yes_or_no', :count => 1
#			assert_select 'span.value', :text => 'Yes', :count => 1
#		end
#	end
#
#	test "wrapped_yes_or_no_spans false" do
#		@user = AppModel.new(:yes_or_no => false)
#		response = HTML::Document.new(
#			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
##<div class="yes_or_no field_wrapper">
##<span class="label">yes_or_no</span>
##<span class="value">no</span>
##</div><!-- class='yes_or_no' -->
#		assert_select response, 'div.yes_or_no.field_wrapper' do
#			assert_select 'label', :count => 0
#			assert_select 'span.label', :text => 'yes_or_no', :count => 1
#			assert_select 'span.value', :text => 'No', :count => 1
#		end
#	end

#	abstract_pages
#
#	test "should respond abstract_pages" do
#		assert respond_to?(:abstract_pages)
#	end

#
#	Calling the named route methods raises
#
#NoMethodError: undefined method `host' for nil:NilClass
#
#	and this is proving a bit tricky to deal with here.
#
#	test "abstract_pages should return without being at subsection" do
#		abstract = FactoryGirl.create(:abstract)
#		response = HTML::Document.new( abstract_pages(abstract) ).root 
#		assert_select response, 'p.center' do
#			assert_select 'a','Back to Abstract',1
#			assert_select 'a[href=?]', abstract_path(abstract)
#		end
#	end
#
#	test "abstract_pages should return being at the first subsection" do
#		controller_name = Abstract.sections.first[:controller]
#		@controller = "Abstract::#{controller_name}".constantize.new
#		abstract = FactoryGirl.create(:abstract)
#		response = abstract_pages(abstract)
#		puts response
#	end
#
#	test "abstract_pages should return being at a middle subsection" do
#		controller_name = Abstract.sections[6][:controller]
#		@controller = "Abstract::#{controller_name}".constantize.new
#		abstract = FactoryGirl.create(:abstract)
#		response = abstract_pages(abstract)
#		puts response
#	end
#
#	test "abstract_pages should return being at the last subsection" do
#		controller_name = Abstract.sections.last[:controller]
#		@controller = "Abstract::#{controller_name}".constantize.new
#		abstract = FactoryGirl.create(:abstract)
#		response = abstract_pages(abstract)
#		puts response
#	end

#	edit_link (abstracts only)
#
#	test "should respond edit_link" do
#		assert respond_to?(:edit_link)
#	end

#	will now actually raise an error for the invalid route
#	test "edit_link should return link without controller and id" do
#		response = HTML::Document.new( edit_link ).root
#		#	without a set controller uses assets
#		#	<p class='center'><a href="/assets?action=edit" class="right button">Edit</a></p>
#		assert_select response, 'p.center' do
#			assert_select 'a.right.button', :text => 'Edit', :count => 1
#			assert_select 'a[href=?]', "/assets?action=edit"
#		end
#	end

#	#	edit_link is only called from abstract section show pages
#	test "edit_link should return link with controller and id" do
##		self.params = { :controller => 'abstracts', :id => 0 }
##abstract = FactoryGirl.create(:abstract)
##		self.params = { :controller => 'abstracts', :id => 0, :study_subject_id => 0 }
##		self.params = { :controller => 'abstracts', :id => abstract.id, :study_subject_id => abstract.study_subject_id }
##		self.params = { :controller => 'cbcs', :abstract_id => abstract.id, :study_subject_id => abstract.study_subject_id }
#		self.params = { :controller => 'abstract/cbcs', :abstract_id => 0 }
#		response = HTML::Document.new( edit_link ).root
#		#	with a set controller and id
#		#	<p class='center'><a href="/abstracts/0/edit" class="right button">Edit</a></p>
#		#	<p class='center'><a href="/abstracts/0/edit" class="right button">Edit</a></p>
##https://dev.sph.berkeley.edu/abstracts/15/bone_marrow/edit
#		assert_select response, 'p.center' do
#			assert_select 'a.right.button', :text => 'Edit', :count => 1
##			assert_select 'a[href=?]', "/abstracts/0/edit"
#			assert_select 'a[href=?]', "/abstracts/0/cbc/edit"
##			assert_select 'a[href=?]', edit_abstract_path(0)
##			assert_select 'a[href=?]', edit_study_subject_abstract_path(0,0)
#			assert_select 'a[href=?]', edit_abstract_cbc_path(0)
#		end
#	end

#	assert_select apparently requires explicit hash of options
#	in ruby 1.9.3 instead of just a list (adding :text and :count to all )
#	ArgumentError: assertion message must be String or Proc, but .... was given.


#	#	apparently not used anywhere anymore.
#	#	could remove the method or test it manually in order to get 100%
#	test "time_mdy(nil) should return nbsp" do
#		response = time_mdy(nil)
#		assert_equal '&nbsp;', response
#	end
#
#	test "time_mdy(some valid time) should return formated time" do
#		response = time_mdy(Time.parse('Dec 24, 1999 11:59 pm'))
#		assert_equal "11:59 PM 12/24/1999", response
#	end

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
#	def response
#		ActionController::TestResponse.new
#	end

#	#	fake the funk for controller as well. (for the abstract_pages tests)
#	def controller
#puts "reading set controller"
#		@controller || TestController.new
#		instance_variable_get("@controller") || TestController.new
#	end
#	def controller=(new_controller)
#puts "setting new controller"
#		@controller = new_controller
#	end
end

__END__
