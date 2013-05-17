#	Rich join of Subject and Address
class Addressing < ActiveRecord::Base

	belongs_to :study_subject, :counter_cache => true
	attr_protected :study_subject_id, :study_subject

	belongs_to :address
	belongs_to :data_source

	delegate :is_other?, :to => :data_source, :allow_nil => true, :prefix => true
	delegate :address_type, :address_type_id,:street,
		:line_1,:line_2,:unit,:city,:state,:zip,:csz,:county,
			:to => :address, :allow_nil => true

#	20130517 - do I still use this?
#	attr_accessor :current_user

	#	flag used in study_subject's nested attributes for addressing
	#		to not reject if address fields are blank.
	attr_accessor :address_required

	validations_from_yaml_file

	scope :current,  
		where(self.arel_table[:current_address].not_eq_all([nil,2]))

	scope :historic, 
		where(self.arel_table[:current_address].eq_any([nil,2]))

	scope :mailing, joins(:address => :address_type).where("address_types.key" => 'mailing')

	#	Don't do the rejections here.
	accepts_nested_attributes_for :address

	attr_accessor :subject_moved

	after_save :create_subject_moved_event, :if => :subject_moved

	after_save :reindex_study_subject!, :if => :changed?

protected

	def reindex_study_subject!
		logger.debug "Addressing changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
#		study_subject.index if study_subject
	end

	#	this will actually create an event on creation as well
	#	if attributes match
	def create_subject_moved_event
		if ['1','true'].include?(subject_moved) &&
				current_address == YNDK[:no] &&
				current_address_was != YNDK[:no] &&
				address.address_type_id == AddressType['residence'].id
			study_subject.operational_events.create!(
				:project_id                => Project['ccls'].id,
				:operational_event_type_id => OperationalEventType['subject_moved'].id,
				:occurred_at               => DateTime.current
			)
		end
	end

end
__END__
