module StudySubjectsFormHelper

	#	May be able to implement this simplicity for the races as well
	#	Simplicity?  This has gotten rather complicated.
	def subject_languages_select( languages )
		#		self.object  #	<-- the subject
		sl_params = @template.params.dig('study_subject','subject_languages_attributes')||{}

		#	"0"=>{"language_id"=>"1"}.to_a 
		#	=> [0,{"language_id"=>"1"}] 
		#	hence l[1] 
		#	=> {"language_id"=>"1"}
		#	and l[1]['language_id']
		#	=> "1"
		#	As working with params, treat these all as strings.
		selected_language_ids = sl_params.collect{ |l| l[1]['language_id'] }

		s =  "<div id='study_subject_languages'>"
		#	TODO would be nice, but not currently needed, to have a label option.
		s << "<div class='languages_label'>Language of parent or caretaker:</div>\n"
		s << "<div id='languages'>\n"
		languages.each do |l|
			sl = self.object.subject_languages.detect{|sl|sl.language_id == l.id } ||
				self.object.subject_languages.build(:language => l)
			classes = ['subject_language']
			classes << ( ( sl.id.nil? ) ? 'creator' : 'destroyer' )
			s << "<div class='#{classes.join(' ')}'>"
			self.fields_for( :subject_languages, sl ) do |sl_fields|
				s << "<div id='other_language'>" if( l.is_other? )
#
#				label = sl_fields.object.language.key.dup.capitalize
#				label << (( l.is_other? ) ? ' (not eligible)' : ' (eligible)')
#
#				if sl.id.nil?	#	not currently existing subject_language
#					#	If exists, the hidden id tag is actually immediately put in the html stream!
#					#	Don't think that it will be a problem, but erks me.
#					s << sl_fields.check_box( :language_id, {
#						:checked => selected_language_ids.include?(sl.language_id.to_s),
#					}, sl.language_id, '' ) << "\n"
#					s << sl_fields.label( :language_id, label ) << "\n"
#				else	#	language exists, this is for possible destruction
#					#	check_box(object_name, method, options = {}, 
#					#		checked_value = "1", unchecked_value = "0")
#					#	when checked, I want it to do nothing (0), when unchecked I want destroy (1)
#					#	Here, I only want existing language_ids
#					#	Yes, this is very backwards.
#
#					#	KEEP ME for finding _destroy!
#					s << sl_fields.hidden_field( :language_id, :value => sl.language_id )
#
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
#					s << sl_fields.check_box( :_destroy, {
#						:checked => language_checked
#					}, 0, 1 ) << "\n"
#					s << sl_fields.label( :_destroy, label ) << "\n"
#				end
#
#				s << sl_fields.specify_other_language() if l.is_other?
#				if( l.is_other? )
#					s << "<div id='specify_other_language'>"
#					s << sl_fields.label( :other, 'specify:' ) << "\n"
#					s << sl_fields.text_field( :other, :size => 12 ) << "\n"
#					s << "</div>"	# id='other_language'>"
#				end


#	I would rather not be picking from the params, but for the moment it seems the only way.
#	Perhaps once this is working, I can change it up, but I don't foresee that.


				if sl.id.nil?	#	not currently existing subject_language
					s << sl_fields.subject_language_creator(selected_language_ids.include?(sl.language_id.to_s))
				else	#	language exists, this is for possible destruction
#	sl_params ...
# {"0"=>{"id"=>"1", "language_id"=>"1", "_destroy"=>"0"}, "1"=>{"language_id"=>""}, "2"=>{"language_id"=>"", "other"=>""}}

					attrs = sl_params.detect{|p| p[1]['language_id'] == sl.language_id.to_s }
#					["0", {"id"=>"1", "language_id"=>"1", "_destroy"=>"1"}]

					#	only uncheck the checkbox if it was unchecked.
					language_checked = ( !attrs.nil? and attrs[1].has_key?('_destroy') ) ?
						( attrs[1]['_destroy'] == '0' ) : true
					
					s << sl_fields.subject_language_destroyer(language_checked)
				end
				s << sl_fields.specify_other_language() if l.is_other?
				s << "</div>"	if( l.is_other? ) # id='other_language'>" 
			end
			s << "</div>\n"	# class='subject_language'>"
		end
		s << "</div>\n"	#	languages
		s << "</div><!-- study_subject_languages -->\n"	#	study_subject_languages
	end

protected

	def subject_language_creator(checked=false)
		#	self.object is a subject_language
		label =  self.object.language.key.dup.capitalize
		label << (( self.object.language.is_other? ) ? ' (not eligible)' : ' (eligible)')
		#	If exists, the hidden id tag is actually immediately put in the html stream!
		#	Don't think that it will be a problem, but erks me.
		s = self.check_box( :language_id, { :checked => checked }, self.object.language_id, '' ) << "\n"
		s << self.label( :language_id, label ) << "\n"
	end

	def subject_language_destroyer(checked=true)
		#	self.object is a subject_language
		label =  self.object.language.key.dup.capitalize
		label << (( self.object.language.is_other? ) ? ' (not eligible)' : ' (eligible)')
		#	KEEP ME for finding _destroy to determine if checked
		s =  self.hidden_field( :language_id, :value => self.object.language_id )
		#	check_box(object_name, method, options = {}, 
		#		checked_value = "1", unchecked_value = "0")
		#	when checked, I want it to do nothing (0), when unchecked I want destroy (1)
		#	Here, I only want existing language_ids
		#	Yes, this is very backwards.
		s << self.check_box( :_destroy, { :checked => checked }, 0, 1 ) << "\n"
		s << self.label( :_destroy, label ) << "\n"
	end

	def specify_other_language
		s =  "<div id='specify_other_language'>"
		s << self.label( :other, 'specify:' ) << "\n"
		s << self.text_field( :other, :size => 12 ) << "\n"
		s << "</div>"	# id='other_language'>"
	end

end
ActionView::Helpers::FormBuilder.send(:include, StudySubjectsFormHelper)
