require 'integration_test_helper'

class CaseIntegrationTest < ActionDispatch::CapybaraIntegrationTest

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

			#	now, all of the sudden, finding and clicking work?
			#	must be using the new "AI" version that learns.

			assert has_no_css?("div#content > script")
			find("button#update_and_download").click




#	after the click, the page load html and then csv.
#	old versions of capybara would test the html with this, but new one use csv and it fails.
#			assert has_css?("div#content > script")
#	and now I'm back to the old version and it doesn't work?





			#	page.body is the html portion (body is an alias to html in Capybara::Session)
			#	page.source looks like the html as well
			#	page.text is somehow different (the csv, but has lost the carriage returns?)


#{"Content-Disposition"=>"attachment; filename=newcases_06102013.csv", "Content-Type"=>"text/csv; charset=utf-8", "X-Ua-Compatible"=>"IE=Edge,chrome=1", "Etag"=>"\"94e35996cc54a770506bd3e78661f434\"", "Cache-Control"=>"max-age=0, private, must-revalidate", "X-Request-Id"=>"7db0f7f5f75242967de43b968b7cbb57", "X-Runtime"=>"0.023621", "Server"=>"WEBrick/1.3.1 (Ruby/1.9.3/2013-05-15)", "Date"=>"Mon, 10 Jun 2013 19:09:50 GMT", "Content-Length"=>"451", "Connection"=>"Keep-Alive"}

			#	it seems that one must call the method alone first before testing any of the keys?
#			assert_not_nil page.response_headers


			#	I don't quite understand this.  The first 2 return the same html header.
			#	The next calls will return the csv header?

#	These headers seem to be a bit unpredictable.  Testing the page.text clearly shows its csv so ...

#			myhtml1 = page.response_headers
#			myhtml = page.response_headers
#			mycsv = page.response_headers
#			assert_equal myhtml, myhtml1
#			assert_match /text\/csv/, mycsv['Content-Type'],
#				"Expected '#{mycsv['Content-Type']}' to match text/csv"
#			assert_match /attachment; filename=newcases_.*csv/, mycsv['Content-Disposition'],
#				"Expected '#{mycsv['Content-Disposition']}' to match newcases*csv"

			csv = page.text
			csv_lines = csv.sub!(/\s+/,"\n").split("\n")
			assert_equal csv_lines[0], "reference_date,case_icfmasterid,icf_master_id,mom_icfmasterid,mother_first_name,mother_maiden_name,mother_last_name,father_first_name,father_last_name,first_name,middle_name,last_name,dob,sex,vital_status,do_not_contact,is_eligible,consented,comments,language,street,unit,city,state,zip,phone,alternate_phone"

			#	reference_date is FIRST so NO LEADING COMMA!!!!
			assert_match /^#{subject1.reference_date.strftime("%m/%d/%Y")},/, csv_lines[1],
				"Expected csv to match subject 1's reference date:#{subject1.reference_date.strftime("%m/%d/%Y")}:"
			assert_match /,#{subject1.dob.strftime("%m/%d/%Y")},/, csv_lines[1],
				"Expected csv to match subject 1's date of birth:#{subject1.dob.strftime("%m/%d/%Y")}:"
			assert_match /,#{subject1.sex},/, csv_lines[1],
				"Expected csv to match subject 1's sex:#{subject1.sex}:"
				
			#	it also seems that the csv \n's are tossed out along the way
			#	csv with 2 lines, 1 header, 1 data
		end

	end

protected

	def subject_for_assigned_for_interview_at
		subject = FactoryBot.create(:patient, :admit_date => 60.days.ago).study_subject
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
		subject.reload
	end

end
