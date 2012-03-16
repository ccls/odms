require 'active_support'
require 'active_support/test_case'
#$LOAD_PATH.unshift(File.dirname(__FILE__))
module ActiveSupportExtension; end
require 'active_support_extension/test_case'
require 'active_support_extension/associations'
require 'active_support_extension/attributes'
require 'active_support_extension/pending'



Rails.backtrace_cleaner.add_silencer {|line|

# 48         send("_#{test_name}_without_verbosity")
	line =~ /active_support_extension\/test_case\.rb:48:/

} if defined? Rails
