class MedicalRecordRequest < ActiveRecord::Base

	belongs_to     :study_subject
	attr_protected :study_subject_id, :study_subject

	def self.statuses
		%w( active waitlist pending complete abstracted )
	end

	#	statuses must be defined above before it can be used below.
	validations_from_yaml_file

	scope :active,   ->{ where( :status => 'active' ) }
	scope :waitlist, ->{ where( :status => 'waitlist' ) }
	scope :pending,  ->{ where( :status => 'pending' ) }
	scope :complete, ->{ where( :status => 'complete' ) }
	scope :abstracted, ->{ where( :status => 'abstracted' ) }
	scope :incomplete, 
		->{ where(self.arel_table[:status].eq(nil).or(
			self.arel_table[:status].not_eq('complete'))) }
	scope :with_status, ->(s=nil){ ( s.blank? ) ? all : where(:status => s) }

	def to_s
		( study_subject ) ? study_subject.studyid : self
	end

end
