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

	belongs_to :vital_status

	after_initialize :set_default_vital_status, :if => :new_record?
	def set_default_vital_status
		# ||= doesn't work with ''
		self.vital_status_id ||= VitalStatus['living'].id
#		self.vital_status ||= VitalStatus['living']
	end

end	#	class_eval
end	#	included
end	#	StudySubjectVitalStatus
