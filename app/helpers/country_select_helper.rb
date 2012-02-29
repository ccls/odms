#
#	Imported the only important file from 
#		https://github.com/rails/country_select
#
#	I really don't like that it 'underscores' the country names in the 
#	option value?  In addition, it doesn't do it in the priority countries?
#	Because of all of this, nothing but the first values is ever selected!?
#
#	<option value="United States">United States</option>
#	<option value="" disabled="disabled">-------------</option>
#	<option value="afghanistan">Afghanistan</option>
#
#	And the values that is saved is the underscore'd values.
#	I want the actual value.  Seems like I'm alone in this.
#	Probably comment this fiasco out and do it my way.
#
# CountrySelect
#module ActionView
#  module Helpers
#    module FormOptionsHelper
#      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
#      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
#        InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
#      end
#      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
#      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
#      # that they will be listed above the rest of the (long) list.
#      #
#      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
#      def country_options_for_select(selected = nil, priority_countries = nil)
#        country_options = ""
#
#        if priority_countries
#          country_options += options_for_select(priority_countries, selected)
#          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
#          # prevents selected from being included twice in the HTML which causes
#          # some browsers to select the second selected option (not priority)
#          # which makes it harder to select an alternative priority country
#          selected=nil if priority_countries.include?(selected)
#        end
#
#        return country_options + options_for_select(COUNTRIES, selected)
#      end
#      # All the countries included in the country_options output.
#      COUNTRIES = ["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola",
#        "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria",
#        "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin",
#        "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil",
#        "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia",
#        "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China",
#        "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo",
#        "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba",
#        "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt",
#        "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)",
#        "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia",
#        "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea",
#        "Guinea-Bissau", "Guyana", "Haiti", "Heard and McDonald Islands", "Holy See (Vatican City State)",
#        "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic of", "Iraq",
#        "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya",
#        "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan",
#        "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya",
#        "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic Of",
#        "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique",
#        "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of",
#        "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru",
#        "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger",
#        "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau",
#        "Palestinian Territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines",
#        "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation",
#        "Rwanda", "Saint Barthelemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia",
#        "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
#        "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore",
#        "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa",
#        "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname",
#        "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic",
#        "Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste",
#        "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan",
#        "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom",
#        "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela",
#        "Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara",
#        "Yemen", "Zambia", "Zimbabwe"] unless const_defined?("COUNTRIES")
#    end
#    
#    class InstanceTag
#      def to_country_select_tag(priority_countries, options, html_options)
#        html_options = html_options.stringify_keys
#        add_default_name_and_id(html_options)
#        value = value(object)
#        content_tag("select",
#          add_options(
#            country_options_for_select(value, priority_countries),
#            options, value
#          ), html_options
#        )
#      end
#    end
#    
#    class FormBuilder
#      def country_select(method, priority_countries = nil, options = {}, html_options = {})
#        @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
#      end
#    end
#  end
#end

module CountrySelectHelper
	# All the countries included in the country_options output.
	COUNTRIES = [
		"United States", 
		"Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola",
		"Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria",
		"Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin",
		"Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil",
		"British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia",
		"Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China",
		"Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo",
		"Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba",
		"Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt",
		"El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)",
		"Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia",
		"French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea",
		"Guinea-Bissau", "Guyana", "Haiti", "Heard and McDonald Islands", "Holy See (Vatican City State)",
		"Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic of", "Iraq",
		"Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya",
		"Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan",
		"Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya",
		"Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic Of",
		"Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique",
		"Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of",
		"Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru",
		"Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger",
		"Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau",
		"Palestinian Territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines",
		"Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation",
		"Rwanda", "Saint Barthelemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia",
		"Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
		"Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore",
		"Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa",
		"South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname",
		"Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic",
		"Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste",
		"Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan",
		"Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom",
		
		"United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela",
		"Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara",
		"Yemen", "Zambia", "Zimbabwe"] unless const_defined?("COUNTRIES")

#	def country_select(method, priority_countries = nil, options = {}, html_options = {})
	def country_select(method, options = {}, html_options = {})
		#	not really using priority_countries so could just remove.
		#	object_name => addressing[address_attributes]
		#	method => country
		@template.select(@object_name, method, COUNTRIES,
			{:include_blank => true}.merge(objectify_options(options)), html_options)
	end
end
ActionView::Helpers::FormBuilder.send(:include, CountrySelectHelper )

__END__

#	This is untested.  Should put in the helpers dir, rename, then test.


	def country_select(method, priority_countries = nil, options = {}, html_options = {})
#				@template.country_select(@object_name, method, priority_countries, 
#					options.merge(:object => @object), html_options)
#	@object_name seems to be equal to object_name
#	object_name is probably a method that returns @object_name. (it is an attr_accessor)
#	objectify_options does options.merge(:object => @object)
#	whole problems seemed to be with the value() method
#	everybody is trying to be clever

		@template.select(@object_name, method, COUNTRIES,
			{:include_blank => true}.merge(objectify_options(options)), html_options)

#	don't know why I need objectify_options here
#	when none of my other selectors need it?
#	Without it, no country will be selected.?
#	Actually, seems more like all the others shouldn't work?  Confused.
#	Something to do with integer / string ?
#	I did try it with pairs of country names, but still same problem.
#	doesn't seem to have anything to do with my wrapped_
	end

