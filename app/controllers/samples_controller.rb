class SamplesController < ApplicationController

	before_filter :may_read_samples_required,
		:only => [:dashboard,:index,:followup,:reports,:manifest]

	def index
		record_or_recall_sort_order
		conditions = [[],{}]
		#	Table names are not necessary if field is unambiguous.
		%w( childid patid icf_master_id first_name ).each do |attr|
			if params[attr] and !params[attr].blank?
				conditions[0] << "( #{attr} LIKE :#{attr} )"
				conditions[1][attr.to_sym] = "%#{params[attr]}%"
			end
		end
		if params[:last_name] and !params[:last_name].blank?
			conditions[0] << "( last_name LIKE :last_name OR maiden_name LIKE :last_name )"
			conditions[1][:last_name] = "%#{params[:last_name]}%"
		end
		if params[:sampleid] and !params[:sampleid].blank?
			conditions[0] << "( samples.id = :sampleid )"	#	MUST include table name here
			conditions[1][:sampleid] = params[:sampleid].gsub(/^0*/,'')
		end
		if params[:sample_type_id] and !params[:sample_type_id].blank? and 
				SampleType.exists?(params[:sample_type_id])
			sample_type = SampleType.find(params[:sample_type_id])
			conditions[0] << "( sample_type_id IN ( :sample_type_ids ) )"
			conditions[1][:sample_type_ids] = if( sample_type.is_root? )
				sample_type.children.collect(&:id)
			else
				[sample_type.id]
			end
		end
		validate_valid_date_range_for(:sent_to_subject_at,conditions)
		validate_valid_date_range_for(:received_by_ccls_at,conditions)
		#
		#	NOTE/FYI: the join to study_subject, filters out samples without a study_subject
		#
		@samples = Sample.joins(:study_subject)
			.order(search_order)
			.where(conditions[0].join(valid_find_operator), conditions[1] )
			.paginate(
				:per_page => params[:per_page]||25,
				:page     => valid_find_page
			)
		#
		#	This is a rather custom set of double joins WITH AS'S as the joins
		#	are on the same table so types and subtypes.
		#
		if params[:order] and %w( type subtype ).include?(params[:order].downcase)
			@samples = @samples
			.joins('INNER JOIN `sample_types` AS subtypes ON `subtypes`.`id` = `samples`.`sample_type_id`')
			.joins('INNER JOIN `sample_types` AS types ON `types`.`id` = `subtypes`.`parent_id`')
			.select('samples.*, subtypes.description AS subtype, types.description AS type')
		end

#Sample.joins('INNER JOIN `sample_types` AS subtypes ON `subtypes`.`id` = `samples`.`sample_type_id`').joins('INNER JOIN `sample_types` AS types ON `types`.`id` = `subtypes`.`parent_id`').select('samples.*, subtypes.description AS subtype, types.description AS type').first.type

		if params[:order] and %w( project ).include?(params[:order].downcase)
			@samples = @samples
			.joins(:project)
			.select('samples.*, projects.key AS project')
		end

		#
		#	As it is possible to set a page and then add a filter,
		#	one could have samples but be on to high of a page to see them.
		#	length would return 0, but count is the total database count
		#
		if @samples.to_a.length == 0 and @samples.count > 0
			flash[:warn] = "Page number was too high, so set to highest valid page number."
			#	Doesn't change the url string, but does work.
			params[:page] = @samples.total_pages
			#	It seems excessive to redirect and do it all again.
			#	Nevertheless ...
#			redirect_to samples_path(params)
#	in rails 5, using string keys is deprecated.  odd since this hash came from RAILS!
			redirect_to samples_path(params.symbolize_keys)
		end
	end

	def manifest
		@samples = Sample.order('received_by_ccls_at DESC')
			.where(Sample.arel_table[:received_by_ccls_at].gt(DateTime.parse('6/1/2012')))

		#
		#	The only reason to have this block is to change the name of the file.
		#	By default, it would just be manifest.csv everytime.
		#	If this is actually desired, remove the entire respond_to block.
		#
		respond_to do |format|
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=sample_manifest_#{Time.now.to_s(:filename)}.csv"
			}
		end
	end

protected

	def search_order
		if params[:order] and
				%w( id type subtype project state received_by_ccls_at ).include?(
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
