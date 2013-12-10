class Sunspot::Rails::Server
	# http://opensoul.org/blog/archives/2010/04/07/cucumber-and-sunspot/
	def running?
		begin
			open("http://localhost:#{self.port}/")
			true
		rescue Errno::ECONNREFUSED => e
			# server not running yet
			false
		rescue OpenURI::HTTPError
			# getting a response so the server is running
			true
		end
	end
end
