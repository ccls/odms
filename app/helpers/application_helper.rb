# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def nbsp
		"&nbsp;".html_safe
	end

	def odms_main_menu
		s = "<div id='mainmenu'>\n"

		s << "<div class='menu_item#{( 
				params[:controller] == 'pages' ) ? ' current' : nil}'>" <<
			link_to('Home', root_path) <<
			"</div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'study_subjects' ) ? ' current' : nil}'>" <<
			link_to('Subjects', find_study_subjects_path ) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('Dashboard', dashboard_study_subjects_path ),
				link_to('New Case', new_case_path),
				link_to('New Control', cases_path),
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
			link_to('Samples', find_samples_path) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('Dashboard', dashboard_samples_path),
				link_to('New/Receive Sample', new_receive_sample_path),
				link_to('Sample Transfers', sample_transfers_path)
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
			else nil
		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
			links = [
				link_to( "New Requests", new_bc_request_path,
					:class => ((current == :new_bc_request)?'current':nil) ),
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

	def subject_side_menu(study_subject)
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
			when 'birth_records' then :birth_record
#	this will catch abstracts, study_subject_abstracts and 
#		all of the abstract/whatevers
			when /abstract/ then :abstracts
			else nil
		end

		return '' unless study_subject
		s = "<div id='sidemenu'>\n"
			links = []
#			if request.env["HTTP_REFERER"] =~ /study_subjects\/find\?/
			if request.env["HTTP_REFERER"] =~ /study_subjects\/find/
				links << link_to( "back to search", request.env["HTTP_REFERER"] )
			end
#				link_to( "back to subjects", dashboard_study_subjects_path ),
			links += [
				link_to( "Basic Info", study_subject_path(study_subject),
					:class => ((current == :general)?'current':nil) ),
				link_to( "Address & Phone", study_subject_contacts_path(study_subject),
					:class => ((current == :contact)?'current':nil) ),
				link_to( "Hospital / Medical", study_subject_patient_path(study_subject),
					:class => ((current == :hospital)?'current':nil) ) ]

			links += [
				link_to( "Birth Record", study_subject_birth_record_path(study_subject),
					:class => ((current == :birth_record)?'current':nil) )
			] if( logged_in? and current_user.may_administrate? )

			links += [
				link_to( "Eligibility & Consent", study_subject_consent_path(study_subject),
					:class => ((current == :consents)?'current':nil) ),
				link_to( "Enrollments",study_subject_enrollments_path(study_subject),
					:class => ((current == :eligibility)?'current':nil) ),
				link_to( "Samples", study_subject_samples_path(study_subject),
					:class => ((current == :samples)?'current':nil) )]

			links += [
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

			links << link_to( "Related Subjects", 
					study_subject_related_subjects_path(study_subject),
					:class => ((current == :related_subjects)?'current':nil) )
			links << link_to( "Abstracts", study_subject_abstracts_path(study_subject),
					:class => ((current == :abstracts)?'current':nil) )
			links << "<span>&nbsp;</span>"
			links << "<div><span>#{link_to('&laquo;&nbsp;prev'.html_safe, prev_study_subject_path(@study_subject, :c => params))}</span><span class='right'>#{link_to('next&nbsp;&raquo;'.html_safe,next_study_subject_path(@study_subject, :c => params))}</span></div>"
			s << links.join("\n")
			s << "\n</div><!-- submenu -->\n"
		s.html_safe
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

	def subject_id_bar(study_subject)
		s = if study_subject
			"<div id='id_bar'>\n" <<
			"<div class='full_name'>\n" <<
			"<span>#{study_subject.full_name}</span>\n" <<
			"</div><!-- class='full_name' -->\n" <<
			"<div class='id_numbers'>" <<
			"<div class='icf_master_id'>\n" <<
			"<span>ICFMasterID:</span>\n" <<
			"<span>#{study_subject.icf_master_id_to_s}</span>\n" <<	#	TODO add test for this
			"</div><!-- class='icf_master_id' -->\n" <<
			"<div class='studyid'>\n" <<
			"<span>StudyID:</span>\n" <<
			"<span>#{study_subject.studyid_to_s}</span>\n" <<		#	TODO add test for this
			"</div><!-- class='studyid' -->\n" <<
			"</div><!-- class='id_numbers' -->\n" <<
			"</div><!-- id='id_bar' -->\n"
		else
			''
		end
		s.html_safe
	end

	def do_not_contact(study_subject)
		s = if study_subject.try(:do_not_contact?)
			"<div id='do_not_contact'>\n" <<
				"Study Subject requests no further contact with Study.\n" <<
				"</div>\n"
		else
			''
		end 
		s.html_safe
	end

	#	Just a simple method to wrap the passed text in a span
	#	with class='required'
	def required(text)
		s = "<span class='required'>#{text}</span>"
		s.html_safe
	end
	alias_method :req, :required


	def sort_up_image
#		"#{Rails.root}/public/images/sort_up.png"
		"#{Rails.root}/app/assets/images/sort_up.png"
	end

	def sort_down_image
#		"#{Rails.root}/public/images/sort_down.png"
		"#{Rails.root}/app/assets/images/sort_down.png"
	end

	#	&uarr; and &darr;
#	def sort_link(column,text=nil)
	def sort_link(*args)
		options = {
			:image => true
		}.merge(args.extract_options!)
		column = args[0]
		text = args[1]
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
				if File.exists?( sort_down_image ) && options[:image]
					image_tag( File.basename(sort_down_image), :class => 'down arrow')
				else
					"<span class='down arrow'>&darr;</span>"
				end
			else
				if File.exists?( sort_up_image ) && options[:image]
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
		(YNDK[value]||'&nbsp;').html_safe
	end

	def ynodk(value=nil)
		(YNODK[value]||'&nbsp;').html_safe
	end

	def ynrdk(value=nil)
		(YNRDK[value]||'&nbsp;').html_safe
	end

	def adna(value=nil)
		(ADNA[value]||'&nbsp;').html_safe
	end

	def pos_neg(value=nil)
		(POSNEG[value]||'&nbsp;').html_safe
	end
	alias_method :posneg, :pos_neg

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

	def _wrapped_pos_neg_spans(object_name,method,options={})
		object = instance_variable_get("@#{object_name}")
		_wrapped_spans(object_name,method,options.update(
			:value => (POSNEG[object.send(method)]||'&nbsp;') ) )
	end

	def mdy(date)
		(( date.nil? ) ? '&nbsp;' : date.strftime("%m/%d/%Y")).html_safe
	end

	def mdyhm(datetime)
		(( datetime.nil? ) ? '&nbsp;' : datetime.strftime("%m/%d/%Y %H:%M (%Z)")).html_safe
	end

	#	For use in CSV output as don't want the &nbsp;
	def mdyhm_or_nil(datetime)
		datetime.strftime("%m/%d/%Y %H:%M (%Z)") unless datetime.blank?
	end

	#	For use in CSV output as don't want the &nbsp;
	def mdy_or_nil(datetime)
		datetime.strftime("%m/%d/%Y") unless datetime.blank?
	end

	def time_mdy(time)
		(( time.nil? ) ? '&nbsp;' : time.strftime("%I:%M %p %m/%d/%Y")).html_safe
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

	def _wrapped_datetime_spans(object_name,method,options={})
		object = instance_variable_get("@#{object_name}")
		_wrapped_spans(object_name,method,options.update(
			:value => mdyhm(object.send(method)) ) )
	end

	#	This is NOT a form field
	def _wrapped_yes_or_no_spans(object_name,method,options={})
		object = instance_variable_get("@#{object_name}")
		s =  "<span class='label'>#{options[:label_text]||method}</span>\n"
		value = (object.send("#{method}?"))?'Yes':'No'
		s << "<span class='value'>#{value}</span>"
	end

	%w( adna_spans date_spans datetime_spans pos_neg_spans spans yes_or_no_spans 
			yndk_spans ynrdk_spans ynodk_spans ).each do |unwrapped_method_name|
#
#	Can't define a method that accepts a block with define_method.
#	I don't think that I need it, so no big deal. For now.
#	HOWEVER, in the form builder, I do send blocks, so I'll need to fix this or
#	just explicitly write a method for those that need it.
#

		define_method "wrapped_#{unwrapped_method_name}" do |*args|
			object_name = args[0]
			method      = args[1]
			content = field_wrapper(method,:class => unwrapped_method_name) do
				#	all of my methods have _wrapped_* versions so far, 
				#	but this could probably be simplified
				send("_wrapped_#{unwrapped_method_name}",*args)
			end
			content
		end
	end

#
#	NOTE I'm surprised that I used the key for the id.
#		I should just add it to the classes.
#
	def flasher
		s = ''
		flash.each do |key, msg|
			unless msg.blank?
				s << content_tag( :p, msg.html_safe, :class => "flash #{key}" )
#				s << content_tag( :p, msg.html_safe, :id => key, :class => 'flash' )
				s << "\n"
			end
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
