module SunspotHelper

#	originally from CLIC

	def multi_select_operator_for(name)
		s  = "<div><span>Multi-select operator</span>\n"
		s << radio_button_tag( "#{name}_op", 'AND',
				( params["#{name}_op"] && params["#{name}_op"] == 'AND' ) )
		s << "<label for='#{name}_op_and'>AND</label>\n"
		s << radio_button_tag( "#{name}_op", 'OR',
				( params["#{name}_op"].blank? || params["#{name}_op"] && params["#{name}_op"] == 'OR' ))
		s << "<label for='#{name}_op_or'>OR</label></div>\n"
	end

	def facet_for(facet,options={})
		#	options include :multiselector, :facetcount
		style, icon = if( params[facet.name] )
			[" style='display:block;'", "ui-icon-triangle-1-s"]
		else
			[                      nil, "ui-icon-triangle-1-e"]
		end
		s  = "<div class='facet_toggle'>" <<
			"<span class='ui-icon #{icon}'>&nbsp;</span>" <<
			"<a href='javascript:void()'>#{facet.name.to_s.titleize}&nbsp;(#{facet.rows.reject{|r|r.value.blank?}.length})</a>" <<
			"</div>\n"
#			"<a href='javascript:void()'>#{pluralize(facet.rows.reject{|r|r.value.blank?}.length,facet.name.to_s.titleize)}</a>" <<
#			"<a href='javascript:void()'>#{pluralize(facet.rows.length,facet.name.to_s.titleize)}</a>" <<
		s << multi_select_operator_for(facet.name) if options[:multiselector]
		#	show this facet if any have been selected
		s << "<ul id='#{facet.name}' class='facet_field'#{style}>\n"
		facet.rows.each do |row|

#
#	NOTE for now, if a blank field has made it into the index, IGNORE IT.
#		Unfortunately, searching for a '' creates syntactically incorrect query.
#
#		Of course, this mucks up the count.  Errr!!!
#		So I had to handle it yet again.
#
			next if row.value.blank?




#	wrapped in [] and added flatten in case is nil as is in testing (20120412)

			s << "<li>"
			if options[:radio]
#						params[facet.name].include?(row.value),
				s << radio_button_tag( "#{facet.name}[]", row.value,
						[params[facet.name]].flatten.include?(row.value),
						{ :id => "#{facet.name}_#{row.value.html_friendly}" } )
			else
#						params[facet.name].include?(row.value),
				s << check_box_tag( "#{facet.name}[]", row.value, 
						[params[facet.name]].flatten.include?(row.value),
						{ :id => "#{facet.name}_#{row.value.html_friendly}" } )
			end
			s << "<label for='#{facet.name}_#{row.value.html_friendly}'>"
			s << "<span>#{row.value}</span>"
			s << "&nbsp;(&nbsp;#{row.count}&nbsp;)" if options[:facet_counts]
			s << "</label></li>\n"
		end
		s << "</ul>\n"
	end

end
