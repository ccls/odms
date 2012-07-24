#	==	requires
#	*	enrollment_id
#	*	unit_id
class Sample < ActiveRecord::Base

	belongs_to :sample_type
	belongs_to :organization, :foreign_key => 'location_id'
	belongs_to :unit     #	NOTE not yet really used
	has_many :aliquots   #	NOTE not yet really used
	has_many :sample_transfers
	belongs_to :project
	belongs_to :study_subject
	belongs_to :sample_format
	belongs_to :sample_temperature

	attr_protected :study_subject_id, :study_subject

#	TODO I don't beleive that a sample_kit has any meaning anymore. Remove?
	has_one :sample_kit
	accepts_nested_attributes_for :sample_kit

	validates_presence_of :sample_type_id
	validates_presence_of :sample_type, :if => :sample_type_id


#	removing requirement for study subject id, although if there
#	is one, it should be a valid subject.  This may be temporary.
#	validates_presence_of :study_subject_id
	validates_presence_of :study_subject, :if => :study_subject_id



	validates_presence_of :project_id
	validates_presence_of :project, :if => :project_id
	validates_presence_of :sample_format, :if => :sample_format_id
	validates_presence_of :sample_temperature, :if => :sample_temperature_id

	validates_length_of   :state, :maximum => 250, :allow_blank => true

	validates_complete_date_for :sent_to_subject_at
	validates_complete_date_for :collected_from_subject_at
	validates_complete_date_for :received_by_ccls_at
	validates_complete_date_for :shipped_to_ccls_at
	validates_complete_date_for :sent_to_lab_at
	validates_complete_date_for :received_by_lab_at
	validates_complete_date_for :aliquotted_at
	validates_complete_date_for :receipt_confirmed_at

	validates_past_date_for :shipped_to_ccls_at
	validates_past_date_for :sent_to_subject_at
	validates_past_date_for :collected_from_subject_at
	validates_past_date_for :received_by_ccls_at
	validates_past_date_for :sent_to_lab_at
	validates_past_date_for :received_by_lab_at
	validates_past_date_for :aliquotted_at
	validates_past_date_for :receipt_confirmed_at

	#	Returns the parent of this sample type
	def sample_type_parent
		sample_type.parent
	end

	after_initialize :set_defaults, :if => :new_record?
	def set_defaults
		# ||= doesn't work with ''
		self.aliquot_or_sample_on_receipt ||= 'Sample'
		self.order_no ||= 1
		self.location_id ||= Organization['CCLS'].id
	end

	def sampleid
		sprintf('%07d',self.attributes['id']) unless new_record?
	end

end
