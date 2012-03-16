class ApiController < ApplicationController

	#	MUST skip this filter explicitly on each controller

#	#	Skip the calnet authentication
#	#	This means no current user and therefore no roles.
#	skip_before_filter :login_required

	#	Everything relies on this ...
	before_filter :authenticate

protected

	def authenticate
#		config = YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/api.yml")).result)
		config = YAML::load(ERB.new(IO.read("#{Rails.root}/config/api.yml")).result)
		authenticate_or_request_with_http_basic do |username, password|
				username == config[:user] && password == config[:password]
		end
	end

end

__END__

# this works (when ssl is ignored)

wget http://dev.sph.berkeley.edu:3000/api/study_subjects --user=... --password=...

curl http://dev.sph.berkeley.edu:3000/api/study_subjects.xml --user ...:...

Can't seem to make a direct request to https ....

Tue Feb 14 11:55:50 -0800 2012: HTTP parse error, malformed request (169.229.196.225): #<Mongrel::HttpParserError: Invalid HTTP format, parsing fails.>
Tue Feb 14 11:55:50 -0800 2012: REQUEST DATA: "\026\003\001\000?\000?O:\274FBx[\003;<Q}CV\236\225J\"\2074\271\234(\244\eD\274\227\025?!?\000\000\\?? .....

But adding -L  will follow the redirect.
Adding -k tells curl to ignore the insecure self-signed certificat.

curl http://dev.sph.berkeley.edu:3000/api/study_subjects.xml -L -k --user ...:...
