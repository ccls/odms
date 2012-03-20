class BcRequest < ActiveRecord::Base

	belongs_to     :study_subject
	attr_protected :study_subject_id, :study_subject

	validates_length_of :request_type, :status, :maximum => 250, :allow_blank => true
	validates_length_of :notes,        :maximum => 65000, :allow_blank => true

#	validates_inclusion_of :status, :in => statuses

	def self.statuses
		%w( active waitlist pending complete )
	end

	def to_s
		( study_subject ) ? study_subject.studyid : self
	end

end
