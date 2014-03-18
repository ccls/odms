class InterviewAssignment < ActiveRecord::Base

	attr_accessible :study_subject_id, :sent_on, :returned_on, :needs_hosp_search, :status, :notes_for_interviewer

#	NOTE this is not used

#  attr_accessible :needs_hosp_search, :notes_for_interviewer, :returned_on, :sent_on, :status, :study_subject_id

	belongs_to :study_subject
	attr_protected :study_subject, :study_subject_id

	validations_from_yaml_file

end
