# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def odms_main_menu
		s = "<div id='mainmenu'>\n"
		s << "<div class='menu_item'>" <<
			link_to('Subjects', dashboard_subjects_path) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to('Dashboard', dashboard_subjects_path),
				link_to('Add Case', new_case_path),
				link_to('Add Control', new_control_path),
				link_to('Manage Birth Certificates', birth_certificates_path),
				link_to( "Browse Subjects", subjects_path )
#				"<span>Basic Info - Read</span>",
#				"<span>Basic Info - Edit</span>",
#				"<span>Address - Read</span>",
#				"<span>Address - Edit</span>",
#				"<span>Phone - Edit</span>",
#				"<span>Hospital - Read</span>",
#				"<span>Hospital - Edit</span>",
			].join("\n    ") <<
			"</div><!-- sub_menu --></div><!-- menu_item -->"
		s << "\n</div><!-- mainmenu -->\n"
	end

	def administrator_menu()
		link_to( "Admin", admin_path,
			:class => 'menu_item' )
	end

	def id_bar_for(object,&block)
		#	In development, the app will forget
		require_dependency 'subject.rb'
#		require_dependency 'gift_card.rb'
		case object
			when Subject  then subject_id_bar(object,&block)
#			when GiftCard then gift_card_id_bar(object,&block)
			else nil
		end
	end

	def sub_menu_for(object)
		#	In development, the app will forget
		require_dependency 'subject.rb'
#		require_dependency 'interview.rb'
		case object
			when Subject   then subject_sub_menu(object)
#			when Interview then interview_sub_menu(object)
			else nil
		end
	end

	def birth_certificates_sub_menu
		current = case
			when( params[:controller] == 'bc_requests' and params[:action] == 'new' )
				:new_bc_request
			when( params[:controller] == 'bc_requests' and params[:action] == 'index' )
				:pending_bc_requests
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
				link_to( "All Requests", bc_requests_path ),
				link_to( "Active Requests", bc_requests_path(:status => 'active') ),
				link_to( "Waitlist Requests", bc_requests_path(:status => 'waitlist') ),
				link_to( "Complete Requests", bc_requests_path(:status => 'complete') ),

				"<span>Request History</span>"
			].join("\n")
			s << "\n</div><!-- submenu -->\n"
		end
	end

	def subject_sub_menu(subject)
		current = case controller.class.name.sub(/Controller$/,'')
			when *%w( Subjects ) then :general
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
				link_to( "Basic Info", subject_path(subject),
					:class => ((current == :general)?'current':nil) ),
				link_to( "Address &amp; Phone", subject_contacts_path(subject),
					:class => ((current == :contact)?'current':nil) ),
#				link_to( "Hospital / Medical", subject_patient_path(subject),
#					:class => ((current == :hospital)?'current':nil) ),
				"<span>Hospital / Medical</span>",
				"<span>Eligibility &amp; Consent</span>",
#				link_to( "Enrollments",subject_enrollments_path(subject),
#					:class => ((current == :eligibility)?'current':nil) ),
				"<span>Enrollments</span>",
				"<span>Samples</span>",
				"<span>Interviews</span>",
#				link_to( "Events", subject_events_path(subject),
#					:class => ((current == :events)?'current':nil) ),
				"<span>Events</span>",
				"<span>Documents</span>",
				"<span>Notes</span>"
			].join("\n")
			s << "\n</div><!-- submenu -->\n"
		end
	end

	#	Just a simple method to wrap the passed text in a span
	#	with class='required'
	def required(text)
		"<span class='required'>#{text}</span>"
	end
	alias_method :req, :required

end
