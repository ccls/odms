class IcfMasterIdsController < ApplicationController

	before_filter :may_read_icf_master_ids_required,
		:only => [:show,:index]

	before_filter :valid_id_required, 
		:only => [:show,:destroy]

	def index
		record_or_recall_sort_order
		@icf_master_ids = IcfMasterId.paginate(
				:per_page => params[:per_page]||25,
				:page     => valid_find_page
			)
			.order(search_order)
	end

protected

	def valid_id_required
		if( !params[:id].blank? && IcfMasterId.exists?(params[:id]) )
			@icf_master_id = IcfMasterId.find(params[:id])
		else
			access_denied("Valid id required!", icf_master_ids_path)
		end
	end

	def search_order
		if params[:order] and %w( icf_master_id study_subject_id assigned_on ).include?(params[:order].downcase)
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
