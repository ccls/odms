require 'integration_test_helper'

class WaiveredJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

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
			
			page.execute_script("$('#study_subject_addressings_attributes_0_address_attributes_zip').change()" );
			sleep 1

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
			page.execute_script("$('#study_subject_patient_attributes_raf_zip').change()" );
			sleep 1

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
			assert page.has_field?(
				'study_subject[patient_attributes][other_diagnosis]', :visible => false)
#	case sensitive? yep.
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.has_field?(
				'study_subject[patient_attributes][other_diagnosis]', :visible => true)
			select "", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.has_field?(
				'study_subject[patient_attributes][other_diagnosis]', :visible => false)
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.has_field?(
				'study_subject[patient_attributes][other_diagnosis]', :visible => true)
		end

	end

end
