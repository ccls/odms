# A study_subject's phone number
class PhoneNumber < ActiveRecord::Base

	acts_as_list :scope => :study_subject_id

	belongs_to :study_subject, :counter_cache => true
	attr_protected :study_subject_id, :study_subject
	belongs_to :phone_type
	belongs_to :data_source

	delegate :is_other?, :to => :data_source, :allow_nil => true, :prefix => true

	validations_from_yaml_file

	scope :current,  
		where(self.arel_table[:current_phone].not_eq_all([nil,2]))
	scope :historic, 
		where(self.arel_table[:current_phone].eq_any([nil,2]))
	scope :primary,   
		where(:is_primary => true)
	scope :alternate,  
		where(self.arel_table[:is_primary].eq_any([nil,false]))

	before_save :format_phone_number, :if => :phone_number_changed?

#	left over from verified_by_uid
#	attr_accessor :current_user

	#	Returns description
	def to_s
		phone_number
	end

	after_save :reindex_study_subject!, :if => :changed?

protected

	def reindex_study_subject!
		logger.debug "Phone Number changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
#		study_subject.index if study_subject
	end

	#	Formats phone numer with () and -
	def format_phone_number
		unless self.phone_number.nil?
			old = self.phone_number.gsub(/\D/,'')
			new_phone = "(#{old[0..2]}) #{old[3..5]}-#{old[6..9]}"
			self.phone_number = new_phone
		end
	end

end
