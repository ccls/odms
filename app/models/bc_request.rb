class BcRequest < ActiveRecord::Base

	belongs_to     :study_subject
	attr_protected :study_subject_id, :study_subject

	validates_length_of :request_type, :status, :maximum => 250, :allow_blank => true
	validates_length_of :notes,        :maximum => 65000, :allow_blank => true

	def self.statuses
		%w( active waitlist pending complete )
	end
	#	statuses must be defined above before it can be used below.
	validates_inclusion_of :status, :in => statuses, :allow_blank => true

	scope :active,   where( :status => 'active' )
	scope :waitlist, where( :status => 'waitlist' )
	scope :pending,  where( :status => 'pending' )
	scope :complete, where( :status => 'complete' )
	scope :incomplete, where("status != 'complete' OR status IS NULL")

	def to_s
		( study_subject ) ? study_subject.studyid : self
	end

	def self.with_status(status=nil)
		( status.blank? ) ? scoped : where(:status => status)
	end

end
