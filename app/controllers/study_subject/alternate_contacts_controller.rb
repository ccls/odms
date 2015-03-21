class StudySubject::AlternateContactsController < StudySubjectController

	before_filter :may_create_alternate_contacts_required,
		:only => [:new,:create]
	before_filter :may_read_alternate_contacts_required,
		:only => [:show,:index]
	before_filter :may_update_alternate_contacts_required,
		:only => [:edit,:update]
	before_filter :may_destroy_alternate_contacts_required,
		:only => :destroy

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def index
	end

	def new
		@alternate_contact = AlternateContact.new
	end

	def create
		@alternate_contact = @study_subject.alternate_contacts.build( alternate_contact_params )
		@alternate_contact.save!
		redirect_to study_subject_contacts_path(@alternate_contact.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "AlternateContact creation failed"
		render :action => 'new'
	end

	def update
		@alternate_contact.update_attributes!( alternate_contact_params )
		redirect_to study_subject_contacts_path(@alternate_contact.study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "AlternateContact update failed"
		render :action => 'edit'
	end

	def destroy
		@alternate_contact.destroy
		redirect_to study_subject_contacts_path(@alternate_contact.study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and @study_subject.alternate_contacts.exists?(params[:id])
			@alternate_contact = @study_subject.alternate_contacts.find(params[:id])
		else
			access_denied("Valid alternate_contact id required!", study_subjects_path)
		end
	end

	def alternate_contact_params
		params.require(:alternate_contact).permit(:name, :relation, :line_1, 
			:line_2, :city, :state, :zip, :phone_number_1, :phone_number_2)
	end

end
