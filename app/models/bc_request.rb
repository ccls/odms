class BcRequest < ActiveRecord::Base

	belongs_to     :study_subject
	attr_protected :study_subject_id, :study_subject

	def self.statuses
		%w( active waitlist pending completed )
	end

	#	statuses must be defined above before it can be used below.
	validations_from_yaml_file

	scope :active,   ->{ where( :status => 'active' ) }
	scope :waitlist, ->{ where( :status => 'waitlist' ) }
	scope :pending,  ->{ where( :status => 'pending' ) }
	scope :incomplete, 
		->{ where(self.arel_table[:status].eq_any([nil,'active','waitlist','pending'])) }

	scope :completed, ->{ where( :status => 'completed' ) }
	scope :complete, 
		->{ where(self.arel_table[:status].eq_any(['completed'])) }

	scope :with_status, ->(s=nil){ ( s.blank? ) ? all : 
		( s.to_s == 'complete' ) ? complete : 
		( s.to_s == 'incomplete' ) ? incomplete : where(:status => s) }

	def to_s
		( study_subject ) ? study_subject.studyid : self
	end

end
