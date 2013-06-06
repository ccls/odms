require 'integration_test_helper'

class ControlIntegrationTest < ActionController::CapybaraIntegrationTest

#	something here is causing ...
#Control Integration should render html and trigger csv download on assigned_for_interview_at with administrator login: P.QNetworkReplyImplPrivate::error: Internal problem, this method must only be called once.
#	and then autotest just hangs indefinitely
#
#	This is the line.  The offender is the trailing ".click"
#	probably not the method that I am looking for
#			find("button[name='commit'][value='update']").click

	site_editors.each do |cu|

		test "should render html and trigger csv download "<<
				"on assigned_for_interview_at with #{cu} login" do
			subject1 = subject_for_assigned_for_interview_at
			subject2 = subject_for_assigned_for_interview_at
			login_as send(cu)
			visit controls_path
			assert_equal current_path, controls_path
			assert has_css?("form[action='#{assign_selected_for_interview_controls_path}']")
			id1 = find("input[name='ids[]'][type='checkbox'][value='#{subject1.id}']")
			assert !id1.checked?
			check("id#{subject1.id}")	#	added id tags in view just for this test
			assert id1.checked?
			id2 = find("input[name='ids[]'][type='checkbox'][value='#{subject2.id}']")
			assert !id2.checked?

#			click update
#			should update values
#			render index
#			click export
#			render csv

pending
		end

	end

protected

	def subject_for_assigned_for_interview_at
		subject = FactoryGirl.create(:control_study_subject)
		assert_nil subject.enrollments.where(
			:project_id => Project[:ccls].id).first.assigned_for_interview_at
		subject
	end

end
__END__

		test "should update assigned_for_interview_at with ids and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			put :assign_selected_for_interview, :ids => [subject.id]
			assert_not_nil subject.enrollments.where(
				:project_id => Project[:ccls].id).first.assigned_for_interview_at
			assert_not_nil flash[:notice]
			assert_response :success
			assert_template :index
		end


