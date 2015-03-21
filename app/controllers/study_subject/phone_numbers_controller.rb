class StudySubject::PhoneNumbersController < StudySubjectController

	before_filter :may_create_phone_numbers_required,
		:only => [:new,:create]
	before_filter :may_read_phone_numbers_required,
		:only => [:show,:index]
	before_filter :may_update_phone_numbers_required,
		:only => [:edit,:update]
	before_filter :may_destroy_phone_numbers_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:edit,:update,:destroy]

	def new
		@phone_number = PhoneNumber.new
	end

	def create
		@phone_number = @study_subject.phone_numbers.build( phone_number_params )
		@phone_number.save!
		redirect_to study_subject_contacts_path(@phone_number.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "PhoneNumber creation failed"
		render :action => 'new'
	end

	def update
		@phone_number.update_attributes!( phone_number_params )
		redirect_to study_subject_contacts_path(@phone_number.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "PhoneNumber update failed"
		render :action => 'edit'
	end

	#	TEMP ADD FOR DEV ONLY!
	def destroy
		@phone_number.destroy
		redirect_to study_subject_contacts_path(@phone_number.study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and @study_subject.phone_numbers.exists?(params[:id])
			@phone_number = @study_subject.phone_numbers.find(params[:id])
		else
			access_denied("Valid phone_number id required!", study_subjects_path)
		end
	end

	def phone_number_params
		params.require(:phone_number).permit(:is_primary, :phone_number,
			:phone_type, :data_source, :other_data_source, :current_phone )
	end

end
