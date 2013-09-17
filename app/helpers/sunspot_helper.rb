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
#
#	20130423 - false.blank? is true so boolean fields won't work here
#
#				perhaps do r.value.to_s.blank? as 'false'.blank? is false
#
			non_blank_row_count = facet.rows.reject{|r|r.value.blank?}.length
			facet_label = facet.name.to_s
			facet_label = if( facet_label.match(/^hex_/) )
#				[facet_label.gsub(/^hex_/,'').split(/:/).first].pack('H*')
				l = facet_label.gsub(/^hex_/,'').split(/:/)
				l[0] = [l[0]].pack('H*')
				l.join(' : ')
			else
				column = @sunspot_search_class.all_sunspot_columns.detect{|c|c.name == facet_label}

				#	Check if a translation exists. Use it if it does, otherwise ...
				#	http://stackoverflow.com/questions/12353416/rails-i18n-check-if-translation-exists
				column.label || ( I18n.t("#{@sunspot_search_class.to_s.underscore}.#{facet.name}",
					:scope => "activerecord.attributes",:raise => true ) rescue false ) || facet_label.titleize
			end
			s << link_to("#{facet_label}&nbsp;(#{non_blank_row_count})".html_safe, 'javascript:void()')
		end
	end

	def facet_for(facet,options={})
		return if facet.rows.empty?

		#	options include :multiselector, :facetcount
		style, icon = if( params[facet.name] )
			[" style='display:block;'", "ui-icon-triangle-1-s"]
		else
			[                      nil, "ui-icon-triangle-1-e"]
		end
		s =  facet_toggle(facet,icon)

		#	Wrap all the rest in a div which will be toggled
		s << "\n<div id='#{facet.name}' class='facet_field'#{style}>\n".html_safe
		s << multi_select_operator_for(facet.name) if options[:multiselector]

		s << "<ul class='facet_field_values'>\n".html_safe
		facet.rows.each do |row|

#
#	NOTE for now, if a blank field has made it into the index, IGNORE IT.
#		Unfortunately, searching for a '' creates syntactically incorrect query.
#
#		Of course, this mucks up the count.  Errr!!!
#		So I had to handle it yet again.
#

#
#	20130423 - false.blank? is true so boolean fields won't work here
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
		s << "</ul>\n".html_safe	#	"<ul class='facet_field_values'>"
		s << "</div>\n".html_safe	#	"<div id='#{facet.name}' class='facet_field'#{style}>"
	end

	def columns
		columns ||= if( params[:c].present? )
			[params[:c]].flatten.uniq	#	sometimes this is needed and others it is not?
		else
			@sunspot_search_class.sunspot_default_column_names
		end
	end

	def column_header(column)
		if @sunspot_search_class.sunspot_orderable_column_names.include?(column.to_s)
			sort_link(column,:image => false)
		else
			column
		end
	end

	#
	#	NEVER use send on a tainted string!
	#
	def column_content(subject,column)
		case column.to_s

			#
			#	Just wanting to format any date columns
			#
			when *@sunspot_search_class.sunspot_date_columns.collect(&:name)
				col = @sunspot_search_class.sunspot_columns.detect{|c|
					c.name == column.to_s }
				( col.hash_table.has_key?(:meth) ) ?
					[col.meth.call(subject)].flatten.join(',') :
					( subject.respond_to?(column) ) ?
						subject.try(column).try(:strftime,'%m/%d/%Y') : 
						'DATE COLUMN NOT FOUND?'

			#
			#	All valid columns can use meth, so I don't need to define them.
			#
			when *@sunspot_search_class.sunspot_column_names
				col = @sunspot_search_class.sunspot_columns.detect{|c|
					c.name == column.to_s }
				( col.hash_table.has_key?(:meth) ) ?
					[col.meth.call(subject)].flatten.join(',') :
					( subject.respond_to?(column) ) ?
						subject.try(column) : 
						'COLUMN NOT FOUND?'

			else
				'UNKNOWN COLUMN'
		end
	end

end
