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
				link_to('Manage Birth Certificates', birth_certificates_path)	#,
#				link_to( "Browse Subjects", study_subjects_path )
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

#		s << "<div class='menu_item#{( 
#				params[:controller] == 'studies' ) ? ' current' : nil}'>" <<
#			link_to('Studies', dashboard_studies_path) <<
#			"</div><!-- menu_item -->"

		s << "\n</div><!-- mainmenu -->\n"
	end

	#	This is called and parsed by javascript, so NO single quotes.
	def administrator_menu()
#		link_to( "Admin", admin_path, :class => 'menu_item' )
		"<div class=\"menu_item\">#{link_to( "Admin", admin_path )}</div>"
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
#			when( params[:controller] == 'bc_validations' )
#				:bc_validations
			else nil
		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
			s << [
				link_to( "New BC Request", new_bc_request_path,
					:class => ((current == :new_bc_request)?'current':nil) ),
				link_to( "Pending Requests", bc_requests_path(:status => 'pending'),
					:class => ((current == :pending_bc_requests)?'current':nil) ),
#				link_to( "BC Validation", bc_validations_path,
#					:class => ((current == :bc_validations)?'current':nil) ),

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
			when *%w( Consents ) then :consents
			when *%w( Enrollments ) then :eligibility
			when *%w( Samples ) then :samples
			when *%w( Interviews ) then :interviews
			when *%w( Events ) then :events
			when *%w( Documents ) then :documents
			when *%w( Notes ) then :notes
			when *%w( Cases ) then :cases
			else nil
		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
			s << [
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
					:class => ((current == :eligibility)?'current':nil) ),
				link_to( "Samples", study_subject_samples_path(study_subject),
					:class => ((current == :samples)?'current':nil) ),
				link_to( "Interviews", study_subject_interviews_path(study_subject),
					:class => ((current == :interviews)?'current':nil) ),
				link_to( "Events", study_subject_events_path(study_subject),
					:class => ((current == :events)?'current':nil) ),
				link_to( "Documents", study_subject_documents_path(study_subject),
					:class => ((current == :documents)?'current':nil) ),
				link_to( "Notes", study_subject_notes_path(study_subject),
					:class => ((current == :notes)?'current':nil) ),
				link_to( "Related Subjects", case_path(study_subject),
					:class => ((current == :cases)?'current':nil) )
			].join("\n")
			s << "\n</div><!-- submenu -->\n"
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
	end

	#	Overrides the method of the same name in ccls_engine
	#	Used to replace the _id_bar partial
	def subject_id_bar(study_subject,&block)
		stylesheets('study_subject_id_bar')
		content_for :subject_header do
			"<div id='id_bar'>\n" <<
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
			"<span>#{study_subject.icf_master_id}</span>\n" <<
			"</div><!-- class='icf_master_id' -->\n" <<
			"<div class='studyid'>\n" <<
			"<span>StudyID:</span>\n" <<
#			"<span>#{study_subject.try(:studyid)}</span>\n" <<
			"<span>#{study_subject.studyid}</span>\n" <<
			"</div><!-- class='studyid' -->\n" <<
#			"<div class='controls'>\n" <<
#			@content_for_id_bar.to_s <<
#			((block_given?)?yield: '') <<
#			"</div><!-- class='controls' -->\n" <<
			"</div><!-- class='id_numbers' -->\n" <<
			"</div><!-- id='id_bar' -->\n"
		end

		content_for :main do
			"<div id='do_not_contact'>\n" <<
			"Study Subject requests no further contact with Study.\n" <<
			"</div>\n" 
		end if study_subject.try(:do_not_contact?)
	end	#	id_bar_for
	alias_method :study_subject_id_bar, :subject_id_bar

end
