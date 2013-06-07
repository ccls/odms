require 'integration_test_helper'

class CaseIntegrationTest < ActionController::CapybaraIntegrationTest

#	something here is causing ...
#Control Integration should render html and trigger csv download on assigned_for_interview_at with administrator login: P.QNetworkReplyImplPrivate::error: Internal problem, this method must only be called once.
#	and then autotest just hangs indefinitely
#
#	This is the line.  The offender is the trailing ".click"
#	probably not the method that I am looking for
#			find("button[name='commit'][value='update']").click
#

	site_editors.each do |cu|

		test "should render html and trigger csv download "<<
				"on assigned_for_interview_at with #{cu} login" do
			subject1 = subject_for_assigned_for_interview_at
			subject2 = subject_for_assigned_for_interview_at
			login_as send(cu)
			visit cases_path
			assert_equal current_path, cases_path
			assert has_css?("form[action='#{assign_selected_for_interview_cases_path}']")
			assert has_css?("input[name='ids[]'][type='checkbox'][value='#{subject1.id}']")
			assert has_css?("input#id#{subject1.id}")
			id1 = find("input[name='ids[]'][type='checkbox'][value='#{subject1.id}']")
			assert !id1.checked?
			check("id#{subject1.id}")	#	added id tags in view just for this test
			assert id1.checked?
			id2 = find("input[name='ids[]'][type='checkbox'][value='#{subject2.id}']")
			assert !id2.checked?

#	just can't seem to click on a button tag without raising th QNetwork error above???!??!?!?!?!

#puts page.body
#click_button("Export selected to CSV")
#  find(:button, 'export_to_csv' ).click
#  find(:button, 'Export selected to CSV' ).click
#  puts find(:button, 'export' ).inspect
#  find(:button, 'export' ).click
#  puts find(:button, 'export' ).inspect

#			find("button#export_to_csv").click
#			click_button 'export_to_csv'
#			click_button 'update_and_download'
#			click_button 'export'

#			click_button "update"
#			should update values
#			render index
#			should then click export
#			render csv

pending
		end

	end

protected

	def subject_for_assigned_for_interview_at
		subject = FactoryGirl.create(:patient, :admit_date => 60.days.ago).study_subject
		#	Pagan only wants subjects with reference_date/admit_date > 30 days ago
		#	updating admit_date should trigger reference_date update
		subject.enrollments.where(:project_id   => Project[:ccls].id).first
			.update_attributes({
				:is_eligible  => YNDK[:yes],
				:consented    => YNDK[:yes],
				:consented_on => Date.current
			})
		assert_equal 5, subject.phase
		assert_nil subject.enrollments.where(
			:project_id => Project[:ccls].id).first.assigned_for_interview_at
		subject
	end

end
