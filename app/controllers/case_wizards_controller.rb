class CaseWizardsController < ApplicationController

	before_filter :may_create_subjects_required


	def new
		@subject = Subject.new
	end

	def create
		@subject = Subject.new(params[:subject])
#	if button clicked was "Next"
	#	if somehow this is valid
		render 'step_1'
	#	else
	#		render 'step_0'
#	otherwise assuming it was "Previous"
	#	calculate previous step

#		redirect_to subjects_path
	end

end
