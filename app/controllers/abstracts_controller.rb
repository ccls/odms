#	Just a RESTful abstract controller, without new or create
class AbstractsController < ApplicationController

	before_filter :may_read_abstracts_required,
		:only => [:show,:index]

	def index
		@abstracts = Abstract.order(:study_subject_id)

		if params[:merged].to_s == 'true'
			@abstracts = @abstracts.merged 
		elsif params[:to_merge].to_s == 'true'
			@abstracts = @abstracts.joins(:study_subject).where(:'study_subjects.abstracts_count' => 2)
		end
	end

end
