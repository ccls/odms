require 'integration_test_helper'

class EventIntegrationTest < ActionController::CapybaraIntegrationTest

	setup :skip_operational_event_type_page_validation
	def skip_operational_event_type_page_validation
		OperationalEventTypesController.skip_after_filter :validate_page
	end

	site_administrators.each do |cu|

		test "should change event types on category change on new event with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit new_study_subject_event_path(study_subject)
			assert page.has_css?('select#category')

			assert_equal 11, page.all('select#category option').length
			# [nil,ascertainment,compensation,completions,correspondence,
			#		enrollments,interviews,operations,other,recruitment,samples]

			assert page.has_css?('select#operational_event_operational_event_type_id')
			assert_equal 1, 
				page.all('select#operational_event_operational_event_type_id option').length
			assert page.find('select#operational_event_operational_event_type_id option'
				).text.blank?

			select 'operations', :from => 'category'
sleep 1	#	sometimes the next statement is still 1
			#	now should have some options.
			#	by doing it this way, capybara 'reloads' the contents before comparison
			#	apparently 'all' does not do the same thing, and so requires a bit of waiting.
			assert_equal 6, 
				page.find('select#operational_event_operational_event_type_id'
					).all('option').length
			page.find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
					assert !option.text.blank?
					assert_match /^operations:/, option.text }

			select 'samples', :from => 'category'
sleep 1	#	sometimes the next statement is still 6
			assert_equal 3, 
				page.find('select#operational_event_operational_event_type_id'
					).all('option').length
			page.find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
					assert !option.text.blank?
					assert_match /^samples:/, option.text }
		end

		test "should change event types on category change on edit event with #{cu} login" do
			study_subject = Factory(:study_subject)
			ccls_enrollment = study_subject.enrollments.find_by_project_id(
				Project['ccls'].id)
			assert_equal 1, ccls_enrollment.operational_events.length
			event = ccls_enrollment.operational_events.first	#	new subject
			login_as send(cu)
			page.visit edit_event_path(event)
			assert page.has_css?('select#category')

			assert_equal 11, page.all('select#category option').length
			# [nil,ascertainment,compensation,completions,correspondence,
			#		enrollments,interviews,operations,other,recruitment,samples]

			event_category = event.operational_event_type.event_category
			assert_equal 'recruitment', event_category

			assert_equal event_category,
				page.find('select#category option[selected=selected]').text

			assert page.has_css?('select#operational_event_operational_event_type_id')

			assert_equal 6, 
				page.find('select#operational_event_operational_event_type_id'
					).all('option').length
			page.find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
					assert !option.text.blank?
					assert_match /^#{event_category}:/, option.text }

			select 'operations', :from => 'category'
			#	now should have some different options.
			#	by doing it this way, capybara 'reloads' the contents before comparison
			#	apparently 'all' does not do the same thing, and so requires a bit of waiting.
			assert_equal 6, 
				page.find('select#operational_event_operational_event_type_id'
					).all('option').length
			page.find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
					assert !option.text.blank?
					assert_match /^operations:/, option.text }
		end

	end

end
