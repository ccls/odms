class MedicalRecordRequestsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :q_value_required, :only => :create
	before_filter :valid_q_id_required, :only => :create
	before_filter :no_existing_incomplete_medical_record_request_required, :only => :create
	before_filter :valid_id_required, :only => [:edit,:update,:destroy,:update_status]

	def new
		#	sole purpose is to make common test for new action happy
		@medical_record_request           = MedicalRecordRequest.new 


		@active_medical_record_requests   = MedicalRecordRequest.active
		@waitlist_medical_record_requests = MedicalRecordRequest.waitlist
	end

	def create
#	remove ...
#	before_filter :valid_q_id_required, :only => :create
#	before_filter :no_existing_incomplete_medical_record_request_required, :only => :create
#	add ..
#	before_filter :valid_commit_value_required, :only => :create
#	and then use ...
#
#		if params[:commit] == 'patid'
#			@study_subject = StudySubject.find_case_by_patid(sprintf("%04d",params[:q].to_i))
#		elsif params[:commit] == 'icf master id'
#			@study_subject = StudySubject.find_case_by_icf_master_id(params[:q])
#		end
#		if @study_subject
#			if @study_subject.medical_record_requests.where(
#					"status != 'complete' OR status IS NULL").exists? )
#				flash.now[:error] = "case study_subject has an incomplete medical_record_request already!"
#			else
#				@study_subject.medical_record_requests.create(:status => 'active')
#	Add creation check
#				flash.now[:notice] = "YAY"
#			end
#		else
#			flash.now[:error] = "No case study_subject found with " <<
#				"#{params[:commit]}:#{params[:q]}!"
#		end
#		render :action => 'new'
#
#	Actually no.  Just simplify the stuff at the bottom.
#	Smaller clearer simpler filters
#	Actually still thinking. Dry. Clear. Clean.
#

		@study_subject.medical_record_requests.create(:status => 'active')
		redirect_to new_medical_record_request_path
	end

	def edit
		session[:medical_record_request_return_to] = request.env["HTTP_REFERER"]
	end

	#		transform update to more generic update for status and comments/notes
	def update
		@medical_record_request.update_attributes!(params[:medical_record_request])
		redirect_path = session[:medical_record_request_return_to] || new_medical_record_request_path
#	NOTE why not delete key?
		session[:medical_record_request_return_to] = nil
		redirect_to redirect_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
		flash.now[:error] = "Medical Record Request Update failed"
		render :action => 'edit'
	end

	#		for updating only status
	def update_status
		@medical_record_request.update_attributes!(:status => params[:status])
		redirect_to new_medical_record_request_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
		flash.now[:error] = "Medical Record Request Status Update failed"
		render :action => 'edit'
	end

	def activate_all_waitlist
		MedicalRecordRequest.waitlist.update_all(:status => 'active')
		flash[:notice] = "Activated all waiting"
		redirect_to new_medical_record_request_path
	end

	def waitlist_all_active
		MedicalRecordRequest.active.update_all(:status => 'waitlist')
		flash[:notice] = "Waitlisted all active"
		redirect_to new_medical_record_request_path
	end

	def destroy
		@medical_record_request.destroy
		redirect_to new_medical_record_request_path
	end

	def index
		@medical_record_requests = MedicalRecordRequest.with_status(params[:status])
		respond_to do |format|
			format.html
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=medical_record_requests_#{params[:status]}_#{Time.now.to_s(:filename)}.csv"
			}
		end
	end

	def confirm
		MedicalRecordRequest.transaction do
			active_medical_record_requests  = MedicalRecordRequest.active
			active_medical_record_requests.each do |medical_record_request|
				study_subject = medical_record_request.study_subject
				study_subject.operational_events.create!(
					:project => Project['ccls'],
					:operational_event_type => OperationalEventType['medical_record_request_sent'],
					:occurred_at => DateTime.current
				)
			end
#	I don't think that this can raise an error, but if the above do it will be skipped
#			MedicalRecordRequest.update_all(
#				{ :status => 'pending', :sent_on => Date.current }, #	updates
#				{ :status => 'active' })  #	conditions
			active_medical_record_requests.update_all(
				{ :status => 'pending', :sent_on => Date.current })
		end	#	MedicalRecordRequest.transaction do
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid =>  e
		flash[:error] = "Confirmation failed:#{e.inspect}:"
	ensure	#	same redirect no matter what happens above 
		redirect_to new_medical_record_request_path
	end

protected

	def valid_id_required
		if !params[:id].blank? and MedicalRecordRequest.exists?(params[:id])
			@medical_record_request = MedicalRecordRequest.find(params[:id])
		else
			access_denied("Valid medical_record_request id required!", new_medical_record_request_path)
		end
	end

	def q_value_required
		access_denied("query value required!", 
			new_medical_record_request_path) if params[:q].blank?
	end

	def valid_q_id_required
#
#	as patids are 4 and icf master ids are 8, I could use the length 
#	of the given string to control which I search for rather
#	than the explicit button
#
		q = params[:q].squish
		if ( q.length <= 4 ) 
			patid = sprintf("%04d",q.to_i)
			@study_subject = StudySubject.find_case_by_patid(patid)
			access_denied("No case study_subject found with patid:#{patid}!", 
				new_medical_record_request_path(:q => params[:q])) if @study_subject.blank?
		else
			@study_subject = StudySubject.find_case_by_icf_master_id(q)
			access_denied("No case study_subject found with icf_master_id:#{q}!", 
				new_medical_record_request_path(:q => params[:q])) if @study_subject.blank?
		end
	end

#
#	I have to use before filters and redirect above because
#	of the following before filter.
#
	def no_existing_incomplete_medical_record_request_required
#		if( @study_subject.medical_record_requests.where(
#				"status != 'complete' OR status IS NULL").exists? )
		if( @study_subject.medical_record_requests.incomplete.exists? )
			access_denied("case study_subject has an incomplete medical_record_request already!", 
				new_medical_record_request_path)
		end
	end

end
