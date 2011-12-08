module StudySubjectsFormHelper

#	#	May be able to implement this simplicity for the races as well
#	#	Simplicity?  This has gotten rather complicated.
#	def ORIGINAL_subject_languages_select( languages )
#		#		self.object  #	<-- the subject
#		sl_params = @template.params.dig('study_subject','subject_languages_attributes')||{}
#
#		#	"0"=>{"language_id"=>"1"}.to_a 
#		#	=> [0,{"language_id"=>"1"}] 
#		#	hence l[1] 
#		#	=> {"language_id"=>"1"}
#		#	and l[1]['language_id']
#		#	=> "1"
#		#	As working with params, treat these all as strings.
#		selected_language_ids = sl_params.collect{ |l| l[1]['language_id'] }
#
#		s =  "<div id='study_subject_languages'>"
#		#	TODO would be nice, but not currently needed, to have a label option.
#		s << "<div class='languages_label'>Language of parent or caretaker:</div>\n"
#		s << "<div id='languages'>\n"
#		languages.each do |l|
#			sl = self.object.subject_languages.detect{|sl|sl.language_id == l.id } ||
#				self.object.subject_languages.build(:language => l)
#			classes = ['subject_language']
#			classes << ( ( sl.id.nil? ) ? 'creator' : 'destroyer' )
#			s << "<div class='#{classes.join(' ')}'>"
#			self.fields_for( :subject_languages, sl ) do |sl_fields|
#				s << "<div id='other_language'>" if( l.is_other? )
#
##	I would rather not be picking from the params, but for the moment it seems the only way.
##	I'd prefer to base it on the existing object, saved or unsaved, but don't know how to do that.
##	Perhaps once this is working, I can change it up, but I don't foresee that.
#
#				if sl.id.nil?	#	not currently existing subject_language
#					s << sl_fields.subject_language_creator(selected_language_ids.include?(sl.language_id.to_s))
#				else	#	language exists, this is for possible destruction
##	sl_params ...
## {"0"=>{"id"=>"1", "language_id"=>"1", "_destroy"=>"0"}, "1"=>{"language_id"=>""}, "2"=>{"language_id"=>"", "other"=>""}}
#
#					attrs = sl_params.detect{|p| p[1]['language_id'] == sl.language_id.to_s }
##					["0", {"id"=>"1", "language_id"=>"1", "_destroy"=>"1"}]
#
#					#	only uncheck the checkbox if it was unchecked.
#					language_checked = ( !attrs.nil? and attrs[1].has_key?('_destroy') ) ?
#						( attrs[1]['_destroy'] == '0' ) : true
#					
#					s << sl_fields.subject_language_destroyer(language_checked)
#				end
#				s << sl_fields.specify_other_language() if l.is_other?
#				s << "</div>"	if( l.is_other? ) # id='other_language'>" 
#			end
#			s << "</div>\n"	# class='subject_language'>"
#		end
#		s << "</div>\n"	#	languages
#		s << "</div><!-- study_subject_languages -->\n"	#	study_subject_languages
#	end

	def subject_languages_select( languages )
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
	end
	alias_method :subject_languages_selector, :subject_languages_select

	def subject_races_select( races = Race.all )
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
#				s << "<div id='other_race'>" if( race.is_other? )

#				s << sr_fields.check_box(:is_primary, {}, true, false)
#	default id="study_subject_subject_races_attributes_0_is_primary"
#	default class=nil
				s << sr_fields.check_box(:is_primary, { 
					:id => "#{@template.dom_id(race)}_is_primary", 
					:class => 'is_primary_selector',
					:title => "Set '#{race}' as the subject's PRIMARY race" } ) << "\n"

				if sr.id.nil?	#	not currently existing subject_race
					s << sr_fields.subject_race_creator(sr_built_or_exists)
				else	#	race exists, this is for possible destruction
					s << sr_fields.subject_race_destroyer(!sr.marked_for_destruction?)
				end
#				s << sr_fields.specify_other_race() if race.is_other?
#				s << "</div>"	if( race.is_other? ) # id='other_race'>" 
			end
			s << "</div>\n"	# class='subject_race'>"
		end
		s << "</div>\n"	#	races
		s << "</div><!-- study_subject_races -->\n"	#	study_subject_races
	end
	alias_method :subject_races_selector, :subject_races_select

protected

#
#	Labels, ids and classes customized for javascript simplicity and usage.
#

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
			:id      => @template.dom_id(self.object.race), 
			:class   => 'race_selector',
			:title   => "Set '#{self.object.race}' as one of the subject's race(s)"
		}, self.object.race_id, '' ) << "\n"
		s << self.label( :race_id, self.race_label,
			:for => @template.dom_id(self.object.race) ) << "\n"
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
			:id      => @template.dom_id(self.object.race), 
			:class   => 'race_selector',
			:title   => "Remove '#{self.object.race}' as one of the subject's race(s)"
		}, 0, 1 ) << "\n"
		s << self.label( :_destroy, self.race_label,
			:for => @template.dom_id(self.object.race) ) << "\n"
	end

#	def specify_other_race
#		s =  "<div id='specify_other_race'>"
#		s << self.label( :other, 'specify:' ) << "\n"
#		s << self.text_field( :other, :size => 12 ) << "\n"
#		s << "</div>"	# id='other_race'>"
#	end

	def language_label
		label =  self.object.language.key.dup.capitalize
		label << (( self.object.language.is_other? ) ? ' (not eligible)' : ' (eligible)')
	end

	def subject_language_creator(checked=false)
		#	self.object is a subject_language
		#	If exists, the hidden id tag is actually immediately put in the html stream!
		#	Don't think that it will be a problem, but erks me.
		s = self.check_box( :language_id, { :checked => checked }, self.object.language_id, '' ) << "\n"
		s << self.label( :language_id, self.language_label ) << "\n"
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
		s << self.check_box( :_destroy, { :checked => checked }, 0, 1 ) << "\n"
		s << self.label( :_destroy, self.language_label ) << "\n"
	end

	def specify_other_language
		s =  "<div id='specify_other_language'>"
		s << self.label( :other, 'specify:' ) << "\n"
		s << self.text_field( :other, :size => 12 ) << "\n"
		s << "</div>"	# id='other_language'>"
	end

end
ActionView::Helpers::FormBuilder.send(:include, StudySubjectsFormHelper)
