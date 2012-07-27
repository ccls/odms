require 'test_helper'

class FakeFacet
	attr_accessor :name,:rows
	def initialize(name)
		self.name = name
		self.rows = []
	end
end
class FakeFacetRow
	attr_accessor :value
	def initialize(value)
		self.value = value
	end
end

class SunspotHelperTest < ActionView::TestCase

#	 def facet_toggle(facet,icon)

	test "facet_toggle should create div with span and link" do
		facet = FakeFacet.new('something')
		response = HTML::Document.new(facet_toggle(facet,'triangle')).root
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => '&nbsp;', :count => 1
			assert_select 'a', :text => "Something&nbsp;(0)", :count => 1 do
				assert_select "[href=?]", "javascript:void()"
			end
		end
	end

	test "facet_toggle should show row count in link text" do
		facet = FakeFacet.new('something')
		facet.rows << FakeFacetRow.new('somevalue')
		facet.rows << FakeFacetRow.new('somevalue')
		response = HTML::Document.new(facet_toggle(facet,'triangle')).root
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => '&nbsp;', :count => 1
			assert_select 'a', :text => "Something&nbsp;(2)", :count => 1 do
				assert_select "[href=?]", "javascript:void()"
			end
		end
	end

	test "facet_toggle should show non-blank row count in link text" do
		facet = FakeFacet.new('something')
		facet.rows << FakeFacetRow.new('somevalue')
		facet.rows << FakeFacetRow.new('')
		response = HTML::Document.new(facet_toggle(facet,'triangle')).root
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => '&nbsp;', :count => 1
			assert_select 'a', :text => "Something&nbsp;(1)", :count => 1 do
				assert_select "[href=?]", "javascript:void()"
			end
		end
	end



#	def facet_for(facet,options={})

#	TODO test with AND/OR operators
#	TODO test with exposures

	test "should respond_to facet_for" do
		assert respond_to?(:facet_for)
	end

#	test "facet_for is gonna be tough to test outside of a controller" do
#		response = HTML::Document.new(facet_for('something')).root
#		puts response
#	end


#	def operator_radio_button_tag_and_label(name,operator,selected)

	test "operator_radio_button_tag_and_label should not check AND for AND and OR" do
		response = HTML::Document.new(
			operator_radio_button_tag_and_label('something','AND','OR')).root
		assert_select response, 'input#something_op_and', :count => 1 do
			assert_select "[type=radio]"
			assert_select "[value=AND]"
			assert_select ":not([checked=checked])"
		end
		assert_select response, 'label', :text => 'AND', :count => 1 do
			assert_select "[for=something_op_and]"
		end
	end

	test "operator_radio_button_tag_and_label should not check OR for OR and AND" do
		response = HTML::Document.new(
			operator_radio_button_tag_and_label('something','OR','AND')).root
		assert_select response, 'input#something_op_or', :count => 1 do
			assert_select "[type=radio]"
			assert_select "[value=OR]"
			assert_select ":not([checked=checked])"
		end
		assert_select response, 'label', :text => 'OR', :count => 1 do
			assert_select "[for=something_op_or]"
		end
	end

	test "operator_radio_button_tag_and_label should check AND for AND and AND" do
		response = HTML::Document.new(
			operator_radio_button_tag_and_label('something','AND','AND')).root
		assert_select response, 'input#something_op_and', :count => 1 do
			assert_select "[type=radio]"
			assert_select "[value=AND]"
			assert_select "[checked=checked]"
		end
		assert_select response, 'label', :text => 'AND', :count => 1 do
			assert_select "[for=something_op_and]"
		end
	end

	test "operator_radio_button_tag_and_label should check OR for OR and OR" do
		response = HTML::Document.new(
			operator_radio_button_tag_and_label('something','OR','OR')).root
		assert_select response, 'input#something_op_or', :count => 1 do
			assert_select "[type=radio]"
			assert_select "[value=OR]"
			assert_select "[checked=checked]"
		end
		assert_select response, 'label', :text => 'OR', :count => 1 do
			assert_select "[for=something_op_or]"
		end
	end





	
#	def multi_select_operator_for(name)

	test "should respond_to multi_select_operator_for" do
		assert respond_to?(:multi_select_operator_for)
	end

	test "multi_select_operator_for(something) with no params should return stuff" do
		response = HTML::Document.new(multi_select_operator_for('something')).root
		assert_select response, "div" do
			assert_select 'span', :text => 'Multi-select operator'
			assert_select 'input', :count => 2
			assert_select 'input[checked=checked]', :count => 1
			assert_select 'input#something_op_or', :count => 1 do
				assert_select "[type=radio]"
				assert_select "[value=OR]"
				assert_select "[checked=checked]"
			end
			assert_select 'input#something_op_and', :count => 1 do
				assert_select "[type=radio]"
				assert_select "[value=AND]"
				assert_select ":not([checked=checked])"
			end
			assert_select 'label', :count => 2
			assert_select 'label', :text => 'OR', :count => 1 do
				assert_select "[for=something_op_or]"
			end
			assert_select 'label', :text => 'AND', :count => 1 do
				assert_select "[for=something_op_and]"
			end
		end
	end

	test "multi_select_operator_for(something) with something_op=OR should check OR" do
		self.params = HashWithIndifferentAccess.new(
			:something_op => 'OR'
			)
		response = HTML::Document.new(multi_select_operator_for('something')).root
		assert_select response, "div" do
			assert_select 'input[checked=checked]', :count => 1
			assert_select 'input#something_op_or[checked=checked]', :count => 1
			assert_select 'input#something_op_and:not([checked=checked])', :count => 1
		end
	end

	test "multi_select_operator_for(something) with something_op=AND should check AND" do
		self.params = HashWithIndifferentAccess.new(
			:something_op => 'AND'
			)
		response = HTML::Document.new(multi_select_operator_for('something')).root
		assert_select response, "div" do
			assert_select 'input[checked=checked]', :count => 1
			assert_select 'input#something_op_or:not([checked=checked])', :count => 1
			assert_select 'input#something_op_and[checked=checked]', :count => 1
		end
	end

protected
#	"fake" controller methods
	def params
		@params || HashWithIndifferentAccess.new
	end
	def params=(new_params)
		@params = new_params
	end
#	def login_as(user)
#		@current_user = user
#	end
#	def current_user	
#		@current_user
#	end
#	def logged_in?
#		!current_user.nil?
#	end
end

__END__

	def facet_for(facet,options={})
		#	options include :multiselector, :facetcount
		s  = "<b>#{pluralize(facet.rows.length,facet.name.to_s.titleize)}</b>\n"
		s << multi_select_operator_for(facet.name) if options[:multiselector]
		s << "<ul id='#{facet.name}' class='facet_field'>\n"
		facet.rows.each do |row|
			s << "<li>"
			if options[:radio]
				s << radio_button_tag( "#{facet.name}[]", row.value,
						params[facet.name].include?(row.value),
						{ :id => "#{facet.name}_#{row.value.html_friendly}" } )
			else
				s << check_box_tag( "#{facet.name}[]", row.value, 
						params[facet.name].include?(row.value),
						{ :id => "#{facet.name}_#{row.value.html_friendly}" } )
			end
			s << "<label for='#{facet.name}_#{row.value.html_friendly}'>"
			s << "<span>#{row.value}</span>"
			s << "&nbsp;(&nbsp;#{row.count}&nbsp;)" if options[:facet_counts]
			s << "</label></li>\n"
		end
    s << "</ul>\n"
	end

