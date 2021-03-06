class BloodSpotRequestsController < ApplicationController

	before_filter :may_create_study_subjects_required
	before_filter :q_value_required, :only => :create
	before_filter :valid_q_id_required, :only => :create
	before_filter :no_existing_incomplete_blood_spot_request_required, :only => :create
	before_filter :valid_id_required, :only => [:edit,:update,:destroy,:update_status]

	def new
		#	sole purpose is to make common test for new action happy
		@blood_spot_request           = BloodSpotRequest.new 

		record_or_recall_sort_order
		@active_blood_spot_requests   = BloodSpotRequest.active
			.joins(:study_subject).order(search_order)
		@waitlist_blood_spot_requests = BloodSpotRequest.waitlist
			.joins(:study_subject).order(search_order)
	end

	def create
		@study_subject.blood_spot_requests.create(:status => 'active')
		redirect_to new_blood_spot_request_path
	end

	def edit
		session[:blood_spot_request_return_to] = request.env["HTTP_REFERER"]
	end

	#		transform update to more generic update for status and comments/notes
	def update
		@blood_spot_request.update_attributes!(blood_spot_request_params)
		redirect_path = session[:blood_spot_request_return_to] || new_blood_spot_request_path
		#	NOTE why not delete key?
		session[:blood_spot_request_return_to] = nil
		redirect_to redirect_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
		flash.now[:error] = "Blood Spot Request Update failed"
		render :action => 'edit'
	end

	#		for updating only status
	def update_status
		@blood_spot_request.update_attributes!(:status => params[:status])
		redirect_to new_blood_spot_request_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
		flash.now[:error] = "Blood Spot Request Status Update failed"
		render :action => 'edit'
	end

	def activate_all_waitlist
		BloodSpotRequest.waitlist.update_all(:status => 'active')
		flash[:notice] = "Activated all waiting"
		redirect_to new_blood_spot_request_path
	end

	def waitlist_all_active
		BloodSpotRequest.active.update_all(:status => 'waitlist')
		flash[:notice] = "Waitlisted all active"
		redirect_to new_blood_spot_request_path
	end

	def destroy
		@blood_spot_request.destroy
		redirect_to new_blood_spot_request_path
	end

	def index
		record_or_recall_sort_order
		@blood_spot_requests = BloodSpotRequest.with_status(params[:status])
			.joins(:study_subject).order(search_order)
		respond_to do |format|
			format.html
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=blood_spot_requests_#{params[:status]}_#{Time.now.to_s(:filename)}.csv"
			}
		end
	end

	def confirm
		BloodSpotRequest.transaction do
			active_blood_spot_requests  = BloodSpotRequest.active
			active_blood_spot_requests.each do |blood_spot_request|
				study_subject = blood_spot_request.study_subject
				study_subject.operational_events.create!(
					:project => Project['ccls'],
					:operational_event_type => OperationalEventType['blood_spot_request_sent'],
					:occurred_at => DateTime.current
				)
			end
			#	I don't think that this can raise an error, but if the above do it will be skipped
			active_blood_spot_requests.update_all(
				{ :status => 'pending', :sent_on => Date.current })
		end	#	BloodSpotRequest.transaction do
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid =>  e
		flash[:error] = "Confirmation failed:#{e.inspect}:"
	ensure	#	same redirect no matter what happens above 
		redirect_to new_blood_spot_request_path
	end

protected

	def valid_id_required
		if !params[:id].blank? and BloodSpotRequest.exists?(params[:id])
			@blood_spot_request = BloodSpotRequest.find(params[:id])
		else
			access_denied("Valid blood_spot_request id required!", new_blood_spot_request_path)
		end
	end

	def q_value_required
		access_denied("query value required!", 
			new_blood_spot_request_path) if params[:q].blank?
	end

	def valid_q_id_required
		q = params[:q].squish
		if ( q.length <= 4 ) 
			patid = sprintf("%04d",q.to_i)
			@study_subject = StudySubject.find_case_by_patid(patid)
			access_denied("No case study_subject found with patid:#{patid}!", 
				new_blood_spot_request_path(:q => params[:q])) if @study_subject.blank?
		else
			@study_subject = StudySubject.find_case_by_icf_master_id(q)
			access_denied("No case study_subject found with icf_master_id:#{q}!", 
				new_blood_spot_request_path(:q => params[:q])) if @study_subject.blank?
		end
	end

	def no_existing_incomplete_blood_spot_request_required
		if( @study_subject.blood_spot_requests.incomplete.exists? )
			access_denied("case study_subject has an incomplete blood_spot_request already!", 
				new_blood_spot_request_path)
		end
	end

	def search_order
		if params[:order] and
				%w( studyid icf_master_id sent_on returned_on status ).include?(
				params[:order].downcase)
			order_string = params[:order]
			dir = case params[:dir].try(:downcase)
				when 'desc' then 'desc'
				else 'asc'
			end
			[order_string,dir].join(' ')
		else
			nil
		end
	end

	def blood_spot_request_params
		params.require(:blood_spot_request).permit(
			:status,:sent_on,:returned_on,:is_found,:notes)
	end

end
