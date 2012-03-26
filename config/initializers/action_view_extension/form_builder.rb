module ActionViewExtension; end
module ActionViewExtension::FormBuilder

	def self.included(base)
		base.send(:include,InstanceMethods)
		base.class_eval do
			alias_method_chain( :method_missing, :field_wrapping 
				) unless base.respond_to?(:method_missing_without_field_wrapping)
		end
	end

	module InstanceMethods



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






#	NOTE 
#		calling <%= f.wrapped_yndk_select :code %> will NOT call these methods.
#		It will call the method missing and then the @template.method
#		Actually, now I believe that it will.
#

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

		def submit_link_to(value=nil,options={})
			#	submit_link_to will remove :value, which is intended for submit
			#	so it MUST be executed first.  Unfortunately, my javascript
			#	expects it to be AFTER the a tag.
	#		s = submit(value,options.reverse_merge(
	#				:id => "#{object_name}_submit_#{value.try(:downcase).try(:gsub,/\s+/,'_')}"
	#			) ) << @template.submit_link_to(value,nil,options)
			s1 = submit(value,options.reverse_merge(
					:id => "#{object_name}_submit_#{value.try(:downcase).try(
						:gsub,/\s+/,'_').try(
						:gsub,/(&amp;|'|\/)/,'').try(
						:gsub,/_+/,'_')}"
				) ) 
			s2 = @template.submit_link_to(value,nil,options)
			s2 << s1
		end 

		def hour_select(method,options={},html_options={})
			@template.select(object_name, method,
				(1..12),
				{:include_blank => 'Hour'}.merge(options), html_options)
		end

		def minute_select(method,options={},html_options={})
			minutes = (0..59).to_a.collect{|m|[sprintf("%02d",m),m]}
			@template.select(object_name, method,
				minutes,
				{:include_blank => 'Minute'}.merge(options), html_options)
		end

		def meridiem_select(method,options={},html_options={})
			@template.select(object_name, method,
				['AM','PM'], 
				{:include_blank => 'Meridiem'}.merge(options), html_options)
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

		def method_missing_with_field_wrapping(symb,*args, &block)
			method_name = symb.to_s
			if method_name =~ /^wrapped_(.+)$/
				unwrapped_method_name = $1	#	check_box, select, ...
				method      = args[0]	#	attribute name
				content = @template.field_wrapper(method,:class => unwrapped_method_name) do
					s = if respond_to?(unwrapped_method_name)
						options    = args.detect{|i| i.is_a?(Hash) }
						label_text = options.delete(:label_text) unless options.nil?
						if unwrapped_method_name == 'check_box'
							send("#{unwrapped_method_name}",*args,&block) <<
							self.label( method, label_text )
						else
							self.label( method, label_text ) <<
							send("#{unwrapped_method_name}",*args,&block)
						end
					else
						send("_#{method_name}",*args,&block)
					end
					s << (( block_given? )? @template.capture(&block) : '')
				end
				#	ActionView::TemplateError (private method `block_called_from_erb?' 
#				( @template.send(:block_called_from_erb?,block) ) ? 
#					@template.concat(content) : content
content.html_safe
			else
				method_missing_without_field_wrapping(symb,*args, &block)
			end
		end

#		%w( adna_select date_text_field hour_select meridiem_select minute_select sex_select
#				yndk_select ynodk_select ynrdk_select ).each do |unwrapped_method_name|
##	can't define methods that accept blocks in ruby 1.8
##
##	could try it with class eval?
##	http://stackoverflow.com/questions/9561072/ruby-using-class-eval-to-define-methods
##
#			define_method "wrapped_#{unwrapped_method_name}" do |*args, &block|
#				method      = args[0]
#				content = @template.field_wrapper(method,:class => unwrapped_method_name) do
#					s = if respond_to?(unwrapped_method_name)
#						options    = args.detect{|i| i.is_a?(Hash) }
#						label_text = options.delete(:label_text) unless options.nil?
#						if unwrapped_method_name == 'check_box'
#							send("#{unwrapped_method_name}",*args,&block) <<
#							self.label( method, label_text )
#						else
#							self.label( method, label_text ) <<
#							send("#{unwrapped_method_name}",*args,&block)
#						end
#					else
#						send("_wrapped_#{unwrapped_method_name}",*args,&block)
#					end
##	one of these should work.  
##					s << (( block_given? )? @template.capture(&block) : '')
##					s << ( ( block_given? ) ? yield : '' )
##					s << ( ( block_given? ) ? block.call : '' )
##					s << block.call if block_given?
#				end
#				content.html_safe
#			end
#		end


#	This way just raises errors
#	ArgumentError: wrong number of arguments (0 for 1)
#		%w( adna_select date_text_field hour_select meridiem_select minute_select sex_select
#				yndk_select ynodk_select ynrdk_select ).each do |unwrapped_method_name|
#class_eval <<EOF
#			def wrapped_#{unwrapped_method_name}(*args, &block)
#				method      = args[0]
#				content = @template.field_wrapper(method,:class => #{unwrapped_method_name}) do
#					s = if respond_to?(unwrapped_method_name)
#						options    = args.detect{|i| i.is_a?(Hash) }
#						label_text = options.delete(:label_text) unless options.nil?
#						if #{unwrapped_method_name} == 'check_box'
#							send("#{unwrapped_method_name}",*args,&block) <<
#							self.label( method, label_text )
#						else
#							self.label( method, label_text ) <<
#							send("#{unwrapped_method_name}",*args,&block)
#						end
#					else
#						send("_wrapped_#{unwrapped_method_name}",*args,&block)
#					end
#					s << (( block_given? )? @template.capture(&block) : '')
#				end
#				content.html_safe
#			end
#EOF
#		end

	end	#	module InstanceMethods

end
ActionView::Helpers::FormBuilder.send(:include, ActionViewExtension::FormBuilder )
