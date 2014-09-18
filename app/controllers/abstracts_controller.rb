#	Just a RESTful abstract controller, without new or create
class AbstractsController < ApplicationController

	before_filter :may_read_abstracts_required

	def index
		record_or_recall_sort_order
		@abstracts = Abstract.joins(:study_subject).order(search_order)
	end

	def merged
		record_or_recall_sort_order
		@abstracts = Abstract.joins(:study_subject).order(search_order).merged
		render :action => :index
	end

	def to_merge
		record_or_recall_sort_order
		@abstracts = Abstract.joins(:study_subject).order(search_order).mergable
		render :action => :index
	end

protected

	def search_order
		if params[:order] and
				%w( id patid entry_1_by_uid entry_2_by_uid ).include?(
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

end
