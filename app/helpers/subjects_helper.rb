module SubjectsHelper

#	TODO move much of this into ccls_engine as is used both in ODMS and HOMEX
#		ccls_engine/lib/ccls_engine/helper.rb

	#	Used to replace the _id_bar partial
	def subject_id_bar(subject,&block)		#	TODO remove as added to ccls_engine > 3.8.7
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


#	Move this down with the subject_languages_select'r
	def select_subject_races(subject)
		#	NOTE THAT THIS PREFIX HAS ONLY THE FIRST LEFT SIDE [
		prefix = "subject[subject_races_attributes"
		sr_params = if( defined?(params) && params[:subject] && 
			params[:subject].has_key?('subject_races_attributes') && 
			params[:subject].is_a?(Hash) )
			params[:subject]['subject_races_attributes']
		else
			{}
		end
		selector  = "<fieldset id='race_selector'><legend>Select Race(s)</legend>\n"
		selector << "<p>TEMP NOTE: primary is first, normal is second</p>\n"
		selector << Race.all.collect do |race|
			s  = ''
			sr = subject.subject_races.find(:first,:conditions => { 
				:race_id => race.id })

			#	Notes ...
			#	check_box_tag(name, value = "1", checked = false, options = {})
			#	"subject_races_attributes"=>{
			#		"6"=>{"is_primary"=>"false"}, 
			#		"1"=>{"race_id"=>"1","is_primary"=>"false"}, 	#	<-- checked
			#		"2"=>{"is_primary"=>"false"}, 
			#		"3"=>{"is_primary"=>"false"}, 
			#		"4"=>{"is_primary"=>"false"}, 
			#		"5"=>{"race_id"=>"5",is_primary"=>"true"} }	#	<-- checked and primary

			s << hidden_field_tag("#{prefix}[#{race.id}]][id]", sr.id ) << "\n" if sr

			#	is_primary is irrelevant of if subject_race already exists
			s << hidden_field_tag("#{prefix}[#{race.id}]][is_primary]", false ) << "\n"
			s << check_box_tag( "#{prefix}[#{race.id}]][is_primary]", true, 
				( sr_params.dig(race.id.to_s,'is_primary') == 'true' ) || sr.try(:is_primary),
				{ :id => "#{dom_id(race)}_is_primary", :class => 'is_primary_selector',
				:title => "Set '#{race}' as the subject's PRIMARY race" } ) << "\n"

			check_box_options = {
				:id => dom_id(race), 
				:class => 'race_selector',
				:title => "Set '#{race}' as one of the subject's race(s)"
			}
			if sr
				#	subject_race exists, so this is for destruction
				#	1 = true, so if checkbox is unchecked, destroy it
				s << hidden_field_tag("#{prefix}[#{race.id}]][_destroy]", 1,
						:class => 'destroy_race' ) << "\n"
				#	0 = false, so if checkbox is checked, keep it
				#		because this is 0 and not the race.id, need to change
				#		some javascript
				s << check_box_tag( "#{prefix}[#{race.id}]][_destroy]", 0, 
					sr_params.dig(race.id.to_s,'_destroy') || true, 
					check_box_options.merge(:class => 'race_selector do_not_destroy_race') ) << "\n"
			else
				#	subject_race does not exist, so this is for creation
				s << check_box_tag( "#{prefix}[#{race.id}]][race_id]", race.id, 
					sr_params.dig(race.id.to_s,'race_id') || false, 
					check_box_options ) << "\n"
			end
			s << label_tag( dom_id(race), race.name ) << "\n"
			s << "<br/>\n"
		end.join()
		selector << "</fieldset><!-- id='race_selector' -->\n"
	end

end



ActionView::Helpers::FormBuilder.class_eval do

	#	As this is a 'new' form, no need for '_destroy' options.
	#	May be able to implement this simplicity for the races as well
	def subject_languages_select( languages )
		#		self.object  #	<-- the subject
		language_ids = @template.params.dig('subject','subject_languages_attributes').try(
			:collect) { |l| l[1]['language_id'] }

		s = "<p>Language of parent or caretaker:</p><p>\n"

		languages.each do |l|
			sl = self.object.subject_languages.detect{|sl|sl.language_id == l.id } ||
				self.object.subject_languages.build(:language => l)

			self.fields_for( :subject_languages, sl ) do |sl_fields|
				s << sl_fields.check_box( :language_id, {
					:checked => language_ids.include?(sl_fields.object.language_id.to_s),
				}, sl_fields.object.language_id, '' ) << "\n"

				label = sl_fields.object.language.key.dup.capitalize
				label << (( l.key == 'other' ) ? ' (not eligible)' : ' (eligible)')
				s << sl_fields.label( :language_id, label ) << "\n"
				if( l.key == 'other' )
					s << sl_fields.label( :other, 'Specify other:' ) << "\n"
					s << sl_fields.text_field( :other, :size => 12 ) << "\n"
				end
			end
		end
		s << "</p>\n"
	end

end
