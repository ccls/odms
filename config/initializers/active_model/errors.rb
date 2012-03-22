module ActiveModel
class Errors
#
## File activemodel/lib/active_model/errors.rb, line 285
#def full_message(attribute, message)
#  return message if attribute == :base
#  attr_name = attribute.to_s.gsub('.', '_').humanize
#  attr_name = @base.class.human_attribute_name(attribute, :default => attr_name)
#puts @base.class
#puts attribute
#puts attr_name
#puts message
#  I18n.t(:"errors.format", {
#    :default   => "%{attribute} %{message}",
#    :attribute => attr_name,
#    :message   => message
#  })
#end
#
end
end
__END__
>> p.errors.full_messages
Patient
admit_date
Admit date
can't be blank

Patient
organization_id
Treating institution
can't be blank

Patient
diagnosis_id
Diagnosis
can't be blank

Patient
hospital_no
Hospital record number
can't be blank

=> ["Admit date can't be blank", "Treating institution can't be blank", "Diagnosis can't be blank", "Hospital record number can't be blank"]



again, the missing type is pissing me off.
There is nothing here that I can use to unambiguously 
single out a model, attribute and error and select a format


Dropping the error :type was a really bad idea. Thanks.


This seems to be an all-or-nothing setup.

I can set the default to just "message" and then place the attribute
at the beginning of every message.  Man, I really want my error type back.


For the moment, the only way I'll be able to do this is with
by redefining ALL of the message formats


