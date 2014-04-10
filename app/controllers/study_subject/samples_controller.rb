class StudySubject::SamplesController < StudySubjectController

	before_filter :may_create_samples_required,
		:only => [:new,:create]
	before_filter :may_read_samples_required,
		:only => [:show,:index]
	before_filter :may_update_samples_required,
		:only => [:edit,:update]
	before_filter :may_destroy_samples_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]


	def index
		@samples = @study_subject.samples
	end

	def show
		respond_to do |format|
			format.html {}
			format.pdf { 
				prawnto :prawn => {
					:page_size => [175,90],
					:page_layout => :portrait,
					:margin => 5,
					:top_margin => 12
				},
				:filename => "sample_#{@sample.sampleid}_#{Time.now.to_s(:filename)}.pdf"
			}
		end
	end

	def new
		@sample = Sample.new
	end

	def create
		@sample = @study_subject.samples.new(params[:sample])

		#	All or nothin'
		Sample.transaction do
			@sample.save!
			@sample.sample_transfers.create!(
				:source_org_id => @sample.location_id,
				:status        => 'waitlist')
		end

		redirect_to study_subject_sample_path(@study_subject,@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample creation failed."
		render :action => 'new'
	end

	def edit
	end

	def update
		@sample.update_attributes!(params[:sample])
		redirect_to study_subject_sample_path(@study_subject,@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample update failed."
		render :action => 'edit'
	end

	def destroy
		@sample.destroy
		redirect_to study_subject_path(@study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and @study_subject.samples.exists?(params[:id])
			@sample = @study_subject.samples.find(params[:id])
		else
			access_denied("Valid sample id required!", study_subjects_path)
		end
	end

end
