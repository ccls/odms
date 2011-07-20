class ControlsController < ApplicationController

	before_filter :may_create_subjects_required

	def show
#	if params[:patid] .... find a case matching patid
		unless params[:patid].blank?
#	search on subject_type == case or case_control_type == 'C' ?
			@subject = Subject.search(:patid => params[:patid], :types => 'case').first
#			@subject = Subject.search(:patid => params[:patid]).first
		end
	end

end
