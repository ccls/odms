class StudySubject::ContactsController < StudySubjectController

	before_filter :may_read_contacts_required,
		:only => [:index]

end
