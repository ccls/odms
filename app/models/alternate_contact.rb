class AlternateContact < ActiveRecord::Base

	belongs_to :study_subject

	validations_from_yaml_file

	before_save :format_phone_numbers, :if => :phone_numbers_changed?

	#	Returns a string with the city, state and zip
	def csz
		"#{self.city}, #{self.state} #{self.zip}"
	end

protected

	def phone_numbers_changed?
		phone_number_1_changed? or phone_number_2_changed?
	end

	#	Formats phone numer with () and -
	def format_phone_numbers
		if self.phone_number_1.present? and self.phone_number_1.length > 9
			old = self.phone_number_1.gsub(/\D/,'')
			new_phone = "(#{old[0..2]}) #{old[3..5]}-#{old[6..9]}"
			self.phone_number_1 = new_phone
		end
		if self.phone_number_2.present? and self.phone_number_2.length > 9
			old = self.phone_number_2.gsub(/\D/,'')
			new_phone = "(#{old[0..2]}) #{old[3..5]}-#{old[6..9]}"
			self.phone_number_2 = new_phone
		end
	end

end
