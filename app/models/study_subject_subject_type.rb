#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectSubjectType
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	attr_protected :subject_type

	def self.valid_subject_types
		%w( Case Control Mother Father Twin )
	end

	#
	#	As this attribute shouldn't ever be changed, I haven't created
	#	the "standard" subject_types method.
	#
	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the subject types.
	#	def subject_types
	#		([self.subject_type] + self.class.valid_subject_types ).compact.uniq
	#	end

	def is_child?
		is_case_or_control?
	end

	def is_case_or_control?
		is_case? or is_control?
	end

	#	Returns boolean of comparison
	#	true only if type is Case
	def is_case?
		subject_type == 'Case'
	end

	#	Returns boolean of comparison
	#	true only if type is Control
	def is_control?
		subject_type == 'Control'
	end

	#	Returns boolean of comparison
	#	true only if type is Mother
	def is_mother?
		subject_type == 'Mother'
	end

	#	Returns boolean of comparison
	#	true only if type is Father
	def is_father?
		subject_type == 'Father'
	end

	#	Returns boolean of comparison
	#	true only if type is Twin
	def is_twin?
		subject_type == 'Twin'
	end

end	#	class_eval
end	#	included
end	#	StudySubjectSubjectType
