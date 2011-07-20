class ControlsController < ApplicationController

	before_filter :may_create_subjects_required
	before_filter :valid_id_required, :only => :show
	before_filter :case_subject_required, :only => :show

	def new
		unless params[:patid].blank?
#	search on subject_type == case or case_control_type == 'C' ?
#	This redundancy is becoming an issue.
			@subject = Subject.search(:patid => params[:patid], :types => 'case').first
		end
	end

	def show
	end

protected

	def valid_id_required
		if !params[:id].blank? and Subject.exists?(params[:id])
			@subject = Subject.find(params[:id])
		else
			access_denied("Valid subject id required!", new_control_path)
		end
	end

	def case_subject_required
		unless @subject.is_case?
			access_denied("Valid case subject required!", new_control_path)
		end
	end

end
