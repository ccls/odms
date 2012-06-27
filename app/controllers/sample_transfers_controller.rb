class SampleTransfersController < ApplicationController

#	before_filter :may_create_sample_transfers_required,
#		:only => [:new,:create]
	before_filter :may_read_sample_transfers_required,
		:only => [:show,:index]
	before_filter :may_update_sample_transfers_required,
		:only => [:edit,:update,:update_status,:confirm]
#	before_filter :may_destroy_sample_transfers_required,
#		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:edit,:update,:destroy,:update_status]

	#		for updating only status
	def update_status	#	PUT
		@sample_transfer.update_attributes!(:status => params[:status])
#		redirect_to sample_transfers_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid 
#	shoul eventually implement a sample_transfer edit/update
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


#	TODO insert a bunch of stuff here.


		flash[:notice] = "STILL DEVING SO NO FUNCTIONS Confirmed transfer to org id:#{params[:organization_id]}:"


		redirect_to sample_transfers_path
	end

protected

	def valid_id_required
		if !params[:id].blank? and SampleTransfer.exists?(params[:id])
			@sample_transfer = SampleTransfer.find(params[:id])
		else
			access_denied("Valid sample_transfer id required!", sample_transfers_path)
		end
	end

end
