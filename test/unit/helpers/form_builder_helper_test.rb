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

#class ActionViewExtension::FormBuilderTest < ActionView::TestCase
class FormBuilderHelperTest < ActionView::TestCase

	#	needed for field_wrapper
	include ApplicationHelper

	test "yndk_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.yndk_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don&#x27;t Know</option></select></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "wrapped_yndk_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_yndk_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field yndk_select field_wrapper'>
<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don&#x27;t Know</option></select>
</div><!-- class='int_field yndk_select' --></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors


	test "ynrdk_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.ynrdk_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don&#x27;t Know</option>
<option value="888">Refused</option></select></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "wrapped_ynrdk_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_ynrdk_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field ynrdk_select field_wrapper'>
<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don&#x27;t Know</option>
<option value="888">Refused</option></select>
</div><!-- class='int_field ynrdk_select' --></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "ynodk_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.ynodk_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="3">Other</option>
<option value="999">Don&#x27;t Know</option></select></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "wrapped_ynodk_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_ynodk_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field ynodk_select field_wrapper'>
<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="3">Other</option>
<option value="999">Don&#x27;t Know</option></select>
</div><!-- class='int_field ynodk_select' --></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "adna_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.adna_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Agree</option>
<option value="2">Do Not Agree</option>
<option value="555">N/A</option>
<option value="999">Don&#x27;t Know</option></select></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "wrapped_adna_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_adna_select(:int_field) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='int_field adna_select field_wrapper'>
<label for="fb_model_int_field">Int field</label><select id="fb_model_int_field" name="fb_model[int_field]"><option value=""></option>
<option value="1">Agree</option>
<option value="2">Do Not Agree</option>
<option value="555">N/A</option>
<option value="999">Don&#x27;t Know</option></select>
</div><!-- class='int_field adna_select' --></form>}
		assert_equal expected, output_buffer
	end

#	rails 3.2.8 now html_escapes ' to &#x27; in these input selectors

	test "sex_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.sex_select(:some_attribute) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">-select-</option>
<option value="M">male</option>
<option value="F">female</option>
<option value="DK">don&#x27;t know</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_sex_select" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_sex_select(:some_attribute) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='some_attribute sex_select field_wrapper'>
<label for="fb_model_some_attribute">Some attribute</label><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">-select-</option>
<option value="M">male</option>
<option value="F">female</option>
<option value="DK">don&#x27;t know</option></select>
</div><!-- class='some_attribute sex_select' --></form>}
		assert_equal expected, output_buffer
	end

	test "datetime_text_field" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.datetime_text_field(:some_attribute) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><input class="datetimepicker" id="fb_model_some_attribute" name="fb_model[some_attribute]" size="30" type="text" /></form>}
		assert_equal expected, output_buffer
	end

	test "datetime_text_field with value" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.datetime_text_field(:some_attribute, :value => 'sometestvalue' ) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><input class="datetimepicker" id="fb_model_some_attribute" name="fb_model[some_attribute]" size="30" type="text" value="sometestvalue" /></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_datetime_text_field" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_datetime_text_field(:some_attribute) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='some_attribute datetime_text_field field_wrapper'>
<label for="fb_model_some_attribute">Some attribute</label><input class="datetimepicker" id="fb_model_some_attribute" name="fb_model[some_attribute]" size="30" type="text" />
</div><!-- class='some_attribute datetime_text_field' --></form>}
		assert_equal expected, output_buffer
	end

	test "date_text_field" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.date_text_field(:some_attribute) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><input class="datepicker" id="fb_model_some_attribute" name="fb_model[some_attribute]" size="30" type="text" /></form>}
		assert_equal expected, output_buffer
	end

	test "date_text_field with value" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.date_text_field(:some_attribute, :value => 'sometestvalue') }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><input class="datepicker" id="fb_model_some_attribute" name="fb_model[some_attribute]" size="30" type="text" value="sometestvalue" /></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_date_text_field" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_date_text_field(:some_attribute) }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='some_attribute date_text_field field_wrapper'>
<label for="fb_model_some_attribute">Some attribute</label><input class="datepicker" id="fb_model_some_attribute" name="fb_model[some_attribute]" size="30" type="text" />
</div><!-- class='some_attribute date_text_field' --></form>}
		assert_equal expected, output_buffer
	end

	#	This isn't in an 'erb block' so it isn't really testing what I wanted.
	test "wrapped_date_text_field with block" do
		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_date_text_field(:some_attribute){ 'testing' } }
		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='some_attribute date_text_field field_wrapper'>
<label for="fb_model_some_attribute">Some attribute</label><input class="datepicker" id="fb_model_some_attribute" name="fb_model[some_attribute]" size="30" type="text" />testing
</div><!-- class='some_attribute date_text_field' --></form>}
		assert_equal expected, output_buffer
	end

#	test "meridiem_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.meridiem_select(:some_attribute) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">Meridiem</option>
#<option value="AM">AM</option>
#<option value="PM">PM</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "wrapped_meridiem_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_meridiem_select(:some_attribute) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='some_attribute meridiem_select field_wrapper'>
#<label for="fb_model_some_attribute">Some attribute</label><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">Meridiem</option>
#<option value="AM">AM</option>
#<option value="PM">PM</option></select>
#</div><!-- class='some_attribute meridiem_select' --></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "minute_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.minute_select(:some_attribute) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">Minute</option>
#<option value="0">00</option>
#<option value="1">01</option>
#<option value="2">02</option>
#<option value="3">03</option>
#<option value="4">04</option>
#<option value="5">05</option>
#<option value="6">06</option>
#<option value="7">07</option>
#<option value="8">08</option>
#<option value="9">09</option>
#<option value="10">10</option>
#<option value="11">11</option>
#<option value="12">12</option>
#<option value="13">13</option>
#<option value="14">14</option>
#<option value="15">15</option>
#<option value="16">16</option>
#<option value="17">17</option>
#<option value="18">18</option>
#<option value="19">19</option>
#<option value="20">20</option>
#<option value="21">21</option>
#<option value="22">22</option>
#<option value="23">23</option>
#<option value="24">24</option>
#<option value="25">25</option>
#<option value="26">26</option>
#<option value="27">27</option>
#<option value="28">28</option>
#<option value="29">29</option>
#<option value="30">30</option>
#<option value="31">31</option>
#<option value="32">32</option>
#<option value="33">33</option>
#<option value="34">34</option>
#<option value="35">35</option>
#<option value="36">36</option>
#<option value="37">37</option>
#<option value="38">38</option>
#<option value="39">39</option>
#<option value="40">40</option>
#<option value="41">41</option>
#<option value="42">42</option>
#<option value="43">43</option>
#<option value="44">44</option>
#<option value="45">45</option>
#<option value="46">46</option>
#<option value="47">47</option>
#<option value="48">48</option>
#<option value="49">49</option>
#<option value="50">50</option>
#<option value="51">51</option>
#<option value="52">52</option>
#<option value="53">53</option>
#<option value="54">54</option>
#<option value="55">55</option>
#<option value="56">56</option>
#<option value="57">57</option>
#<option value="58">58</option>
#<option value="59">59</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "wrapped_minute_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_minute_select(:some_attribute) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='some_attribute minute_select field_wrapper'>
#<label for="fb_model_some_attribute">Some attribute</label><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">Minute</option>
#<option value="0">00</option>
#<option value="1">01</option>
#<option value="2">02</option>
#<option value="3">03</option>
#<option value="4">04</option>
#<option value="5">05</option>
#<option value="6">06</option>
#<option value="7">07</option>
#<option value="8">08</option>
#<option value="9">09</option>
#<option value="10">10</option>
#<option value="11">11</option>
#<option value="12">12</option>
#<option value="13">13</option>
#<option value="14">14</option>
#<option value="15">15</option>
#<option value="16">16</option>
#<option value="17">17</option>
#<option value="18">18</option>
#<option value="19">19</option>
#<option value="20">20</option>
#<option value="21">21</option>
#<option value="22">22</option>
#<option value="23">23</option>
#<option value="24">24</option>
#<option value="25">25</option>
#<option value="26">26</option>
#<option value="27">27</option>
#<option value="28">28</option>
#<option value="29">29</option>
#<option value="30">30</option>
#<option value="31">31</option>
#<option value="32">32</option>
#<option value="33">33</option>
#<option value="34">34</option>
#<option value="35">35</option>
#<option value="36">36</option>
#<option value="37">37</option>
#<option value="38">38</option>
#<option value="39">39</option>
#<option value="40">40</option>
#<option value="41">41</option>
#<option value="42">42</option>
#<option value="43">43</option>
#<option value="44">44</option>
#<option value="45">45</option>
#<option value="46">46</option>
#<option value="47">47</option>
#<option value="48">48</option>
#<option value="49">49</option>
#<option value="50">50</option>
#<option value="51">51</option>
#<option value="52">52</option>
#<option value="53">53</option>
#<option value="54">54</option>
#<option value="55">55</option>
#<option value="56">56</option>
#<option value="57">57</option>
#<option value="58">58</option>
#<option value="59">59</option></select>
#</div><!-- class='some_attribute minute_select' --></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "hour_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.hour_select(:some_attribute) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">Hour</option>
#<option value="1">1</option>
#<option value="2">2</option>
#<option value="3">3</option>
#<option value="4">4</option>
#<option value="5">5</option>
#<option value="6">6</option>
#<option value="7">7</option>
#<option value="8">8</option>
#<option value="9">9</option>
#<option value="10">10</option>
#<option value="11">11</option>
#<option value="12">12</option></select></form>}
#		assert_equal expected, output_buffer
#	end
#
#	test "wrapped_hour_select" do
#		output_buffer = form_for(FBModel.new,:url => '/'){|f| f.wrapped_hour_select(:some_attribute) }
#		expected = %{<form accept-charset="UTF-8" action="/" class="new_fb_model" id="new_fb_model" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div class='some_attribute hour_select field_wrapper'>
#<label for="fb_model_some_attribute">Some attribute</label><select id="fb_model_some_attribute" name="fb_model[some_attribute]"><option value="">Hour</option>
#<option value="1">1</option>
#<option value="2">2</option>
#<option value="3">3</option>
#<option value="4">4</option>
#<option value="5">5</option>
#<option value="6">6</option>
#<option value="7">7</option>
#<option value="8">8</option>
#<option value="9">9</option>
#<option value="10">10</option>
#<option value="11">11</option>
#<option value="12">12</option></select>
#</div><!-- class='some_attribute hour_select' --></form>}
#		assert_equal expected, output_buffer
#	end

end	#	class FormBuilderHelperTest < ActionView::TestCase
#end	#	class ActionViewExtension::FormBuilderTest < ActionView::TestCase
