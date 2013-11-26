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
		#	If create fails and re-renders 'new', then the
		#	address id may be on the form due to after_create
		#	modifications and it causes problems.
		#	I believe that this is a rails issue.
#
#	NOTE This may have been corrected in rails 3, but I haven't tested.
#
#
#	Don't know if this'll be needed with merging
#
#		if params[:address] && params[:address][:address_attributes] 
#			params[:address][:address_attributes][:id] = nil
#		end

#		@address = @study_subject.addresses.build(
#			params[:address].merge( :current_user => current_user ) )
		@address = @study_subject.addresses.build( params[:address] )
		@address.save!
		redirect_to study_subject_contacts_path(@address.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Address creation failed"
		render :action => 'new'
	end

	def update
#		@address.update_attributes!(
#			params[:address].merge( :current_user => current_user ) )
		@address.update_attributes!( params[:address] )
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
#		if !params[:id].blank? and Address.exists?(params[:id])
#			@address = Address.find(params[:id])
#			@study_subject = @address.study_subject
		else
			access_denied("Valid address id required!", 
				study_subjects_path)
		end
	end

end
