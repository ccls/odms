# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def odms_main_menu
		s = "<div id='mainmenu'>\n"

		s << "<div class='menu_item#{( 
				params[:controller] == 'pages' ) ? ' current' : nil}'>" <<
			link_to('Home', root_path) <<
			"</div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'study_subjects' ) ? ' current' : nil}'>" <<
			link_to('Subjects', dashboard_study_subjects_path ) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('New Case', new_case_path),
				link_to('New Control', cases_path),
#				link_to('Manage Birth Certificates', birth_certificates_path)
#				link_to('Manage Birth Certificates', new_bc_request_path)
				link_to('Birth Data Requests', new_bc_request_path)
			].join("\n    ") <<
			"</div><!-- sub_menu --></div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'interviews' ) ? ' current' : nil}'>" <<
			link_to('Interviews', dashboard_interviews_path) <<
			"</div><!-- menu_item -->" if (
			logged_in? and current_user.may_administrate? )

		s << "<div class='menu_item#{( 
				params[:controller] == 'samples' ) ? ' current' : nil}'>" <<
			link_to('Samples', dashboard_samples_path) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('New/Receive Sample', new_receive_sample_path),
				'<span>Manage Samples</span>'
			].join("\n    ") <<
			"</div><!-- sub_menu --></div><!-- menu_item -->"

#		s << "<div class='menu_item#{( 
#				params[:controller] == 'studies' ) ? ' current' : nil}'>" <<
#			link_to('Studies', dashboard_studies_path) <<
#			"</div><!-- menu_item -->"

		s << "<div class='menu_item'>#{link_to( "Admin", '/admin' )}</div>" if(
			logged_in? and current_user.may_administrate? )

		s << "\n</div><!-- mainmenu -->\n"
		s.html_safe
	end

	def id_bar_for(object,&block)
		case object
			when StudySubject  then study_subject_id_bar(object,&block)
#			when GiftCard then gift_card_id_bar(object,&block)
			else nil
		end
	end

	def sub_menu_for(object)
		case object
			when StudySubject   then study_subject_sub_menu(object)
#			when Interview then interview_sub_menu(object)
			else nil
		end
	end

	def birth_certificates_sub_menu
		#	added the to_s's to ensure not nil
		current = case params[:controller].to_s
			when 'bc_requests' 
				case params[:action].to_s
					when 'new' then :new_bc_request
					when 'index' 
						case params[:status].to_s
							when 'pending'  then :pending_bc_requests
							when 'active'   then :active_bc_requests
							when 'waitlist' then :waitlist_bc_requests
							when 'complete' then :complete_bc_requests
							else :all_bc_requests
						end
					else nil
				end
#			when( params[:controller] == 'bc_validations' )
#				:bc_validations
			else nil
		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
			links = [
#				link_to( "New BC Request", new_bc_request_path,
				link_to( "New Requests", new_bc_request_path,
					:class => ((current == :new_bc_request)?'current':nil) ),
#				link_to( "BC Validation", bc_validations_path,
#					:class => ((current == :bc_validations)?'current':nil) ),

				"<hr/>",
				link_to( "All Requests", bc_requests_path,
					:class => ((current == :all_bc_requests)?'current':nil) ),
				link_to( "Active Requests", bc_requests_path(:status => 'active'),
					:class => ((current == :active_bc_requests)?'current':nil) ),
				link_to( "Waitlist Requests", bc_requests_path(:status => 'waitlist'),
					:class => ((current == :waitlist_bc_requests)?'current':nil) ),
				link_to( "Pending Requests", bc_requests_path(:status => 'pending'),
					:class => ((current == :pending_bc_requests)?'current':nil) ),
				link_to( "Complete Requests", bc_requests_path(:status => 'complete'),
					:class => ((current == :complete_bc_requests)?'current':nil) )

			]
#			links << "<span>Request History</span>"
			s << links.join("\n")
			s << "\n</div><!-- submenu -->\n"
			s.html_safe
#	NOTE test this as I suspect that it needs an "html_safe" added
		end
	end

	def study_subject_sub_menu(study_subject)
		current = case params[:controller]
			when 'study_subjects' then :general
			when 'patients' then :hospital
			when 'addresses' then :contact
			when 'addressings' then :contact
			when 'contacts' then :contact
			when 'phone_numbers' then :contact
			when 'consents' then :consents
			when 'enrollments' then :eligibility
			when 'samples' then :samples
			when 'interviews' then :interviews
			when 'events' then :events
			when 'documents' then :documents
			when 'notes' then :notes
			when 'related_subjects' then :related_subjects
#			when 'cases' then :cases
#			else nil
		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
			links = [
				link_to( "back to subjects", dashboard_study_subjects_path ),
				link_to( "Basic Info", study_subject_path(study_subject),
					:class => ((current == :general)?'current':nil) ),
				link_to( "Address &amp; Phone", study_subject_contacts_path(study_subject),
					:class => ((current == :contact)?'current':nil) ),
				link_to( "Hospital / Medical", study_subject_patient_path(study_subject),
					:class => ((current == :hospital)?'current':nil) ),
				link_to( "Eligibility &amp; Consent", study_subject_consent_path(study_subject),
					:class => ((current == :consents)?'current':nil) ),
				link_to( "Enrollments",study_subject_enrollments_path(study_subject),
					:class => ((current == :eligibility)?'current':nil) ) ]

			links += [
				link_to( "Samples", study_subject_samples_path(study_subject),
					:class => ((current == :samples)?'current':nil) ),
				link_to( "Interviews", study_subject_interviews_path(study_subject),
					:class => ((current == :interviews)?'current':nil) ) 
			] if( logged_in? and current_user.may_administrate? )

			links << link_to( "Events", study_subject_events_path(study_subject),
					:class => ((current == :events)?'current':nil) )

			links += [
				link_to( "Documents", study_subject_documents_path(study_subject),
					:class => ((current == :documents)?'current':nil) ),
				link_to( "Notes", study_subject_notes_path(study_subject),
					:class => ((current == :notes)?'current':nil) ),
			] if( logged_in? and current_user.may_administrate? )

			links << link_to( "Related Subjects", related_subject_path(study_subject),
					:class => ((current == :related_subjects)?'current':nil) )
			s << links.join("\n")
			s << "\n</div><!-- submenu -->\n"
			s.html_safe
#	NOTE test this as I suspect that it needs an "html_safe" added
		end
	end

	def control_bar
		s  = "<div id='dashboard_control_bar'>"
		links = []
		links << link_to( 'dashboard', 
			{ :controller => params[:controller], :action => :dashboard },
			:class => (params[:action] == 'dashboard') ? 'current' : nil )
		links << link_to( 'find', 
			{ :controller => params[:controller], :action => :find },
			:class => (params[:action] == 'find') ? 'current' : nil )
		links << link_to( 'follow-up', 
			{ :controller => params[:controller], :action => :followup },
			:class => (params[:action] == 'followup') ? 'current' : nil )
		links << link_to( 'reports', 
			{ :controller => params[:controller], :action => :reports },
			:class => (params[:action] == 'reports') ? 'current' : nil )
		s << links.join('&nbsp;')
		s << "</div>"
		s.html_safe
	end

	#	Overrides the method of the same name in ccls_engine
	#	Used to replace the _id_bar partial
	def subject_id_bar(study_subject,&block)
		stylesheets('study_subject_id_bar')
		content_for :subject_header do
			s = "<div id='id_bar'>\n" <<
			"<div class='full_name'>\n" <<
			"<span>#{study_subject.full_name}</span>\n" <<
			"</div><!-- class='full_name' -->\n" <<
			"<div class='id_numbers'>" <<
#			"<div class='childid'>\n" <<
#			"<span>ChildID:</span>\n" <<
#			"<span>#{study_subject.try(:childid)}</span>\n" <<
#			"</div><!-- class='childid' -->\n" <<
			"<div class='icf_master_id'>\n" <<
			"<span>ICFMasterID:</span>\n" <<
#			"<span>#{study_subject.try(:icf_master_id)}</span>\n" <<
			"<span>#{study_subject.icf_master_id_to_s}</span>\n" <<	#	TODO add test for this
			"</div><!-- class='icf_master_id' -->\n" <<
			"<div class='studyid'>\n" <<
			"<span>StudyID:</span>\n" <<
#			"<span>#{study_subject.try(:studyid)}</span>\n" <<
			"<span>#{study_subject.studyid_to_s}</span>\n" <<		#	TODO add test for this
			"</div><!-- class='studyid' -->\n" <<
			"</div><!-- class='id_numbers' -->\n" <<
			"</div><!-- id='id_bar' -->\n"
			s.html_safe
		end

		content_for :main do
			s = "<div id='do_not_contact'>\n" <<
			"Study Subject requests no further contact with Study.\n" <<
			"</div>\n"
			s.html_safe
		end if study_subject.try(:do_not_contact?)
	end	#	id_bar_for
	alias_method :study_subject_id_bar, :subject_id_bar


	#	Just a simple method to wrap the passed text in a span
	#	with class='required'
	def required(text)
		s = "<span class='required'>#{text}</span>"
		s.html_safe
	end
	alias_method :req, :required


	def sort_up_image
		"#{Rails.root}/public/images/sort_up.png"
	end

	def sort_down_image
		"#{Rails.root}/public/images/sort_down.png"
	end

	#	&uarr; and &darr;
	def sort_link(column,text=nil)
		#	make local copy so mods to muck up real params which
		#	may still be references elsewhere.
		local_params = params.dup

#
#	May want to NOT flip dir for other columns.  Only the current order.
#	Will wait until someone else makes the suggestion.
#
		order = column.to_s.downcase.gsub(/\s+/,'_')
		dir = ( local_params[:dir] && local_params[:dir] == 'asc' ) ? 'desc' : 'asc'

		local_params[:page] = nil
		link_text = text||column
		classes = ['sortable',order]
		arrow = ''
		if local_params[:order] && local_params[:order] == order
			classes.push('sorted')
			arrow = if dir == 'desc'
				if File.exists? sort_down_image
					image_tag( File.basename(sort_down_image), :class => 'down arrow')
				else
					"<span class='down arrow'>&darr;</span>"
				end
			else
				if File.exists? sort_up_image
					image_tag( File.basename(sort_up_image), :class => 'up arrow')
				else
					"<span class='up arrow'>&uarr;</span>"
				end
			end
		end
		s = "<div class='#{classes.join(' ')}'>"
		s << link_to(link_text,local_params.merge(:order => order,:dir => dir))
		s << arrow unless arrow.blank?
		s << "</div>"
		s.html_safe
#	NOTE test this as I suspect that it needs an "html_safe" added
	end

	def user_roles
		s = ''
		if current_user.may_administrate?
			s << "<ul>"
			@roles.each do |role|
				s << "<li>"
				if @user.role_names.include?(role.name)
#	TODO rails 3 does some new stuff for links with methods?
#	data-method, etc.
#					s << link_to( "Remove user role of '#{role.name}'", 
					s << button_to( "Remove user role of '#{role.name}'", 
						user_role_path(@user,role.name),
						:method => :delete )
				else
#	TODO rails 3 does some new stuff for links with methods?
#	data-method, etc.
#					s << link_to( "Assign user role of '#{role.name}'", 
					s << button_to( "Assign user role of '#{role.name}'", 
						user_role_path(@user,role.name),
						:method => :put )
				end
				s << "</li>\n"
			end
			s << "</ul>\n"
		end
		s.html_safe
	end


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
#				if block_called_from_erb?(block)
#					concat(content)
#				else
				content
#				end
		else
			method_missing_without_wrapping(symb,*args, &block)
		end
	end
	alias_method_chain( :method_missing, :wrapping )	unless respond_to?(:method_missing_without_wrapping)




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


#	TODO replace me with button_to calls
#	Can't remove until destroy_link_to is gone
	def form_link_to( title, url, options={}, &block )
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
		s.html_safe
	end

#	TODO replace me with button_to calls
	def destroy_link_to( title, url, options={}, &block )
		s = form_link_to( title, url, options.merge(
			'method' => 'delete',
			:class => 'destroy_link_to'
		),&block )
	end

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
				@javascripts.push(javascript.to_s)	#	remember
				content_for(:head,javascript_include_tag(javascript).to_s)
			end
		end
	end

end	#	module ApplicationHelper
