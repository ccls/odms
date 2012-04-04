module ObjectExtension	#	:nodoc:
	def self.included(base)
		base.instance_eval do
			include InstanceMethods
		end
	end

	module InstanceMethods

#		def to_boolean
##			return [true, 'true', 1, '1', 't'].include?(
#			return ![nil, false, 'false', 0, '0', 'f'].include?(
#				( self.is_a?(String) ) ? self.downcase : self )
#		end
#
#		#	looking for an explicit true
#		def true?
#			return [true, 'true', 1, '1', 't'].include?(
#				( self.is_a?(String) ) ? self.downcase : self )
#		end
#
#		#	looking for an explicit false (not nil)
#		def false?
#			return [false, 'false', 0, '0', 'f'].include?(
#				( self.is_a?(String) ) ? self.downcase : self )
#		end

	end

end
Object.send(:include, ObjectExtension)
