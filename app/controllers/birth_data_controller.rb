class BirthDataController < ApplicationController

#	before_filter :may_create_birth_data_required,
#		:only => [:new,:create]
	before_filter :may_read_birth_data_required,
		:only => [:show,:index]
#	before_filter :may_update_birth_data_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_birth_data_required,
#		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		record_or_recall_sort_order
		@birth_data = BirthDatum.paginate(
				:per_page => params[:per_page]||25,
				:page     => valid_find_page
			)
			.order(search_order)

	end

#	def update
#		@birth_datum.update_attributes!(params[:birth_datum])
#		flash[:notice] = 'Success!'
##		redirect_to birth_data_path
##		redirect_to @birth_datum.birth_datum_update
#		redirect_to @birth_datum
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the birth_datum"
#		render :action => "edit"
#	end
#
#	def destroy
#		@birth_datum.destroy
#		redirect_to birth_data_path
#	end

protected

	def valid_id_required
		if( !params[:id].blank? && BirthDatum.exists?(params[:id]) )
			@birth_datum = BirthDatum.find(params[:id])
		else
			access_denied("Valid id required!", birth_data_path)
		end
	end


	def search_order
		if params[:order] and %w( study_subject_id ).include?(params[:order].downcase)
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

end
