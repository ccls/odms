class CasesController < ApplicationController

	before_filter :may_create_study_subjects_required

	def new
	end

#	def create
#		case params[:commit]
#			when 'waivered'
#				redirect_to new_waivered_path
#			when 'nonwaivered'
#				redirect_to new_nonwaivered_path
#			else
#				flash[:error] = "Commit must be waivered or nonwaivered, not #{params[:commit]}"
#				redirect_to root_path
#		end
#	end

end
