class ReceiveSamplesController < ApplicationController

	before_filter :may_create_samples_required,
		:only => [:new,:create]

	before_filter :valid_study_subject_id_required,
		:only => [:create]

	def new
		if !params[:study_subject_id].blank?
			if StudySubject.exists?(params[:study_subject_id])
				@study_subject = StudySubject.find(params[:study_subject_id])
			else
				flash[:warn] = "No Study Subjects Found."
			end
		elsif params[:studyid] or params[:icf_master_id]
			study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
				params[:studyid]||nil, params[:icf_master_id]||nil )
			case study_subjects.length 
				when 0 
					flash[:warn] = "No Study Subjects Found."
				when 1 
					@study_subject = study_subjects.first
				else
					flash[:warn] = "Multiple Study Subjects Found."
					@study_subjects = study_subjects
			end
		end
		if @study_subject

#
#
#	The subject returned should be the childs, not the mothers, I think.
#
#

#	SHOULD be at least CCLS.
#	SHOULD also only include consented enrollments (but using all for now)
			@projects = @study_subject.enrollments.collect(&:project)
			@sample = @study_subject.samples.new
		end
	end

	def create
		@sample = @study_subject.samples.new(params[:sample])
		@sample.save!


		redirect_to sample_path(@sample)
#	NO.

#		render :action => 'new'


	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved


		#	will be needed on the form
		@projects = @study_subject.enrollments.collect(&:project)


		flash.now[:error] = "Sample creation failed."
		render :action => 'new'
	end

protected

	#	redefined as needed to change redirect
	def valid_study_subject_id_required
		if !params[:study_subject_id].blank? and StudySubject.exists?(params[:study_subject_id])
			@study_subject = StudySubject.find(params[:study_subject_id])
		else
#	could be confusing as the id is in the link, not explicitly provided by the user.
			access_denied("Invalid study_subject id!", new_receive_sample_path)
		end
	end

end
__END__
