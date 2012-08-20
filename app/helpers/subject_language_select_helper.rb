module SubjectLanguageSelectHelper

#	def subject_languages_select( languages = Language.all )
	#	doing it this way allows passing nothing, an array 
	#	(as is currently in views), or just as list
	def subject_languages_select( *args )
		options = args.extract_options!
		languages = args.flatten
		languages = Language.order('position') if languages.empty?
		#		self.object  #	<-- the subject
		div = @template.content_tag(:div,
			:id => 'study_subject_languages', :class => options[:class]) do
			#	TODO would be nice, but not currently needed, to have a label option.
			s =  "<div class='languages_label'>Language of parent or caretaker:</div>\n"
			s << "<div id='languages'>\n"
			languages.each do |l|
				sl = self.object.subject_languages.detect{|sl|sl.language_id == l.id }
				#	This effectively requires that the attributes have 
				#		been updated in the controller.
				#	@study_subject.subject_languages_attributes = params.dig(
				#		'study_subject','subject_languages_attributes')||{}
				sl_built_or_exists = ( sl.nil? ) ? false : true						#	need to remember
				sl = self.object.subject_languages.build(:language => l) if sl.nil?
				classes = ['subject_language']
				classes << ( ( sl.id.nil? ) ? 'creator' : 'destroyer' )
				s << "<div class='#{classes.join(' ')}'>"
	
	
	
	# TODO fields_for is what would generate the id field (i think)
	# gotta figure out how to get it back in there
	
	
				s << self.fields_for( :subject_languages, sl ) do |sl_fields|
					srl = ''
					srl << "<div id='other_language'>" if( l.is_other? )
	
					if sl.id.nil?	#	not currently existing subject_language
						srl << sl_fields.subject_language_creator(sl_built_or_exists)
					else	#	language exists, this is for possible destruction
						srl << sl_fields.subject_language_destroyer(!sl.marked_for_destruction?)
					end
					srl << sl_fields.specify_other_language() if l.is_other?
					srl << "</div>"	if( l.is_other? ) # id='other_language'>" 
					srl.html_safe
				end
				s << "</div>\n"	# class='subject_language'>"
			end
			s << "</div>\n"	#	languages
			s.html_safe
		end	#	content_tag(:div,:id => 'study_subject_languages', :class => options[:class])
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

	#	should really change this to language_other_other_language for clarity
	def specify_other_language
		s =  "<div id='specify_other_language'>"
		s << self.label( :other_language, 'specify:', :for => 'other_other_language' ) << "\n"
		s << self.text_field( :other_language, :size => 12, :id => 'other_other_language' ) << "\n"
		s << "</div>"	# id='other_language'>"
	end

end
ActionView::Helpers::FormBuilder.send(:include, SubjectLanguageSelectHelper)

__END__
