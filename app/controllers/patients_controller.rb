class PatientsController < ApplicationController

	permissive

#	before_filter :valid_hx_study_subject_id_required
	before_filter :valid_study_subject_id_required
	before_filter :valid_patient_required,
		:only => [:show,:edit,:update,:destroy]
	before_filter :case_study_subject_required,
		:only => [:new,:create]
	before_filter :no_patient_required,
		:only => [:new,:create]
	
#	def show
##	won't actually make it here if not case due to before filter
##	it will get kicked to :new, then get kicked out
#		render :action => 'not_case' unless @study_subject.is_case?
#	end

	def new
		flash.discard	#	dump the Patient required from 'show' redirect
##	this flash discard doesn't seem to work as it still shows up
##	need to find better way
		@patient = @study_subject.build_patient
	end

	def create
		@patient = @study_subject.build_patient(params[:patient])
		@patient.save!
#		flash[:notice] = "Patient created"
		redirect_to study_subject_patient_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Patient creation failed"
		render :action => 'new'
	end

##Editors can modify the current address and designated it as being an invalid address. If they designated the address as invalid, the why_invalid text field is mandatory.
##
##By default, there is no value for whether an address is valid.
##
##As part of study_subject tracing, we will have the ability to designated whether an address we have has been verified by some means. When an address is verified, the user will set is_verified to true. They will then be required to provide a value for the how_verified field and the system will capture both their user_id in verified_by and the current date in verified_on fields.
#	
	def update
		@patient.update_attributes!(params[:patient])
		flash[:notice] = "Patient updated"
		redirect_to study_subject_patient_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "Patient update failed"
		render :action => 'edit'
	end

	def destroy
		@patient.destroy
		redirect_to study_subject_path(@study_subject)
	end

protected

	def case_study_subject_required
		unless( @study_subject.is_case? )
			access_denied("StudySubject must be Case to have patient data!",
				@study_subject)
		end
	end

	def no_patient_required
		unless( @study_subject.patient.nil? )
			access_denied("Patient already exists!",
				study_subject_patient_path(@study_subject))
		end
	end

	def valid_patient_required
		if( ( @patient = @study_subject.patient ).nil? )
			access_denied("Valid patient required!",
				new_study_subject_patient_path(@study_subject))
		end
	end

end
