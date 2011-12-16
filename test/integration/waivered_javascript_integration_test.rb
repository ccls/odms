require 'integration_test_helper'

class WaiveredJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest


#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

#	site_administrators.each do |cu|
	site_editors.each do |cu|

		test "should toggle specify other language when other language checked" <<
				" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
			check(language_input_id('other'))
			assert_page_has_checked_language_id('other')
			assert_other_language_visible
			uncheck(language_input_id('other'))
			assert_page_has_unchecked_language_id('other')
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
