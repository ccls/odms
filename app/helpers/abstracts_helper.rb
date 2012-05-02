module AbstractsHelper

	def abstract_pages(abstract)
		sections = Abstract.sections
		ci = sections.find_index{|i| 
			i[:controller] =~ /^#{controller.class.name.demodulize}$/i }

		s = "<p class='center'>"
		s << (( !ci.nil? && ci > 0 ) ? "<span class='left'>" << 
				link_to( "&laquo; #{sections[ci-1][:label]}".html_safe,
					send(sections[ci-1][:show],abstract) ) << 
				"</span>" : '')
		s << link_to( "Back to Abstract", abstract_path(abstract) )
		s << (( !ci.nil? && ci < ( sections.length - 1 ) ) ? "" <<
				"<span class='right'>" << 
				link_to( "#{sections[ci+1][:label]} &raquo;".html_safe,
					send(sections[ci+1][:show],abstract) ) << 
				"</span>" : '' )
		s << "</p>"
		s.html_safe
	end

	def edit_link
		s =  "<p class='center'>"
		s << link_to( "Edit", params.update(:action => 'edit'), :class => 'right button' )
		s << "</p>"
		s.html_safe
	end

end


ActionView::Helpers::FormBuilder.class_eval do

	def submit_bar(controller_name)
		s = "<div class='submit_bar'>"
		s << "<p class='submit_bar'>"
		s << @template.link_to( "Cancel and Show Section", 
			{ :action => 'show' }, { :class => 'button' } )
		s << "&nbsp;\n"
		s << submit( 'Save and Show Section',:name => nil )
		s << "</p>\n"
		sections = Abstract.sections
		ci = sections.find_index{|i| 
			i[:controller] =~ /^#{controller_name.demodulize}$/i }
		s << "<p class='submit_bar'>"
		s << (( !ci.nil? && ci > 0 ) ? 

#	these values were used in the controllers before as the value
#	of a HIDDEN submit button.  As the submit button is no longer
#	hidden, must find a different way.  I'm thinking of rather
#	than getting the value of the commit param, simply looking
#	for the edit_next or edit_previous param.

#			submit_link_to( "Save and Edit '#{sections[ci-1][:label]}'",
#				:value => 'edit_previous') : '' )
			submit( "Save and Edit '#{sections[ci-1][:label]}'".html_safe,
				:name => 'edit_previous') : '' )
		s << "&nbsp;\n"
		s << (( !ci.nil? && ci < ( sections.length - 1 ) ) ?
#			submit_link_to( "Save and Edit '#{sections[ci+1][:label]}'",
#				:value => 'edit_next') : '' )
			submit( "Save and Edit '#{sections[ci+1][:label]}'".html_safe,
				:name => 'edit_next') : '' )
		s << "</p>\n"
		s << "</div><!-- class='submit_bar' -->"
		s.html_safe
	end

end
