# A study_subject's phone number
class PhoneNumber < ActiveRecord::Base

	acts_as_list :scope => :study_subject_id

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :phone_type
	belongs_to :data_source

	delegate :is_other?, :to => :data_source, :allow_nil => true, :prefix => true

	validations_from_yaml_file

	#	Want to ensure contains 10 digits.
	#	I'm kinda surprised that this regex works.
	validates_format_of   :phone_number, :with => /\A(\D*\d\D*){10}\z/,
		:allow_blank => true

	scope :current,  
		where(self.arel_table[:current_phone].not_eq_all([nil,2]))
	scope :historic, 
		where(self.arel_table[:current_phone].eq_any([nil,2]))
	scope :primary,   
		where(:is_primary => true)
	scope :alternate,  
		where(self.arel_table[:is_primary].eq_any([nil,false]))

	before_save :format_phone_number, :if => :phone_number_changed?

	attr_accessor :current_user

	#	Returns description
	def to_s
		phone_number
	end

protected

	#	Formats phone numer with () and -
	def format_phone_number
		unless self.phone_number.nil?
			old = self.phone_number.gsub(/\D/,'')
			new_phone = "(#{old[0..2]}) #{old[3..5]}-#{old[6..9]}"
			self.phone_number = new_phone
		end
	end

end
