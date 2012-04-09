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

	validates_presence_of :subject_type_id
	validates_presence_of :subject_type, :if => :subject_type_id

	#	Returns boolean of comparison
	#	true only if type is Case
	def is_case?
		subject_type_id == StudySubject.subject_type_case_id
	end

	#	Returns boolean of comparison
	#	true only if type is Control
	def is_control?
		subject_type_id == StudySubject.subject_type_control_id
	end

	#	Returns boolean of comparison
	#	true only if type is Mother
	def is_mother?
		subject_type_id == StudySubject.subject_type_mother_id
	end

protected

	#	Use these to stop the constant checking.
	def self.subject_type_mother_id
		@@subject_type_mother_id ||= SubjectType['Mother'].id
	end

	def self.subject_type_control_id
		@@subject_type_control_id ||= SubjectType['Control'].id
	end

	def self.subject_type_case_id
		@@subject_type_case_id ||= SubjectType['Case'].id
	end

end	#	class_eval
end	#	included
end	#	StudySubjectSubjectType
