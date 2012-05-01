ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'active_model_extension'
require 'action_controller_extension'
require 'active_support_extension'
require 'factory_test_helper'

require 'partial_abstract_controller_test_helper'

#	These are not automatically included as they
#		contain duplicate methods names.
#	They must be explicitly included in the test classes
#		that use them.
require 'icf_master_tracker_update_test_helper'
require 'birth_data_update_test_helper'

class ActiveSupport::TestCase

	fixtures :all

end

class ActionController::TestCase

#
#	Don't think that I need this with force_ssl
#
#	setup :turn_https_on

end

def brand	#	for auto-generated tests
	"@@ "
end
