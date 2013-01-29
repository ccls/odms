module SubjectRaceSelectHelper

#	def subject_races_select( races = Race.all )
	#	doing it this way allows passing nothing, an array 
	#	(as is currently in views), or just as list
	def subject_races_select( *args )
		races = args.flatten
		races = Race.order('position') if races.empty?
		#		self.object  #	<-- the subject
		s =  "<div id='study_subject_races'>"
		#	TODO would be nice, but not currently needed, to have a label option.
		s << "<div class='races_label'>Select Race(s): "
#	20130129 - no longer using 'is_primary'
#		s <<   ".... ( [primary] [partial] Text )</div>\n"
		s <<   "</div>\n"
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


#	TODO fields_for is what would generate the id field (I think)
#	gotta figure out how to get it back in there

			s << self.fields_for( :subject_races, sr ) do |sr_fields|
				srf = ''
				srf << "<div id='other_race'>" if( race.is_other? )
				srf << "<div id='mixed_race'>" if( race.is_mixed? )

#				s << sr_fields.check_box(:is_primary, {}, true, false)
#	default id="study_subject_subject_races_attributes_0_is_primary"
#	default class=nil
#					:id => "#{@template.dom_id(race)}_is_primary", 

#	20130129 - no longer using 'is_primary'
#				srf << sr_fields.check_box(:is_primary, { 
#					:id => "#{race.key}_is_primary",	#	other_is_primary
#					:class => 'is_primary_selector',
#					:title => "Set '#{race}' as the subject's PRIMARY race" } ) << "\n"

				if sr.id.nil?	#	not currently existing subject_race
					srf << sr_fields.subject_race_creator(sr_built_or_exists)
				else	#	race exists, this is for possible destruction
					srf << sr_fields.subject_race_destroyer(!sr.marked_for_destruction?)
				end
				srf << sr_fields.specify_other_race() if race.is_other?
				srf << sr_fields.specify_mixed_race() if race.is_mixed?
				srf << "</div>"	if( race.is_other? ) # id='other_race'>" 
				srf << "</div>"	if( race.is_mixed? ) # id='mixed_race'>" 	COULD UNIFY WITH ABOVE
				srf.html_safe
			end

			s << "</div>\n"	# class='subject_race'>"
		end
		s << "</div>\n"	#	races
		s << "</div><!-- study_subject_races -->\n"	#	study_subject_races
		s.html_safe
	end
	alias_method :subject_races_selector, :subject_races_select
	alias_method :select_subject_races, :subject_races_select

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
		s << self.label( :other_race, 'specify:', :for => 'race_other_other_race' ) << "\n"
		s << self.text_field( :other_race, :size => 12, :id => 'race_other_other_race' ) << "\n"
		s << "</div>"	# id='other_race'>"
	end
#
#	could probably join these 2 methods
#
	def specify_mixed_race
		s =  "<div id='specify_mixed_race'>"
		s << self.label( :mixed_race, 'specify:', :for => 'race_mixed_mixed_race' ) << "\n"
		s << self.text_field( :mixed_race, :size => 12, :id => 'race_mixed_mixed_race' ) << "\n"
		s << "</div>"	# id='mixed_race'>"
	end

end
ActionView::Helpers::FormBuilder.send(:include, SubjectRaceSelectHelper)

__END__
