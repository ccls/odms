require 'integration_test_helper'

class EventIntegrationTest < ActionDispatch::CapybaraIntegrationTest

	setup :skip_operational_event_type_page_validation
	def skip_operational_event_type_page_validation
		OperationalEventTypesController.skip_after_filter :validate_page
	end

	site_administrators.each do |cu|

		test "should change event types on category change on new event with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			visit new_study_subject_event_path(study_subject)
			assert has_css?('select#category')

			assert_equal 12, all('select#category option').length
			# [nil,ascertainment,compensation,completions,correspondence,
#	20120514 - added 'errors'
			#		enrollments,interviews,operations,other,recruitment,samples]

			assert has_css?('select#operational_event_operational_event_type_id')
			assert_equal 1, 
				all('select#operational_event_operational_event_type_id option').length
			assert find('select#operational_event_operational_event_type_id option'
				).text.blank?

			#	on load it does have this css (invalid html without) so we can't use it to test
			#assert	!has_css?('select#operational_event_operational_event_type_id option')

			select 'operations', :from => 'category'

			wait_until { 
				all('select#operational_event_operational_event_type_id option').length > 1 }
#				!find('select#operational_event_operational_event_type_id option'
#				).text.blank? }

			#	now should have some options.
			#	by doing it this way, capybara 'reloads' the contents before comparison
			#	apparently 'all' does not do the same thing, and so requires a bit of waiting.
#	20120514 - added 'operations:birthDataReceived'
#	20120810 - added 'errors:dataconflict'
#	20130320 - added 2 'operations:*' medical record requested & received
			assert_equal 10, 
				find('select#operational_event_operational_event_type_id'
					).all('option').length
			find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
#					assert !option.text.blank?
					assert option.text.present?
					assert_match /^operations:/, option.text }

			#	select nothing so can test if cleared
			#	and can then test not cleared again.
			#	selecting nothing will trigger the loading of nothing in the selector
			select '', :from => 'category'
			wait_until { 
				find('select#operational_event_operational_event_type_id'
					).all('option').length == 0
			}
			assert !has_css?('select#operational_event_operational_event_type_id option')

			select 'samples', :from => 'category'

			wait_until { 
				has_css?('select#operational_event_operational_event_type_id option') }
			assert	has_css?('select#operational_event_operational_event_type_id option')

			assert_equal 3, 
				find('select#operational_event_operational_event_type_id'
					).all('option').length
			find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
#					assert !option.text.blank?
					assert option.text.present?
					assert_match /^samples:/, option.text }
		end

		test "should change event types on category change on edit event with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			events = study_subject.operational_events.where(
				:project_id => Project['ccls'].id)
			assert_equal 1, events.length
			event = events.first	#	new subject
			login_as send(cu)
			visit edit_study_subject_event_path(study_subject,event)
			assert has_css?('select#category')

			assert_equal 12, all('select#category option').length
			# [nil,ascertainment,compensation,completions,correspondence,
#	20120514 - added 'errors'
			#		enrollments,interviews,operations,other,recruitment,samples]

			event_category = event.operational_event_type.event_category
			assert_equal 'recruitment', event_category

			assert_equal event_category,
				find('select#category option[selected=selected]').text

			assert has_css?('select#operational_event_operational_event_type_id')

			assert_equal 6, 
				find('select#operational_event_operational_event_type_id'
					).all('option').length
			find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
#					assert !option.text.blank?
					assert option.text.present?
					assert_match /^#{event_category}:/, option.text }

			#	select nothing so can test if cleared
			#	and can then test not cleared again.
			#	selecting nothing will trigger the loading of nothing in the selector
			select '', :from => 'category'
			wait_until { 
				find('select#operational_event_operational_event_type_id'
					).all('option').length == 0
			}
			assert !has_css?('select#operational_event_operational_event_type_id option')

			select 'operations', :from => 'category'
			wait_until { 
				has_css?('select#operational_event_operational_event_type_id option') }

			#	now should have some different options.
			#	by doing it this way, capybara 'reloads' the contents before comparison
			#	apparently 'all' does not do the same thing, and so requires a bit of waiting.
#	20120514 - added 'operations:birthDataReceived'
#	20120810 - added 'errors:dataconflict'
#	20130320 - added 2 'operations:*' medical record requested & received
			assert_equal 10, 
				find('select#operational_event_operational_event_type_id'
					).all('option').length
			find('select#operational_event_operational_event_type_id'
				).all('option').each { |option|
#					assert !option.text.blank?
					assert option.text.present?
					assert_match /^operations:/, option.text }
		end

	end

end
