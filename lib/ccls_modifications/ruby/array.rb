class Array
#module ArrayExtension	#	:nodoc:
#	def self.included(base)
##	instance_eval????
##	why not just include
#		base.instance_eval do
#			include InstanceMethods
#		end
##		base.send(:include, InstanceMethods)
#	end
#
#	module InstanceMethods

#		def to_boolean
#			!empty? && all?{|v| v.to_boolean }
#		end
##		alias_method :true?, :to_boolean
#		alias_method :to_b,  :to_boolean
#
#		#	[].true? 
#		#	=> false
#		#	[true].true? 
#		#	=> true
#		#	[true,false].true? 
#		#	=> true
#		#	[false].true? 
#		#	=> false
#		def true?
#			!empty? && any?{|v| v.true? }
#		end
#
#		def false?
#			!empty? && any?{|v| v.false? }
#		end
#

#
#	WAS used in StudySubjectSearch
#
#		#	I need to work on this one ...
#		def true_xor_false?
##			self.include?('true') ^ self.include?('false') ^
##				self.include?(true) ^ self.include?(false)
#			contains_true = contains_false = false
#			each {|v|
##				( v.to_boolean ) ? contains_true = true : contains_false = true
#				eval("contains_#{v.to_boolean}=true")
#			}
#			contains_true ^ contains_false
#		end


#	end
end
#Array.send(:include, ArrayExtension)
