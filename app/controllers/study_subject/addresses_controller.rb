class StudySubject::AddressesController < StudySubjectController

	before_filter :may_create_addresses_required,
		:only => [:new,:create]
	before_filter :may_read_addresses_required,
		:only => [:show,:index]
	before_filter :may_update_addresses_required,
		:only => [:edit,:update]
	before_filter :may_destroy_addresses_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def index
	end

	def new
		@address = Address.new
	end

	def create
		@address = @study_subject.addresses.build( address_params )
		@address.save!
		redirect_to study_subject_contacts_path(@address.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Address creation failed"
		render :action => 'new'
	end

	def update
		@address.update_attributes!( address_params )
		redirect_to study_subject_contacts_path(@address.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Address update failed"
		render :action => 'edit'
	end

	def destroy
		@address.destroy
		redirect_to study_subject_contacts_path(@address.study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and @study_subject.addresses.exists?(params[:id])
			@address = @study_subject.addresses.find(params[:id])
		else
			access_denied("Valid address id required!", study_subjects_path)
		end
	end

	def address_params
		params.require(:address).permit( :address_type, :data_source, :other_data_source, 
			:line_1, :unit, :line_2, :city, :state, :zip, :county, :country,
			:current_address, :subject_moved, :address_at_diagnosis, :notes )
	end

end
