class StudySubjectsController < ApplicationController

	before_filter :may_create_study_subjects_required,
		:only => [:new,:create]
	before_filter :may_read_study_subjects_required, 
		:only => [:show,:index,:dashboard,:followup,:reports,:by]
	before_filter :may_update_study_subjects_required,
		:only => [:edit,:update]
	before_filter :may_destroy_study_subjects_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:next,:prev]	#,:first,:last]


	def index
		record_or_recall_sort_order
		conditions = [[],{}]
		#	Table names are not necessary if field is unambiguous.
		%w( subjectid childid patid hospital_no icf_master_id first_name ).each do |attr|
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
		if params[:registrar_no].present?
			conditions[0] << "( do_not_use_state_id_no LIKE :registrar_no OR do_not_use_state_registrar_no LIKE :registrar_no OR do_not_use_local_registrar_no LIKE :registrar_no )"
			conditions[1][:registrar_no] = "%#{params[:registrar_no]}%"
		end
		if params[:subject_type].present?
			conditions[0] << "( subject_type = :subject_type )"
			conditions[1][:subject_type] = params[:subject_type]
		end
		if params[:phase].present?
			conditions[0] << "( phase = :phase )"
			conditions[1][:phase] = params[:phase].to_i
		end

		#	LEFT JOIN because not all subjects will have a patient.
		#	otherwise, we'd effectively only search cases
		@study_subjects = StudySubject.order(search_order)
			.left_join_patient
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
#			redirect_to study_subjects_path(params)
			#	rails 4.2.0 is deprecating string keys
			redirect_to study_subjects_path(params.symbolize_keys)
		end
	end

	def edit
	end

	def show
	end

	def update
		@study_subject.update_attributes!(study_subject_params)
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
		if params[:by_id].present? && (
				StudySubject.with_icf_master_id(params[:by_id]).exists? ||
				StudySubject.with_subjectid(params[:by_id]).exists? )
#				StudySubject.where( :icf_master_id => params[:by_id]).exists? ||
#				StudySubject.where( :subjectid => params[:by_id]).exists? )
			study_subject = StudySubject.with_icf_master_id(params[:by_id]).first ||
				StudySubject.with_subjectid(params[:by_id]).first
			redirect_to url_for_subject(study_subject)
		else
			flash[:warn] = "Valid icf_master_id or subjectid required."
			redirect_to_referrer_or_default( root_path )
		end
	end

	def first
		first_study_subject = StudySubject.order('id asc').limit(1).first
		redirect_to url_for_subject(first_study_subject)
	end

	def next
		next_study_subject = StudySubject
			.where(StudySubject.arel_table[:id].gt(@study_subject.id))
			.order('id asc').limit(1).first
		if next_study_subject.nil?
			flash[:warn] = "Rolled over"
			next_study_subject = StudySubject.order('id asc').first
		end
		redirect_to url_for_subject(next_study_subject)
	end
#
#	For some reason, redirect_to study_subject_path(nil) 
#	actually redirects to the current study_subject#show
#	which is nice, but I don't understand why.
#
#	This hain't true no mo.
#
	def prev
		prev_study_subject = StudySubject
			.where(StudySubject.arel_table[:id].lt(@study_subject.id))
			.order('id desc').limit(1).first
		if prev_study_subject.nil?
			flash[:warn] = "Rolled over"
			prev_study_subject = StudySubject.order('id desc').first
		end
		redirect_to url_for_subject(prev_study_subject)
	end

	def last
		last_study_subject = StudySubject.order('id desc').limit(1).first
		redirect_to url_for_subject(last_study_subject)
	end

protected

	def url_for_subject(subject)
		referrer_params = Odms::Application.routes.recognize_path(request.referrer||'') || {}
		#referrer_params returns symbolized keys
		case
			when referrer_params.keys.include?(:study_subject_id)
				if referrer_params.delete(:id)
					referrer_params[:action] = 'index'
				end
				referrer_params[:study_subject_id] = subject.id
				url_for(referrer_params)
			else study_subject_path(subject)
		end
	end

	def valid_id_required
		if !params[:id].blank? and StudySubject.exists?(params[:id])
			@study_subject = StudySubject.find(params[:id])
		else
			access_denied("Valid study_subject id required!", study_subjects_path)
		end
	end

	def search_order
		if params[:order] and
#				%w( phase icf_master_id studyid last_name reference_date ).include?(params[:order].downcase)
#	20150211 - icf_master_id replaced by subjectid
#	20150211 - why was phase here? 
				%w( subjectid studyid last_name reference_date ).include?(params[:order].downcase)
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

	def study_subject_params
		params.require(:study_subject).permit( :do_not_contact ,
			:first_name, :middle_name, :last_name, :dob, :sex,
			:do_not_use_state_registrar_no, :do_not_use_local_registrar_no, :reference_date, :vital_status,
			:mother_first_name, :mother_middle_name, :mother_last_name, :mother_maiden_name,
			:father_first_name, :father_middle_name, :father_last_name,
			:guardian_first_name, :guardian_middle_name, :guardian_last_name,
			:guardian_relationship, :other_guardian_relationship,
			{ subject_races_attributes: 
				[:id, :_destroy, :race_code, :other_race, :mixed_race] }
			)
	end

end
