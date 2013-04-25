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
