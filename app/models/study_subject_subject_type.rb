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

	belongs_to :subject_type

#	validates_presence_of :subject_type_id
#	validates_presence_of :subject_type, :if => :subject_type_id

	attr_protected :subject_type_id

	def is_child?
		is_case_or_control?
	end

	def is_case_or_control?
		is_case? or is_control?
	end

	#	Returns boolean of comparison
	#	true only if type is Case
	def is_case?
#		subject_type_id == StudySubject.subject_type_case_id
		subject_type_id == SubjectType['case'].id
	end

	#	Returns boolean of comparison
	#	true only if type is Control
	def is_control?
#		subject_type_id == StudySubject.subject_type_control_id
		subject_type_id == SubjectType['control'].id
	end

	#	Returns boolean of comparison
	#	true only if type is Mother
	def is_mother?
#		subject_type_id == StudySubject.subject_type_mother_id
		subject_type_id == SubjectType['mother'].id
	end

	#	Returns boolean of comparison
	#	true only if type is Father
	def is_father?
#		subject_type_id == StudySubject.subject_type_father_id
		subject_type_id == SubjectType['father'].id
	end

	#	Returns boolean of comparison
	#	true only if type is Twin
	def is_twin?
#		subject_type_id == StudySubject.subject_type_twin_id
		subject_type_id == SubjectType['twin'].id
	end

#protected
#
#	#	Use these to stop the constant checking.
#	def self.subject_type_mother_id
#		@@subject_type_mother_id ||= SubjectType['Mother'].id
#	end
#
#	def self.subject_type_father_id
#		@@subject_type_father_id ||= SubjectType['Father'].id
#	end
#
#	def self.subject_type_twin_id
#		@@subject_type_twin_id ||= SubjectType['Twin'].id
#	end
#
#	def self.subject_type_control_id
#		@@subject_type_control_id ||= SubjectType['Control'].id
#	end
#
#	def self.subject_type_case_id
#		@@subject_type_case_id ||= SubjectType['Case'].id
#	end

end	#	class_eval
end	#	included
end	#	StudySubjectSubjectType
