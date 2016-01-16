require 'mail'
#module MailMessageExtension
class Mail::Message

	#	Rails 4.2.0 deprecates deliver for deliver_now
	#	To allow possible downgrading, just create an alias ...
	v = Rails.version.split('.')
	#=> ["4", "1", "14"]
	if( "#{v[0]}.#{v[1]}".to_f < 4.2 )
		# pre rails 4.2.0
		alias :deliver_now :deliver
		#alias :asdf :to_s 
	end

end
#Mail::Message.send( :include, MailMessageExtension )
