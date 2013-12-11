class Sunspot::SubjectsController < SunspotController

	def index
		search_sunspot_for StudySubject
	end

end
__END__
