module ActiveRecord
	module Querying
		#	This makes it available as the first call
		delegate :left_joins, :to => :scoped
	end	#	module Querying
end	#	module ActiveRecord
