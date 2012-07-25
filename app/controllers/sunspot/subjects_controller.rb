class Sunspot::SubjectsController < SunspotController
	skip_before_filter :login_required
#	before_filter :may_administrate_required
	def index
		@search = StudySubject.search do
			facet :subject_type
			facet :vital_status
			facet :case_control_type
#	date :reference_date
			facet :sex
#	date :dob
#	date :died_on
			facet :phase
#	integer :birth_year 
		end
	end
end
