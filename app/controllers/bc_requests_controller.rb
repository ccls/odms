class BcRequestsController < ApplicationController
	before_filter :may_create_subjects_required
	before_filter :valid_patid_required, :only => :create
	before_filter :case_subject_required, :only => :create
	before_filter :no_existing_bc_request_required, :only => :create
	before_filter :valid_id_required, :only => [:update,:destroy]
	before_filter :valid_status_required, :only => :update

	def new
		@bc_request          = BcRequest.new #	sole purpose is to make testing happy
		@active_bc_requests  = BcRequest.find(:all, :conditions => { :status => 'active' })
		@waitlist_bc_requests = BcRequest.find(:all, :conditions => { :status => 'waitlist' })
	end

	def create
		@subject.create_bc_request(:status => 'active')
		redirect_to new_bc_request_path
	end

	def update
		@bc_request.update_attribute(:status,params[:status])
		redirect_to new_bc_request_path
	end

	def destroy
		@bc_request.destroy
		redirect_to new_bc_request_path
	end

protected

	def valid_status_required
		if params[:status].blank? or !BcRequest.statuses.include?(params[:status])
			access_denied("Valid bc_request status required! Status '#{params[:status]}' is unknown.", new_bc_request_path)
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
			subjects = Subject.search(:patid => params[:patid], :types => 'case')
			case
				when subjects.length < 1 
					access_denied("No case subject found with that patid!", new_bc_request_path)
				when subjects.length > 1
					access_denied("Multiple case subjects found with that patid!", new_bc_request_path)
				else
					@subject = subjects.first
			end
		else
			access_denied("Valid subject patid required!", new_bc_request_path)
		end
	end

	def case_subject_required
		unless @subject.is_case?
			access_denied("Valid case subject required!", new_bc_request_path)
		end
	end

	def no_existing_bc_request_required
		if @subject.bc_request
			access_denied("case subject has bc_request already!", new_bc_request_path)
		end
	end

end
