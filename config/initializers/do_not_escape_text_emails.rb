#
#
#	All this for the ":escape" line as I want my text emails
#	to have the apostophe/single-quote rather than the html
#	code "&#x27;"
#
#	This has been discussed for sometime but rails still does
#	not include this patch.
#
#	actionpack-3.2.9/lib/action_view/template/handlers/erb.rb
#
#	http://stackoverflow.com/questions/11756304/rails-escapes-html-in-my-plain-text-mails
#
#
module ActionView
  class Template
    module Handlers
      class ERB
        def call(template)
#          if template.source.encoding_aware?	#	rails 3
          if template.source.respond_to?(:encode)	#	rails 4
            # First, convert to BINARY, so in case the encoding is
            # wrong, we can still find an encoding tag
            # (<%# encoding %>) inside the String using a regular
            # expression
            template_source = template.source.dup.force_encoding("BINARY")

            erb = template_source.gsub(ENCODING_TAG, '')
            encoding = $2

            erb.force_encoding valid_encoding(template.source.dup, encoding)

            # Always make sure we return a String in the default_internal
            erb.encode!
          else
            erb = template.source.dup
          end

          self.class.erb_implementation.new(
            erb,
            :trim => (self.class.erb_trim_mode == "-"),
            :escape => template.identifier =~ /\.text/ # only escape HTML templates
          ).src
        end
      end
    end
  end
end
