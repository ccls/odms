#	Just a RESTful abstract controller, without new or create
class AbstractsController < ApplicationController

	before_filter :may_read_abstracts_required

	def index
		@abstracts = Abstract.order(:study_subject_id)
	end

	def merged
		@abstracts = Abstract.order(:study_subject_id).merged
		render :action => :index
	end

	def to_merge
		@abstracts = Abstract.order(:study_subject_id).mergable
		render :action => :index
	end

end
