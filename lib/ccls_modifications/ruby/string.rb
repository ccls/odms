class String
#module StringExtension	#	:nodoc:
#	def self.included(base)
#		base.instance_eval do
#			include InstanceMethods
#		end
#	end
#
#	module InstanceMethods

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

		def to_ssn
			nums = self.gsub(/\D/,'')
			#	All 0s or 9s is apparently invalid
			if( nums.length == 9 and nums !~ /(0|9){9}/ )
				"#{nums[0..2]}-#{nums[3..4]}-#{nums[5..9]}"
			else
				nil
			end
		end

#	end	#	module InstanceMethods

end	#	module StringExtension	#	:nodoc:
#String.send( :include, StringExtension )
