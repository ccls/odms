class StudiesController < ApplicationController

	before_filter :may_read_study_subjects_required, 
		:only => [:dashboard]

end
