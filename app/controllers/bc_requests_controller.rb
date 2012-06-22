class BcRequestsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :valid_patid_required, :only => :create
#	before_filter :case_study_subject_required, :only => :create
	before_filter :no_existing_incomplete_bc_request_required, :only => :create
	before_filter :valid_id_required, :only => [:edit,:update,:destroy,:update_status]

	def new
		@bc_request           = BcRequest.new #	sole purpose is to make testing happy
		@active_bc_requests   = BcRequest.active
		@waitlist_bc_requests = BcRequest.waitlist
	end

	def create
		@study_subject.bc_requests.create(:status => 'active')
		redirect_to new_bc_request_path
	end

	def edit
		session[:bc_request_return_to] = request.env["HTTP_REFERER"]
	end

	#		transform update to more generic update for status and comments/notes
	def update
		@bc_request.update_attributes!(params[:bc_request])
		redirect_path = session[:bc_request_return_to] || new_bc_request_path
#	NOTE why not delete key?
		session[:bc_request_return_to] = nil
		redirect_to redirect_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
		flash.now[:error] = "BC Request Update failed"
		render :action => 'edit'
	end

	#		for updating only status
	def update_status
		@bc_request.update_attributes!(:status => params[:status])
		redirect_to new_bc_request_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
		flash.now[:error] = "BC Request Status Update failed"
		render :action => 'edit'
	end

	def destroy
		@bc_request.destroy
		redirect_to new_bc_request_path
	end

	def index
		@bc_requests = BcRequest.with_status(params[:status])
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
			active_bc_requests  = BcRequest.active
			active_bc_requests.each do |bc_request|
				study_subject = bc_request.study_subject
				study_subject.operational_events.create!(
					:project => Project['ccls'],
					:operational_event_type => OperationalEventType['bc_request_sent'],
					:occurred_at => DateTime.now
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

	def valid_id_required
		if !params[:id].blank? and BcRequest.exists?(params[:id])
			@bc_request = BcRequest.find(params[:id])
		else
			access_denied("Valid bc_request id required!", new_bc_request_path)
		end
	end

	def valid_patid_required
		if !params[:patid].blank? 
			#	pad patid with leading 0's here
			#	Do not use LIKE as would accept leading digits other than 0.
			#	MUST use to_i to avoid octal conversion or error if leading zero given!
			#	CANNOT have leading 0's in sprintf as it thinks its octal and converts
			#>> sprintf("%06d","0001234")
			#=> "000668"
			#
			# CANNOT have leading 0's and include and 8 or 9 as it thinks its octal
			# so convert back to Integer first
			#>> sprintf("%06d","0001280")
			#ArgumentError: invalid value for Integer: "0001280"
			# from (irb):24:in `sprintf'
			# from (irb):24

			patid = sprintf("%04d",params[:patid].to_i)	
			@study_subject = StudySubject.find_case_by_patid(patid)

			if @study_subject.blank?
				access_denied("No case study_subject found with patid:#{patid}!", 
					new_bc_request_path)
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
			access_denied("case study_subject has an incomplete bc_request already!", 
				new_bc_request_path)
		end
	end

#	def no_existing_bc_request_required
#		if @study_subject.bc_request
#			access_denied("case study_subject has bc_request already!", new_bc_request_path)
#		end
#	end

end
