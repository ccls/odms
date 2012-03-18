require 'active_support/core_ext/object/blank'

module ActiveModel

	# == Active Model Absence Validator
	module Validations
		class CompleteDateValidator < EachValidator
			def validate(record)
				[attributes].flatten.each do |attribute|

#
#	This doesn't work for DateTimes
#

					value = record.send("#{attribute}_before_type_cast")
					unless( options[:allow_nil] && value.nil? ) ||
						( options[:allow_blank] && value.blank? ) ||
						( !value.is_a?(String) )
						date_hash = Date._parse(value)
						#	>> Date._parse( '1/10/2011')
						#	=> {:mon=>1, :year=>2011, :mday=>10}
						unless date_hash.has_key?(:year) &&
							date_hash.has_key?(:mon) &&
							date_hash.has_key?(:mday)
#							record.errors.add(attribute, "is not a complete date.", options)
							#	associated default error message is in config/locales/en.yml
							record.errors.add(attribute, :incomplete_date, options)
						end
					end
				end
			end
		end


		module HelperMethods
			# Validates that the specified attributes are not blank (as defined by Object#blank?). Happens by default on save. Example:
			#
			#	 class Person < ActiveRecord::Base
			#		 validates_complete_date_for :dob
			#	 end
			#
			# The first_name attribute must be in the object and it cannot be blank.
			#
			# If you want to validate the absence of a boolean field (where the real values are true and false),
			# you will want to use <tt>validates_inclusion_of :field_name, :in => [true, false]</tt>.
			#
			# This is due to the way Object#blank? handles boolean values: <tt>false.blank? # => true</tt>.
			#
			# Configuration options:
			# * <tt>:message</tt> - A custom error message (default is: "can't be blank").
			# * <tt>:on</tt> - Specifies when this validation is active. Runs in all
			#	 validation contexts by default (+nil+), other options are <tt>:create</tt>
			#	 and <tt>:update</tt>.
			# * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
			#	 occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>).
			#	 The method, proc or string should return or evaluate to a true or false value.
			# * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
			#	 not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>).
			#	 The method, proc or string should return or evaluate to a true or false value.
			# * <tt>:strict</tt> - Specifies whether validation should be strict. 
			#	 See <tt>ActiveModel::Validation#validates!</tt> for more information
			#
			def validates_complete_date_for(*attr_names)
				validates_with CompleteDateValidator, _merge_attributes(attr_names)
			end
		end
	end
end


#
#	Basically I copied the "presence" validator and inverted it.
#	Is this better than before?  Doubt it.  Actually seems like a whole lot of extra.
#	Nevertheless, the old version doesn't seem to work in Rails 3.
#	Let's see if this one does. I am curious as to what I need to do to load this
#	as I'm not sure that this'll make it all the way down to ActiveRecord.
#	Should be obvious and raise a method_missing if it doesn't.
#
#	If it does, I'll have to do the same for "complete_date" and "past_date"
#
#	Seems to work.
#




