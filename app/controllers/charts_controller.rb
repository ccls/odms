class ChartsController < ApplicationController
	def enrollments
		@enrollments = Enrollment.select('project_id, count(*) as count'
			).group('project_id')
	end
	def vital_statuses
		@study_subjects = StudySubject.joins(:vital_status).group('vital_status_id'
			).select('vital_status_id, count(*) as count, vital_statuses.*')
	end
	def vital_statuses_pie
		@study_subjects = StudySubject.joins(:vital_status).group('vital_status_id'
			).select('vital_status_id, count(*) as count, vital_statuses.*')
	end
	def subject_types
		@study_subjects = StudySubject.joins(:subject_type).group('subject_type_id'
			).select('subject_type_id, count(*) as count, subject_types.*')
	end
	def subject_types_pie
		@study_subjects = StudySubject.joins(:subject_type).group('subject_type_id'
			).select('subject_type_id, count(*) as count, subject_types.*')
	end
	def case_control_types
		@study_subjects = StudySubject.select('case_control_type, count(*) as count'
			).group('case_control_type')
	end
	def case_control_types_pie
		@study_subjects = StudySubject.select('case_control_type, count(*) as count'
			).group('case_control_type')
	end
	def childidwho
		@study_subjects = StudySubject.select('childidwho, count(*) as count'
			).group('childidwho')
	end
	def is_eligible
		@enrollments = Enrollment.select('is_eligible, count(*) as count'
			).group('is_eligible')
	end
	def consented
		@enrollments = Enrollment.select('consented, count(*) as count'
			).group('consented')
	end

	def samples_sample_types
		@samples = Sample.joins(:sample_type).group('sample_type_id'
			).select('sample_type_id, count(*) as count, sample_types.*')
	end
	def samples_sample_temperatures
		@samples = Sample.joins(:sample_temperature).group('sample_temperature_id'
			).select('sample_temperature_id, count(*) as count, sample_temperatures.*')
	end
	def samples_locations
		@samples = Sample.joins(:organization).group('location_id'
			).select('location_id, count(*) as count, organizations.*')
	end
	def samples_projects
		@samples = Sample.joins(:project).group('project_id'
			).select('project_id, count(*) as count, projects.*')
	end

end
__END__
