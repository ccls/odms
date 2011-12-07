require 'integration_test_helper'

class WaiveredJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	def assert_other_language_visible
		assert page.has_css?("#specify_other_language", :visible => true)
		assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => true)
		assert page.has_field?("study_subject[subject_languages_attributes][2][other]")
		assert page.find_field("study_subject[subject_languages_attributes][2][other]").visible?
	end
	def assert_other_language_hidden
		assert page.has_css?("#specify_other_language", :visible => false)
		assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => false)
		assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?
	end


#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_administrators.each do |cu|

		test "should toggle specify other language when other language checked with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			#	[2] since 'other' will be the third language in the array
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert_other_language_hidden

			check("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert page.has_checked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert_other_language_visible

			uncheck("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert_other_language_hidden
		end

		test "should should update blank address info on zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_county]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_zip]").value.blank?

			fill_in "study_subject[addressings_attributes][0][address_attributes][zip]",  
				:with => "17857"
			#	I don't think that the change event get triggered correctly
			#	in the test environment.
			#
			#	This may happen as the browser
			#	actually exists and perhaps me coding while the browser is trying to
			#	test takes focus away from it?  Can I force the browser into the background?
			#
			#	maybe "change" isn't the appropriate event trigger for this?
			#	explicitly trigger the change event.
			#	If the user running the tests is using the machine,
			#	it can inhibit this test.  Don't know why.
			#	It will send a blank zip code which will result in
			#	no field updates.
#	When using capybara-webkit, this isn't necessary!  Yay!
#		If we change back to selenium, this may need uncommented.
#			page.execute_script("$('#study_subject_addressings_attributes_0_address_attributes_zip').change()" );
#			sleep 1

			assert_equal 'NORTHUMBERLAND', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value
			assert_equal 'PA', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value
			assert_equal '17857', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[patient_attributes][raf_county]").value
			assert_equal '17857', page.find_field(
				"study_subject[patient_attributes][raf_zip]").value
		end

		test "should should update blank address info on raf_zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_county]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_zip]").value.blank?

			fill_in "study_subject[patient_attributes][raf_zip]",  :with => "17857"
			#	I don't think that the change event get triggered correctly
			#	in the test environment.
			#
			#	This may happen as the browser
			#	actually exists and perhaps me coding while the browser is trying to
			#	test takes focus away from it?  Can I force the browser into the background?
			#
			#	maybe "change" isn't the appropriate event trigger for this?
			#	explicitly trigger the change event.
			#	If the user running the tests is using the machine,
			#	it can inhibit this test.  Don't know why.
			#	It will send a blank zip code which will result in
			#	no field updates.
#	When using capybara-webkit, this isn't necessary!  Yay!
#		If we change back to selenium, this may need uncommented.
#			page.execute_script("$('#study_subject_patient_attributes_raf_zip').change()" );
#			sleep 1

			assert_equal 'NORTHUMBERLAND', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value
			assert_equal 'PA', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value
			assert_equal '17857', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[patient_attributes][raf_county]").value
			assert_equal '17857', page.find_field(
				"study_subject[patient_attributes][raf_zip]").value
		end


		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert !page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
#	case sensitive? yep.
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
			select "", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert !page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
		end

	end

end
