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

	validations_from_yaml_file

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
#	I think back in ruby 1.8.7 self.id returned the object id, NOT the database record id.  VERY DIFFERENT.
#		sprintf('%07d',self.attributes['id']) unless new_record?
		sprintf('%07d',self.id) unless new_record?
	end

	#	for destroy confirmation pop-up
	def to_s
		"SampleID #{sampleid}"
	end

	after_save :reindex_study_subject!

protected

	def reindex_study_subject!
		study_subject.index if study_subject
	end

end
