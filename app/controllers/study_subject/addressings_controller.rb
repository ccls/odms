class StudySubject::AddressingsController < StudySubjectController

	before_filter :may_create_addressings_required,
		:only => [:new,:create]
	before_filter :may_read_addressings_required,
		:only => [:show,:index]
	before_filter :may_update_addressings_required,
		:only => [:edit,:update]
	before_filter :may_destroy_addressings_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def index
	end

	def new
		@addressing = Addressing.new
	end

	def create
		#	If create fails and re-renders 'new', then the
		#	address id may be on the form due to after_create
		#	modifications and it causes problems.
		#	I believe that this is a rails issue.
#
#	NOTE This may have been corrected in rails 3, but I haven't tested.
#
		if params[:addressing] && params[:addressing][:address_attributes] 
			params[:addressing][:address_attributes][:id] = nil
		end

#		@addressing = @study_subject.addressings.build(
#			params[:addressing].merge( :current_user => current_user ) )
		@addressing = @study_subject.addressings.build( params[:addressing] )
		@addressing.save!
		redirect_to study_subject_contacts_path(@addressing.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Address creation failed"
		render :action => 'new'
	end

	def update
#		@addressing.update_attributes!(
#			params[:addressing].merge( :current_user => current_user ) )
		@addressing.update_attributes!( params[:addressing] )
		redirect_to study_subject_contacts_path(@addressing.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Address update failed"
		render :action => 'edit'
	end

	def destroy
		@addressing.destroy
		redirect_to study_subject_contacts_path(@addressing.study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and @study_subject.addressings.exists?(params[:id])
			@addressing = @study_subject.addressings.find(params[:id])
#		if !params[:id].blank? and Addressing.exists?(params[:id])
#			@addressing = Addressing.find(params[:id])
#			@study_subject = @addressing.study_subject
		else
			access_denied("Valid addressing id required!", 
				study_subjects_path)
		end
	end

end
