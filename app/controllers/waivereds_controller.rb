class WaiveredsController < RafController

	before_filter :may_create_study_subjects_required

	def new
#		@hospitals = Hospital.waivered(:include => :organization)
		@hospitals = Hospital.active.waivered.includes(:organization)
		@study_subject = StudySubject.new(params[:study_subject])
	end

#	@hospitals only actually needed if organization not passed to study_subject

	def create
#		@hospitals = Hospital.waivered(:include => :organization)
		@hospitals = Hospital.active.waivered.includes(:organization)
		study_subject_params = params[:study_subject].dup.to_hash
		common_raf_create(study_subject_params)
	end

end
