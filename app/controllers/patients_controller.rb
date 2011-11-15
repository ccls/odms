class PatientsController < ApplicationController

	before_filter :may_create_patients_required,
		:only => [:new,:create]
	before_filter :may_read_patients_required,
		:only => [:show,:index]
	before_filter :may_update_patients_required,
		:only => [:edit,:update]
	before_filter :may_destroy_patients_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required
	before_filter :valid_patient_required,
		:only => [:edit,:update,:destroy]
#		:only => [:show,:edit,:update,:destroy]
	before_filter :case_study_subject_required,
		:only => [:new,:create]
	before_filter :no_patient_required,
		:only => [:new,:create]
	
#
#	Attempting to show patient for non-case subject results in
#		a double redirect.  
#			valid patient required -> new_patient
#		then
#			case study_subject required -> study_subject
#
#	This results in a flash message hanging around a bit long.
#	Need to change this all anyway.
#

	def show
		if !@study_subject.is_case?
			render :action => 'not_case' 
		elsif( ( @patient = @study_subject.patient ).nil? )
			access_denied("Valid patient required!",
				new_study_subject_patient_path(@study_subject))
#			redirect_to new_study_subject_patient_path(@study_subject)
		end
	end

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
