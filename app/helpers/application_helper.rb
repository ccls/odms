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
#				link_to('New Control', new_control_path),
				link_to('New Control', cases_path),
				link_to('Manage Birth Certificates', birth_certificates_path),
				link_to( "Browse Subjects", study_subjects_path )
			].join("\n    ") <<
			"</div><!-- sub_menu --></div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'interviews' ) ? ' current' : nil}'>" <<
			link_to('Interviews', dashboard_interviews_path) <<
			"</div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'samples' ) ? ' current' : nil}'>" <<
			link_to('Samples', dashboard_samples_path) <<
			"</div><!-- menu_item -->"

		s << "<div class='menu_item#{( 
				params[:controller] == 'studies' ) ? ' current' : nil}'>" <<
			link_to('Studies', dashboard_studies_path) <<
			"</div><!-- menu_item -->"

		s << "\n</div><!-- mainmenu -->\n"
	end

	def administrator_menu()
		link_to( "Admin", admin_path, :class => 'menu_item' )
	end

	def id_bar_for(object,&block)
		#	In development, the app will forget
#		require_dependency 'study_subject.rb' unless StudySubject	#	don't think true anymore
#		require_dependency 'gift_card.rb' unless GiftCard
		case object
			when StudySubject  then study_subject_id_bar(object,&block)
#			when GiftCard then gift_card_id_bar(object,&block)
			else nil
		end
	end

	def sub_menu_for(object)
		#	In development, the app will forget
#		require_dependency 'study_subject.rb' unless StudySubject	# don't think true anymore
#		require_dependency 'interview.rb' unless Interview
		case object
			when StudySubject   then study_subject_sub_menu(object)
#			when Interview then interview_sub_menu(object)
			else nil
		end
	end

	def birth_certificates_sub_menu
		current = case
			when( params[:controller] == 'bc_requests' and params[:action] == 'new' )
				:new_bc_request
			when( params[:controller] == 'bc_requests' and params[:action] == 'index' and params[:status].blank? )
				:all_bc_requests
			when( params[:controller] == 'bc_requests' and params[:action] == 'index' and params[:status] == 'pending' )
				:pending_bc_requests
			when( params[:controller] == 'bc_requests' and params[:action] == 'index' and params[:status] == 'active' )
				:active_bc_requests
			when( params[:controller] == 'bc_requests' and params[:action] == 'index' and params[:status] == 'waitlist' )
				:waitlist_bc_requests
			when( params[:controller] == 'bc_requests' and params[:action] == 'index' and params[:status] == 'complete' )
				:complete_bc_requests
			when( params[:controller] == 'bc_validations' )
				:bc_validations
			else nil
		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
			s << [
				link_to( "New BC Request", new_bc_request_path,
					:class => ((current == :new_bc_request)?'current':nil) ),
				link_to( "Pending Requests", bc_requests_path(:status => 'pending'),
					:class => ((current == :pending_bc_requests)?'current':nil) ),
				link_to( "BC Validation", bc_validations_path,
					:class => ((current == :bc_validations)?'current':nil) ),

				"<hr/>",
				link_to( "All Requests", bc_requests_path,
					:class => ((current == :all_bc_requests)?'current':nil) ),
				link_to( "Active Requests", bc_requests_path(:status => 'active'),
					:class => ((current == :active_bc_requests)?'current':nil) ),
				link_to( "Waitlist Requests", bc_requests_path(:status => 'waitlist'),
					:class => ((current == :waitlist_bc_requests)?'current':nil) ),
				link_to( "Complete Requests", bc_requests_path(:status => 'complete'),
					:class => ((current == :complete_bc_requests)?'current':nil) ),

				"<span>Request History</span>"
			].join("\n")
			s << "\n</div><!-- submenu -->\n"
		end
	end

	def study_subject_sub_menu(study_subject)
		current = case controller.class.name.sub(/Controller$/,'')
			when *%w( StudySubjects ) then :general
			when *%w( Patients ) then :hospital
			when *%w( Addresses Addressings Contacts PhoneNumbers 
				) then :contact
			when *%w( Enrollments ) then :eligibility
			when *%w( Events ) then :events
			else nil
		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
			s << [
				link_to( "Basic Info", study_subject_path(study_subject),
					:class => ((current == :general)?'current':nil) ),
				link_to( "Address &amp; Phone", study_subject_contacts_path(study_subject),
					:class => ((current == :contact)?'current':nil) ),
				link_to( "Hospital / Medical", study_subject_patient_path(study_subject),
					:class => ((current == :hospital)?'current':nil) ),
#				"<span>Hospital / Medical</span>",
				"<span>Eligibility &amp; Consent</span>",
#				link_to( "Enrollments",study_subject_enrollments_path(study_subject),
#					:class => ((current == :eligibility)?'current':nil) ),
				"<span>Enrollments</span>",
				"<span>Samples</span>",
				"<span>Interviews</span>",
#				link_to( "Events", study_subject_events_path(study_subject),
#					:class => ((current == :events)?'current':nil) ),
				"<span>Events</span>",
				"<span>Documents</span>",
				"<span>Notes</span>"
			].join("\n")
			s << "\n</div><!-- submenu -->\n"
		end
	end

#	#	Just a simple method to wrap the passed text in a span
#	#	with class='required'
#	def required(text)			#	TODO remove as is in ccls_engine > 3.8.7
#		"<span class='required'>#{text}</span>"
#	end
#	alias_method :req, :required

	def control_bar
		s  = "<div class='control_bar'>"
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
	end

end
