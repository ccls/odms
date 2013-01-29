require 'integration_test_helper'

class StudySubjectIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "should preserve creation of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 0 ){
				@study_subject = Factory(:study_subject)
			}
			login_as send(cu)
			visit edit_study_subject_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_path(@study_subject.id)
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][0][race_id]")	#	white
			#	trigger a kickback from StudySubject update failure
			StudySubject.any_instance.stubs(:valid?).returns(false)
			click_button 'Save'
			assert has_css?("p.flash.error")
			assert_equal current_path, study_subject_path(@study_subject.id) #	still a kickback
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][0][race_id]")	#	white
		end

		test "should preserve destruction of subject_race on edit kickback with #{cu} login" do
			assert_difference( 'SubjectRace.count', 1 ){
				@study_subject = Factory(:study_subject, :subject_races_attributes => { 
					'0' => { :race_id => Race['white'].id }})
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

		test "should check race_id when is_primary is checked with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit edit_study_subject_path(study_subject)
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
			check "study_subject[subject_races_attributes][1][is_primary]"
			assert has_checked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
		end

		test "should uncheck other is_primary's when is_primary is checked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit edit_study_subject_path(study_subject)
			check "study_subject[subject_races_attributes][1][is_primary]"
			assert has_checked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
			check "study_subject[subject_races_attributes][2][is_primary]"
			assert has_checked_field?(
				"study_subject[subject_races_attributes][2][is_primary]")
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
		end

		test "should uncheck is_primary when race_id is unchecked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit edit_study_subject_path(study_subject)
			check "study_subject[subject_races_attributes][1][is_primary]"
			assert has_checked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
			assert has_checked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
			uncheck "study_subject[subject_races_attributes][1][race_id]"
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][1][race_id]")
			assert has_unchecked_field?(
				"study_subject[subject_races_attributes][1][is_primary]")
		end

		test "should toggle specify other race when other race_id is checked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit edit_study_subject_path(study_subject)
			assert has_css?("#specify_other_race",:visible => false)

			check "other_race_id"
			assert has_checked_field?("other_race_id")
			assert has_unchecked_field?("other_is_primary")
			assert has_css?("#specify_other_race",:visible => true)

			uncheck "other_race_id"
			assert has_unchecked_field?("other_race_id")
			assert has_unchecked_field?("other_is_primary")
			assert has_css?("#specify_other_race",:visible => false)

			check "other_is_primary"
			assert has_checked_field?("other_race_id")
			assert has_checked_field?("other_is_primary")
			assert has_css?("#specify_other_race",:visible => true)

			uncheck "other_is_primary"
			assert has_checked_field?("other_race_id")
			assert has_unchecked_field?("other_is_primary")
			assert has_css?("#specify_other_race",:visible => true)
		end

		test "should toggle specify mixed race when mixed race_id is checked" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit edit_study_subject_path(study_subject)
			assert has_css?("#specify_mixed_race",:visible => false)

			check "mixed_race_id"
			assert has_checked_field?("mixed_race_id")
			assert has_unchecked_field?("mixed_is_primary")
			assert has_css?("#specify_mixed_race",:visible => true)

			uncheck "mixed_race_id"
			assert has_unchecked_field?("mixed_race_id")
			assert has_unchecked_field?("mixed_is_primary")
			assert has_css?("#specify_mixed_race",:visible => false)

			check "mixed_is_primary"
			assert has_checked_field?("mixed_race_id")
			assert has_checked_field?("mixed_is_primary")
			assert has_css?("#specify_mixed_race",:visible => true)

			uncheck "mixed_is_primary"
			assert has_checked_field?("mixed_race_id")
			assert has_unchecked_field?("mixed_is_primary")
			assert has_css?("#specify_mixed_race",:visible => true)
		end

		test "should have 'back to search' link if show subject from find" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit find_study_subjects_path	#	sets request.env['HTTP_REFERER']
			find('td.icf_master_id a').click	#	in reality many, in test should be only one
			wait_until { has_css?("div#sidemenu") }
			assert_select HTML::Document.new(body).root, 
				'div#sidemenu > a', :text => "back to search"
		end

		#	first, prev, next, last and by should reference 
		#		request.env['HTTP_REFERER'] (request.referrer) if exists
		test "first should stay on same controller as referrer with #{cu} login" do
			first_study_subject = Factory(:study_subject)
			middle_study_subject = Factory(:study_subject)
			last_study_subject  = Factory(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(last_study_subject,
				last_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'first'
			assert_equal current_path, study_subject_enrollments_path(first_study_subject)
		end

		test "prev should stay on same controller as referrer with #{cu} login" do
			first_study_subject = Factory(:study_subject)
			middle_study_subject = Factory(:study_subject)
			last_study_subject  = Factory(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(last_study_subject,
				last_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'prev'
			assert_equal current_path, study_subject_enrollments_path(middle_study_subject)
		end

		test "next should stay on same controller as referrer with #{cu} login" do
			first_study_subject = Factory(:study_subject)
			middle_study_subject = Factory(:study_subject)
			last_study_subject  = Factory(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(first_study_subject,
				first_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'next'
			assert_equal current_path, study_subject_enrollments_path(middle_study_subject)
		end

		test "last should stay on same controller as referrer with #{cu} login" do
			first_study_subject = Factory(:study_subject)
			middle_study_subject = Factory(:study_subject)
			last_study_subject  = Factory(:study_subject)
			login_as send(cu)
			visit study_subject_enrollment_path(first_study_subject,
				first_study_subject.enrollments.by_project_key('ccls').first)
			click_link 'last'
			assert_equal current_path, study_subject_enrollments_path(last_study_subject)
		end

		test "by should stay on same controller as referrer with #{cu} login" do
			first_study_subject = Factory(:study_subject)
			middle_study_subject = Factory(:study_subject)
			last_study_subject  = Factory(:study_subject,:icf_master_id => 'FINDME')
			login_as send(cu)
			visit study_subject_enrollment_path(first_study_subject,
				first_study_subject.enrollments.by_project_key('ccls').first)
			fill_in 'icf_master_id', :with => 'FINDME'
			click_button 'go'
			assert_equal current_path, study_subject_enrollments_path(last_study_subject)
		end

	end

end
