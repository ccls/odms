class ReceiveSamplesController < ApplicationController

	before_filter :may_create_samples_required,
		:only => [:new,:create]

	before_filter :valid_study_subject_id_required,
		:only => [:create]

	def new
		if !params[:study_subject_id].blank?
#			if StudySubject.exists?(params[:study_subject_id])
#				@study_subject = StudySubject.find(params[:study_subject_id])
#	what if subject exists, but there is no child?
#	use where instead of find so doesn't raise error on bad id
			unless @study_subject = StudySubject.where(
					:id => params[:study_subject_id] ).first.try(:child)
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

			#	get the children, in case given mother's icf_master_id
			study_subjects = study_subjects.collect(&:child)
#	 StudySubject.children.with_subjectid(familyid).includes(:subject_type).first
			#	uniqify in case child and mother both found
			study_subjects = study_subjects.uniq

			#	actually don't think compacting is needed
			#
			#	UNLESS subject has blank familyid (shouldn't happen)
			#
#			study_subjects = study_subjects.compact

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
#	SHOULD be at least CCLS.
#	SHOULD also only include consented enrollments (but using all for now)
#
			@sample = Sample.new
		end
	end

	def create
#
#	here, we need to consider the :sample_source parameter
#
#	what if is mother, but there is no mother????
#
		sample_source = params[:sample_source] || 'child'

#	If used the form correctly, the @study_subject is a child (not a mother)
#	However, just to be sure ....
		@study_subject = @study_subject.child
#	what is is no child? this shouldn't happen

		subject = ( sample_source.match(/mother/i) ) ? 
			@study_subject.mother : @study_subject

#		@sample = @study_subject.samples.new(params[:sample])
		@sample = subject.samples.new(params[:sample])
		@sample.received_by_ccls_at = DateTime.now
		@sample.save!
		flash.now[:notice] = "Sample creation for #{sample_source} succeeded."
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
