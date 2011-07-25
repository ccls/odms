class BcRequestsController < ApplicationController
	before_filter :may_create_subjects_required
	before_filter :valid_patid_required, :only => :create
	before_filter :case_subject_required, :only => :create
	before_filter :no_existing_bc_request_required, :only => :create

	def new
		@active_bc_requests  = BcRequest.find(:all, :conditions => { :status => 'active' })
		@waiting_bc_requests = BcRequest.find(:all, :conditions => { :status => 'waiting' })
	end

	def create
#		BcRequest.create(:study_subject_id => @subject.id)
		@subject.create_bc_request(:status => 'active')
		new
		redirect_to new_bc_request_path
	end

protected

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
