#module ActionViewExtension; end
#module ActionViewExtension::FormBuilder
module FormBuilderHelper

#	why include after included?
#	there are no class methods, so just keep it simple.
#	def self.included(base)
#		base.send(:include,InstanceMethods)
#	end
#
#	module InstanceMethods

#	TODO	add tests for this
#	COMING SOON
#		Replacement for Rails 3 deprecated helper.

		def error_messages
			if self.object.errors.count > 0
				s  = '<div id="errorExplanation" class="errorExplanation">'
				s << "<h2>#{self.object.errors.count} #{"error".pluralize(self.object.errors.count)} prohibited this #{self.object.class} from being saved:</h2>"
				s << '<p>There were problems with the following fields:</p>'
				s << '<ul>'
				self.object.errors.full_messages.each do |msg|
					s << "<li>#{msg}</li>"
				end
				s << '</ul></div>'
				s.html_safe
			end
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

		def adna_select(method,options={},html_options={})
			@template.select(object_name, method, ADNA.selector_options,
				{:include_blank => true}.merge(objectify_options(options)), html_options)
		end

#		def hour_select(method,options={},html_options={})
#			@template.select(object_name, method,
#				(1..12),
#				{:include_blank => 'Hour'}.merge(options), html_options)
#		end
#
#		def minute_select(method,options={},html_options={})
#			minutes = (0..59).to_a.collect{|m|[sprintf("%02d",m),m]}
#			@template.select(object_name, method,
#				minutes,
#				{:include_blank => 'Minute'}.merge(options), html_options)
#		end
#
#		def meridiem_select(method,options={},html_options={})
#			@template.select(object_name, method,
#				['AM','PM'], 
#				{:include_blank => 'Meridiem'}.merge(options), html_options)
#		end

	def pos_neg_select(method, options={}, html_options={})
#		@template.select(object_name, method,
#			[['Positive',1],['Negative',2]],
		@template.select(object_name, method, POSNEG.selector_options,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end

		def sex_select(method,options={},html_options={})
			@template.select(object_name, method,
				[['-select-',''],['male','M'],['female','F'],["don't know",'DK']],
				options, html_options)
		end
		alias_method :gender_select, :sex_select

		def date_text_field(method, options = {})
			format = options.delete(:format) || '%m/%d/%Y'
			tmp_value = if options[:value].blank? #and !options[:object].nil?
#				object = options[:object]
				tmp = self.object.send("#{method}") ||
				      self.object.send("#{method}_before_type_cast")
			else
				options[:value]
			end
			begin
				options[:value] = tmp_value.to_date.try(:strftime,format)
			rescue NoMethodError, ArgumentError
				options[:value] = tmp_value
			end
			options.update(:class => [options[:class],'datepicker'].compact.join(' '))
			@template.text_field( object_name, method, options )
		end

		def datetime_text_field(method, options = {})
			format = options.delete(:format) || '%m/%d/%Y %H:%M'
			tmp_value = if options[:value].blank?
				tmp = self.object.send("#{method}") ||
				      self.object.send("#{method}_before_type_cast")
			else
				options[:value]
			end
			begin
				options[:value] = tmp_value.to_datetime.try(:strftime,format)
			rescue NoMethodError, ArgumentError
				options[:value] = tmp_value
			end
			options.update(:class => [options[:class],'datetimepicker'].compact.join(' '))
			@template.text_field( object_name, method, options )
		end


		def wrapped_check_box(*args,&block)
			method      = args[0]
			content = @template.field_wrapper(method,:class => 'check_box') do
				options    = args.detect{|i| i.is_a?(Hash) }
				label_text = options.delete(:label_text) unless options.nil?
#	INVERTED ORDER SO NOT INCLUDED BELOW
				s  = check_box(*args,&block) <<
					self.label( method, label_text )
				s << (( block_given? )? @template.capture(&block) : '')
			end
			content.html_safe
		end

#	special
#		def wrapped_check_box(*args,&block)

#
#	This isn't pretty, but does appear to work.
#	Dynamically defined using a class_eval rather than
#	define_method. And no method_missing.
#
		%w( adna_select collection_select country_select 
				datetime_select date_text_field datetime_text_field 
				file_field
				hour_select minute_select meridiem_select
				grouped_collection_select pos_neg_select select sex_select text_area
				text_field yndk_select ynodk_select ynrdk_select 
			).each do |unwrapped_method_name|
class_eval %Q"
		def wrapped_#{unwrapped_method_name}(*args,&block)
			method      = args[0]
			content = @template.field_wrapper(method,:class => '#{unwrapped_method_name}') do
				options    = args.detect{|i| i.is_a?(Hash) }
				label_text = options.delete(:label_text) unless options.nil?
				s  = self.label( method, label_text ) <<
					#{unwrapped_method_name}(*args,&block)
				s << (( block_given? )? @template.capture(&block) : '')
			end
			content.html_safe
		end
"
end

#
#	wouldn't the controller name already be accessible and therefore
#	not need to be passed as a parameter?
#
#	Possibly, but not directly. Actually, through @template
#
	def submit_bar(ignore_incoming_controller_name)
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

#	end	#	module InstanceMethods

end
ActionView::Helpers::FormBuilder.send(:include, FormBuilderHelper )
