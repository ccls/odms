class ReceiveSamplesController < ApplicationController

	before_filter :may_create_samples_required,
		:only => [:new,:create]

	before_filter :valid_study_subject_id_required,
		:only => [:create]

	before_filter :valid_sample_for_subject_required,
		:only => [:create]

	def new
		if !params[:study_subject_id].blank?
			unless @study_subject = StudySubject.where(
					:id => params[:study_subject_id] ).first.try(:child)
				flash.now[:warn] = "No Study Subjects Found."
			end
		elsif !params[:q].blank?
			#	As studyid and icf_master_id are different formats
			#	there should never actually be more than one match.
			study_subject = StudySubject.where(
				StudySubject.arel_table[:studyid].eq(params[:q]).or(
					StudySubject.arel_table[:icf_master_id].eq(params[:q]))).limit(1).first
#				'studyid = :q OR icf_master_id = :q', :q => params[:q]).limit(1).first

			#	get the child, in case given mother's icf_master_id
			#	if no study subject found, study_subject is nil, so use try
			study_subject = study_subject.try(:child)

			if study_subject
				@study_subject = study_subject
			else
				flash.now[:warn] = "No Study Subjects Found."
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

		@sample = @sample_for_subject.samples.new(params[:sample])
		@sample.received_by_ccls_at = DateTime.current

		#	All or nothin'
		Sample.transaction do
			@sample.save!
			@sample.sample_transfers.create!(
				:source_org_id => @sample.location_id,
				:status        => 'waitlist')
			@sample_for_subject.operational_events.create!(
				:description               => "Sample received: #{@sample.sample_type}",
				:project_id                => @sample.project_id,
				:operational_event_type_id => OperationalEventType['sample_received'].id,
				:occurred_at               => DateTime.current
			)
		end

		flash.now[:notice] = "Sample and Transfer creation for #{@sample_source} succeeded."
		render :action => 'new'
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample and Transfer creation failed."
		render :action => 'new'
	end

protected

	#	redefined as needed to change redirect
	def valid_study_subject_id_required
		if !params[:study_subject_id].blank? and 
				StudySubject.exists?(params[:study_subject_id])
			@study_subject = StudySubject.find(params[:study_subject_id])
		else
			#	could be confusing as the study_subject_id is in the link, 
			#	not explicitly provided by the user.
			access_denied("Invalid study_subject id!", new_receive_sample_path)
		end
	end

	def valid_sample_for_subject_required
		@sample_source = params[:sample_source] || 'child'
		#	@study_subject should really always be a child
		#	however, deal with possible
		@sample_for_subject = if( @sample_source.match(/mother/i) )
			( @study_subject.is_mother? ) ? @study_subject : @study_subject.mother
		else
			( @study_subject.is_child? ) ? @study_subject : @study_subject.child
		end
		if @sample_for_subject.blank?
			@sample = Sample.new(params[:sample])	#	for valid form
			flash.now[:error] = "Sample source / subject type mismatch."
			#	this render trigger filter failure so nothing else happens.
			render :action => 'new'
		end
	end

end
__END__
