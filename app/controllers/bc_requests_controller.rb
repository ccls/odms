class BcRequestsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_patid_required, :only => :create
#	before_filter :case_study_subject_required, :only => :create
	before_filter :no_existing_incomplete_bc_request_required, :only => :create
	before_filter :valid_id_required, :only => [:edit,:update,:destroy,:update_status]
	before_filter :valid_status_required, :only => [:update_status]

	def new
		@bc_request           = BcRequest.new #	sole purpose is to make testing happy
		@active_bc_requests   = BcRequest.find(:all, :conditions => { :status => 'active' })
		@waitlist_bc_requests = BcRequest.find(:all, :conditions => { :status => 'waitlist' })
	end

	def create
		@study_subject.bc_requests.create(:status => 'active')
		redirect_to new_bc_request_path
	end

	def edit
	end

	#		transform update to more generic update for status and comments/notes
	def update
#	TODO add validation in bc_request model that request status in statuses (don't forget factory)
		@bc_request.update_attributes(params[:bc_request])
		redirect_to new_bc_request_path
# TODO add rescues for failed update
#
#
	end

	#		for updating only status
	def update_status
		@bc_request.update_attribute(:status,params[:status])
# TODO add rescues for failed update
		redirect_to new_bc_request_path
	end

	def destroy
		@bc_request.destroy
		redirect_to new_bc_request_path
	end

	def index
		conditions = {}
		conditions[:status] = params[:status] if params[:status]
		@bc_requests  = BcRequest.find(:all, :conditions => conditions )
		respond_to do |format|
			format.html
			format.csv { 
				headers["Content-disposition"] = "attachment; " <<
					"filename=bc_requests_#{params[:status]}_#{Time.now.to_s(:filename)}.csv"
			}
		end
	end

	def confirm
		BcRequest.transaction do
			active_bc_requests  = BcRequest.find(:all, :conditions => { :status => 'active' })
			active_bc_requests.each do |bc_request|
				study_subject = bc_request.study_subject
				enrollment = study_subject.enrollments.find_or_create_by_project_id(
					Project['ccls'].id )
#				enrollment.operational_events << OperationalEvent.create!(
				OperationalEvent.create!(
					:enrollment => enrollment,
					:operational_event_type => OperationalEventType['bc_request_sent'],
					:occurred_on => Date.today
				)
			end
#	I don't think that this can raise an error, but if the above do it will be skipped
			BcRequest.update_all(
				{ :status => 'pending', :sent_on => Date.today }, #	updates
				{ :status => 'active' })  #	conditions
		end	#	BcRequest.transaction do
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid =>  e
		flash[:error] = "Confirmation failed:#{e.inspect}:"
	ensure	#	same redirect no matter what happens above 
		redirect_to new_bc_request_path
	end

protected

	def valid_status_required
		if params[:status].blank? or !BcRequest.statuses.include?(params[:status])
			access_denied("Valid bc_request status required! Status '#{params[:status]}' is unknown.", 
				new_bc_request_path)
		end
	end

	def valid_id_required
		if !params[:id].blank? and BcRequest.exists?(params[:id])
			@bc_request = BcRequest.find(params[:id])
		else
			access_denied("Valid bc_request id required!", new_bc_request_path)
		end
	end

	def valid_patid_required
		if !params[:patid].blank? 
			@study_subject = StudySubject.find_case_by_patid(params[:patid])
			if @study_subject.blank?
				access_denied("No case study_subject found with that patid!", new_bc_request_path)
			end
		else
			access_denied("Valid study_subject patid required!", new_bc_request_path)
		end
	end

#	def case_study_subject_required
#		unless @study_subject.is_case?
#			access_denied("Valid case study_subject required!", new_bc_request_path)
#		end
#	end

	def no_existing_incomplete_bc_request_required
		if( BcRequest.exists?(
				["study_subject_id = ? AND ( status != 'complete' OR status IS NULL )", @study_subject.id]) )
#	TODO need the null.  should set default to '' 
#				["study_subject_id = ? AND ( status != 'complete' )", @study_subject.id]) )
			access_denied("case study_subject has an incomplete bc_request already!", new_bc_request_path)
		end
	end

#	def no_existing_bc_request_required
#		if @study_subject.bc_request
#			access_denied("case study_subject has bc_request already!", new_bc_request_path)
#		end
#	end

end
