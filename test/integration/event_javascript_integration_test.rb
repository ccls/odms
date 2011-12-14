require 'integration_test_helper'

class EventJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	def setup
		super
		OperationalEventTypesController.skip_after_filter :validate_page
	end

	site_editors.each do |cu|

		test "should get new study_subject event with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit new_study_subject_event_path(study_subject)
			assert page.has_css?('select#category')

			assert_equal 11, page.all('select#category option').length
# [nil,ascertainment,compensation,completions,correspondence,enrollments,interviews,operations,other,recruitment,samples]

			assert page.has_css?('select#operational_event_operational_event_type_id')
			assert_equal 1, 
				page.all('select#operational_event_operational_event_type_id option').length
			assert page.find('select#operational_event_operational_event_type_id option').text.blank?

			select 'operations', :from => 'category'
			sleep 2	#	give ajax a couple seconds to actually do its thing

			#	now has some options.  Yay!
			page.all('select#operational_event_operational_event_type_id option').each do |option|
				assert !option.text.blank?
			end
			assert_equal 8, 
				page.all('select#operational_event_operational_event_type_id option').length
		end

	end

end
