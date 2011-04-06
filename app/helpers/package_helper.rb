module PackageHelper

	def tracks_for(package)
		s = "<div id='tracks'>&nbsp;\n"	#	leave the &nbsp; so never empty
		s << if package.tracks.empty?
			"<div class='row'>Sorry, but there don't appear to be any tracks for the package with tracking number: '#{package.tracking_number}'.</div>"
		else
			package.tracks.collect do |event|
				"<div class='track row'>\n" <<
				"<div class='name'>#{event.name}</div>\n" <<
				"<div class='location'>#{event.location}</div>\n" <<
				"<div class='time'>#{event.time}</div>\n" <<
				"</div><!-- class='track row' -->\n"
			end.join()
		end 
		s << "</div><!-- id='tracks' -->\n"
	end

end
