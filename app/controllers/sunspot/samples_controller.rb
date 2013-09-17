class Sunspot::SamplesController < SunspotController

	def index
		search_sunspot_for Sample
	end

end
__END__
