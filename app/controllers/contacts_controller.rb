class ContactsController < ApplicationController

	layout 'subject'

	before_filter :may_create_contacts_required,
		:only => [:new,:create]
	before_filter :may_read_contacts_required,
		:only => [:show,:index]
	before_filter :may_update_contacts_required,
		:only => [:edit,:update]
	before_filter :may_destroy_contacts_required,
		:only => :destroy

#	before_filter :valid_hx_study_subject_id_required
	before_filter :valid_study_subject_id_required

end
