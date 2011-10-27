class StudySubjectsController < ApplicationController

	before_filter :may_create_study_subjects_required,
		:only => [:new,:create]
	before_filter :may_read_study_subjects_required, 
		:only => [:show,:index,:dashboard,:find,:followup,:reports]
	before_filter :may_update_study_subjects_required,
		:only => [:edit,:update]
	before_filter :may_destroy_study_subjects_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def find
#	If this gets much more complex, we may want to consider using something like solr.
		record_or_recall_sort_order
		operator = ' OR '
		if params[:operator] and !params[:operator].blank? and 
				['AND','OR'].include?(params[:operator])
			operator = " #{params[:operator]} "
		end
		conditions = [[],[]]
		if params[:first_name] and !params[:first_name].blank?
			conditions[0] << "( piis.first_name LIKE ? )"
			conditions[1] << "%#{params[:first_name]}%"
		end
		if params[:last_name] and !params[:last_name].blank?
			conditions[0] << "( piis.last_name LIKE ? OR piis.maiden_name LIKE ? )"
			conditions[1] << "%#{params[:last_name]}%"
			conditions[1] << "%#{params[:last_name]}%"
		end
		%w( childid patid hospital_no icf_master_id ).each do |attr|
			if params[attr] and !params[attr].blank?
				conditions[0] << "( identifiers.#{attr} LIKE ? )"
				conditions[1] << "%#{params[attr]}%"
			end
		end
		if params[:dob] and !params[:dob].blank?
#			conditions[0] << "( identifiers.icf_master_id LIKE ? )"
#			conditions[1] << "%#{params[:dob]}%"
		end
		if params[:registrar_no] and !params[:registrar_no].blank?
			conditions[0] << "( identifiers.state_id_no LIKE ? OR identifiers.state_registrar_no LIKE ? OR identifiers.local_registrar_no LIKE ? )"
			conditions[1] << "%#{params[:registrar_no]}%"
			conditions[1] << "%#{params[:registrar_no]}%"
			conditions[1] << "%#{params[:registrar_no]}%"
		end
		@study_subjects = StudySubject.paginate(
			:include => [:pii,:patient,:identifier],
			:joins => [
				'LEFT JOIN piis ON study_subjects.id = piis.study_subject_id',
				'LEFT JOIN patients ON study_subjects.id = patients.study_subject_id',
				'LEFT JOIN identifiers ON study_subjects.id = identifiers.study_subject_id',
			],
			:conditions => [ conditions[0].join(operator),
					*(conditions[1].flatten) ],
			:per_page => params[:per_page]||25,
			:page     => params[:page]||1
		)
	end

	#	there is no longer a link to this action, nevertheless
	def index
		record_or_recall_sort_order
		if params[:commit] && params[:commit] == 'download'
			params[:paginate] = false
		end
#	TODO stop using StudySubject.search, but here it may be needed
		@study_subjects = StudySubject.search(params)
		if params[:commit] && params[:commit] == 'download'
			params[:format] = 'csv'
			headers["Content-disposition"] = "attachment; " <<
				"filename=study_subjects_#{Time.now.to_s(:filename)}.csv" 
		end
	end

	def show
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

protected

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", study_subjects_path)
		end
	end

end
