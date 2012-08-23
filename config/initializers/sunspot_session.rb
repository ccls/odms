class Sunspot::Session
#
#	cattr_accessor :disable_commit
#
#	def commit_with_disabling
#		commit_without_disabling unless disable_commit
#	end
#	alias_method_chain :commit, :disabling
#
end
__END__

It appears that the Sunspot auto commit is just a controller after_filter.

If I understand it correctly, this works perfectly as the expensive
commit only occurs after the entire csv and all of the associated updates
have been done.
