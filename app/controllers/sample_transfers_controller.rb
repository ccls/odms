class SampleTransfersController < ApplicationController

#	before_filter :may_create_sample_transfers_required,
#		:only => [:new,:create]
	before_filter :may_read_sample_transfers_required,
		:only => [:show,:index]
	before_filter :may_update_sample_transfers_required,
		:only => [:edit,:update,:update_status,:confirm]
	before_filter :may_destroy_sample_transfers_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:edit,:update,:destroy,:update_status]
	before_filter :valid_organization_id_required, 
		:only => [:confirm]
	before_filter :active_sample_transfers_required, 
		:only => [:confirm]



	def edit
		@study_subject = @sample_transfer.sample.study_subject
		render :layout => 'subject'
	end

	def update
		@study_subject = @sample_transfer.sample.study_subject
		@sample_transfer.update_attributes!(params[:sample_transfer])
		flash[:notice] = 'Sample Transfer successfully updated!'
		redirect_to study_subject_sample_path(@study_subject,@sample_transfer.sample_id)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
		flash.now[:error] = "Sample Transfer Update failed"
		render :action => 'edit'
	end

	

	#		for updating only status
	def update_status	#	PUT
		@sample_transfer.update_attributes!(:status => params[:status])
#		redirect_to sample_transfers_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
#	should eventually implement a sample_transfer edit/update
#		flash.now[:error] = "Sample Transfer Status Update failed"
#		render :action => 'edit'
		flash[:error] = "Sample Transfer Status Update failed"
	ensure
		redirect_to sample_transfers_path
	end

	def index
		@active_sample_transfers   = SampleTransfer.active
		@waitlist_sample_transfers = SampleTransfer.waitlist
		respond_to do |format|
			format.html
			format.csv {
				headers["Content-Disposition"] = "attachment; " <<
					"filename=sample_transfers_#{Time.now.to_s(:filename)}.csv"
			}
		end
	end

	def confirm	#	PUT
		SampleTransfer.transaction do

			#	do this BEFORE CHANGING THE STATUS!
			SampleTransfer.active.each do |t|
				#	OperationalEvent#study_subject_id is protected so ...
				t.sample.study_subject.operational_events.create!({
					:project_id => t.sample.project_id,
					:operational_event_type_id => OperationalEventType['sample_to_lab'].id,
					:description => "Sample ID #{t.sample.sampleid}, " <<
						"#{t.sample.sample_type}, " <<
						"transferred to #{@organization.try(:key)} " <<
						"from #{Organization.where(:id => t.sample.location_id).first.try(:key)}",
	
	#					"from #{t.source_org_id}",	#	created in controller on create
	#					"from #{t.sample.location_id}",	#	should be same?????  should change?
#					:occurred_at => Time.now
					:occurred_at => DateTime.current
				}) unless t.sample.study_subject.nil?
				#	Sample does not require study subject, so 
				#	check that before doing this.  Realistically
				#	shouldn't happen.


				t.sample.update_attributes!({
					:location_id    => params[:organization_id],
					:sent_to_lab_at => DateTime.current
				})
			end
	
			#	NOTE update_all DOES NOT DO RAILS VALIDATIONS
			#		and so will probably never raise an error.
#	
#	The source_org_id should be correct as it is set to the 
#	sample's location_id on create.
#
			SampleTransfer.active.update_all({
				:destination_org_id => params[:organization_id],
				:status => 'complete',
				:sent_on => Date.current
			})
		end	#	SampleTransfer.transaction do
		flash[:notice] = "Confirmed transfer to org id:#{params[:organization_id]}:"
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#
#	Probably operational event create failure
#
		flash[:error] = "Something really bad happened."
	ensure
		redirect_to sample_transfers_path
	end

	def destroy
		@sample_transfer.destroy
		redirect_to sample_transfers_path
	end

protected

	def valid_organization_id_required
		if !params[:organization_id].blank? and Organization.exists?(params[:organization_id])
			@organization = Organization.find(params[:organization_id])
		else
			access_denied("Valid organization id required!", sample_transfers_path)
		end
	end

	def valid_id_required
		if !params[:id].blank? and SampleTransfer.exists?(params[:id])
			@sample_transfer = SampleTransfer.find(params[:id])
		else
			access_denied("Valid sample_transfer id required!", sample_transfers_path)
		end
	end

	def active_sample_transfers_required
		@active_sample_transfers = SampleTransfer.active
		if @active_sample_transfers.empty?
			access_denied("Active sample transfers required to confirm!", sample_transfers_path)
		end
	end

end
