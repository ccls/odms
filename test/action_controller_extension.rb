require 'action_controller'
require 'action_controller/test_case'
#$LOAD_PATH.unshift(File.dirname(__FILE__))
module ActionControllerExtension; end
require 'action_controller_extension/test_case'
require 'action_controller_extension/accessible_via_protocol'
require 'action_controller_extension/accessible_via_user'
require 'action_controller_extension/routing'
