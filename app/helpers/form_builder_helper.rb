module FormBuilderHelper

	#	almost "wrapped"
	def radio_button_with_label(method,value)
		s = ""
#		s = "<div>"
		s << @template.radio_button(object_name,method,value)
		s << @template.label(object_name,method,value,:value => value)
#		s << "</div>"
		s.html_safe
	end

	def found_not_found(method)
		s = "<div>"
		s << @template.label( object_name, method, "Found", {:value => 'yes' })
		s << @template.radio_button( object_name, method, 'yes')
		s << '&nbsp;'
		s << '&nbsp;'
		s << @template.label( object_name, method, "Not Found", {:value => 'no' })
		s << @template.radio_button( object_name, method, 'no')
		s << "</div>"
		s.html_safe
	end

	def yndk_select(method,options={},html_options={})
		@template.select(object_name, method, YNDK.selector_options,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end

	def ynrdk_select(method,options={},html_options={})
		@template.select(object_name, method, YNRDK.selector_options,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end

	def ynodk_select(method,options={},html_options={})
		@template.select(object_name, method, YNODK.selector_options,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end

	def ynordk_select(method,options={},html_options={})
		@template.select(object_name, method, YNORDK.selector_options,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end

	def adna_select(method,options={},html_options={})
		@template.select(object_name, method, ADNA.selector_options,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end

	def pos_neg_select(method, options={}, html_options={})
		@template.select(object_name, method, POSNEG.selector_options,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end

	def submit_bar()
		controller_name = @template.controller.class.name
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
			submit( "Save and Edit '#{sections[ci-1][:label]}'".html_safe,
				:name => 'edit_previous') : '' )
		s << "&nbsp;\n"
		s << (( !ci.nil? && ci < ( sections.length - 1 ) ) ?
			submit( "Save and Edit '#{sections[ci+1][:label]}'".html_safe,
				:name => 'edit_next') : '' )
		s << "</p>\n"
		s << "</div><!-- class='submit_bar' -->"
		s.html_safe
	end

end
ActionView::Helpers::FormBuilder.send(:include, FormBuilderHelper )
