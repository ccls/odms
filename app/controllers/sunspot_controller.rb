class SunspotController < ApplicationController

protected	#	from what and why?

	#	the subjects and samples search is so close that it could be genericized.
	def search_sunspot
	end

	def search_order
		if params[:order] and @sunspot_searching.sunspot_orderable_columns.include?(
				params[:order].downcase )
			order_string = params[:order]
			dir = case params[:dir].try(:downcase)
				when 'desc' then 'desc'
				else 'asc'
			end
			return order_string.to_sym, dir.to_sym
		else
			return :id, :asc
		end
	end

end
