require 'test_helper'

class ControlsControllerTest < ActionController::TestCase

	#	Too complex for common assertions

	site_editors.each do |cu|

#
#	The new control link from the menu goes to the new control page.
#	Searching for a case via the patid will then return you to the
#	new control page with the case info if any found.
#	Clicking continue will take you to the related subjects page.
#	On the related subjects page, there is a add control link
#	which will take you to the create control action.
#

		test "should get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should return nothing without matching patid and #{cu} login" do
			login_as send(cu)
			get :new, :q => 'NOPE'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:NOPE/,
				flash[:error]
		end

		test "should return nothing without matching icf master id and #{cu} login" do
			login_as send(cu)
			get :new, :q => 'donotmatch'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:donotmatch/,
				flash[:error]
		end

		test "should return case study_subject with matching patid and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			get :new, :q => case_study_subject.patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should return case study_subject with matching patid missing" <<
				" leading zeroes and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			# case_study_subject.patid should be a small 4-digit string
			#   with leading zeroes. (probably 0001). Remove them before submit.
			patid = case_study_subject.patid.to_i
			assert patid < 1000,
				'Expected auto-generated patid to be less than 1000 for this test'
			get :new, :q => patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should return case study_subject with matching icf master id and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			get :new, :q => case_study_subject.icf_master_id
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

	



		test "should get new control with case_id, matching candidate and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			post :create, :case_id => case_study_subject.id
			assert_nil flash[:error]
			assert_redirected_to edit_candidate_control_path(candidate)
		end

		test "should NOT get new control with case_id, no matching candidate and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:case_study_subject)
			post :create, :case_id => case_study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_related_subjects_path(case_study_subject)
		end

		test "should NOT get new control with #{cu} login and invalid case_id" do
			login_as send(cu)
			post :create, :case_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to new_control_path
		end

		test "should NOT get new control with #{cu} login and non-case study_subject" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
			post :create, :case_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to new_control_path
		end

		test "should get index with date and #{cu} login" do
			login_as send(cu)
			subject = FactoryGirl.create(:control_study_subject)
			assert_equal 5, subject.phase
			assert_nil subject.enrollments.where(:project_id => Project[:ccls].id
				).first.assigned_for_interview_at
#			some_datetime = DateTime.current
			some_datetime = Time.parse('1971-12-05 12:00')
			subject.enrollments.where(:project_id => Project[:ccls].id
				).first.update_attribute(:assigned_for_interview_at, some_datetime)
			assert_not_nil subject.enrollments.where(:project_id => Project[:ccls].id
				).first.assigned_for_interview_at
			assert_equal subject.enrollments.where(:project_id => Project[:ccls].id
				).first.assigned_for_interview_at.to_date, some_datetime.to_date


#puts StudySubject.controls
#	.where( :phase => 5 )
#	.order('reference_date DESC')
#	.joins(:enrollments)
#	.merge(
#		Enrollment.where(:project_id => Project['ccls'].id)
#		.where("date(assigned_for_interview_at) = ?", Date.parse(now.to_date.to_s))
#	).to_sql
#Controls Controller should get index with date and administrator login: SELECT `study_subjects`.* FROM `study_subjects` INNER JOIN `enrollments` ON `enrollments`.`study_subject_id` = `study_subjects`.`id` WHERE `study_subjects`.`subject_type` = 'Control' AND `study_subjects`.`phase` = 5 AND `enrollments`.`project_id` = 10 AND (date(assigned_for_interview_at) = '2013-11-25') ORDER BY reference_date DESC

#	after 4pm, this fails due to time zones????

#	TODO
#	change assigned_for_interview_at to assigned_for_interview_on, just a Date field?

#			get :index, :date => DateTime.tomorrow.to_date.to_s


			#	The database stores datetimes as UTC so setting the time within 7 or 8 hours
			#	of midnight will result in the date part of the datetime being tomorrow.
			#	Searching for today will NOT find it.
			#	fortunately, the use of "date" is an undocument, only-used-once feature

			get :index, :date => some_datetime.to_date.to_s
			assert_response :success
			assert_template 'index'

			#	This test may fail if run at just the wrong time causing 
			#	the set date and requested date to somehow differ?

			assert  assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert_equal 1, assigns(:study_subjects).length
			assert_equal subject, assigns(:study_subjects).first
		end

		test "should get index with #{cu} login" do
			login_as send(cu)
			subject = FactoryGirl.create(:control_study_subject)
			assert_equal 5, subject.phase
			assert_nil subject.enrollments.where(:project_id => Project[:ccls].id).first.assigned_for_interview_at
			get :index
			assert_response :success
			assert_template 'index'
#	will this be set automatically??? hmm, let's see ... NOPE
#	must explicitly set this.  Is that necessary? Doesn't seem to be.
#			assert_not_nil @response.headers['Content-Disposition']
#				.match(/attachment; filename=newcontrols_.*csv/)
			assert  assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert_equal 1, assigns(:study_subjects).length
			assert_equal subject, assigns(:study_subjects).first
		end

		test "should get index csv with #{cu} login" do
			login_as send(cu)
			subject = FactoryGirl.create(:control_study_subject)
			assert_equal 5, subject.phase
			assert_nil subject.enrollments.where(:project_id => Project[:ccls].id).first.assigned_for_interview_at
			get :index, :format => :csv
			assert_response :success
			assert_template 'index'
#	will this be set automatically??? hmm, let's see ... NOPE
#	must explicitly set this.  Is that necessary? Doesn't seem to be.
			assert_not_nil @response.headers['Content-Disposition']
				.match(/attachment; filename=newcontrols_.*csv/)
			assert  assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert_equal 1, assigns(:study_subjects).length
			assert_equal subject, assigns(:study_subjects).first
		end

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

		test "should render index csv of ids if commit is 'export' with #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			put :assign_selected_for_interview, :ids => [subject.id], :commit => :export
			#	SHOULD NOT UPDATE
			assert_nil subject.enrollments.where(
				:project_id => Project[:ccls].id).first.assigned_for_interview_at
			assert_response :success
			assert_template :index

			assert_not_nil @response.headers['Content-Disposition']
				.match(/attachment; filename=newcontrols_.*csv/)
			assert  assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert_equal 1, assigns(:study_subjects).length
			assert_equal subject, assigns(:study_subjects).first

			require 'csv'
			f = CSV.parse(@response.body)
			assert_equal 2, f.length  # 2 rows, 1 header and 1 data
			assert_equal 29, f[0].length	#	2 longer than cases as includes parent's ssns
			assert_equal 29, f[1].length	#	2 longer than cases as includes parent's ssns
			assert_equal f[0], "reference_date,case_icfmasterid,icf_master_id,mom_icfmasterid,mother_first_name,mother_maiden_name,mother_last_name,mother_ssn,father_first_name,father_last_name,father_ssn,first_name,middle_name,last_name,dob,sex,vital_status,do_not_contact,is_eligible,consented,comments,language,street,unit,city,state,zip,phone,alternate_phone".split(',')
			assert_equal subject.dob.strftime("%m/%d/%Y"), f[1][14],
				"Expected csv to match subject's date of birth:#{subject.dob.strftime("%m/%d/%Y")}:#{f[1][14]}:"
			assert_match subject.sex, f[1][15]
				"Expected csv to match subject's sex:#{subject.sex}:#{f[1][15]}:"
		end

		test "should NOT update assigned_for_interview_at with #{cu} login" <<
				" without ids" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			put :assign_selected_for_interview
			assert_not_nil flash[:error]
			assert_redirected_to controls_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get new control with case_id and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:case_study_subject)
			post :create, :case_id => case_study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_redirected_to root_path
		end

		test "should NOT get index csv with #{cu} login" do
			login_as send(cu)
			get :index, :format => :csv
			assert_redirected_to root_path
		end

		test "should NOT update selected with #{cu} login" do
			login_as send(cu)
			put :assign_selected_for_interview, :ids => [1,2,3]
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get new without login" do
		get :new
		assert_redirected_to_login
	end

	test "should NOT get new control with case_id and without login" do
		case_study_subject = FactoryGirl.create(:case_study_subject)
		post :create, :case_id => case_study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get index without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT get index csv without login" do
		get :index, :format => :csv
		assert_redirected_to_login
	end

	test "should NOT update selected without login" do
		put :assign_selected_for_interview, :ids => [1,2,3]
		assert_redirected_to_login
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
#	for cases
	def subject_for_assigned_for_interview_at
		subject = FactoryGirl.create(:case_study_subject)
		FactoryGirl.create(:patient, :study_subject => subject,
			:admit_date => 60.days.ago)
		#	Pagan only wants subjects with reference_date/admit_date > 30 days ago
		#	updating admit_date should trigger reference_date update
		subject.enrollments.where(
			:project_id   => Project[:ccls].id).first.update_attributes({
			:is_eligible  => YNDK[:yes],
			:consented    => YNDK[:yes],
			:consented_on => Date.current
		})
		assert_equal 5, subject.phase
		assert_nil subject.enrollments.where(
			:project_id => Project[:ccls].id).first.assigned_for_interview_at
		subject
	end
