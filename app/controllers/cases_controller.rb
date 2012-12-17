class CasesController < ApplicationController

	class Under15InconsistencyFound < StandardError; end

	before_filter :may_create_study_subjects_required,
		:only => [:index]
#		:only => [:new,:create,:show,:index]
#		:only => [:new,:create]
#	before_filter :may_read_study_subjects_required,
#		:only => [:show,:index]
#	before_filter :may_update_study_subjects_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_study_subjects_required,
#		:only => :destroy
#
#	before_filter :valid_id_required,
#		:only => [:edit,:update,:show,:destroy]
#	before_filter :case_study_subject_required,
#		:only => [:edit,:update,:show,:destroy]

	############################################################
	#
	#	The beginning of new control selection
	#
	def index
		unless params[:q].blank?
			q = params[:q].squish
			@study_subject = if( q.length <= 4 )
				patid = sprintf("%04d",q.to_i)
				StudySubject.find_case_by_patid(patid)
			else
				StudySubject.find_case_by_icf_master_id(q)
			end
			flash.now[:error] = "No case study_subject found with given" <<
				":#{params[:q]}" unless @study_subject
		end
	end

end
