#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectSunspot
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

searchable do
	# fields for faceting or explicit field searching
	string :subject_type
	string :vital_status
	string :case_control_type
	date :reference_date
	string :gender
	date :dob
	date :died_on
	string :phase
	integer :birth_year
	# fields for text searching
	# ALL ids and names
	# enrolled projects
	# sampleids
	# Phone numbers
end

end	#	class_eval
end	#	included
end	#	StudySubjectSunspot
