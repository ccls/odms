class AddressingsController < ApplicationController

	before_filter :may_create_addressings_required,
		:only => [:new,:create]
	before_filter :may_read_addressings_required,
		:only => [:show,:index]
	before_filter :may_update_addressings_required,
		:only => [:edit,:update]
	before_filter :may_destroy_addressings_required,
		:only => :destroy

#	before_filter :valid_hx_study_subject_id_required,
	before_filter :valid_study_subject_id_required,
		:only => [:new,:create,:index]
	before_filter :valid_id_required,
		:only => [:edit,:update,:destroy]

	def new
		@addressing = Addressing.new
	end

	def create
		#	If create fails and re-renders 'new', then the
		#	address id may be on the form due to after_create
		#	modifications and it causes problems.
		if params[:addressing] && params[:addressing][:address_attributes] 
			params[:addressing][:address_attributes][:id] = nil
		end

		@addressing = @study_subject.addressings.build(
			params[:addressing].merge( :current_user => current_user ) )
		@addressing.save!
		redirect_to study_subject_contacts_path(@addressing.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Address creation failed"
		render :action => 'new'
	end

#Editors can modify the current address and designated it as being an invalid address. If they designated the address as invalid, the why_invalid text field is mandatory.
#
#By default, there is no value for whether an address is valid.
#
#As part of study_subject tracing, we will have the ability to designated whether an address we have has been verified by some means. When an address is verified, the user will set is_verified to true. They will then be required to provide a value for the how_verified field and the system will capture both their user_id in verified_by and the current date in verified_on fields.

	def update
		@addressing.update_attributes!(
			params[:addressing].merge( :current_user => current_user ) )
		redirect_to study_subject_contacts_path(@addressing.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Address update failed"
		render :action => 'edit'
	end



	#	TEMP ADD FOR DEV ONLY!
	def destroy
		@addressing.destroy
		redirect_to study_subject_contacts_path(@addressing.study_subject)
	end


protected

	def valid_id_required
		if !params[:id].blank? and Addressing.exists?(params[:id])
			@addressing = Addressing.find(params[:id])
		else
			access_denied("Valid address id required!", 
				study_subjects_path)
		end
	end

end
