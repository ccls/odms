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

#	test "yndk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.yndk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="999">Don&#x27;t Know</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#	test "wrapped_yndk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_yndk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field yndk_select field_wrapper'>
#<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="999">Don&#x27;t Know</option></select>
#</div><!-- class='int_field yndk_select' --></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#
#	test "ynrdk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.ynrdk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="999">Don&#x27;t Know</option>
#<option value="888">Refused</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#	test "wrapped_ynrdk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_ynrdk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field ynrdk_select field_wrapper'>
#<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="999">Don&#x27;t Know</option>
#<option value="888">Refused</option></select>
#</div><!-- class='int_field ynrdk_select' --></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#	test "ynodk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.ynodk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="3">Other</option>
#<option value="999">Don&#x27;t Know</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#	test "wrapped_ynodk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_ynodk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field ynodk_select field_wrapper'>
#<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="3">Other</option>
#<option value="999">Don&#x27;t Know</option></select>
#</div><!-- class='int_field ynodk_select' --></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "ynordk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.ynordk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="3">Other</option>
#<option value="999">Don&#x27;t Know</option>
#<option value="888">Refused</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#	test "wrapped_ynordk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_ynordk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field ynordk_select field_wrapper'>
#<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Yes</option>
#<option value="2">No</option>
#<option value="3">Other</option>
#<option value="999">Don&#x27;t Know</option>
#<option value="888">Refused</option></select>
#</div><!-- class='int_field ynordk_select' --></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#	test "padk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.padk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Present</option>
#<option value="2">Absent</option>
#<option value="999">Don&#x27;t Know</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "adna_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.adna_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Agree</option>
#<option value="2">Do Not Agree</option>
#<option value="555">N/A</option>
#<option value="999">Don&#x27;t Know</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
##	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors
#
#	test "wrapped_padk_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_padk_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field padk_select field_wrapper'>
#<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Present</option>
#<option value="2">Absent</option>
#<option value="999">Don&#x27;t Know</option></select>
#</div><!-- class='int_field padk_select' --></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "wrapped_adna_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_adna_select(:int_field) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field adna_select field_wrapper'>
#<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
#<option value="1">Agree</option>
#<option value="2">Do Not Agree</option>
#<option value="555">N/A</option>
#<option value="999">Don&#x27;t Know</option></select>
#</div><!-- class='int_field adna_select' --></form>}
#		assert_equal expected, output_buffer
#	end

end	#	class FormBuilderHelperTest < ActionView::TestCase
