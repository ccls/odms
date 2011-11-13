ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase

	fixtures :all

end

class ActionController::TestCase

	setup :turn_https_on

	def create_case_control_study_subject
		create_case_study_subject(
			'identifier_attributes' => { 'case_control_type' => 'C' })
	end

end
