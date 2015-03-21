class BirthDataController < ApplicationController

	before_filter :may_read_birth_data_required,
		:only => [:show,:index]

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
