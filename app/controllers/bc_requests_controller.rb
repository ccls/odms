class BcRequestsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :q_value_required, :only => :create
	before_filter :valid_q_id_required, :only => :create
	before_filter :no_existing_incomplete_bc_request_required, :only => :create
	before_filter :valid_id_required, :only => [:edit,:update,:destroy,:update_status]

	def new
		@bc_request           = BcRequest.new #	sole purpose is to make testing happy
		@active_bc_requests   = BcRequest.active
		@waitlist_bc_requests = BcRequest.waitlist
	end

	def create
#	remove ...
#	before_filter :valid_q_id_required, :only => :create
#	before_filter :no_existing_incomplete_bc_request_required, :only => :create
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
#			if @study_subject.bc_requests.where(
#					"status != 'complete' OR status IS NULL").exists? )
#				flash.now[:error] = "case study_subject has an incomplete bc_request already!"
#			else
#				@study_subject.bc_requests.create(:status => 'active')
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
				headers["Content-Disposition"] = "attachment; " <<
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
#			BcRequest.update_all(
#				{ :status => 'pending', :sent_on => Date.today }, #	updates
#				{ :status => 'active' })  #	conditions
			active_bc_requests.update_all(
				{ :status => 'pending', :sent_on => Date.today })
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

	def q_value_required
		access_denied("query value required!", 
			new_bc_request_path) if params[:q].blank?
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
				new_bc_request_path(:q => params[:q])) if @study_subject.blank?
		else
			@study_subject = StudySubject.find_case_by_icf_master_id(q)
			access_denied("No case study_subject found with icf_master_id:#{q}!", 
				new_bc_request_path(:q => params[:q])) if @study_subject.blank?
		end
	end

#
#	I have to use before filters and redirect above because
#	of the following before filter.
#
	def no_existing_incomplete_bc_request_required
		if( @study_subject.bc_requests.where(
				"status != 'complete' OR status IS NULL").exists? )
			access_denied("case study_subject has an incomplete bc_request already!", 
				new_bc_request_path)
		end
	end

end
