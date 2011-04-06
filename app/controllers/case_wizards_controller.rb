class CaseWizardsController < ApplicationController

	before_filter :may_create_subjects_required


	def new
	end

	def create
		redirect_to subjects_path
	end

end
