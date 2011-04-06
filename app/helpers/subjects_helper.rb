#	Convention over configuration ...
#	Calling this SubjectHelper rather than SubjectsHelper
#	eventually (meaning didn't initially, but now does)
#	caused the following error.  Pluralizing it fixed it.???
#	Why does it matter?  All helpers are loaded for all controllers.
#	I have other helpers that work.  Why just this one?
#ActionView::TemplateError (A copy of SubjectHelper has been removed from the module tree but is still active!) on line #4 of app/views/subjects/_search.html.erb:
#1: <% form_tag(subjects_path, :id => 'subject_search',:method => :get) do %>
#2: 	<%= races_check_boxes() %>
#3: 	<%= subject_types_check_boxes() %>
#4: 	<%= study_event_stuff() %>
#5: 	<div id='something'>
#6: 	<%= text_field_tag :q, params[:q] %>
#7: 	<%= submit_tag 'Search Subjects', :name => nil %>
module SubjectsHelper

#	def races_check_boxes
#		if Race.count > 0
#			s = "<fieldset id='races'>\n"
#			s << "<legend>Races</legend>\n"
#			s << "<ul>\n"
#			Race.all.each do |race|
#				s << "<li>"
#				s << check_box_tag( 'races[]', race.name, 
#						params['races'].try(:include?,race.name), 
#						:id => dom_id(race))
#				s << label_tag( dom_id(race), race.name )
#				s << "</li>\n"
#			end
#			s << "</ul>\n"
#			s << "</fieldset><!-- races -->\n"
#		end # if Race.count > 0
#	end

#	def subject_types_check_boxes
#		if SubjectType.count > 0
#			s = "<fieldset id='types'>\n"
#			s << "<legend>SubjectTypes</legend>\n"
#			s << "<ul>\n"
#			SubjectType.all.each do |type|
#				s << "<li>"
#				s << check_box_tag( 'types[]', type.name, 
#					params['types'].try(:include?,type.name), 
#					:id => dom_id(type))
#				s << label_tag( dom_id(type), type.name )
#				s << "</li>\n"
#			end
#			s << "</ul>\n"
#			s << "</fieldset><!-- types -->\n"
#		end # if SubjectType.count > 0
#	end

#	def dust_kit_radio_buttons
#		s = "<fieldset id='dust_kit'>\n"
#		s << "<legend>Dust Kit</legend>\n"
#		s << "<ul>\n"
#		s << "<li>"
#		dk = params['dust_kit'] || ''
#		s << radio_button_tag( 'dust_kit', 'ignore', ( dk == 'ignore' || dk.blank? ))
#		s << label_tag( 'dust_kit_ignore', 'Ignore Dust Kit' )
#		s << "</li>\n"
#		s << "<li>"
#		s << radio_button_tag( 'dust_kit', 'none', ( dk == 'none') )
#		s << label_tag( 'dust_kit_none', 'No Dust Kit' )
#		s << "</li>\n"
#		s << "<li>"
#		s << radio_button_tag( 'dust_kit', 'shipped', ( dk == 'shipped') )
#		s << label_tag( 'dust_kit_shipped', 'Dust Kit Shipped' )
#		s << "</li>\n"
#		s << "<li>"
#		s << radio_button_tag( 'dust_kit', 'delivered', ( dk == 'delivered') )
#		s << label_tag( 'dust_kit_delivered', 'Dust Kit Delivered' )
#		s << "</li>\n"
#		s << "<li>"
#		s << radio_button_tag( 'dust_kit', 'returned', ( dk == 'returned') )
#		s << label_tag( 'dust_kit_returned', 'Dust Kit Returned' )
#		s << "</li>\n"
#		s << "<li>"
#		s << radio_button_tag( 'dust_kit', 'received', ( dk == 'received') )
#		s << label_tag( 'dust_kit_received', 'Dust Kit Received' )
#		s << "</li>\n"
#		s << "</ul>\n"
#		s << "</fieldset><!-- dust_kit -->\n"
#	end

#	def study_event_stuff
#		if Project.count > 0
#			s = ''
#			Project.all.each do |se|
#				s << "<fieldset class='project'>\n"
#				s << "<legend>#{se.description}</legend><ul>\n"
#				s << se_check_boxes(se,:eligible)
#				s << se_check_boxes(se,:candidate)
#				s << se_check_boxes(se,:chosen)
#				s << se_check_boxes(se,:consented)
#				s << se_check_boxes(se,:closed)
#				s << se_check_boxes(se,:terminated)
#				s << se_check_boxes(se,:completed)
#				s << "<li>Refused</li>\n"
#				s << "<li>Awaiting Letter</li>\n"
#				s << "<li>Sent Letter</li>\n"
#				s << "<li>Awaiting Interview</li>\n"
#				s << "<li>Interviewed</li>\n"
#				s << "</ul>\n"
#				s << "</fieldset><!-- project -->\n"
#			end
#			s
#		end	#	if Project.count > 0
#	end
#	alias_method :project_stuff, :study_event_stuff


	#	&uarr; and &darr;
	def sort_link(column,text=nil)
		order = column.to_s.downcase.gsub(/\s+/,'_')
		dir = ( params[:dir] && params[:dir] == 'asc' ) ? 'desc' : 'asc'
		link_text = text||column
		classes = []	#[order]
		arrow = ''
		if params[:order] && params[:order] == order
			classes.push('sorted')
			arrow = if dir == 'desc'
				"<span class='arrow'>&darr;</span>"
			else
				"<span class='arrow'>&uarr;</span>"
			end
		end
		s = "<div class='#{classes.join(' ')}'>"
		s << link_to(link_text,params.merge(:order => order,:dir => dir))
		s << arrow unless arrow.blank?
		s << "</div>"
		s
	end

	#	Used to replace the _id_bar partial
#	def id_bar_for(subject,&block)
	def subject_id_bar(subject,&block)
		stylesheets('subject_id_bar')
		content_for :main do
			"<div id='id_bar'>\n" <<
			"<div class='childid'>\n" <<
			"<span>ChildID:</span>\n" <<
			"<span>#{subject.try(:childid)}</span>\n" <<
			"</div><!-- class='childid' -->\n" <<
			"<div class='studyid'>\n" <<
			"<span>StudyID:</span>\n" <<
			"<span>#{subject.try(:studyid)}</span>\n" <<
			"</div><!-- class='studyid' -->\n" <<
			"<div class='full_name'>\n" <<
			"<span>#{subject.try(:full_name)}</span>\n" <<
			"</div><!-- class='full_name' -->\n" <<
			"<div class='controls'>\n" <<
#			content_for(:id_bar).to_s <<
			@content_for_id_bar.to_s <<
			((block_given?)?yield: '') <<
			"</div><!-- class='controls' -->\n" <<
			"</div><!-- id='id_bar' -->\n"
		end

		content_for :main do
			"<div id='do_not_contact'>\n" <<
			"Subject requests no further contact with Study.\n" <<
			"</div>\n" 
		end if subject.try(:do_not_contact?)
	end	#	id_bar_for

end
