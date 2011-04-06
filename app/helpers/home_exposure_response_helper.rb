module HomeExposureResponseHelper

#	def show_row(object_name,method,options={})
#		s = "<tr class='row'><td>#{method.to_s.titleize}:</td><td>"
#		value = if options[:value]
#			options[:value]
#		else
#			object = instance_variable_get("@#{object_name}")
#			value = object.send(method)
#			value = (value.to_s.blank?)?'&nbsp;':h(value.to_s)
#		end
#		s << value
#		s << "</td><td>"
#		s << answer_text(method,value)
#		s << "</td></tr>"
#	end
#
#	def answer_text(method,value)
#		return '' if value.blank? or value == '&nbsp;'
#		require 'question'
#		require 'answer'
#		q = Question.find_by_data_export_identifier(method)
#		if q.nil?
#			'question not found?'
#		else
#			a = q.answers.find_by_data_export_identifier(value)
##			if a.nil?
##				"answer not found with value #{value}"
##			else
##				a.text
##			end
##			(a.nil?) ? '&nbsp;' : a.text 
#			(a.nil?) ? '' : a.text 
#		end
#	end

end
