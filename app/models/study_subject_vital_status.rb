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

	after_initialize :set_default_vital_status, :if => :new_record?
	def set_default_vital_status
		# ||= doesn't work with ''
		self.vital_status ||= 'Living'
	end

	def self.valid_vital_statuses
		["Living", "Deceased", "Refused to State", "Don't Know"]
	end

	#	This method is predominantly for a form selector.
	#	It will show the existing value first followed by the other valid values.
	#	This will allow an existing invalid value to show on the selector,
	#		but should fail on save as it is invalid.  This way it won't
	#		silently change the vital status.
	def vital_statuses
		[self.vital_status] + ( self.class.valid_vital_statuses - [self.vital_status])
	end

	def is_living?
		vital_status == 'Living'
	end

	def is_deceased?
		vital_status == 'Deceased'
	end

end	#	class_eval
end	#	included
end	#	StudySubjectVitalStatus
