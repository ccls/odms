require 'integration_test_helper'

class StudySubjectIntegrationTest < ActionDispatch::CapybaraIntegrationTest

	#	not everything in here requires admin privileges, nevertheless, for simplicity ...

	site_administrators.each do |cu|

		test "should preserve creation of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 0 ){
				@study_subject = FactoryBot.create(:study_subject)
			}
			login_as send(cu)
			visit edit_study_subject_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_path(@study_subject.id)
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][0][race_code]")	#	white
			#	trigger a kickback from StudySubject update failure
			StudySubject.any_instance.stubs(:valid?).returns(false)
			click_button 'Save'
			assert has_css?("p.flash.error")
			assert_equal current_path, study_subject_path(@study_subject.id) #	still a kickback
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][0][race_code]")	#	white
		end

		test "should preserve destruction of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 1 ){
				@study_subject = FactoryBot.create(:study_subject, :subject_races_attributes => { 
					'0' => { :race_code => Race['white'].code }})
			}
			login_as send(cu)
			visit edit_study_subject_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_path(@study_subject.id)
			assert has_checked_field?(
				"study_subject[subject_races_attributes][0][_destroy]")	#	white
			#	trigger a kickback from StudySubject update failure
			StudySubject.any_instance.stubs(:valid?).returns(false)
			click_button 'Save'
			assert has_css?("p.flash.error")
			assert has_checked_field?(
				"study_subject[subject_races_attributes][0][_destroy]")	#	white
		end

		test "should toggle specify other race when other race_code is checked" <<
				" with #{cu} login" do
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit edit_study_subject_path(study_subject)
			assert has_css?("#specify_other_race",:visible => false)

			check "other_race_code"
			assert has_checked_field?("other_race_code")
			assert has_css?("#specify_other_race",:visible => true)

			uncheck "other_race_code"
			assert has_unchecked_field?("other_race_code")
			assert has_css?("#specify_other_race",:visible => false)
		end

		test "should toggle specify mixed race when mixed race_code is checked" <<
				" with #{cu} login" do
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit edit_study_subject_path(study_subject)
			assert has_css?("#specify_mixed_race",:visible => false)

			check "mixed_race_code"
			assert has_checked_field?("mixed_race_code")
			assert has_css?("#specify_mixed_race",:visible => true)

			uncheck "mixed_race_code"
			assert has_unchecked_field?("mixed_race_code")
			assert has_css?("#specify_mixed_race",:visible => false)
		end

		test "should have Back To Search link if show subject from find" <<
				" with #{cu} login" do
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit study_subjects_path	#	sets request.env['HTTP_REFERER']
			find('td.subjectid a').click	#	in reality many, in test should be only one
			wait_until { has_css?("#sidemenu") }
			assert_select body.to_html_document, 
				'#sidemenu > li > a', :text => "back to search"
		end

		#	first, prev, next, last and by should reference 
		#		request.env['HTTP_REFERER'] (request.referrer) if exists
		test "first should stay on same controller as referrer with #{cu} login" do
			first_study_subject = FactoryBot.create(:study_subject)
			middle_study_subject = FactoryBot.create(:study_subject)
			last_study_subject  = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(last_study_subject,
				last_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'first'
			assert_equal current_path, study_subject_enrollments_path(first_study_subject)
		end

		test "prev should stay on same controller as referrer with #{cu} login" do
			first_study_subject = FactoryBot.create(:study_subject)
			middle_study_subject = FactoryBot.create(:study_subject)
			last_study_subject  = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(last_study_subject,
				last_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'prev'
			assert_equal current_path, study_subject_enrollments_path(middle_study_subject)
		end

		test "next should stay on same controller as referrer with #{cu} login" do
			first_study_subject = FactoryBot.create(:study_subject)
			middle_study_subject = FactoryBot.create(:study_subject)
			last_study_subject  = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(first_study_subject,
				first_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'next'
			assert_equal current_path, study_subject_enrollments_path(middle_study_subject)
		end

		test "last should stay on same controller as referrer with #{cu} login" do
			first_study_subject = FactoryBot.create(:study_subject)
			middle_study_subject = FactoryBot.create(:study_subject)
			last_study_subject  = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(first_study_subject,
				first_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'last'
			assert_equal current_path, study_subject_enrollments_path(last_study_subject)
		end





		test "by should stay on same controller as referrer with #{cu} login" do
			first_study_subject = FactoryBot.create(:study_subject)
			middle_study_subject = FactoryBot.create(:study_subject)
			last_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_enrollment_path(first_study_subject,
				first_study_subject.enrollments.by_project_key('ccls').first)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_enrollments_path(last_study_subject)
		end



		test "by should contacts index from contacts index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_contacts_path(study_subject)
			assert_equal current_path, study_subject_contacts_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_contacts_path(other_study_subject)
		end

		test "by should interviews index from interviews index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_interviews_path(study_subject)
			assert_equal current_path, study_subject_interviews_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_interviews_path(other_study_subject)
		end

		test "by should related_subjects index from related_subjects index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_related_subjects_path(study_subject)
			assert_equal current_path, study_subject_related_subjects_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_related_subjects_path(other_study_subject)
		end

		test "by should phone_numbers index from phone_numbers index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_related_subjects_path(study_subject)
			assert_equal current_path, study_subject_related_subjects_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_related_subjects_path(other_study_subject)
		end

		test "by should phone_numbers new from phone_numbers new with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit new_study_subject_phone_number_path(study_subject)
			assert_equal current_path, new_study_subject_phone_number_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, new_study_subject_phone_number_path(other_study_subject)
		end

		test "by should phone_numbers index from phone_numbers edit with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			phone_number         = FactoryBot.create(:phone_number,:study_subject => study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit edit_study_subject_phone_number_path(study_subject,phone_number)
			assert_equal current_path, edit_study_subject_phone_number_path(study_subject,phone_number)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_phone_numbers_path(other_study_subject)
		end

		test "by should addresses index from addresses index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_addresses_path(study_subject)
			assert_equal current_path, study_subject_addresses_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_addresses_path(other_study_subject)
		end

		test "by should addresses new from addresses new with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit new_study_subject_address_path(study_subject)
			assert_equal current_path, new_study_subject_address_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, new_study_subject_address_path(other_study_subject)
		end

		test "by should addresses index from addresses edit with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			address           = FactoryBot.create(:address, :study_subject => study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit edit_study_subject_address_path(study_subject.reload,address)
			assert_equal current_path, edit_study_subject_address_path(study_subject,address)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_addresses_path(other_study_subject)
		end

		test "by should consent show from consent show with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_consent_path(study_subject)
			assert_equal current_path, study_subject_consent_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_consent_path(other_study_subject)
		end

		test "by should consent edit from consent edit with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert_equal current_path, edit_study_subject_consent_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, edit_study_subject_consent_path(other_study_subject)
		end

		test "by should enrollments index from enrollments index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_enrollments_path(study_subject)
			assert_equal current_path, study_subject_enrollments_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_enrollments_path(other_study_subject)
		end

		test "by should enrollments new from enrollments new with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit new_study_subject_enrollment_path(study_subject)
			assert_equal current_path, new_study_subject_enrollment_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, new_study_subject_enrollment_path(other_study_subject)
		end

		test "by should enrollments index from enrollments show with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_enrollment_path(study_subject,study_subject.enrollments.first)
			assert_equal current_path, study_subject_enrollment_path(study_subject,study_subject.enrollments.first)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_enrollments_path(other_study_subject)
		end

		test "by should enrollments index from enrollments edit with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit edit_study_subject_enrollment_path(study_subject,study_subject.enrollments.first)
			assert_equal current_path, edit_study_subject_enrollment_path(study_subject,study_subject.enrollments.first)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_enrollments_path(other_study_subject)
		end

		test "by should events index from events index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_events_path(study_subject)
			assert_equal current_path, study_subject_events_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_events_path(other_study_subject)
		end

		test "by should events new from events new with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit new_study_subject_event_path(study_subject)
			assert_equal current_path, new_study_subject_event_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, new_study_subject_event_path(other_study_subject)
		end

		test "by should events index from events show with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_event_path(study_subject, study_subject.operational_events.first)
			assert_equal current_path, study_subject_event_path(study_subject, study_subject.operational_events.first)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_events_path(other_study_subject)
		end

		test "by should events index from events edit with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			assert_not_nil study_subject.operational_events.first
			visit edit_study_subject_event_path(study_subject, study_subject.operational_events.first)
			assert_equal current_path, edit_study_subject_event_path(study_subject, study_subject.operational_events.first)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_events_path(other_study_subject)
		end

		test "by should samples index from samples index with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_samples_path(study_subject)
			assert_equal current_path, study_subject_samples_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_samples_path(other_study_subject)
		end

		test "by should samples new from samples new with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit new_study_subject_sample_path(study_subject)
			assert_equal current_path, new_study_subject_sample_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, new_study_subject_sample_path(other_study_subject)
		end

		test "by should samples index from samples show with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			sample               = FactoryBot.create(:sample,:study_subject => study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_sample_path(study_subject, sample)
			assert_equal current_path, study_subject_sample_path(study_subject, sample)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_samples_path(other_study_subject)
		end

		test "by should samples index from samples edit with #{cu} login" do
			study_subject        = FactoryBot.create(:study_subject)
			sample               = FactoryBot.create(:sample,:study_subject => study_subject)
			other_study_subject  = FactoryBot.create(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit edit_study_subject_sample_path(study_subject,sample)
			assert_equal current_path, edit_study_subject_sample_path(study_subject,sample)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_samples_path(other_study_subject)
		end




		#	case specific controller(s)

		test "by should patient show from patient show if case with #{cu} login" do
			study_subject        = FactoryBot.create(:patient).study_subject
			other_study_subject  = FactoryBot.create(:case_study_subject,:icf_master_id => 'FINDME')
			FactoryBot.create(:patient, :study_subject => other_study_subject)
			login_as send(cu)
			visit study_subject_patient_path(study_subject)
			assert_equal current_path, study_subject_patient_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, study_subject_patient_path(other_study_subject)
		end

		test "by should study_subject show from patient show if control with #{cu} login" do
			study_subject        = FactoryBot.create(:patient).study_subject
			other_study_subject  = FactoryBot.create(:control_study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_patient_path(study_subject)
			assert_equal current_path, study_subject_patient_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert has_css?("div#patient > h3", :text => "Hospital data is valid for case subjects only")
			#	doesn't redirect. renders action "not_case"
			assert_equal current_path, study_subject_patient_path(other_study_subject)
		end

		test "by should study_subject show from patient show if mother with #{cu} login" do
			study_subject        = FactoryBot.create(:patient).study_subject
			other_study_subject  = FactoryBot.create(:mother_study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_patient_path(study_subject)
			assert_equal current_path, study_subject_patient_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert has_css?("div#patient > h3", :text => "Hospital data is valid for case subjects only")
			#	doesn't redirect. renders action "not_case"
			assert_equal current_path, study_subject_patient_path(other_study_subject)
		end

		test "by should patient edit from patient edit if case with #{cu} login" do
			study_subject        = FactoryBot.create(:patient).study_subject
			other_study_subject  = FactoryBot.create(:case_study_subject,:icf_master_id => 'FINDME')
			FactoryBot.create(:patient, :study_subject => other_study_subject)
			login_as send(cu)
			visit edit_study_subject_patient_path(study_subject)
			assert_equal current_path, edit_study_subject_patient_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert_equal current_path, edit_study_subject_patient_path(other_study_subject)
		end

		test "by should study_subject show from patient edit if control with #{cu} login" do
			study_subject        = FactoryBot.create(:patient).study_subject
			other_study_subject  = FactoryBot.create(:control_study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit edit_study_subject_patient_path(study_subject)
			assert_equal current_path, edit_study_subject_patient_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert has_css?("p.flash.error", :text => "StudySubject must be Case to have patient data!")
			assert_equal current_path, study_subject_path(other_study_subject)
		end

		test "by should study_subject show from patient edit if mother with #{cu} login" do
			study_subject        = FactoryBot.create(:patient).study_subject
			other_study_subject  = FactoryBot.create(:mother_study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit edit_study_subject_patient_path(study_subject)
			assert_equal current_path, edit_study_subject_patient_path(study_subject)
			fill_in 'by_id', :with => 'FINDME'
#	request.referrer not being correctly reset in testing.  Remains that of last test?
Capybara.current_session.driver.header 'Referer', current_path	#	added for rails 4.2
			click_button 'go'
			assert has_css?("p.flash.error", :text => "StudySubject must be Case to have patient data!")
			assert_equal current_path, study_subject_path(other_study_subject)
		end

	end

end
