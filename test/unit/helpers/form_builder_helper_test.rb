require 'test_helper'

#	Use a name that is unique to this test!
class FBModel
	extend ActiveModel::Naming
	attr_accessor :some_attribute

	#	for date_text_field and datetime_text_field validation
	attr_accessor :some_attribute_before_type_cast 

	attr_accessor :yes_or_no, :int_field
	def to_key
	end
	def initialize(*args,&block)
		yield self if block_given?
	end
	def yes_or_no?
		!!yes_or_no
	end
	def errors
		[]
	end
end

class FormBuilderHelperTest < ActionView::TestCase

	#	needed to include field_wrapper ( I think )
	include CommonLib::ActionViewExtension::Base

end	#	class FormBuilderHelperTest < ActionView::TestCase
