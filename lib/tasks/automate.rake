task :automate => :environment do

	require 'csv'

	# Only send to me in development (add this to ICF also)
	def email_options 
		( Rails.env == 'development' ) ?
			{ :to => 'jakewendt@berkeley.edu' } : {}
	end   

	# gonna start asserting that everything is as expected.
	# will slow down import, but I want to make sure I get it right.
	def assert(expression,message = 'Assertion failed.')
		raise "#{message} :\n #{caller[0]}" unless expression
	end

	def assert_string_equal(a,b,field)
		assert a.to_s == b.to_s, "#{field} mismatch:#{a}:#{b}:"
	end

end
