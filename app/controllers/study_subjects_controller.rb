class StudySubjectsController < ApplicationController

	before_filter :may_create_study_subjects_required,
		:only => [:new,:create]
	before_filter :may_read_study_subjects_required, 
		:only => [:show,:index,:dashboard,:find,:followup,:reports,:by]
	before_filter :may_update_study_subjects_required,
		:only => [:edit,:update]
	before_filter :may_destroy_study_subjects_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:next,:prev,:first,:last]


	def find
		record_or_recall_sort_order
		conditions = [[],{}]
		#	Table names are not necessary if field is unambiguous.
		%w( childid patid hospital_no icf_master_id first_name ).each do |attr|
			if params[attr] and !params[attr].blank?
				conditions[0] << "( #{attr} LIKE :#{attr} )"
				conditions[1][attr.to_sym] = "%#{params[attr]}%"
			end
		end
		validate_valid_date_range_for(:dob,conditions)
		if params[:last_name] and !params[:last_name].blank?
			conditions[0] << "( last_name LIKE :last_name OR maiden_name LIKE :last_name )"
			conditions[1][:last_name] = "%#{params[:last_name]}%"
		end
		if params[:registrar_no] and !params[:registrar_no].blank?
			conditions[0] << "( state_id_no LIKE :registrar_no OR state_registrar_no LIKE :registrar_no OR local_registrar_no LIKE :registrar_no )"
			conditions[1][:registrar_no] = "%#{params[:registrar_no]}%"
		end
		if params[:subject_type_id] and !params[:subject_type_id].blank?
			conditions[0] << "( subject_type_id = :subject_type_id )"
			conditions[1][:subject_type_id] = params[:subject_type_id].to_i
		end
		if params[:phase] and !params[:phase].blank?
			conditions[0] << "( phase = :phase )"
			conditions[1][:phase] = params[:phase].to_i
		end
		#	LEFT JOIN because not all subjects will have a patient.
		#	otherwise, we'd effectively only search cases
#			).joins('LEFT JOIN patients ON study_subjects.id = patients.study_subject_id'
		@study_subjects = StudySubject.order(search_order)
			.includes(:patient,:subject_type).join_patients()
			.where(conditions[0].join(valid_find_operator), conditions[1])
			.paginate(
				:per_page => params[:per_page]||25,
				:page     => valid_find_page
			)

		#
		#	As it is possible to set a page and then add a filter,
		#	one could have samples but be on to high of a page to see them.
		#	length would return 0, but count is the total database count
		#
		if @study_subjects.length == 0 and @study_subjects.count > 0
			flash[:warn] = "Page number was too high, so set to highest valid page number."
			#	Doesn't change the url string, but does work.
			params[:page] = @study_subjects.total_pages
			#	It seems excessive to redirect and do it all again.
			#	Nevertheless ...
			redirect_to find_study_subjects_path(params)
		end
	end

	#	there is no longer a link to this action, nevertheless
	def index
		record_or_recall_sort_order
		if params[:commit] && params[:commit] == 'download'
			#	Manually set to the csv format for rendering
			request.format = :csv
			params[:paginate] = false
		end
		flash.now[:notice] = "This page isn't used at the moment."
		@study_subjects = StudySubject.paginate(
				:per_page => params[:per_page]||25,
				:page     => valid_find_page
			)
		#	respond_to blocks are based on 'request.format', not params[:format]
		respond_to do |format|
			format.html
			format.csv { 
				headers["Content-Disposition"] = "attachment; " <<
					"filename=study_subjects_#{Time.now.to_s(:filename)}.csv" 
			}
		end
	end

	def edit
		render :layout => 'subject'
	end

	def show
		render :layout => 'subject'
	end

#	def new
#		@study_subject = StudySubject.new
#	end
#
#	def destroy
#		@study_subject.destroy
#		redirect_to study_subject_path
#	end
#
#	def create
#		@study_subject = StudySubject.new(params[:study_subject])
#		@study_subject.save!
#		flash[:notice] = 'Success!'
#		redirect_to @study_subject
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem creating the study_subject"
#		render :action => "new"
#	end 

	def update
		@study_subject.update_attributes!(params[:study_subject])
		flash[:notice] = 'Success!'
		redirect_to study_subject_path(@study_subject)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the study_subject"
		render :action => "edit"
	end

#
#	The following actions are all "redirectors"
#

	def by
		if params[:icf_master_id].present? && StudySubject.where(
			:icf_master_id => params[:icf_master_id]).exists?
			redirect_to study_subject_path( StudySubject.where(
			:icf_master_id => params[:icf_master_id]).first )
		else
			flash[:warn] = "Valid icf_master_id required."
			redirect_to_referer_or_default( root_path )
		end
	end

#
#
#
	def first
		first_study_subject = StudySubject.order('id asc').limit(1).first
		redirect_to study_subject_path(first_study_subject)
#		redirect_to url_for( (params[:c]||{}).update(:study_subject_id => first_study_subject.id) )
#			:controller => params[:c][:controller],
#			:action => params[:c][:action],
#			:study_subject_id => first_study_subject.id )
	end

	def next
#		if params[:study_subject_id]
#			params[:study_subject_id] = params[:study_subject_id].to_i + 1
#		end
#		params.delete(:action)
#		redirect_to params
#		next_study_subject = StudySubject.where('id > ?',@study_subject.id)
		next_study_subject = StudySubject
			.where(StudySubject.arel_table[:id].gt(@study_subject.id))
			.order('id asc').limit(1).first
		redirect_to study_subject_path(next_study_subject)

#		next_study_subject = StudySubject.where('id > ?',@study_subject.id)
#			.order('id asc').limit(1).first || StudySubject.order('id asc').limit(1).first
#		n = params[:c].dup
#		if n.has_key?('study_subject_id')
#			#	this is a nice, nested, restful route
#			n['study_subject_id'] = next_study_subject.id 
#		else
#			#	this is a pain.  probably in a show for address, phone, event, ...
#			n.delete('id')
#			n['action'] = 'index'
#			n['study_subject_id'] = next_study_subject.id
#			#	seems to work surprisingly
#
##	what about study_subject_path(@study_subject)
#
#		end
#		redirect_to url_for(n)
	end
#
#	For some reason, redirect_to study_subject_path(nil) 
#	actually redirects to the current study_subject#show
#	which is nice, but I don't understand why.
#
	def prev
#		prev_study_subject = StudySubject.where('id < ?',@study_subject.id)
		prev_study_subject = StudySubject
			.where(StudySubject.arel_table[:id].lt(@study_subject.id))
			.order('id desc').limit(1).first
		redirect_to study_subject_path(prev_study_subject)
	end

	def last
		last_study_subject = StudySubject.order('id desc').limit(1).first
		redirect_to study_subject_path(last_study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", study_subjects_path)
		end
	end

	def search_order
		if params[:order] and
				%w( phase icf_master_id studyid last_name reference_date ).include?(params[:order].downcase)
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
