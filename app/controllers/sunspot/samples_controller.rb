class Sunspot::SamplesController < SunspotController

	def index
		search_sunspot_for Sample
	end

end
__END__


#	before_filter :may_edit_required
#	before_filter :search_method_defined_required

#	def search_method_defined_required
#		Sample.methods.include?(:search) ||
#			access_denied("Sunspot server probably wasn't started first!", root_path)
#	end

	def oldindex
#		@sunspot_searching = Sample
		@search = sunspot_searching.search do

			sunspot_searching.sunspot_all_facets.each do |p|
#				if child_age_facets.include?(p)
#					range_facet_and_filter_for(p,params.dup,:start => 1, :step => 2)
#				elsif parent_age_facets.include?(p)
#					range_facet_and_filter_for(p,params.dup)
#				elsif year_facets.include?(p)
#					range_facet_and_filter_for(p,params.dup,{:start => 1980, :stop => 2010, :step => 5})
#				else
					if params[p]
#
#	20130423 - be advised that false.blank? is true so the boolean attributes
#						will not work correctly here.  Need to find another way.
#
						params[p] = [params[p].dup].flatten.reject{|x|x.blank?}
#						if params[p+'_op'] && params[p+'_op']=='AND'
#							unless params[p].empty?
#								with(p).all_of params[p]
#							else
#								params.delete(p)	#	remove the key so doesn't show in view
#							end
#						else
							unless params[p].blank?	#empty?	# blank? works for arrays too
								with(p).any_of params[p]
							else
								params.delete(p)	#	remove the key so doesn't show in view
							end
#						end
					end
#				end
				#	facet.sort
				#	This param determines the ordering of the facet field constraints.
				#	    count - sort the constraints by count (highest count first)
				#	    index - to return the constraints sorted in their index order 
				#			(lexicographic by indexed term). For terms in the ascii range, 
				#				this will be alphabetically sorted. 
				#	The default is count if facet.limit is greater than 0, index otherwise.
				#	Prior to Solr1.4, one needed to use true instead of count and false instead of index.
				#	This parameter can be specified on a per field basis. 
				facet p.to_sym, :sort => :index
			end

			order_by *search_order

			if request.format.to_s.match(/csv/)
				#	don't paginate csv file.  Only way seems to be to make BIG query
				#	rather than the arbitrarily big number, I could possibly
				#	use the @search.total from the previous search sent as param?
				paginate :per_page => 100000
			end
			paginate :page => params[:page], :per_page => params[:per_page]
		end

	rescue Errno::ECONNREFUSED
		flash[:error] = "Solr seems to be down for the moment."
		redirect_to root_path
	end

#protected
#
#	def search_order
#		if params[:order] and Sample.sunspot_orderable_columns.include?( 
#			params[:order].downcase )
#			order_string = params[:order]
#			dir = case params[:dir].try(:downcase)
#				when 'desc' then 'desc'
#				else 'asc'
#			end
#			return order_string.to_sym, dir.to_sym
#		else
#			return :id, :asc
#		end
#	end

end
__END__
