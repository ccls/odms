ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'simply_authorized_factory_test_helper'
require 'factory_test_helper'
require 'calnet_authenticated_test_helper'
require 'ccls_assertions'

#	These are not automatically included as they
#		contain duplicate methods names.
#	They must be explicitly included in the test classes
#		that use them.
require 'icf_master_tracker_update_test_helper'
require 'live_birth_data_update_test_helper'

class ActiveSupport::TestCase

	fixtures :all

end

class ActionController::TestCase

	setup :turn_https_on

end
