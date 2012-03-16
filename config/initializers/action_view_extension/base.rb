#
#	Now that this is in the app, this could really just be a helper!
#
module ActionViewExtension; end
module ActionViewExtension::Base

	def self.included(base)
		base.send(:include, InstanceMethods)
		base.class_eval do
			alias_method_chain( :method_missing, :wrapping 
				) unless base.respond_to?(:method_missing_without_wrapping)
		end
	end

	module InstanceMethods

		def yndk(value=nil)
			YNDK[value]||'&nbsp;'
		end

		def ynodk(value=nil)
			YNODK[value]||'&nbsp;'
		end

		def ynrdk(value=nil)
			YNRDK[value]||'&nbsp;'
		end

		def adna(value=nil)
			ADNA[value]||'&nbsp;'
		end

		def _wrapped_yndk_spans(object_name,method,options={})
			object = instance_variable_get("@#{object_name}")
			_wrapped_spans(object_name,method,options.update(
				:value => (YNDK[object.send(method)]||'&nbsp;') ) )
		end

		def _wrapped_ynodk_spans(object_name,method,options={})
			object = instance_variable_get("@#{object_name}")
			_wrapped_spans(object_name,method,options.update(
				:value => (YNODK[object.send(method)]||'&nbsp;') ) )
		end

		def _wrapped_ynrdk_spans(object_name,method,options={})
			object = instance_variable_get("@#{object_name}")
			_wrapped_spans(object_name,method,options.update(
				:value => (YNRDK[object.send(method)]||'&nbsp;') ) )
		end

		def _wrapped_adna_spans(object_name,method,options={})
			object = instance_variable_get("@#{object_name}")
			_wrapped_spans(object_name,method,options.update(
				:value => (ADNA[object.send(method)]||'&nbsp;') ) )
		end

		def mdy(date)
			( date.nil? ) ? '&nbsp;' : date.strftime("%m/%d/%Y")
		end

		def time_mdy(time)
			( time.nil? ) ? '&nbsp;' : time.strftime("%I:%M %p %m/%d/%Y")
		end

		def field_wrapper(method,options={},&block)
			classes = [method,options[:class]].compact.join(' ')
			s =  "<div class='#{classes} field_wrapper'>\n"
			s << yield 
			s << "\n</div><!-- class='#{classes}' -->"
			s.html_safe
		end

		#	This is NOT a form field
		def _wrapped_spans(object_name,method,options={})
			s =  "<span class='label'>#{options[:label_text]||method}</span>\n"
			value = if options[:value]
				options[:value]
			else
				object = instance_variable_get("@#{object_name}")
				value = object.send(method)
				value = (value.to_s.blank?)?'&nbsp;':value
			end
			s << "<span class='value'>#{value}</span>"
		end

		def _wrapped_date_spans(object_name,method,options={})
			object = instance_variable_get("@#{object_name}")
			_wrapped_spans(object_name,method,options.update(
				:value => mdy(object.send(method)) ) )
		end

		#	This is NOT a form field
		def _wrapped_yes_or_no_spans(object_name,method,options={})
			object = instance_variable_get("@#{object_name}")
			s =  "<span class='label'>#{options[:label_text]||method}</span>\n"
			value = (object.send("#{method}?"))?'Yes':'No'
			s << "<span class='value'>#{value}</span>"
		end

		def method_missing_with_wrapping(symb,*args, &block)
			method_name = symb.to_s
			if method_name =~ /^wrapped_(.+)$/
				unwrapped_method_name = $1
	#
	#	It'd be nice to be able to genericize all of the
	#	wrapped_* methods since they are all basically
	#	the same.
	#		Strip of the "wrapped_"
	#		Label
	#		Call "unwrapped" method
	#

				object_name = args[0]
				method      = args[1]

				content = field_wrapper(method,:class => unwrapped_method_name) do
					s = if respond_to?(unwrapped_method_name)
						options    = args.detect{|i| i.is_a?(Hash) }
						label_text = options.delete(:label_text) unless options.nil?
						if unwrapped_method_name == 'check_box'
							send("#{unwrapped_method_name}",*args,&block) <<
							label( object_name, method, label_text )
						else
							label( object_name, method, label_text ) <<
							send("#{unwrapped_method_name}",*args,&block)
						end
					else
						send("_#{method_name}",*args,&block)
					end

					s << (( block_given? )? capture(&block) : '')
	#				send("_#{method_name}",*args) << 
	#					(( block_given? )? capture(&block) : '')
				end
				if block_called_from_erb?(block)
					concat(content)
				else
					content
				end
			else
				method_missing_without_wrapping(symb,*args, &block)
			end
		end


		#	Just add the classes 'submit' and 'button'
		#	for styling and function
		def submit_link_to(*args,&block)
			html_options = if block_given?
				args[1] ||= {}
			else
				args[2] ||= {}
			end
			html_options.delete(:value)   #	possible key meant for submit button
			html_options.delete('value')  #	possible key meant for submit button
			( html_options[:class] ||= '' ) << ' submit button'
			link_to( *args, &block )
		end


		def form_link_to( title, url, options={}, &block )
	#			"action='#{url}' " <<
			extra_tags = extra_tags_for_form(options)
			s =  "\n" <<
				"<form " <<
				"class='#{options.delete(:class)||'form_link_to'}' " <<
				"action='#{url_for(url)}' " <<
				"method='#{options.delete('method')}'>\n" <<
				extra_tags << "\n"
			s << (( block_given? )? capture(&block) : '')
			s << submit_tag(title, :name => nil ) << "\n" <<
				"</form>\n"
			if block_called_from_erb?(block)
				concat(s)
			else
				s
			end
		end

		def destroy_link_to( title, url, options={}, &block )
			s = form_link_to( title, url, options.merge(
				'method' => 'delete',
				:class => 'destroy_link_to'
			),&block )
		end

#
#	20120316 : Don't believe that this is used anymore
#
#		def aws_image_tag(image,options={})
#			#	in console @controller is nil
#			protocol = @controller.try(:request).try(:protocol) || 'http://'
#			host = 's3.amazonaws.com/'
#			bucket = ( defined?(RAILS_APP_NAME) && RAILS_APP_NAME ) || 'ccls'
#			src = "#{protocol}#{host}#{bucket}/images/#{image}"
#			alt = options.delete(:alt) || options.delete('alt') || image
#			tag('img',options.merge({:src => src, :alt => alt}))
#		end
#
#
#	20120316 : Don't believe that this is used anymore
#
#		#	This style somehow for some reason actually submits the request TWICE?
#		#	In many cases, this is no big deal, but when using it to send
#		#	emails or something, the controller/action is called twice
#		#	resulting in 2 emails (if that's what your action does)
#		#	I'd really like to understand why.
#		def button_link_to( title, url, options={} )
#			classes = ['link']
#			classes << options[:class]
#			s =  "<a href='#{url_for(url)}' style='text-decoration:none;'>"
#			s << "<button type='button'>"
#			s << title
#			s << "</button></a>\n"
#		end
#
#
#	20120316 : Don't believe that this is used anymore
#
#		#	This creates a button that looks like a submit button
#		#	but is just a javascript controlled link.
#		#	I don't like it.
#		def old_button_link_to( title, url, options={} )
#	#		id = "id='#{options[:id]}'" unless options[:id].blank?
#	#		klass = if options[:class].blank?
#	#			"class='link'"
#	#		else
#	#			"class='#{options[:class]}'"
#	#		end
#	#		s =  "<button #{id} #{klass} type='button'>"
#			classes = ['link']
#			classes << options[:class]
#			s =  "<button class='#{classes.flatten.join(' ')}' type='button'>"
#			s << "<span class='href' style='display:none;'>"
#			s << url_for(url)
#			s << "</span>"
#			s << title
#			s << "</button>"
#			s
#		end

		def flasher
			s = ''
			flash.each do |key, msg|
				s << content_tag( :p, msg, :id => key, :class => 'flash' )
				s << "\n"
			end
			s << "<noscript><p id='noscript' class='flash'>\n"
			s << "Javascript is required for this site to be fully functional.\n"
			s << "</p></noscript>\n"
			s.html_safe
		end

		#	Created to stop multiple entries of same stylesheet
		def stylesheets(*args)
			@stylesheets ||= []
			args.each do |stylesheet|
				unless @stylesheets.include?(stylesheet.to_s)
					@stylesheets.push(stylesheet.to_s)
					content_for(:head,stylesheet_link_tag(stylesheet.to_s))
				end
			end
		end

		def javascripts(*args)
			@javascripts ||= []
			args.each do |javascript|
				unless @javascripts.include?(javascript.to_s)
					@javascripts.push(javascript.to_s)
					content_for(:head,javascript_include_tag(javascript).to_s)
				end
			end
		end

	end	#	module InstanceMethods

end	#	module ActionViewExtension::Base
ActionView::Base.send(:include, ActionViewExtension::Base )
