module StringExtension	#	:nodoc:
	def self.included(base)
		base.instance_eval do
			include InstanceMethods
		end
	end

	module InstanceMethods

		#	titleize DOES NOT PRESERVE DASHES
		#	humanize(underscore(word)).gsub(/\b('?[a-z])/) { $1.capitalize }
		#
		#	capitalize only does the first
		#	(slice(0) || chars('')).upcase + (slice(1..-1) || chars('')).downcase
		def namerize
#			self.downcase.gsub(/\b('?[a-z])/) { $1.capitalize }
#	what about O'Grady
			self.downcase.gsub(/\b([a-z])/) { $1.capitalize }
		end

	end

end	#	module StringExtension	#	:nodoc:
String.send( :include, StringExtension )
