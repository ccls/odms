class SamplesController < ApplicationController

	before_filter :may_create_samples_required,
		:only => [:new,:create]
	before_filter :may_read_samples_required,
		:only => [:show,:index,:dashboard,:find,:followup,:reports,:manifest]
	before_filter :may_update_samples_required,
		:only => [:edit,:update]
	before_filter :may_destroy_samples_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:new,:create,:index]
#		:except => [:dashboard,:find,:followup,:reports,:edit,:update,:show,:destroy]

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def find
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
#			.joins('INNER JOIN `sample_types` AS subtypes ON `subtypes`.`id` = `samples`.`sample_type_id`')
#			.joins('INNER JOIN `sample_types` AS types ON `types`.`id` = `subtypes`.`parent_id`')
#			.select('samples.*, subtypes.description AS subtype, types.description AS type')
		@samples = Sample.joins(:study_subject)
			.order(search_order)
			.where(conditions[0].join(valid_find_operator), conditions[1] )
			.paginate(
				:per_page => params[:per_page]||25,
				:page     => valid_find_page
			)

#Sample.joins('INNER JOIN `sample_types` AS subtypes ON `subtypes`.`id` = `samples`.`sample_type_id`').joins('INNER JOIN `sample_types` AS types ON `types`.`id` = `subtypes`.`parent_id`').select('samples.*, subtypes.description AS subtype, types.description AS type').first.type

		#
		#	As it is possible to set a page and then add a filter,
		#	one could have samples but be on to high of a page to see them.
		#	length would return 0, but count is the total database count
		#
		if @samples.length == 0 and @samples.count > 0
			flash[:warn] = "Page number was too high, so set to highest valid page number."
			#	Doesn't change the url string, but does work.
			params[:page] = @samples.total_pages
			#	It seems excessive to redirect and do it all again.
			#	Nevertheless ...
			redirect_to find_samples_path(params)
		end
	end

	def manifest
		@samples = Sample.order('received_by_ccls_at DESC'
			).where("received_by_ccls_at > '#{DateTime.parse('6/1/2012')}'")
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

	def index
		@samples = @study_subject.samples
		render :layout => 'subject'
	end

	def show
		respond_to do |format|
			format.html {
				render :layout => 'subject'
			}
			format.pdf { 
				prawnto :prawn => {
					:page_size => [175,90],
					:page_layout => :portrait,
					:margin => 5,
					:top_margin => 12
				},
				:filename => "sample_#{@sample.sampleid}_#{Time.now.to_s(:filename)}.pdf"
			}
		end
	end

	def new
		@sample = Sample.new
		render :layout => 'subject'
	end

	def create
		@sample = @study_subject.samples.new(params[:sample])

		#	All or nothin'
		Sample.transaction do
			@sample.save!
			@sample.sample_transfers.create!(
				:source_org_id => @sample.location_id,
				:status        => 'waitlist')
		end

		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample creation failed."
		render :action => 'new', :layout => 'subject'
	end

	def edit
		render :layout => 'subject'
	end

	def update
		@sample.update_attributes!(params[:sample])
		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample update failed."
		render :action => 'edit', :layout => 'subject'
	end

	def destroy
		@sample.destroy
		redirect_to study_subject_path(@study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and Sample.exists?(params[:id])
			@sample = Sample.find(params[:id])
			@study_subject = @sample.study_subject
##	in dev on brg, above fails so being more explicit, the below works
#			@study_subject = StudySubject.find(@sample.study_subject_id)
		else
			access_denied("Valid sample id required!", study_subjects_path)
		end
	end

	def search_order
		if params[:order] and
				%w( id received_by_ccls_at ).include?(
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
