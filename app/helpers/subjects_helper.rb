module SubjectsHelper

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

	def select_subject_races(subject)
		Race.all.collect do |race|
			s  = ''
			sr = SubjectRace.find(:first,:conditions => { 
				:race_id => race.id,
				:study_subject_id => subject.id })
			#	The race.id in ...
			#	subject[subject_races_attributes[#{race.id}]]
			#	is used solely for ensuring that it is unique in the form
#	check_box_tag(name, value = "1", checked = false, options = {})
#	radio_button_tag(name, value, checked = false, options = {})
			s << hidden_field_tag("subject[subject_races_attributes[#{race.id}]][id]", 
				sr.id ) << "\n" if sr
			s << radio_button_tag( "subject[primary_race_id]", race.id,
				subject.primary_race_id == race.id ) << "\n"
			if sr
				s << hidden_field_tag("subject[subject_races_attributes[#{race.id}]][_destroy]", 
					1 ) << "\n"
				s << check_box_tag( "subject[subject_races_attributes[#{race.id}]][_destroy]",
					0, true, :id => dom_id(race) ) << "\n"
			else
				s << check_box_tag( "subject[subject_races_attributes[#{race.id}]][race_id]",
					race.id, false, :id => dom_id(race) ) << "\n"
			end
			s << label_tag( dom_id(race), race.name ) << "\n"
			s << "<br/>\n"
		end.join()
	end

end
