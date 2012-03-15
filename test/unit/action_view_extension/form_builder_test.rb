require 'test_helper'

class SomeModel
	attr_accessor :some_attribute
	attr_accessor :some_attribute_before_type_cast #	for date_text_field validation
	attr_accessor :yes_or_no, :int_field
	def initialize(*args,&block)
		yield self if block_given?
	end
	def yes_or_no?
		!!yes_or_no
	end
end

class ActionViewExtension::FormBuilderTest < ActionView::TestCase

	#	needed for field_wrapper
	include ActionViewExtension::Base

#	setting template no longer needed as do not have methods in base and form_builder with the same name
#	form_for(:some_model,@some_model,ActionView::Base.new,:url => '/'){|f| concat f.a_d_na_select(:adna) }
#	despite form_for accepting template as the third argument, fields_for does not actually use it.
#		It uses self, which in this case is this test class Ccls::ActionViewExtension::FormBuilderTest
#		which already has a method named a_d_na_select which causes ...
#		ArgumentError: wrong number of arguments (4 for 3)
#	Stubbing does not fix this as it is an instance variable.
#		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
##			f.instance_variable_set('@template',ActionView::Base.new)	#	fake the funk
#			concat f.y_n_dk_select(:yndk) }

	test "yndk_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.yndk_select(:int_field) }
		expected = %{<form action="/" method="post"><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don't Know</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_yndk_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_yndk_select(:int_field) }
		expected = %{<form action="/" method="post"><div class='int_field yndk_select field_wrapper'>
<label for="some_model_int_field">Int field</label><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don't Know</option></select>
</div><!-- class='int_field yndk_select' --></form>}
		assert_equal expected, output_buffer
	end


	test "ynrdk_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.ynrdk_select(:int_field) }
		expected = %{<form action="/" method="post"><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don't Know</option>
<option value="888">Refused</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_ynrdk_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_ynrdk_select(:int_field) }
		expected = %{<form action="/" method="post"><div class='int_field ynrdk_select field_wrapper'>
<label for="some_model_int_field">Int field</label><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="999">Don't Know</option>
<option value="888">Refused</option></select>
</div><!-- class='int_field ynrdk_select' --></form>}
		assert_equal expected, output_buffer
	end

	test "ynodk_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.ynodk_select(:int_field) }
		expected = %{<form action="/" method="post"><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="3">Other</option>
<option value="999">Don't Know</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_ynodk_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_ynodk_select(:int_field) }
		expected = %{<form action="/" method="post"><div class='int_field ynodk_select field_wrapper'>
<label for="some_model_int_field">Int field</label><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Yes</option>
<option value="2">No</option>
<option value="3">Other</option>
<option value="999">Don't Know</option></select>
</div><!-- class='int_field ynodk_select' --></form>}
		assert_equal expected, output_buffer
	end

	test "adna_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.adna_select(:int_field) }
		expected = %{<form action="/" method="post"><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Agree</option>
<option value="2">Do Not Agree</option>
<option value="555">N/A</option>
<option value="999">Don't Know</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_adna_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_adna_select(:int_field) }
		expected = %{<form action="/" method="post"><div class='int_field adna_select field_wrapper'>
<label for="some_model_int_field">Int field</label><select id="some_model_int_field" name="some_model[int_field]"><option value=""></option>
<option value="1">Agree</option>
<option value="2">Do Not Agree</option>
<option value="555">N/A</option>
<option value="999">Don't Know</option></select>
</div><!-- class='int_field adna_select' --></form>}
		assert_equal expected, output_buffer
	end

	test "sex_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.sex_select(:some_attribute) }
		expected = %{<form action="/" method="post"><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">-select-</option>
<option value="M">male</option>
<option value="F">female</option>
<option value="DK">don't know</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_sex_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_sex_select(:some_attribute) }
		expected = %{<form action="/" method="post"><div class='some_attribute sex_select field_wrapper'>
<label for="some_model_some_attribute">Some attribute</label><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">-select-</option>
<option value="M">male</option>
<option value="F">female</option>
<option value="DK">don't know</option></select>
</div><!-- class='some_attribute sex_select' --></form>}
		assert_equal expected, output_buffer
	end

	test "date_text_field" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.date_text_field(:some_attribute) }
		expected = %{<form action="/" method="post"><input class="datepicker" id="some_model_some_attribute" name="some_model[some_attribute]" size="30" type="text" /></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_date_text_field" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_date_text_field(:some_attribute) }
		expected = %{<form action="/" method="post"><div class='some_attribute date_text_field field_wrapper'>
<label for="some_model_some_attribute">Some attribute</label><input class="datepicker" id="some_model_some_attribute" name="some_model[some_attribute]" size="30" type="text" />
</div><!-- class='some_attribute date_text_field' --></form>}
		assert_equal expected, output_buffer
	end

	#	This isn't in an 'erb block' so it isn't really testing what I wanted.
	test "wrapped_date_text_field with block" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_date_text_field(:some_attribute){
				'testing'
			} }
		expected = %{<form action="/" method="post"><div class='some_attribute date_text_field field_wrapper'>
<label for="some_model_some_attribute">Some attribute</label><input class="datepicker" id="some_model_some_attribute" name="some_model[some_attribute]" size="30" type="text" />testing
</div><!-- class='some_attribute date_text_field' --></form>}
		assert_equal expected, output_buffer
	end

	test "meridiem_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.meridiem_select(:some_attribute) }
		expected = %{<form action="/" method="post"><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">Meridiem</option>
<option value="AM">AM</option>
<option value="PM">PM</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_meridiem_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_meridiem_select(:some_attribute) }
		expected = %{<form action="/" method="post"><div class='some_attribute meridiem_select field_wrapper'>
<label for="some_model_some_attribute">Some attribute</label><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">Meridiem</option>
<option value="AM">AM</option>
<option value="PM">PM</option></select>
</div><!-- class='some_attribute meridiem_select' --></form>}
		assert_equal expected, output_buffer
	end

	test "minute_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.minute_select(:some_attribute) }
		expected = %{<form action="/" method="post"><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">Minute</option>
<option value="0">00</option>
<option value="1">01</option>
<option value="2">02</option>
<option value="3">03</option>
<option value="4">04</option>
<option value="5">05</option>
<option value="6">06</option>
<option value="7">07</option>
<option value="8">08</option>
<option value="9">09</option>
<option value="10">10</option>
<option value="11">11</option>
<option value="12">12</option>
<option value="13">13</option>
<option value="14">14</option>
<option value="15">15</option>
<option value="16">16</option>
<option value="17">17</option>
<option value="18">18</option>
<option value="19">19</option>
<option value="20">20</option>
<option value="21">21</option>
<option value="22">22</option>
<option value="23">23</option>
<option value="24">24</option>
<option value="25">25</option>
<option value="26">26</option>
<option value="27">27</option>
<option value="28">28</option>
<option value="29">29</option>
<option value="30">30</option>
<option value="31">31</option>
<option value="32">32</option>
<option value="33">33</option>
<option value="34">34</option>
<option value="35">35</option>
<option value="36">36</option>
<option value="37">37</option>
<option value="38">38</option>
<option value="39">39</option>
<option value="40">40</option>
<option value="41">41</option>
<option value="42">42</option>
<option value="43">43</option>
<option value="44">44</option>
<option value="45">45</option>
<option value="46">46</option>
<option value="47">47</option>
<option value="48">48</option>
<option value="49">49</option>
<option value="50">50</option>
<option value="51">51</option>
<option value="52">52</option>
<option value="53">53</option>
<option value="54">54</option>
<option value="55">55</option>
<option value="56">56</option>
<option value="57">57</option>
<option value="58">58</option>
<option value="59">59</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_minute_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_minute_select(:some_attribute) }
		expected = %{<form action="/" method="post"><div class='some_attribute minute_select field_wrapper'>
<label for="some_model_some_attribute">Some attribute</label><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">Minute</option>
<option value="0">00</option>
<option value="1">01</option>
<option value="2">02</option>
<option value="3">03</option>
<option value="4">04</option>
<option value="5">05</option>
<option value="6">06</option>
<option value="7">07</option>
<option value="8">08</option>
<option value="9">09</option>
<option value="10">10</option>
<option value="11">11</option>
<option value="12">12</option>
<option value="13">13</option>
<option value="14">14</option>
<option value="15">15</option>
<option value="16">16</option>
<option value="17">17</option>
<option value="18">18</option>
<option value="19">19</option>
<option value="20">20</option>
<option value="21">21</option>
<option value="22">22</option>
<option value="23">23</option>
<option value="24">24</option>
<option value="25">25</option>
<option value="26">26</option>
<option value="27">27</option>
<option value="28">28</option>
<option value="29">29</option>
<option value="30">30</option>
<option value="31">31</option>
<option value="32">32</option>
<option value="33">33</option>
<option value="34">34</option>
<option value="35">35</option>
<option value="36">36</option>
<option value="37">37</option>
<option value="38">38</option>
<option value="39">39</option>
<option value="40">40</option>
<option value="41">41</option>
<option value="42">42</option>
<option value="43">43</option>
<option value="44">44</option>
<option value="45">45</option>
<option value="46">46</option>
<option value="47">47</option>
<option value="48">48</option>
<option value="49">49</option>
<option value="50">50</option>
<option value="51">51</option>
<option value="52">52</option>
<option value="53">53</option>
<option value="54">54</option>
<option value="55">55</option>
<option value="56">56</option>
<option value="57">57</option>
<option value="58">58</option>
<option value="59">59</option></select>
</div><!-- class='some_attribute minute_select' --></form>}
		assert_equal expected, output_buffer
	end

	test "hour_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.hour_select(:some_attribute) }
		expected = %{<form action="/" method="post"><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">Hour</option>
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="10">10</option>
<option value="11">11</option>
<option value="12">12</option></select></form>}
		assert_equal expected, output_buffer
	end

	test "wrapped_hour_select" do
		form_for(:some_model,SomeModel.new,:url => '/'){|f| 
			concat f.wrapped_hour_select(:some_attribute) }
		expected = %{<form action="/" method="post"><div class='some_attribute hour_select field_wrapper'>
<label for="some_model_some_attribute">Some attribute</label><select id="some_model_some_attribute" name="some_model[some_attribute]"><option value="">Hour</option>
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="10">10</option>
<option value="11">11</option>
<option value="12">12</option></select>
</div><!-- class='some_attribute hour_select' --></form>}
		assert_equal expected, output_buffer
	end

end	#	class ActionViewExtension::FormBuilderTest < ActionView::TestCase
