class ChartsController < ApplicationController
	def enrollments
		@enrollments = Enrollment.all(
			:select => 'project_id, count(*) as count', 
			:group => 'project_id')
	end
	def vital_statuses
		@study_subjects = StudySubject.all(
			:select => 'vital_status_id, count(*) as count', 
			:group => 'vital_status_id')
	end
	def vital_statuses_pie
		@study_subjects = StudySubject.all(
			:select => 'vital_status_id, count(*) as count', 
			:group => 'vital_status_id')
	end
	def subject_types
		@study_subjects = StudySubject.all(
			:select => 'subject_type_id, count(*) as count', 
			:group => 'subject_type_id')
	end
	def subject_types_pie
		@study_subjects = StudySubject.all(
			:select => 'subject_type_id, count(*) as count', 
			:group => 'subject_type_id')
	end
	def case_control_types
		@identifiers = Identifier.all(
			:select => 'case_control_type, count(*) as count', 
			:group => 'case_control_type')
	end
	def case_control_types_pie
		@identifiers = Identifier.all(
			:select => 'case_control_type, count(*) as count', 
			:group => 'case_control_type')
	end
end
