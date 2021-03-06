require 'test_helper'

class FakeFacet
	attr_accessor :name,:rows
	def initialize(name)
		self.name = name
		self.rows = []
	end
end
class FakeFacetRow
	attr_accessor :value, :count
	def initialize(value,count=0)
		self.value = value
		self.count = count
	end
end

class ActiveRecordSunspotter::SunspotHelperTest < ActionView::TestCase

#	 def facet_toggle(facet,icon)

	test "facet_toggle should create div with span and link" do
		facet = FakeFacet.new('subject_type')
		@sunspot_search_class = StudySubject
		response = facet_toggle(facet,'triangle').to_html_document
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => /\s*/, :count => 1
			assert_select "a[href='javascript:void()']", 
				:text => /Subject Type.+\(0\)/, 
				:count => 1
		end
	end

	test "facet_toggle should show row count in link text" do
		facet = FakeFacet.new('subject_type')
		facet.rows << FakeFacetRow.new('somevalue')
		facet.rows << FakeFacetRow.new('somevalue')
		@sunspot_search_class = StudySubject
		response = facet_toggle(facet,'triangle').to_html_document
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => /\s*/, :count => 1
			assert_select "a[href='javascript:void()']",
				:text => /Subject Type.+\(2\)/, 
				:count => 1
		end
	end

	test "facet_toggle should show non-blank row count in link text" do
		facet = FakeFacet.new('subject_type')
		facet.rows << FakeFacetRow.new('somevalue')
		facet.rows << FakeFacetRow.new('')
		@sunspot_search_class = StudySubject
		response = facet_toggle(facet,'triangle').to_html_document
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => /\s*/, :count => 1
			assert_select "a[href='javascript:void()']",
				:text => /Subject Type.+\(1\)/, 
				:count => 1 
		end
	end

	test "facet_toggle should show decode hex label row count in link text" do
		facet = FakeFacet.new("hex_#{'CCLS'.unpack('H*').first}")
		facet.rows << FakeFacetRow.new('somevalue')
		response = facet_toggle(facet,'triangle').to_html_document
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => /\s*/, :count => 1
			assert_select "a[href='javascript:void()']",
				:text => /CCLS.+\(1\)/, 
				:count => 1
		end
	end

	test "facet_toggle should show decode first part of hex label row count in link text" do
		facet = FakeFacet.new("hex_#{'CCLS'.unpack('H*').first}:Unencoded")
		facet.rows << FakeFacetRow.new('somevalue')
		response = facet_toggle(facet,'triangle').to_html_document
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon.triangle', :text => /\s*/, :count => 1
			assert_select "a[href='javascript:void()']",
				:text => /CCLS : Unencoded.+\(1\)/, 
				:count => 1
		end
	end



#	def facet_for(facet,options={})

#	TODO test with AND/OR operators
#	TODO test with exposures

	test "should respond_to facet_for" do
		assert respond_to?(:facet_for)
	end

	test "facet_for should return nil if no rows" do
		facet = FakeFacet.new('something')
		assert facet.rows.empty?
		assert_nil facet_for(facet)
	end

	test "facet_for should return checkbox fields for facet" do
		facet = FakeFacet.new('subject_type')
		facet.rows << FakeFacetRow.new('somevalue1')
		facet.rows << FakeFacetRow.new('somevalue2')
		@sunspot_search_class = StudySubject
		response = facet_for(facet).to_html_document
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon', :text => /\s*/, :count => 1
			assert_select "a[href='javascript:void()']",
				:text => /Subject Type.+\(2\)/, 
				:count => 1
		end
		assert_select( response, 'div.facet_field', :count => 1 ){|divs| divs.each { |div|
			assert_select( div, 'ul.facet_field_values', :count => 1 ){|uls| uls.each { |ul|
				assert_select( ul, 'li', :count => 2 ){|lis| lis.each { |li|
					assert_select li, 'input[type=checkbox]', :count => 1
					assert_select li, 'label', :count => 1
					assert_select li, 'span',  :count => 1
		} } } } } }
	end

	test "facet_for should return radio fields for facet if radio true" do
		facet = FakeFacet.new('subject_type')
		facet.rows << FakeFacetRow.new('somevalue1')
		facet.rows << FakeFacetRow.new('somevalue2')
		@sunspot_search_class = StudySubject
		response = facet_for(facet, :radio => true).to_html_document
		assert_select response, "div.facet_toggle", :count => 1 do
			assert_select 'span.ui-icon', :text => /\s*/, :count => 1
			assert_select "a[href='javascript:void()']",
				:text => /Subject Type.+\(2\)/, 
				:count => 1
		end
		assert_select( response, 'div.facet_field', :count => 1 ){|divs| divs.each { |div|
			assert_select( div, 'ul.facet_field_values', :count => 1 ){|uls| uls.each { |ul|
				assert_select( ul, 'li', :count => 2 ){|lis| lis.each { |li|
					assert_select li, 'input[type=radio]', :count => 1
					assert_select li, 'label', :count => 1
					assert_select li, 'span',  :count => 1
		} } } } } }
	end

#	test "facet_for is gonna be tough to test outside of a controller" do
#		response = facet_for('something').to_html_document
#		puts response
#	end


#	def operator_radio_button_tag_and_label(name,operator,selected)

	test "operator_radio_button_tag_and_label should not check AND for AND and OR" do
		response = operator_radio_button_tag_and_label('something','AND','OR').to_html_document
		assert_select response, "input#something_op_and[type=radio]" <<
			"[value=AND]:not([checked=checked])", :count => 1
		assert_select response, 'label', :text => 'AND', :count => 1 do
			assert_select "[for=something_op_and]"
		end
	end

	test "operator_radio_button_tag_and_label should not check OR for OR and AND" do
		response = operator_radio_button_tag_and_label('something','OR','AND').to_html_document
		assert_select response, "input#something_op_or[type=radio]" <<
			"[value=OR]:not([checked=checked])", :count => 1
		assert_select response, 'label', :text => 'OR', :count => 1 do
			assert_select "[for=something_op_or]"
		end
	end

	test "operator_radio_button_tag_and_label should check AND for AND and AND" do
		response = operator_radio_button_tag_and_label('something','AND','AND').to_html_document
		assert_select response, "input#something_op_and[type=radio]" <<
			"[value=AND][checked=checked]", :count => 1
		assert_select response, 'label', :text => 'AND', :count => 1 do
			assert_select "[for=something_op_and]"
		end
	end

	test "operator_radio_button_tag_and_label should check OR for OR and OR" do
		response = operator_radio_button_tag_and_label('something','OR','OR').to_html_document
		assert_select response, "input#something_op_or[type=radio]" <<
			"[value=OR][checked=checked]", :count => 1
		assert_select response, 'label', :text => 'OR', :count => 1 do
			assert_select "[for=something_op_or]"
		end
	end





	
#	def multi_select_operator_for(name)

	test "should respond_to multi_select_operator_for" do
		assert respond_to?(:multi_select_operator_for)
	end

	test "multi_select_operator_for(something) with no params should return stuff" do
		response = multi_select_operator_for('something').to_html_document
		assert_select response, "div" do
			assert_select 'span', :text => 'Multi-select operator'
			assert_select 'input', :count => 2
			assert_select 'input[checked=checked]', :count => 1
			assert_select "input#something_op_or[type=radio]" <<
				"[value=OR][checked=checked]", :count => 1
			assert_select "input#something_op_and[type=radio]" <<
				"[value=AND]:not([checked=checked])", :count => 1
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
		self.params = HWIA.new(
			:something_op => 'OR'
			)
		response = multi_select_operator_for('something').to_html_document
		assert_select response, "div" do
			assert_select 'input[checked=checked]', :count => 1
			assert_select 'input#something_op_or[checked=checked]', :count => 1
			assert_select 'input#something_op_and:not([checked=checked])', :count => 1
		end
	end

	test "multi_select_operator_for(something) with something_op=AND should check AND" do
		self.params = HWIA.new(
			:something_op => 'AND'
			)
		response = multi_select_operator_for('something').to_html_document
		assert_select response, "div" do
			assert_select 'input[checked=checked]', :count => 1
			assert_select 'input#something_op_or:not([checked=checked])', :count => 1
			assert_select 'input#something_op_and[checked=checked]', :count => 1
		end
	end



#	def available_columns
#
#	test "should respond_to available_columns" do
#		assert respond_to?(:available_columns)
#	end
#
#	test "available_columns should be an array" do
#		assert available_columns.is_a?(Array)
#	end


#	def SunspotHelper.default_columns
#
#	test "should respond_to default_columns" do
#		assert SunspotHelper.respond_to?(:default_columns)
#	end
#
#	test "default_columns should be an array" do
#		assert SunspotHelper.default_columns.is_a?(Array)
#	end


#	def columns

	test "should respond_to columns" do
		assert respond_to?(:columns)
	end

	test "columns should be an array of default columns without params[:c]" do
		@sunspot_search_class = StudySubject
		assert columns.is_a?(Array)
		assert_equal columns, StudySubject.sunspot_default_column_names
	end

	test "columns should be an array of default columns with nil params['c']" do
		@sunspot_search_class = StudySubject
		self.params = HWIA.new({ 'c' => nil })
		assert columns.is_a?(Array)
		assert_equal columns, StudySubject.sunspot_default_column_names
	end

	test "columns should be an array of default columns with nil params[:c]" do
		@sunspot_search_class = StudySubject
		self.params = HWIA.new({ :c => nil })
		assert columns.is_a?(Array)
		assert_equal columns, StudySubject.sunspot_default_column_names
	end

	test "columns should be an array of default columns with blank params['c']" do
		@sunspot_search_class = StudySubject
		self.params = HWIA.new({ 'c' => '' })
		assert columns.is_a?(Array)
		assert_equal columns, StudySubject.sunspot_default_column_names
	end

	test "columns should be an array of default columns with blank params[:c]" do
		@sunspot_search_class = StudySubject
		self.params = HWIA.new({ :c => '' })
		assert columns.is_a?(Array)
		assert_equal columns, StudySubject.sunspot_default_column_names
	end

	test "columns should be an array of default columns with empty params['c']" do
		@sunspot_search_class = StudySubject
		self.params = HWIA.new({ 'c' => [] })
		assert columns.is_a?(Array)
		assert_equal columns, StudySubject.sunspot_default_column_names
	end

	test "columns should be an array of default columns with empty params[:c]" do
		@sunspot_search_class = StudySubject
		self.params = HWIA.new({ :c => [] })
		assert columns.is_a?(Array)
		assert_equal columns, StudySubject.sunspot_default_column_names
	end

	test "columns should be an array with string params['c']" do
		self.params = HWIA.new({ 'c' => 'apple' })
		assert columns.is_a?(Array)
		assert_equal columns, ['apple']
	end

	test "columns should be an array with string params[:c]" do
		self.params = HWIA.new({ :c => 'apple' })
		assert columns.is_a?(Array)
		assert_equal columns, ['apple']
	end

	test "columns should be an array with array params['c']" do
		self.params = HWIA.new({ 'c' => ['apple'] })
		assert columns.is_a?(Array)
		assert_equal columns, ['apple']
	end

	test "columns should be an array with array params[:c]" do
		self.params = HWIA.new({ :c => ['apple'] })
		assert columns.is_a?(Array)
		assert_equal columns, ['apple']
	end


#	def column_header(column)

	test "should respond_to column_header" do
		assert respond_to?(:column_header)
	end

	test "column_header should return blank for blank column" do
		@sunspot_search_class = StudySubject
		assert column_header('').blank?
	end


#	def column_content(subject,column)

	test "should respond_to column_content" do
		assert respond_to?(:column_content)
	end

	test "column_content should NOT destroy subject with column destroy" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject)
		assert_difference('StudySubject.count',0){
			response = column_content(subject,'destroy')
#			assert_nil response
			assert_equal "UNKNOWN COLUMN", response
		}
	end

	test "column_content should return formatted subject dob" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject, :dob => Date.parse('Dec 31, 1950') )
		response = column_content(subject,'dob')
		assert_equal response, '12/31/1950'
	end

	test "column_content should return formatted subject died_on" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject, :died_on => Date.parse('Dec 31, 1950') )
		response = column_content(subject,'died_on')
		assert_equal response, '12/31/1950'
	end

	test "column_content should return formatted subject reference_date" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject, :reference_date => Date.parse('Dec 31, 1950') )
		response = column_content(subject,'reference_date')
		assert_equal response, '12/31/1950'
	end

	test "column_content should return formatted subject admit_date" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:case_study_subject)
		subject.build_patient(:admit_date => Date.parse('Dec 31, 1950'))
		response = column_content(subject,'admit_date')
		assert_equal response, '12/31/1950'
	end

	test "column_content should return blank for subject without languages" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject)
		response = column_content(subject,'languages')
		assert response.blank?
	end

	test "column_content should return language names for subject with languages" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject)
		subject.languages << Language['english']
		subject.languages << Language['spanish']
		response = column_content(subject,'languages')
		assert_equal response, 'English,Spanish'
	end

	test "column_content should return other languages for subject with other languages" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject)
		subject.subject_languages.create(:language => Language['other'],
			:other_language => "Redneck")
		response = column_content(subject,'languages')
		assert_equal response, 'Redneck'
	end


	test "column_content should return blank for subject without races" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject)
		response = column_content(subject,'races')
		assert response.blank?
	end

	test "column_content should return race names for subject with races" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject)
		subject.races << Race['asian']
		subject.races << Race['nativeamerican']
		response = column_content(subject,'races')
		assert_equal response, 'Asian,Native American'
	end

	test "column_content should return other races for subject with other races" do
		@sunspot_search_class = StudySubject
		subject = FactoryBot.create(:study_subject)
		subject.subject_races.create(:race => Race['other'],
			:other_race => "Redneck")
		response = column_content(subject,'races')
		assert_equal response, 'Redneck'
	end

#	test "column_content should return Yes for consented" do
#		enrollment = FactoryBot.create(:consented_enrollment)
#		subject = enrollment.study_subject
#		assert_equal 'Yes',
#			column_content(subject,"#{enrollment.project.description}:consented")
#	end
#
#	test "column_content should return Yes for eligible" do
#		enrollment = FactoryBot.create(:eligible_enrollment)
#		subject = enrollment.study_subject
#		assert_equal 'Yes',
#			column_content(subject,"#{enrollment.project.description}:is_eligible")
#	end

protected
#	HWIA = HashWithIndifferentAccess

#	"fake" controller methods
	def params
		@params || HWIA.new
	end
#
#	Be very aware of your params hash.  Either use a hash with indifferent access
#	or ensure that the app code and test code match keys types.
#	For non-HWIA hashes, :keyname and 'keyname' are DIFFERENT!
#
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

