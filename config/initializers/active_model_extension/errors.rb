module ActiveModelExtension; end
module ActiveModelExtension::Errors
	def self.included(base)
		base.extend(ClassMethods)
		base.send(:include,InstanceMethods)
	end
	module InstanceMethods

		#	deprecated in rails 3
		#	but this seems to work
		def on(attribute)
puts
puts "errors.on(#{attribute}) is gone."
puts "replace with errors.include?(#{attribute}) instead"
puts "Sorry.  Rails 3 did it."
puts
			self.include?(attribute.to_sym)	#	all keys converted to symbols?
		end


		def matching?(attribute,message)
#>> a.errors.messages[:cbc_report_found]
#=> ["is not included in the list"]
#>> a.errors.messages[:cbc_report_found].any?{|m| m.match(/include/)}
#=> true
#>> a.errors.messages[:cbc_report_found].any?{|m| m.match(/inclue/)}
#=> false
			#	all keys seem to be converted to symbols? NOT indifferent.
			self.include?(attribute.to_sym) &&
				@messages[attribute].any?{|m| m.match(/#{message.to_s}/) }
		end


		#
		#	Can't believe this doesn't exist in rails.  It has proved very beneficial.
		#
		def on_attr_and_type(attribute,type)
puts
puts "ActiveRecord::Error is gone."
puts "Therefore error.type is gone."
puts "Therefore error type is no longer directly testable."
puts "on_attr_and_type(#{attribute},#{type})"
puts "error messages:#{@messages.inspect}"
puts "Replace with some type of text match."
puts "Trying to match messages with given type."
puts "Sorry.  Rails 3 did it."
puts 
			attribute = attribute.to_s
#			return nil unless @errors.has_key?(attribute)
#			@errors[attribute].collect(&:type).include?(type)
#			return nil unless @messages.has_key?(attribute)
#			@messages[attribute].collect(&:type).include?(type)


#>> a.errors.include?(:cbc_report_found)
#=> true
#>> a.errors.messages[:cbc_report_found]
#=> ["is not included in the list"]


			if self.include?(attribute.to_sym)
#>> a.errors.messages[:cbc_report_found]
#=> ["is not included in the list"]
#>> a.errors.messages[:cbc_report_found].any?{|m| m.match(/include/)}
#=> true
#>> a.errors.messages[:cbc_report_found].any?{|m| m.match(/inclue/)}
#=> false
#				@messages[attribute].collect(&:type).include?(type)
				@messages[attribute].any?{|m| m.match(/#{type.to_s}/) }
			else
				return nil 
			end
		end
		alias_method :on_attr_and_type?, :on_attr_and_type
	end
	module ClassMethods
# This was for removing :username and :password from 
# failed session login so it wouldn't show on view
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
