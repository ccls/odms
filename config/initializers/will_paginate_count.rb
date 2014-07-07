#require 'will_paginate/active_record'
#
#module WillPaginate
#	module ActiveRecord
#		module RelationMethods
#			def count
#				if limit_value
#					excluded = [:order, :limit, :offset, :reorder]
#					excluded << :includes unless eager_loading?
#					rel = self.except(*excluded)
#					# TODO: hack. decide whether to keep
#					rel = rel.apply_finder_options(@wp_count_options) if defined? @wp_count_options
#
##	This count crashes when a select is provided in the query.
##					rel.count
##	https://github.com/mislav/will_paginate/pull/348
#					rel.unscope(:select).count
#
#				else
#					super
#				end
#			end
#		end
#	end
#end
