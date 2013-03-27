class StudySubject::ContactsController < StudySubjectController

	before_filter :may_create_contacts_required,
		:only => [:new,:create]
	before_filter :may_read_contacts_required,
		:only => [:show,:index]
	before_filter :may_update_contacts_required,
		:only => [:edit,:update]
	before_filter :may_destroy_contacts_required,
		:only => :destroy

end
