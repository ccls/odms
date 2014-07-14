require 'integration_test_helper'

class ControlIntegrationTest < ActionDispatch::CapybaraIntegrationTest

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
			visit controls_path
			assert_equal current_path, controls_path
			assert has_css?("form[action='#{assign_selected_for_interview_controls_path}']")
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




#	after the click, the page loads html and then csv.
#	old versions of capybara would test the html with this, but new one use csv and it fails.
			assert has_css?(   "div#content > script")





			#	page.body is the html portion (body is an alias to html in Capybara::Session)
			#	page.source looks like the html as well
			#	page.text is somehow different (the csv, but has lost the carriage returns?)


#{"Content-Disposition"=>"attachment; filename=newcases_06102013.csv", "Content-Type"=>"text/csv; charset=utf-8", "X-Ua-Compatible"=>"IE=Edge,chrome=1", "Etag"=>"\"94e35996cc54a770506bd3e78661f434\"", "Cache-Control"=>"max-age=0, private, must-revalidate", "X-Request-Id"=>"7db0f7f5f75242967de43b968b7cbb57", "X-Runtime"=>"0.023621", "Server"=>"WEBrick/1.3.1 (Ruby/1.9.3/2013-05-15)", "Date"=>"Mon, 10 Jun 2013 19:09:50 GMT", "Content-Length"=>"451", "Connection"=>"Keep-Alive"}

#ControlIntegrationTest#test_should_render_html_and_trigger_csv_download_on_assigned_for_interview_at_with_superuser_login [test/integration/control_integration_test.rb:55]:
#Expected 'text/csv; charset=utf-8' to match text/csv.
#Expected /text\/csv/ to match "text/html; charset=utf-8".

#	I don't understand the above?
#	or below?  The hash says its for html, but when the key is extracted it is csv?

#Control Integration should render html and trigger csv download on assigned_for_interview_at with superuser login: {"X-Frame-Options"=>"SAMEORIGIN", "X-Xss-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "Content-Type"=>"text/html; charset=utf-8", "Etag"=>"\"582541e52c0e3984a9c3bca1f7ae3608\"", "Cache-Control"=>"max-age=0, private, must-revalidate", "X-Request-Id"=>"f8be16af-89a3-4386-9263-a1b7b8d74043", "X-Runtime"=>"0.842865", "Server"=>"WEBrick/1.3.1 (Ruby/2.0.0/2014-05-08)", "Date"=>"Fri, 11 Jul 2014 22:57:21 GMT", "Content-Length"=>"5670", "Connection"=>"Keep-Alive", "Set-Cookie"=>"_odms_session=RlIyT1QrVDB2MStlTGRVWFdXMTc2Mys4Sy9EeXBuZjVLUnRrUVNTYmtMZiszakFSc1hIa3cwUWppL2NVbmplKzJpejhSRSswdmZ1WkVQbFRBaGNEQUd0Rm9EUDUwVWRaV2VDdTF5dGhJZklmR3llekZFZzNaVVVnOGg0OEo5L0ZMdU11R0lIUkdPeGtORmE1SEpqVG1KR1ZGaisrZWpLNzhkbEpodDBRNzJhVy83TGxVTkxzSkduVGM5NWdaeTk5aWJDRUFjUGJxNFViWk41bXVrNDVXWTczSFRIZk5jSnM2ak0vT2R5N09VTUlOUXpYL2szSTI5WHBRLzc3T2w1K2dnRGJVLzV2QmhZeHNLbENQUGJRV0E9PS0tWUd5TzFkUTFrUlhYb2F0ZFdybU5Vdz09--d75d8f2c7ecfd016b31089c702ace8ba15581ca6; path=/; HttpOnly"}
#text/csv; charset=utf-8
#attachment; filename=newcontrols_07112014.csv


#	now I'm really confused.  Its both?
#Control Integration should render html and trigger csv download on assigned_for_interview_at with superuser login: text/html; charset=utf-8
#attachment; filename=newcontrols_07112014.csv


#puts page.response_headers.inspect

			#	it seems that one must call the method alone first before testing any of the keys?
#			assert_not_nil page.response_headers
#puts page.response_headers.inspect

			myhtml1 = page.response_headers
			myhtml = page.response_headers
			mycsv = page.response_headers

			assert_equal myhtml, myhtml1

			assert_match /text\/csv/, mycsv['Content-Type'],
				"Expected '#{mycsv['Content-Type']}' to match text/csv"
			assert_match /attachment; filename=newcontrols_.*csv/, mycsv['Content-Disposition'],
				"Expected '#{mycsv['Content-Disposition']}' to match newcontrols*csv"

			csv = page.text
			csv_lines = csv.sub!(/\s+/,"\n").split("\n")
			assert_equal csv_lines[0], "reference_date,case_icfmasterid,icf_master_id,mom_icfmasterid,mother_first_name,mother_maiden_name,mother_last_name,mother_ssn,father_first_name,father_last_name,father_ssn,first_name,middle_name,last_name,dob,sex,vital_status,do_not_contact,is_eligible,consented,comments,language,street,unit,city,state,zip,phone,alternate_phone"
			
#puts csv_lines[1]
#,[No Case Subject],[no ID assigned],[No Mother Subject],,,,,,,,,,,07/10/1995,F,Living,false,,,,,,,,,,,

#	no reference_date for generic control
			#	reference_date is FIRST so NO LEADING COMMA!!!!
#			assert_match /^#{subject1.reference_date.strftime("%m/%d/%Y")},/, csv_lines[1],
#				"Expected csv to match subject 1's reference date:#{subject1.reference_date.strftime("%m/%d/%Y")}:"
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
		subject = FactoryGirl.create(:control_study_subject)
		assert_nil subject.enrollments.where(
			:project_id => Project[:ccls].id).first.assigned_for_interview_at
		subject
	end

end
