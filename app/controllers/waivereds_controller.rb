class WaiveredsController < RafController
#
#	def new
#		@hospitals = Hospital.active.waivered.includes(:organization)
#			.order('organizations.name ASC')
#		@study_subject = StudySubject.new(params[:study_subject])
#	end
#
##	@hospitals only actually needed if organization not passed to study_subject
##	would put this in view, but is common template with different values
#
#	def create
#		@hospitals = Hospital.active.waivered.includes(:organization)
#			.order('organizations.name ASC')
#		study_subject_params = params[:study_subject].dup.to_hash
#		common_raf_create(study_subject_params)
#	end
#
end
