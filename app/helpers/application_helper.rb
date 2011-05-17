# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def odms_main_menu
		s = "<div id='mainmenu'>\n"
		s << "<div class='menu_item'>" <<
			link_to('Subjects', dashboard_subjects_path) <<
			"<div class='sub_menu'>\n    " <<
			[
				link_to( "New Case Wizard", new_case_wizard_path ),
				"<span>New Control Wizard</span>",
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

	def subject_sub_menu(subject)
		current = nil
#		current = case controller.class.name.sub(/Controller$/,'')
#			when *%w( Subjects ) then :general
#			when *%w( Patients ) then :hospital
#			when *%w( Addresses Addressings Contacts PhoneNumbers 
#				) then :contact
#			when *%w( Enrollments ) then :eligibility
#			when *%w( Events ) then :events
#			else nil
#		end
		content_for :side_menu do
			s = "<div id='sidemenu'>\n"
#			l=[link_to( 'general', subject_path(subject),
#				:class => ((current == :general)?'current':nil)
#			)]
#			l.push(link_to( 'hospital', subject_patient_path(subject),
#				:class => ((current == :hospital)?'current':nil)
#			)) #if subject.is_case?
#			l.push(link_to( 'address/contact', subject_contacts_path(subject),
#				:class => ((current == :contact)?'current':nil)))
#			l.push(link_to( 'eligibility/enrollments', 
#				subject_enrollments_path(subject),
#				:class => ((current == :eligibility)?'current':nil)))
#			l.push(link_to( 'events', 
#				subject_events_path(subject),
#				:class => ((current == :events)?'current':nil)))
#			s << l.join("\n")
			s << [
				link_to( "Basic Info", subject_path(subject) ),
#				link_to( "Address &amp; Phone", subject_contacts_path(subject) ),
				"<span>Address &amp; Phone</span>",
#				link_to( "Hospital / Medical", subject_patient_path(subject) ),
				"<span>Hospital / Medical</span>",
				"<span>Eligibility &amp; Consent</span>",
#				link_to( "Enrollments",subject_enrollments_path(subject) ),
				"<span>Enrollments</span>",
				"<span>Samples</span>",
				"<span>Interviews</span>",
#				link_to( "Events", subject_events_path(subject) ),
				"<span>Events</span>",
				"<span>Documents</span>",
				"<span>Notes</span>"
			].join("\n")
			s << "\n</div><!-- submenu -->\n"
		end
	end

end
