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
				flash.now[:warn] = "No Study Subjects Found."
			end
		elsif params[:studyid] or params[:icf_master_id]
			conditions = [[],{}]
			%w( studyid icf_master_id ).each do |attr|
				if params[attr] and !params[attr].blank?
					conditions[0] << "( #{attr} LIKE :#{attr} )"
					conditions[1][attr.to_sym] = "%#{params[attr].split(/\s+/).join('%')}%"
				end
			end
			study_subjects = StudySubject.where(
				conditions[0].join(' OR '), conditions[1])
			case study_subjects.length 
				when 0 
					flash.now[:warn] = "No Study Subjects Found."
				when 1 
					@study_subject = study_subjects.first
				else
					flash.now[:warn] = "Multiple Study Subjects Found."
					@study_subjects = study_subjects
			end
		end
		if @study_subject
#
#
#	TODO The subject returned should be the childs, not the mothers, I think.
#
#
#	SHOULD be at least CCLS.
#	SHOULD also only include consented enrollments (but using all for now)
#
			@sample = Sample.new
		end
	end

	def create
		@sample = @study_subject.samples.new(params[:sample])
		@sample.received_by_ccls_at = DateTime.now
		@sample.save!
		render :action => 'new'
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
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
