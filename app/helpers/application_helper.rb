# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	#	t is RedCloth.textualize NOT I18n.translate

	def odms_main_menu
		s = "<div id='mainmenu'>\n"

		s << "<div class='menu_item#{( 
				params[:controller] == 'pages' ) ? ' current' : nil}'>" <<
			link_to('Home', root_path) <<
			"</div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'study_subjects' ) ? ' current' : nil}'>" <<
			link_to('Subjects', study_subjects_path ) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('Dashboard', dashboard_study_subjects_path ),
				link_to('New Case (RAF)', new_raf_path),

#	not doing controls anymore, and /controls/new takes over a minute to load
#				link_to('New Control', new_control_path),

				link_to('Birth Data Requests', new_bc_request_path),
				link_to('Blood Spot Requests', new_blood_spot_request_path),
				link_to('Med Rec Requests', new_medical_record_request_path),
				link_to('Abstracts', abstracts_path)
			].join("\n    ") <<
			"</div><!-- sub_menu --></div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'interviews' ) ? ' current' : nil}'>" <<
			link_to('Interviews', dashboard_interviews_path) <<
			"</div><!-- menu_item -->" if (
			logged_in? and current_user.may_administrate? )

		s << "<div class='menu_item#{( 
				params[:controller] == 'samples' ) ? ' current' : nil}'>" <<
			link_to('Samples', samples_path) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('Dashboard', dashboard_samples_path),
				link_to('New/Receive Sample', new_receive_sample_path),
				link_to('Sample Transfers', sample_transfers_path)
			].join("\n    ") <<
			"</div><!-- sub_menu --></div><!-- menu_item -->"

#		s << "<div class='menu_item#{( 
#				params[:controller] == 'interviews' ) ? ' current' : nil}'>" <<
#			link_to('Interviews', dashboard_interviews_path) <<
		s << "<div class='menu_item'>" <<
			"<a>Data Transfers</a>" <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('Birth Data Requests', new_bc_request_path),
				link_to('Med Rec Requests', new_medical_record_request_path),
				link_to('Blood Spot Requests', new_blood_spot_request_path),
				link_to('Case Assignment', cases_path)
#				"<span>Subject Data</span>",
#				"<span>Tracking Data</span>"
			].join("\n    ") <<
			"</div><!-- sub_menu --></div><!-- menu_item -->" if (
			logged_in? and current_user.may_edit? )

#		s << "<div class='menu_item#{( 
#				params[:controller] == 'studies' ) ? ' current' : nil}'>" <<
#			link_to('Studies', dashboard_studies_path) <<
#			"</div><!-- menu_item -->"

		s << "<div class='menu_item'>#{link_to( "Admin", '/admin' )}</div>" if(
			logged_in? and current_user.may_administrate? )

		s << "\n</div><!-- mainmenu -->\n"
		s << "<form id='icf_master_id_form' action='#{by_study_subjects_path}' method='get'><label>ICF Master ID:</label><input name='icf_master_id' type='text'/><input type='submit' value='go'/></form>"
		s.html_safe
	end

	def medical_records_sub_menu
		#	added the to_s's to ensure not nil
		current = case params[:controller].to_s
			when 'medical_record_requests' 
				case params[:action].to_s
					when 'new' then :new_medical_record_request
					when 'index' 
						case params[:status].to_s
							when 'pending'  then :pending_medical_record_requests
							when 'active'   then :active_medical_record_requests
							when 'waitlist' then :waitlist_medical_record_requests
							when 'abstracted' then :abstracted_medical_record_requests
							when 'incomplete' then :incomplete_medical_record_requests
							when 'completed' then :completed_medical_record_requests
							when 'complete' then :complete_medical_record_requests
							else :all_medical_record_requests
						end
					else nil
				end
			else nil
		end
		content_for :side_menu do
			s = "<ul id='sidemenu'>\n"
			list_items = [
				link_to( "New Requests", new_medical_record_request_path,
					:class => ((current == :new_medical_record_request)?'current':nil) ),
				"<hr/>",
				link_to( "All Requests", medical_record_requests_path,
					:class => ((current == :all_medical_record_requests)?'current':nil) ),
				"<hr/>",
				link_to( "Active Requests", medical_record_requests_path(:status => 'active'),
					:class => ((current == :active_medical_record_requests)?'current':nil) ),
				link_to( "Waitlist Requests", medical_record_requests_path(:status => 'waitlist'),
					:class => ((current == :waitlist_medical_record_requests)?'current':nil) ),
				link_to( "Pending Requests", medical_record_requests_path(:status => 'pending'),
					:class => ((current == :pending_medical_record_requests)?'current':nil) ),
				link_to( "Abstracted Requests", medical_record_requests_path(:status => 'abstracted'),
					:class => ((current == :abstracted_medical_record_requests)?'current':nil) ),
				link_to( "All Incomplete Requests", medical_record_requests_path(:status => 'incomplete'),
					:class => ((current == :incomplete_medical_record_requests)?'current':nil) ),
				"<hr/>",
				link_to( "Completed Requests", medical_record_requests_path(:status => 'completed'),
					:class => ((current == :completed_medical_record_requests)?'current':nil) ),
				link_to( "All Complete Requests", medical_record_requests_path(:status => 'complete'),
					:class => ((current == :complete_medical_record_requests)?'current':nil) )
			]
			s << list_items.collect{|i|"<li>#{i}</li>"}.join("\n")
			s << "\n</ul><!-- sidemenu -->\n"
			s.html_safe
		end
	end

	def blood_spots_sub_menu
		#	added the to_s's to ensure not nil
		current = case params[:controller].to_s
			when 'blood_spot_requests' 
				case params[:action].to_s
					when 'new' then :new_blood_spot_request
					when 'index' 
						case params[:status].to_s
							when 'pending'  then :pending_blood_spot_requests
							when 'active'   then :active_blood_spot_requests
							when 'waitlist' then :waitlist_blood_spot_requests
							when 'incomplete' then :incomplete_blood_spot_requests
							when 'completed' then :completed_blood_spot_requests
							when 'unavailable' then :unavailable_blood_spot_requests
							when 'complete' then :complete_blood_spot_requests
							else :all_blood_spot_requests
						end
					else nil
				end
			else nil
		end
		content_for :side_menu do
			s = "<ul id='sidemenu'>\n"
			list_items = [
				link_to( "New Requests", new_blood_spot_request_path,
					:class => ((current == :new_blood_spot_request)?'current':nil) ),
				"<hr/>",
				link_to( "All Requests", blood_spot_requests_path,
					:class => ((current == :all_blood_spot_requests)?'current':nil) ),
				"<hr/>",
				link_to( "Active Requests", blood_spot_requests_path(:status => 'active'),
					:class => ((current == :active_blood_spot_requests)?'current':nil) ),
				link_to( "Waitlist Requests", blood_spot_requests_path(:status => 'waitlist'),
					:class => ((current == :waitlist_blood_spot_requests)?'current':nil) ),
				link_to( "Pending Requests", blood_spot_requests_path(:status => 'pending'),
					:class => ((current == :pending_blood_spot_requests)?'current':nil) ),
				link_to( "All Incomplete Requests", blood_spot_requests_path(:status => 'incomplete'),
					:class => ((current == :incomplete_blood_spot_requests)?'current':nil) ),
				"<hr/>",
				link_to( "Completed Requests", blood_spot_requests_path(:status => 'completed'),
					:class => ((current == :completed_blood_spot_requests)?'current':nil) ),
				link_to( "Unavailable Requests", blood_spot_requests_path(:status => 'unavailable'),
					:class => ((current == :unavailable_blood_spot_requests)?'current':nil) ),
				link_to( "All Complete Requests", blood_spot_requests_path(:status => 'complete'),
					:class => ((current == :complete_blood_spot_requests)?'current':nil) )

			]
			s << list_items.collect{|i|"<li>#{i}</li>"}.join("\n")
			s << "\n</ul><!-- sidemenu -->\n"
			s.html_safe
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
							when 'incomplete' then :incomplete_bc_requests
							when 'completed' then :completed_bc_requests
							when 'complete' then :complete_bc_requests
							else :all_bc_requests
						end
					else nil
				end
			else nil
		end
		content_for :side_menu do
			s = "<ul id='sidemenu'>\n"
			list_items = [
				link_to( "New Requests", new_bc_request_path,
					:class => ((current == :new_bc_request)?'current':nil) ),
				"<hr/>",
				link_to( "All Requests", bc_requests_path,
					:class => ((current == :all_bc_requests)?'current':nil) ),
				"<hr/>",
				link_to( "Active Requests", bc_requests_path(:status => 'active'),
					:class => ((current == :active_bc_requests)?'current':nil) ),
				link_to( "Waitlist Requests", bc_requests_path(:status => 'waitlist'),
					:class => ((current == :waitlist_bc_requests)?'current':nil) ),
				link_to( "Pending Requests", bc_requests_path(:status => 'pending'),
					:class => ((current == :pending_bc_requests)?'current':nil) ),
				link_to( "All Incomplete Requests", bc_requests_path(:status => 'incomplete'),
					:class => ((current == :incomplete_bc_requests)?'current':nil) ),
				"<hr/>",
				link_to( "Completed Requests", bc_requests_path(:status => 'completed'),
					:class => ((current == :completed_bc_requests)?'current':nil) ),
				link_to( "All Complete Requests", bc_requests_path(:status => 'complete'),
					:class => ((current == :complete_bc_requests)?'current':nil) )

			]
			s << list_items.collect{|i|"<li>#{i}</li>"}.join("\n")
			s << "\n</ul><!-- sidemenu -->\n"
			s.html_safe
		end
	end

	def subject_side_menu(study_subject)
		#	using params[:controller] rather than the controller object
		#	as it is easier to test
		current = case params[:controller]
			when 'study_subjects' then :general
			when /patients$/ then :hospital
#			when /addresses$/ then :contact
			when /addresses$/ then :contact
			when /contacts$/ then :contact
			when /phone_numbers$/ then :contact
			when /consents$/ then :consents
			when /enrollments$/ then :eligibility
			when /samples$/ then :samples
			when /interviews$/ then :interviews
			when /events$/ then :events
#			when /documents$/ then :documents
#			when /notes$/ then :notes
			when /related_subjects$/ then :related_subjects
			when /birth_records$/ then :birth_record
#	this will catch abstracts, study_subject_abstracts and 
#		all of the abstract/whatevers
			when /abstract/ then :abstracts
			when 'rafs' then :raf
			else nil
		end

		return '' unless study_subject

		content_for :side_menu do
			s = "<ul id='sidemenu'>\n"
				list_items = []
				if request.env["HTTP_REFERER"] =~ /study_subjects\?/ || request.env["HTTP_REFERER"] =~ /study_subjects$/
					list_items << link_to( "back to search", request.env["HTTP_REFERER"] )
				end
	
				# the logged_in? check is a bit much as you should never get here without it.
				#	( only used in the helper tests )
	
				list_items += [
					link_to( "Basic Info", study_subject_path(study_subject),
						:class => ((current == :general)?'current':nil) ),
					( link_to( "Address & Phone", study_subject_contacts_path(study_subject),
						:class => ((current == :contact)?'current':nil) ) <<
						"<span class='count'>#{study_subject.addresses_count}/#{study_subject.phone_numbers_count}</span>".html_safe )
				]
				list_items << link_to( "Hospital / Medical", study_subject_patient_path(study_subject),
						:class => ((current == :hospital)?'current':nil) ) if study_subject.is_case?
	
				list_items += [
					link_to( "Birth Records", study_subject_birth_records_path(study_subject),
						:class => ((current == :birth_record)?'current':nil) ) <<
						"<span class='count'>#{study_subject.birth_data_count}</span>".html_safe
				] if( logged_in? and current_user.may_administrate? )
	
				list_items += [
					link_to( "Eligibility & Consent", study_subject_consent_path(study_subject),
						:class => ((current == :consents)?'current':nil) ),
					(link_to( "Enrollments",study_subject_enrollments_path(study_subject),
						:class => ((current == :eligibility)?'current':nil) )<<
						"<span class='count'>#{study_subject.enrollments_count}</span>".html_safe),
					(link_to( "Samples", study_subject_samples_path(study_subject),
						:class => ((current == :samples)?'current':nil) ) <<
						"<span class='count'>#{study_subject.samples_count}</span>".html_safe)
				]
	
				list_items += [
					link_to( "Interviews", study_subject_interviews_path(study_subject),
						:class => ((current == :interviews)?'current':nil) ) <<
						"<span class='count'>#{study_subject.interviews_count}</span>".html_safe
				] if( logged_in? and current_user.may_administrate? )
	
				list_items << (link_to( "Events", study_subject_events_path(study_subject),
						:class => ((current == :events)?'current':nil) ) << 
					"<span class='count'>#{study_subject.operational_events_count}</span>".html_safe)
	
#				list_items += [
#					link_to( "Documents", study_subject_documents_path(study_subject),
#						:class => ((current == :documents)?'current':nil) ),
#					link_to( "Notes", study_subject_notes_path(study_subject),
#						:class => ((current == :notes)?'current':nil) ),
#				] if( logged_in? and current_user.may_administrate? )
	
				list_items << link_to( "Related Subjects", 
						study_subject_related_subjects_path(study_subject),
						:class => ((current == :related_subjects)?'current':nil) )
				if study_subject.is_case?
					list_items << (link_to( "Abstracts", study_subject_abstracts_path(study_subject),
						:class => ((current == :abstracts)?'current':nil) ) <<
						"<span class='count'>#{study_subject.abstracts_count}</span>".html_safe)
					list_items << link_to( "RAF Info", raf_path(study_subject),
						:class => ((current == :raf)?'current':nil) ) 
				end
				list_items << "<span>&nbsp;</span>"
				list_items << ("<div style='text-align:center;'>" <<
					link_to('first'.html_safe, first_study_subjects_path()) <<
						"&nbsp;&middot;&nbsp;".html_safe <<
					link_to('prev'.html_safe,  prev_study_subject_path(study_subject)) <<
						"&nbsp;&middot;&nbsp;".html_safe <<
					link_to('next'.html_safe,  next_study_subject_path(study_subject)) <<
						"&nbsp;&middot;&nbsp;".html_safe <<
					link_to('last'.html_safe,  last_study_subjects_path()) <<
					"</div>")
					#	for first and last, passing currnent subject seems pointless
				s << list_items.collect{|i|"<li>#{i}</li>"}.join("\n")
				s << "\n</ul><!-- sidemenu -->\n"
			s.html_safe
		end	#	content_for :side_menu do
	end

	def dashboard_control_bar
		s  = "<div id='dashboard_control_bar'>"
		links = []
		links << link_to( 'dashboard', 
			{ :controller => params[:controller], :action => :dashboard },
			:class => (params[:action] == 'dashboard') ? 'current' : nil )
		links << link_to( 'find', 
			{ :controller => params[:controller], :action => :index },
			:class => (params[:action] == 'index') ? 'current' : nil )
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
			"<div id='subject_header'>\n" <<
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
			"</div><!-- id='id_bar' -->\n" <<
			"</div><!-- id='subject_header' -->\n"
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

	def ineligible(study_subject)
		s = if study_subject.try(:ineligible?)
			"<div id='ineligible'>\n" <<
				"Study Subject is not eligible.\n" <<
				"</div>\n"
		else
			''
		end 
		s.html_safe
	end

	def refused(study_subject)
		s = if study_subject.try(:refused?)
			"<div id='refused'>\n" <<
				"Study Subject refused consent.\n" <<
				"</div>\n"
		else
			''
		end 
		s.html_safe
	end

	def sort_up_image
		"#{Rails.root}/app/assets/images/sort_up.png"
	end

	def sort_down_image
		"#{Rails.root}/app/assets/images/sort_down.png"
	end

	#	&uarr; and &darr;
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
		s << link_to(link_text.html_safe,local_params.merge(:order => order,:dir => dir))
		s << arrow unless arrow.blank?
		s << "</div>"
		s.html_safe
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

end
