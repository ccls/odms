class ChartsController < ApplicationController
	def phase_5_case_enrollment
		@study_subjects = StudySubject.cases
			.joins( :enrollments )
			.where( :phase => 5 )
			.where( 'enrollments.project_id = ?',Project['ccls'].id)
			.group( 'enrollments.is_eligible, enrollments.consented' )
			.select('enrollments.is_eligible as is_eligible, enrollments.consented as consented, count(*) as count')
	end

	def case_enrollment
		#	the study_subjects.id is NEEDED to get the organization_id afterwards?
		@study_subjects = StudySubject.cases
			.joins( :patient => :organization )
			.joins( :enrollments )
			.where( 'enrollments.project_id = ?',Project['ccls'].id)
			.group( 'patients.organization_id, enrollments.is_eligible, enrollments.consented' )
			.select('study_subjects.id, patients.organization_id, enrollments.is_eligible as is_eligible, enrollments.consented as consented, count(*) as count')
			.order( 'organizations.key ASC' )
	end

	def blood_bone_marrow
		#	the study_subjects.id is NEEDED to get the organization_id afterwards?
		@study_subjects = StudySubject.cases.where( :phase => 5 )
			.joins( :patient => :organization )
			.joins( :samples => :sample_type )
			.group( 'patients.organization_id, sample_types.id' )
			.select('study_subjects.id, patients.organization_id, sample_types.key as type_key, sample_types.description as type_text, count(*) as count')
			.order( 'organizations.key ASC' )
			.having("type_key IN ('marrowdiag','periph')")
	end



	def subject_types_by_phase
		@study_subjects = StudySubject
			.joins(:subject_type)
			.group('phase, subject_type_id')
			.select('phase, subject_type_id, count(*) as count, subject_types.*')
	end
	def vital_statuses_by_phase
		@study_subjects = StudySubject
			.joins(:vital_status)
			.group('phase, vital_status_id')
			.select('phase, vital_status_id, count(*) as count, vital_statuses.*')
	end





	def enrollments
		@enrollments = Enrollment
			.select('project_id, count(*) as count')
			.group('project_id')
	end
	def vital_statuses
		@study_subjects = StudySubject
			.joins(:vital_status)
			.group('vital_status_id')
			.where(:phase => 5)
			.select('vital_status_id, count(*) as count, vital_statuses.*')
	end
	def vital_statuses_pie
		@study_subjects = StudySubject
			.joins(:vital_status)
			.group('vital_status_id')
			.select('vital_status_id, count(*) as count, vital_statuses.*')
	end
	def subject_types
		@study_subjects = StudySubject
			.joins(:subject_type)
			.group('subject_type_id')
			.where(:phase => 5)
			.select('subject_type_id, count(*) as count, subject_types.*')
	end
	def subject_types_pie
		@study_subjects = StudySubject
			.joins(:subject_type)
			.group('subject_type_id')
			.select('subject_type_id, count(*) as count, subject_types.*')
	end
	def case_control_types
		@study_subjects = StudySubject
			.select('case_control_type, count(*) as count')
			.group('case_control_type')
	end
	def case_control_types_pie
		@study_subjects = StudySubject
			.select('case_control_type, count(*) as count')
			.group('case_control_type')
	end
	def childidwho
		@study_subjects = StudySubject
			.select('childidwho, count(*) as count')
			.group('childidwho')
	end
	def is_eligible
		@enrollments = Enrollment
			.select('is_eligible, count(*) as count')
			.group('is_eligible')
	end
	def consented
		@enrollments = Enrollment
			.select('consented, count(*) as count')
			.group('consented')
	end

	def samples_sample_types
		@samples = Sample
			.joins(:sample_type)
			.group('sample_type_id')
			.select('sample_type_id, count(*) as count, sample_types.*')
	end
	def samples_sample_temperatures
		@samples = Sample
			.joins(:sample_temperature)
			.group('sample_temperature_id')
			.select('sample_temperature_id, count(*) as count, sample_temperatures.*')
	end
	def samples_locations
		@samples = Sample
			.joins(:organization)
			.group('location_id')
			.select('location_id, count(*) as count, organizations.*')
	end
	def samples_projects
		@samples = Sample
			.joins(:project)
			.group('project_id')
			.select('project_id, count(*) as count, projects.*')
	end

end
__END__
