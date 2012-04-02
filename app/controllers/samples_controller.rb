class SamplesController < ApplicationController

	before_filter :may_create_samples_required,
		:only => [:new,:create]
	before_filter :may_read_samples_required,
		:only => [:show,:index,:dashboard,:find,:followup,:reports]
	before_filter :may_update_samples_required,
		:only => [:edit,:update]
	before_filter :may_destroy_samples_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:new,:create,:index]
#		:except => [:dashboard,:find,:followup,:reports,:edit,:update,:show,:destroy]

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def find
		#	If this gets much more complex, we may want to consider using something like solr.
		record_or_recall_sort_order
		conditions = [[],{}]

		#	Table names are not necessary if field is unambiguous.
		%w( childid patid icf_master_id first_name ).each do |attr|
			if params[attr] and !params[attr].blank?
				conditions[0] << "( #{attr} LIKE :#{attr} )"
				conditions[1][attr.to_sym] = "%#{params[attr]}%"
			end
		end

		if params[:last_name] and !params[:last_name].blank?
			conditions[0] << "( last_name LIKE :last_name OR maiden_name LIKE :last_name )"
			conditions[1][:last_name] = "%#{params[:last_name]}%"
		end

		if params[:sampleid] and !params[:sampleid].blank?
#			conditions[0] << "( samples.id LIKE :sampleid )"		#	LIKE?  REALLY?
#			conditions[1][:sampleid] = "%#{params[:sampleid]}%"
			conditions[0] << "( samples.id = :sampleid )"	#	MUST include table name here
			conditions[1][:sampleid] = params[:sampleid].gsub(/^0*/,'')
		end

		if params[:sample_type_id] and !params[:sample_type_id].blank? and 
				SampleType.exists?(params[:sample_type_id])
			sample_type = SampleType.find(params[:sample_type_id])
			conditions[0] << "( sample_type_id IN ( :sample_type_ids ) )"
			conditions[1][:sample_type_ids] = if( sample_type.is_root? )
				sample_type.children.collect(&:id)
			else
				[sample_type.id]
			end
		end

		#	may want to implement this for study_subjects/find on dob as well
		validate_valid_date_range_for(:sent_to_subject_at,conditions)
		validate_valid_date_range_for(:received_by_ccls_at,conditions)

		@samples = Sample.joins(:study_subject
			).where(conditions[0].join(valid_find_operator), conditions[1] 
			).paginate(
				:per_page => params[:per_page]||25,
				:page     => valid_find_page
			)
	end

	def index
		@samples = @study_subject.samples
		render :layout => 'subject'
	end

	def show
		render :layout => 'subject'
	end

	def new
		@sample = Sample.new
		render :layout => 'subject'
	end

	def create
		@sample = @study_subject.samples.new(params[:sample])
		@sample.save!
		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample creation failed."
		render :action => 'new', :layout => 'subject'
	end

	def edit
		render :layout => 'subject'
	end

	def update
		@sample.update_attributes!(params[:sample])
		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample update failed."
		render :action => 'edit', :layout => 'subject'
	end

	def destroy
		@sample.destroy
		redirect_to study_subject_path(@study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and Sample.exists?(params[:id])
			@sample = Sample.find(params[:id])
			@study_subject = @sample.study_subject
##	in dev on brg, above fails so being more explicit, the below works
#			@study_subject = StudySubject.find(@sample.study_subject_id)
		else
			access_denied("Valid sample id required!", study_subjects_path)
		end
	end

end
