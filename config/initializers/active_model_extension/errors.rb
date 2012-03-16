module ActiveModelExtension; end
module ActiveModelExtension::Errors
	def self.included(base)
		base.extend(ClassMethods)
		base.send(:include,InstanceMethods)
	end
	module InstanceMethods
		#
		#	Can't believe this doesn't exist in rails.  It has proved very beneficial.
		#
		def on_attr_and_type(attribute,type)
			attribute = attribute.to_s
#			return nil unless @errors.has_key?(attribute)
#			@errors[attribute].collect(&:type).include?(type)
			return nil unless @messages.has_key?(attribute)
			@messages[attribute].collect(&:type).include?(type)
		end
		alias_method :on_attr_and_type?, :on_attr_and_type
	end
	module ClassMethods
#		def delete(key)
#			@errors.delete(key.to_s)
#		end
	end
end	#	ActiveModelExtension::Errors


#	TODO Removed for rails 3
#
#	Due to the apparent fact that Rails3 does not use the :type,
#	this is now unfortunately pointless.  If true many of my tests
#	are also pointless.  VERY UNFORTUNATE.

ActiveModel::Errors.send(:include,ActiveModelExtension::Errors)
