# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def home_exposure_main_menu
		current = case controller.class.name.sub(/Controller$/,'')
			when *%w( 
					Addressings
					Contacts
					Enrollments
					Patients
					PhoneNumbers
					Subjects
					Events
				) then :subjects
			when *%w( 
					Interview::Subjects 
					Interviews
					HomeExposureResponses
				) then  :interview
#					ResponseSets
			when *%w( 
					Samples 
					Sample::Subjects 
					Packages
				) then :sample
			when *%w( 
					GiftCards
					Followup::GiftCards
					Followup::Subjects 
				) then :followup
			when *%w( 
					Guides 
					Users 
					Pages
				) then :admin
			else nil
		end

		s = "<div id='mainmenu'>\n"
		l = [link_to( "Subjects", subjects_path,
			:class => ((current == :subjects)?'current':nil))]
		l.push(link_to( "Interview", interview_subjects_path,  
			:class => ((current == :interview)?'current':nil)))
		l.push(link_to( "Samples", sample_subjects_path,
			:class => ((current == :sample)?'current':nil)))
		l.push(link_to( "Gift Cards", followup_subjects_path,
			:class => ((current == :followup)?'current':nil)))

#		l.push(link_to( "Admin", admin_path,
#			:class => ((current == :admin)?'current':nil))
#		) if current_user.try(:may_administrate?)

		s << l.join("\n")
		s << "\n</div><!-- mainmenu -->\n"
	end

	def administrator_menu()
		link_to( "Admin", admin_path )
	end

	def id_bar_for(object,&block)
		#	In development, the app will forget
		require_dependency 'subject.rb'
		require_dependency 'gift_card.rb'
		case object
			when Subject  then subject_id_bar(object,&block)
			when GiftCard then gift_card_id_bar(object,&block)
			else nil
		end
	end

	def sub_menu_for(object)
		#	In development, the app will forget
		require_dependency 'subject.rb'
		require_dependency 'interview.rb'
#		if object.is_a?(Subject)
		case object
			when Subject   then subject_sub_menu(object)
			when Interview then interview_sub_menu(object)
			else nil
		end
	end

	def followup_sub_menu
		current = case controller.class.name.sub(/Controller$/,'')
			when *%w( Followup::Subjects )  then :subjects
			when *%w( Followup::GiftCards ) then :gift_cards
			else nil
		end
		content_for :main do
			s = "<div id='submenu'>\n"
			l=[link_to( 'manage by subject', followup_subjects_path,
				:class => ((current == :subjects)?'current':nil)
			)]
			l.push(link_to( 'manage by cards',
				followup_gift_cards_path,
				:class => ((current == :gift_cards)?'current':nil)))
			s << l.join("\n")
			s << "\n</div><!-- submenu -->\n"
		end
	end

	def interview_sub_menu(interview)
		current = case controller.class.name.sub(/Controller$/,'')
			when *%w( Interviews ) then :general
#			when *%w( ResponseSets ) then :edit
			else nil
		end
		content_for :main do
			s = "<div id='submenu'>\n"
#			l=[link_to( 'schedule interview', subject_path(interview.subject),
			l=[link_to( 'general', interview_path(interview),
				:class => ((current == :general)?'current':nil)
			)]
#			l.push(link_to( 'edit/view interview', 
#				subject_response_sets_path(interview.subject),
#				:class => ((current == :edit)?'current':nil)))
			s << l.join("\n")
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
		content_for :main do
			s = "<div id='submenu'>\n"
			l=[link_to( 'general', subject_path(subject),
				:class => ((current == :general)?'current':nil)
			)]
			l.push(link_to( 'hospital', subject_patient_path(subject),
				:class => ((current == :hospital)?'current':nil)
			)) #if subject.is_case?
			l.push(link_to( 'address/contact', subject_contacts_path(subject),
				:class => ((current == :contact)?'current':nil)))
			l.push(link_to( 'eligibility/enrollments', 
				subject_enrollments_path(subject),
				:class => ((current == :eligibility)?'current':nil)))
			l.push(link_to( 'events', 
				subject_events_path(subject),
				:class => ((current == :events)?'current':nil)))
			s << l.join("\n")
			s << "\n</div><!-- submenu -->\n"
		end
	end

#	def se_check_boxes(se,attr)
#		s = "<li>#{attr.to_s.capitalize}?<ul><li>\n"
#		s << check_box_tag( "projects[#{se.id}][#{attr}][]", 'true',
#				params.dig('projects',se.id.to_s,attr.to_s).true?,
#				:id => "projects_#{se.id}_#{attr}_true" )
#		s << label_tag( "projects_#{se.id}_#{attr}_true", "True" )
#		s << "</li><li>\n"
#		s << check_box_tag( "projects[#{se.id}][#{attr}][]", 'false',
#				params.dig('projects',se.id.to_s,attr.to_s).false?,
#				:id => "projects_#{se.id}_#{attr}_false" )
#		s << label_tag( "projects_#{se.id}_#{attr}_false", "False" )
#		s << "</li></ul></li>\n"
#	end

	def mdy(date)
		( date.nil? )?'&nbsp;':date.strftime("%m/%d/%Y")
	end

	def y_n_dk(value)
		case value
			when 1   then 'Yes'
			when 2   then 'No'
			when 999 then "Don't Know"
			else '&nbsp;'
		end
	end

end
