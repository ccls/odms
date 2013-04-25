#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectVitalStatus
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

#	belongs_to :vital_status, :primary_key => "code", :foreign_key => "vital_status_code"

	after_initialize :set_default_vital_status, :if => :new_record?
	def set_default_vital_status
		# ||= doesn't work with ''
#		self.vital_status_code ||= VitalStatus['living'].code
		self.vital_status ||= 'Living'
	end

	def self.valid_vital_statuses
		["Living", "Deceased", "Refused to State", "Don't Know"]
	end

	def is_living?
#		vital_status_code == VitalStatus['living'].code
		vital_status == 'Living'
	end

	def is_deceased?
#		vital_status_code == VitalStatus['deceased'].code
		vital_status == 'Deceased'
	end

end	#	class_eval
end	#	included
end	#	StudySubjectVitalStatus
