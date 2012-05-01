module AbstractsHelper

	def abstract_pages(abstract)
		sections = Abstract.sections
		current_index = sections.find_index{|i| i[:controller] =~ /^#{controller.class.name}$/i }

		s = "<p class='center'>"
		s << (( !current_index.nil? && current_index > 0 ) ? "<span class='left'>" << 
				link_to( "&laquo; #{sections[current_index-1][:label]}".html_safe,
					send(sections[current_index-1][:show],abstract) ) << 
				"</span>" : '')
		s << link_to( "Back to Abstract", abstract_path(abstract) )
		s << (( !current_index.nil? && current_index < ( sections.length - 1 ) ) ? "" <<
				"<span class='right'>" << 
				link_to( "#{sections[current_index+1][:label]} &raquo;".html_safe,
					send(sections[current_index+1][:show],abstract) ) << 
				"</span>" : '' )
		s << "</p>"
		s.html_safe
	end

	def edit_link
		s =  "<p class='center'>"
#		s << "<span class='left'>#{controller.class.name.gsub(/Controller$/,'').singularize}</span>"
		s << link_to( "Edit", params.update(:action => 'edit'), :class => 'right button' )
		s << "</p>"
		s.html_safe
	end

	def pos_neg(value)
		case value
			when 1   then 'Positive'
			when 2   then 'Negative'
			else '&nbsp;'
		end
	end

end


ActionView::Helpers::FormBuilder.class_eval do

	def submit_bar(controller=nil)
		s = "<div class='submit_bar'>"
		s << "<p class='submit_bar'>"
		s << @template.link_to( "Cancel and Show Section", 
			{ :action => 'show' }, { :class => 'button' } )
		s << "&nbsp;\n"
		s << submit( 'Save and Show Section',:name => nil )
		s << "</p>\n"
		sections = Abstract.sections
		ci = sections.find_index{|i| i[:controller] == controller }
		s << "<p class='submit_bar'>"
		s << (( !ci.nil? && ci > 0 ) ? 

#	these values were used in the controllers before as the value
#	of a HIDDEN submit button.  As the submit button is no longer
#	hidden, must find a different way.  I'm thinking of rather
#	than getting the value of the commit param, simply looking
#	for the edit_next or edit_previous param.

#			submit_link_to( "Save and Edit '#{sections[ci-1][:label]}'",
#				:value => 'edit_previous') : '' )
			submit( "Save and Edit '#{sections[ci-1][:label]}'",
				:name => 'edit_previous') : '' )
		s << "&nbsp;\n"
		s << (( !ci.nil? && ci < ( sections.length - 1 ) ) ?
#			submit_link_to( "Save and Edit '#{sections[ci+1][:label]}'",
#				:value => 'edit_next') : '' )
			submit( "Save and Edit '#{sections[ci+1][:label]}'",
				:name => 'edit_next') : '' )
		s << "</p>\n"
		s << "</div><!-- class='submit_bar' -->"
		s.html_safe
	end

end
