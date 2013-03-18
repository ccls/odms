#	because HashWithIndifferentAccess is just too long a name
HWIA = HashWithIndifferentAccess

require 'ccls_modifications/ruby'
require 'ccls_modifications/active_model'
require 'ccls_modifications/active_record'
require 'ccls_modifications/date_and_time_formats'
require 'ccls_modifications/do_not_escape_text_emails'



require 'hpricot'
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| 
	error_class = 'field_error'
	nodes = Hpricot(html_tag)
	nodes.each_child { |node| 
		node[:class] = node.classes.push(error_class).join(' ') unless !node.elem? || node[:type] == 'hidden' || node.classes.include?(error_class) 
	}
	nodes.to_html.html_safe
}
