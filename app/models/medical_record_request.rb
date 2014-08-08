class MedicalRecordRequest < ActiveRecord::Base

	belongs_to     :study_subject
	attr_protected :study_subject_id, :study_subject

	def self.statuses
		%w( active waitlist pending abstracted completed )
	end

	#	statuses must be defined above before it can be used below.
	validations_from_yaml_file

	scope :active,   ->{ where( :status => 'active' ) }
	scope :waitlist, ->{ where( :status => 'waitlist' ) }
	scope :pending,  ->{ where( :status => 'pending' ) }
	scope :abstracted, ->{ where( :status => 'abstracted' ) }
	scope :incomplete, 
		->{ where(self.arel_table[:status].eq_any([nil,'active','waitlist','pending','abstracted'])) }

	scope :completed, ->{ where( :status => 'completed' ) }
	scope :complete, 
		->{ where(self.arel_table[:status].eq_any(['completed'])) }

	scope :with_status, ->(s=nil){ ( s.blank? ) ? all : 
		( s.to_s == 'complete' ) ? complete : 
		( s.to_s == 'incomplete' ) ? incomplete : where(:status => s) }

	def to_s
		( study_subject ) ? study_subject.studyid : self
	end

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Medical Record Request changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if( study_subject && study_subject.persisted? )
	end

end
