#	separated out this so could modify without 
#	always restarting all the tests.
require 'simplecov'
SimpleCov.start 'rails' do
	add_filter 'lib/method_missing_with_authorization.rb'
	add_filter 'lib/ucb_ldap-1.4.2'
end

#
#	I would really like to figure out how to include the views!
#
