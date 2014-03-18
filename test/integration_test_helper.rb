require 'test_helper'
require 'capybara_integration_test_helper'

class ActionDispatch::CapybaraIntegrationTest

	#	wait_until has been removed in Capybara > 2.0
	#	effectively just a yield wrapped in a timeout
	#	Putting more logic in this.
	#	This is actually quite generic and could be put elsewhere.
	#	Although, I don't know anywhere else that I'd use it.
	#	Could add params like max delay or max tries,
	#	but this is working just great as is.
	def wait_until
		result = false
		start_time = Time.now
		count = 0
		begin
			count += 1
			result = yield
#
#			puts "Loop:#{count}:result:#{result}:"
#
		end until result || ( Time.now > ( start_time + 5.seconds ) )
		result	#	return it just in case
	end

end
