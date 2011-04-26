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
		prefix = "subject[subject_races_attributes"
		selector  = "<fieldset id='race_selector'><legend>Select Race(s)</legend>\n"
		selector << "<p>TEMP NOTE: primary is first, normal is second</p>\n"
		selector << Race.all.collect do |race|
			s  = ''
			sr = subject.subject_races.find(:first,:conditions => { 
				:race_id => race.id })

			#	Notes ...
			#	check_box_tag(name, value = "1", checked = false, options = {})
			#	radio_button_tag(name, value, checked = false, options = {})

			s << hidden_field_tag("#{prefix}[#{race.id}]][id]", 
				sr.id ) << "\n" if sr
			#	is_primary is irrelevant of if subject_race already exists
			s << hidden_field_tag("#{prefix}[#{race.id}]][is_primary]", false ) << "\n"
			s << check_box_tag( "#{prefix}[#{race.id}]][is_primary]",
				true, sr.try(:is_primary), :id => "#{dom_id(race)}_is_primary",
				:class => 'is_primary_selector' ) << "\n"

			if sr
				#	subject_race exists, so this is for destruction
				#	1 = true, so if checkbox is unchecked, destroy it
				s << hidden_field_tag("#{prefix}[#{race.id}]][_destroy]", 1 ) << "\n"
				#	0 = false, so if checkbox is checked, keep it
				#		because this is 0 and not the race.id, need to change
				#		some javascript
				s << check_box_tag( "#{prefix}[#{race.id}]][_destroy]",
					0, true, :id => dom_id(race),
					:class => 'race_selector' ) << "\n"
			else
				#	subject_race does not exist, so this is for creation
				s << check_box_tag( "#{prefix}[#{race.id}]][race_id]",
					race.id, false, :id => dom_id(race),
					:class => 'race_selector' ) << "\n"
			end
			s << label_tag( dom_id(race), race.name ) << "\n"
			s << "<br/>\n"
		end.join()
		selector << "</fieldset><!-- id='race_selector' -->\n"
	end

end
