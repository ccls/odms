require 'simplecov_test_helper'	#	should be first for some reason

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'test_helper_helper'

require 'active_model_extension'
require 'action_controller_extension'
require 'active_support_extension'

require 'factory_test_helper'
require 'partial_abstract_controller_test_helper'

#	These are not automatically included as they
#		contain duplicate methods names.
#	They must be explicitly included in the test classes
#		that use them.
#	I'd like to uniqify these so that they aren't special
require 'icf_master_tracker_update_test_helper'
require 'birth_datum_update_test_helper'

class ActiveSupport::TestCase

	fixtures :all

end

def brand	#	for auto-generated tests
	"@@ "
end
