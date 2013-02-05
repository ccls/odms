#	don't know exactly
class VitalStatus < ActiveRecord::Base

	acts_as_list
	acts_like_a_hash

	validates_presence_of   :code, :allow_blank => false
	validates_uniqueness_of :code

	has_many :study_subjects, :primary_key => "code", :foreign_key => "vital_status_code"

	#	Returns description
	def to_s
		description
	end

end
