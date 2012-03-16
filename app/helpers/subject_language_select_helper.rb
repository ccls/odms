module SubjectLanguageSelectHelper

#	def subject_languages_select( languages = Language.all )
	#	doing it this way allows passing nothing, an array 
	#	(as is currently in views), or just as list
	def subject_languages_select( *args )
		languages = args.flatten
		languages = Language.all if languages.empty?
		#		self.object  #	<-- the subject
		s =  "<div id='study_subject_languages'>"
		#	TODO would be nice, but not currently needed, to have a label option.
		s << "<div class='languages_label'>Language of parent or caretaker:</div>\n"
		s << "<div id='languages'>\n"
		languages.each do |l|
			sl = self.object.subject_languages.detect{|sl|sl.language_id == l.id }
			#	This effectively requires that the attributes have been updated in the controller.
			#	@study_subject.subject_languages_attributes = params.dig('study_subject','subject_languages_attributes')||{}
			sl_built_or_exists = ( sl.nil? ) ? false : true												#	need to remember
			sl = self.object.subject_languages.build(:language => l) if sl.nil?
			classes = ['subject_language']
			classes << ( ( sl.id.nil? ) ? 'creator' : 'destroyer' )
			s << "<div class='#{classes.join(' ')}'>"
			self.fields_for( :subject_languages, sl ) do |sl_fields|
				s << "<div id='other_language'>" if( l.is_other? )

				if sl.id.nil?	#	not currently existing subject_language
					s << sl_fields.subject_language_creator(sl_built_or_exists)
				else	#	language exists, this is for possible destruction
					s << sl_fields.subject_language_destroyer(!sl.marked_for_destruction?)
				end
				s << sl_fields.specify_other_language() if l.is_other?
				s << "</div>"	if( l.is_other? ) # id='other_language'>" 
			end
			s << "</div>\n"	# class='subject_language'>"
		end
		s << "</div>\n"	#	languages
		s << "</div><!-- study_subject_languages -->\n"	#	study_subject_languages
		s.html_safe
	end
	alias_method :subject_languages_selector, :subject_languages_select
	alias_method :select_subject_languages, :subject_languages_select

protected

#
#	Labels, ids and classes customized for javascript simplicity and usage.
#

	def language_label
		label =  self.object.language.key.dup.capitalize
		label << (( self.object.language.is_other? ) ? ' (not eligible)' : ' (eligible)')
	end

	def subject_language_creator(checked=false)
		#	self.object is a subject_language
		#	If exists, the hidden id tag is actually immediately put in the html stream!
		#	Don't think that it will be a problem, but erks me.
		s = self.check_box( :language_id, { 
			:id => "#{self.object.language.key}_language_id",	#	english_language_id
			:checked => checked }, self.object.language_id, '' ) << "\n"
		s << self.label( :language_id, self.language_label,
			:for => "#{self.object.language.key}_language_id" ) << "\n"
	end

	def subject_language_destroyer(checked=true)
		#	self.object is a subject_language
		#	KEEP ME for finding _destroy to determine if checked
		s =  self.hidden_field( :language_id, :value => self.object.language_id )
		#	check_box(object_name, method, options = {}, 
		#		checked_value = "1", unchecked_value = "0")
		#	when checked, I want it to do nothing (0), when unchecked I want destroy (1)
		#	Here, I only want existing language_ids
		#	Yes, this is very backwards.
		s << self.check_box( :_destroy, { 
			:id => "#{self.object.language.key}__destroy",	# english__destroy
			:checked => checked }, 0, 1 ) << "\n"
		s << self.label( :_destroy, self.language_label,
			:for => "#{self.object.language.key}__destroy" ) << "\n"
	end

	#	should really change this to language_other_other for clarity
	def specify_other_language
		s =  "<div id='specify_other_language'>"
		s << self.label( :other_language, 'specify:', :for => 'other_other_language' ) << "\n"
		s << self.text_field( :other_language, :size => 12, :id => 'other_other_language' ) << "\n"
		s << "</div>"	# id='other_language'>"
	end

end
ActionView::Helpers::FormBuilder.send(:include, SubjectLanguageSelectHelper)

__END__


#	def subject_races_select( races = Race.all )
	#	doing it this way allows passing nothing, an array 
	#	(as is currently in views), or just as list
	def subject_races_select( *args )
		races = args.flatten
		races = Race.all if races.empty?
		#		self.object  #	<-- the subject
		s =  "<div id='study_subject_races'>"
		#	TODO would be nice, but not currently needed, to have a label option.
		s << "<div class='races_label'>Select Race(s): "
		s <<   ".... ( [primary] [partial] Text )</div>\n"
		s << "<div id='races'>\n"
		races.each do |race|
			sr = self.object.subject_races.detect{|sr|sr.race_id == race.id }
			#	This effectively requires that the attributes have been updated in the controller.
			#	@study_subject.subject_races_attributes = params.dig('study_subject','subject_races_attributes')||{}
			sr_built_or_exists = ( sr.nil? ) ? false : true												#	need to remember
			sr = self.object.subject_races.build(:race => race) if sr.nil?
			classes = ['subject_race']
			classes << ( ( sr.id.nil? ) ? 'creator' : 'destroyer' )
			s << "<div class='#{classes.join(' ')}'>"
			self.fields_for( :subject_races, sr ) do |sr_fields|
				s << "<div id='other_race'>" if( race.is_other? )

#				s << sr_fields.check_box(:is_primary, {}, true, false)
#	default id="study_subject_subject_races_attributes_0_is_primary"
#	default class=nil
				s << sr_fields.check_box(:is_primary, { 
#					:id => "#{@template.dom_id(race)}_is_primary", 
					:id => "#{race.key}_is_primary",	#	other_is_primary
					:class => 'is_primary_selector',
					:title => "Set '#{race}' as the subject's PRIMARY race" } ) << "\n"

				if sr.id.nil?	#	not currently existing subject_race
					s << sr_fields.subject_race_creator(sr_built_or_exists)
				else	#	race exists, this is for possible destruction
					s << sr_fields.subject_race_destroyer(!sr.marked_for_destruction?)
				end
				s << sr_fields.specify_other_race() if race.is_other?
				s << "</div>"	if( race.is_other? ) # id='other_race'>" 
			end
			s << "</div>\n"	# class='subject_race'>"
		end
		s << "</div>\n"	#	races
		s << "</div><!-- study_subject_races -->\n"	#	study_subject_races
	end
	alias_method :subject_races_selector, :subject_races_select
	alias_method :select_subject_races, :subject_races_select

protected

	def race_label
		label =  self.object.race.to_s	#.dup.capitalize
#		label << (( self.object.race.is_other? ) ? ' (not eligible)' : ' (eligible)')
	end

	def subject_race_creator(checked=false)
		#	self.object is a subject_race
		#	If exists, the hidden id tag is actually immediately put in the html stream!
		#	Don't think that it will be a problem, but erks me.
#	default id="study_subject_subject_races_attributes_0_race_id"
#	default class=nil
		s = self.check_box( :race_id, { 
			:checked => checked,
#			:id      => @template.dom_id(self.object.race), 
			:id      => "#{self.object.race.key}_race_id",	#	other_race_id
			:class   => 'race_selector',
			:title   => "Set '#{self.object.race}' as one of the subject's race(s)"
		}, self.object.race_id, '' ) << "\n"
		s << self.label( :race_id, self.race_label,
			:for => "#{self.object.race.key}_race_id" ) << "\n"
#			:for => @template.dom_id(self.object.race) ) << "\n"
	end

	def subject_race_destroyer(checked=true)
		#	self.object is a subject_race
		#	KEEP ME for finding _destroy to determine if checked
		s =  self.hidden_field( :race_id, :value => self.object.race_id )
		#	check_box(object_name, method, options = {}, 
		#		checked_value = "1", unchecked_value = "0")
		#	when checked, I want it to do nothing (0), when unchecked I want destroy (1)
		#	Here, I only want existing race_ids
		#	Yes, this is very backwards.
#	default id="study_subject_subject_races_attributes_1__destroy"
#	default class=nil
		s << self.check_box( :_destroy, { 
			:checked => checked,
#			:id      => @template.dom_id(self.object.race), 
			:id      => "#{self.object.race.key}__destroy",	# other__destroy
			:class   => 'race_selector',
			:title   => "Remove '#{self.object.race}' as one of the subject's race(s)"
		}, 0, 1 ) << "\n"
		s << self.label( :_destroy, self.race_label,
			:for => "#{self.object.race.key}__destroy" ) << "\n"
#			:for => @template.dom_id(self.object.race) ) << "\n"
	end

	def specify_other_race
		s =  "<div id='specify_other_race'>"
		s << self.label( :other, 'specify:', :for => 'race_other_other' ) << "\n"
		s << self.text_field( :other, :size => 12, :id => 'race_other_other' ) << "\n"
		s << "</div>"	# id='other_race'>"
	end

