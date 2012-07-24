class InterviewAssignment < ActiveRecord::Base
#  attr_accessible :needs_hosp_search, :notes_for_interviewer, :returned_on, :sent_on, :status, :study_subject_id

	belongs_to :study_subject
	attr_protected :study_subject, :study_subject_id

	validations_from_yaml_file

#	validates_length_of   :notes_for_interviewer,
#		:maximum => 65000, :allow_blank => true
#	validates_length_of   :status,
#		:maximum => 250, :allow_blank => true
#	validates_complete_date_for :sent_on, :returned_on,
#		:allow_blank => true

end
