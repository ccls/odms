module SunspotHelper

	#	Rails helpers are already "html_safe".
	#	Manually creating the strings will require adding it.

	def operator_radio_button_tag_and_label(name,operator,selected)
		s =  radio_button_tag( "#{name}_op", operator, selected == operator,
				:id => "#{name}_op_#{operator.downcase}" )
		s << label_tag( "#{name}_op_#{operator.downcase}", operator )
	end

#	originally from CLIC

	def multi_select_operator_for(name)
		content_tag(:div) do
			selected = ( params["#{name}_op"] && params["#{name}_op"] == 'AND' ) ? 'AND' : 'OR'
			s  = content_tag(:span,"Multi-select operator")
			s << operator_radio_button_tag_and_label(name,'AND',selected)
			s << operator_radio_button_tag_and_label(name,'OR',selected)
		end
	end

	def facet_toggle(facet,icon)
		content_tag(:div,:class => 'facet_toggle') do
			s =  content_tag(:span,'&nbsp;'.html_safe,:class => "ui-icon #{icon}")
			#	Don't include the blank fields, so don't count them.
			#	May need to figure out how to deal with blanks in the future
			#	as occassionally they are what one would be searching for.
			non_blank_row_count = facet.rows.reject{|r|r.value.blank?}.length
			facet_label = facet.name.to_s
			facet_label = if( facet_label.match(/^hex_/) )
#				[facet_label.gsub(/^hex_/,'').split(/:/).first].pack('H*')
				l = facet_label.gsub(/^hex_/,'').split(/:/)
				l[0] = [l[0]].pack('H*')
				l.join(' : ')
			else
				facet_label.titleize
			end
			s << link_to("#{facet_label}&nbsp;(#{non_blank_row_count})".html_safe, 'javascript:void()')
		end
	end

	def facet_for(facet,options={})
		#	options include :multiselector, :facetcount
		style, icon = if( params[facet.name] )
			[" style='display:block;'", "ui-icon-triangle-1-s"]
		else
			[                      nil, "ui-icon-triangle-1-e"]
		end
		s =  facet_toggle(facet,icon)
		s << multi_select_operator_for(facet.name) if options[:multiselector]
		#	show this facet if any have been selected
		s << "<ul id='#{facet.name}' class='facet_field'#{style}>\n".html_safe
		facet.rows.each do |row|

#
#	NOTE for now, if a blank field has made it into the index, IGNORE IT.
#		Unfortunately, searching for a '' creates syntactically incorrect query.
#
#		Of course, this mucks up the count.  Errr!!!
#		So I had to handle it yet again.
#
			next if row.value.blank?


#	TODO figure out how to facet on NULL and BLANK values
#		I don't think that NULL gets faceted


			s << "<li>".html_safe
			if options[:radio]
				s << radio_button_tag( "#{facet.name}[]", row.value,
						[params[facet.name]].flatten.include?(row.value.to_s),
						{ :id => "#{facet.name}_#{row.value.html_friendly}" } )
			else
				s << check_box_tag( "#{facet.name}[]", row.value, 
						[params[facet.name]].flatten.include?(row.value.to_s),
						{ :id => "#{facet.name}_#{row.value.html_friendly}" } )
			end
			s << "<label for='#{facet.name}_#{row.value.html_friendly}'>".html_safe
			s << "<span>#{row.value}</span>".html_safe
			s << "&nbsp;(&nbsp;#{row.count}&nbsp;)".html_safe if options[:facet_counts]
			s << "</label></li>\n".html_safe
		end
		s << "</ul>\n".html_safe
	end

	def available_columns
		%w( id case_icf_master_id mother_icf_master_id icf_master_id 
			subject_type vital_status case_control_type reference_date
			sex dob died_on phase birth_year 
mother_first_name
mother_maiden_name
mother_last_name
father_first_name
father_last_name
first_name
middle_name
maiden_name
last_name
do_not_contact
father_ssn
mother_ssn
patid
languages
)
	end

#
#	language_names
#

	def default_columns
		%w( id case_icf_master_id mother_icf_master_id icf_master_id 
			subject_type vital_status sex dob 
first_name
last_name
)
	end

	def columns
		columns ||= if( params[:columns].present? )
			params[:columns]
		else
			default_columns
		end
	end

	def column_header(column)
		case column.to_s
			when '' then ''
			else sort_link(column,:image => false)
		end
	end

	def column_content(subject,column)
		case column.to_s
			when 'dob','died_on','reference_date' then subject.send(column).try(:strftime,'%m/%d/%Y')
			when 'languages' then subject.languages.collect(&:key).join(',')
			when 'icf_master_id' then subject.icf_master_id_to_s
			when 'case_icf_master_id' then subject.case_subject.try(:icf_master_id_to_s)||'[No Case Subject]'
			when 'mother_icf_master_id' then subject.mother.try(:icf_master_id_to_s)||'[No Mother Subject]'
			when 'father_ssn' then subject.birth_data.order('created_at DESC').collect(&:father_ssn).compact.first
			when 'mother_ssn' then subject.birth_data.order('created_at DESC').collect(&:mother_ssn).compact.first
			else ( subject.respond_to?(column) ? subject.try(column) : nil )
		end
	end

end
