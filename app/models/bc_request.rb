class BcRequest < ActiveRecord::Base

	belongs_to     :study_subject
	attr_protected :study_subject_id, :study_subject

	def self.statuses
		%w( active waitlist pending complete )
	end

	#	statuses must be defined above before it can be used below.
	validations_from_yaml_file

	scope :active,   ->{ where( :status => 'active' ) }
	scope :waitlist, ->{ where( :status => 'waitlist' ) }
	scope :pending,  ->{ where( :status => 'pending' ) }
	scope :complete, ->{ where( :status => 'complete' ) }
	scope :incomplete, 
		->{ where(self.arel_table[:status].eq(nil).or(
			self.arel_table[:status].not_eq('complete'))) }

	def to_s
		( study_subject ) ? study_subject.studyid : self
	end

	def self.with_status(status=nil)
		( status.blank? ) ? all : where(:status => status)
	end

end
