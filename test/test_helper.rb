ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'factory_test_helper'

class ActiveSupport::TestCase
	fixtures :all
end

class ActionController::TestCase
	setup :turn_https_on
end
