class Sunspot::Session
#	Sunspot.commit just calls session.commit
#	Sunspot is a MODULE not a CLASS
#module Sunspot
#class << self

#	This works in the session, but can't get it to go in just Sunspot so ...
	def commit_with_disabling
#puts "DISABLED!"
#	wrap this in some type of check and away we go
		commit_without_disabling
	end
	alias_method_chain :commit, :disabling
#end
end
