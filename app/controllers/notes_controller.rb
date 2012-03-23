class NotesController < ApplicationController

	layout 'subject'

	before_filter :may_create_notes_required,
		:only => [:new,:create]
	before_filter :may_read_notes_required,
		:only => [:show,:index]
	before_filter :may_update_notes_required,
		:only => [:edit,:update]
	before_filter :may_destroy_notes_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:index]

end
