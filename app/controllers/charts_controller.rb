class ChartsController < ApplicationController
	def phase_5_case_enrollment_by_month
		dates = 15.times.collect{|i| Date.current - i.months }.reverse

		phase5 = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5') 
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
		}	#	by month over the past 12 months
		p = Project['ccls']
		consenting = StudySubject.search{
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
			with(:subject_type, 'Case')
			with(:phase, '5')
			with(:ccls_consented,"Yes")
			with(:ccls_is_eligible,"Yes") }

		refused = StudySubject.search{
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
			with(:subject_type, 'Case')
			with(:phase, '5')
			with(:ccls_consented,"No")
			with(:ccls_is_eligible,"Yes") }

		ineligible = StudySubject.search{
			facet(:reference_date) {
				dates.each { |date|
					row("#{date.month}-#{date.year}"){ with(:reference_date).between([
						date.beginning_of_month, date.end_of_month]) } } } 
			with(:subject_type, 'Case')
			with(:phase, '5')
			with(:ccls_is_eligible,"No") }

		@total_counts = dates.collect{|date|
			phase5.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}
		@consenting_counts = dates.collect{|date|
			consenting.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}
		@refused_counts = dates.collect{|date|
			refused.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}
		@ineligible_counts = dates.collect{|date|
			ineligible.facet(:reference_date).rows.detect{|row|
				row.value == "#{date.month}-#{date.year}" }.try(:count)||0}

		@labels = dates.collect{|d| d.strftime('%b%y') }
		@max_y = @total_counts.max
	end
	def phase_5_case_enrollment
		phase5 = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5') }
		p = Project['ccls']
		consenting = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5')
			with(:ccls_consented,"Yes")
			with(:ccls_is_eligible,"Yes") }

		refused = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5')
			with(:ccls_consented,"No")
			with(:ccls_is_eligible,"Yes") }

		ineligible = StudySubject.search{
			with(:subject_type, 'Case')
			with(:phase, '5')
			with(:ccls_is_eligible,"No") }

		@counts = [ phase5.total, consenting.total,
			refused.total,ineligible.total ]
		@max_y = phase5.total
	end

	def case_enrollment
		all = StudySubject.search{
			facet :hospital_key
			order_by :hospital_key, :asc }	#	not needed as array is sorted?
		p = Project['ccls']
		eligible = StudySubject.search{
			facet :hospital_key
			with(:ccls_is_eligible,"Yes") }

		consenting = StudySubject.search{
			facet :hospital_key
			with(:ccls_consented,"Yes")
			with(:ccls_is_eligible,"Yes") }

		@all_hospital_keys = all.facet(:hospital_key).rows.collect(&:value).sort.uniq
		#	non-nil needed, at least for testing
		@total_counts = @all_hospital_keys.collect{|hospital|
			all.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@eligible_counts = @all_hospital_keys.collect{|hospital|
			eligible.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@consenting_counts = @all_hospital_keys.collect{|hospital|
			consenting.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@max_y = @total_counts.max || 0
	end

	def blood_bone_marrow
		#	Would be nice to do this in just 1 query
		#	but don't think if I can.
		marrow = StudySubject.search{
			facet :hospital_key
			order_by :hospital_key, :asc	#	not needed as array is sorted?
			with(:sample_types,"bone marrow - diagnostic")}
		blood = StudySubject.search{
			facet :hospital_key
			order_by :hospital_key, :asc	#	not needed as array is sorted?
			with(:sample_types,"peripheral blood - diagnostic")}

		@all_hospital_keys = [blood,marrow].collect{|b| 
			b.facet(:hospital_key) }.collect(&:rows).flatten.collect(&:value).sort.uniq
		#	non-nil needed, at least for testing
		@max_y = [blood,marrow].collect{|b| 
			b.facet(:hospital_key) }.collect(&:rows).flatten.collect(&:count).max || 0
		@marrow_counts = @all_hospital_keys.collect{|hospital| 
			marrow.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
		@blood_counts  = @all_hospital_keys.collect{|hospital| 
			blood.facet(:hospital_key).rows.detect{|row|
				row.value == hospital }.try(:count)||0}
	end

	def subject_types_by_phase
		@study_subjects = StudySubject
			.group('phase, subject_type')
			.select('phase, subject_type, count(*) as count')
	end
	def vital_statuses_by_phase
		@study_subjects = StudySubject
			.group('phase, vital_status')
			.select('phase, vital_status, count(*) as count')
	end

	def enrollments
		@enrollments = Enrollment
			.select('project_id, count(*) as count')
			.group('project_id')
	end
	def vital_statuses
		@study_subjects = StudySubject
			.group('vital_status')
			.where(:phase => 5)
			.select('vital_status, count(*) as count')

		@vital_statuses = @study_subjects.collect{|s| s.vital_status }
		@max_y = @study_subjects.collect{|s|s.count.to_i}.max
	end
	def vital_statuses_pie
		@study_subjects = StudySubject
			.group('vital_status')
			.select('vital_status, count(*) as count')
	end
	def subject_types
		@study_subjects = StudySubject
			.group('subject_type')
			.where(:phase => 5)
			.select('subject_type, count(*) as count')
		@subject_types = @study_subjects.collect{|s| s.subject_type }
		@max_y = @study_subjects.collect{|s|s.count.to_i}.max
	end
	def subject_types_pie
		@study_subjects = StudySubject
			.group('subject_type')
			.select('subject_type, count(*) as count')
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
			.group(:sample_temperature)
			.select('sample_temperature, count(*) as count')
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
