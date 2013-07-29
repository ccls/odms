class Sunspot::AbstractsController < SunspotController

	def index
		search_sunspot_for Abstract
	end

end
__END__
