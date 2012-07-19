module ObjectExtension	#	:nodoc:
#	def self.included(base)
#		base.instance_eval do
#
#	why would I include this in an include?
#	just leave it out and let it be included.
#
#			include InstanceMethods
#		end
#	end

#	module InstanceMethods
#
#		def to_boolean
##			return [true, 'true', 1, '1', 't'].include?(
#			return ![nil, false, 'false', 0, '0', 'f'].include?(
#				( self.is_a?(String) ) ? self.downcase : self )
#		end
#
#		#	looking for an explicit true
#		def true?
#			return [true, 'true', 1, '1', 't'].include?(
#				( self.is_a?(String) ) ? self.downcase : self )
#		end
#
#		#	looking for an explicit false (not nil)
#		def false?
#			return [false, 'false', 0, '0', 'f'].include?(
#				( self.is_a?(String) ) ? self.downcase : self )
#		end
#
#	end

	#	so nil stops complaining
	def chart_round
		self
	end

	def decode_county
	#	case county_code.to_s.slice(-2,2)
	#	what if '01' or '1' or 1 or '12341234123401'
		case sprintf('%02d',self.to_i).to_s.slice(-2,2).to_i
	#		when 0 then the given state code was all text
			when 1 then 'Alameda'
			when 2 then 'Alpine'
			when 3 then 'Amador'
			when 4 then 'Butte' 
			when 5 then 'Calaveras' 
			when 6 then 'Colusa' 
			when 7 then 'Contra Costa' 
			when 8 then 'Del Norte' 
			when 9 then 'El Dorado'
			when 10 then 'Fresno'
			when 11 then 'Glenn' 
			when 12 then 'Humboldt' 
			when 13 then 'Imperial' 
			when 14 then 'Inyo' 
			when 15 then 'Kern' 
			when 16 then 'Kings'
			when 17 then 'Lake' 
			when 18 then 'Lassen' 
			when 19 then 'Los Angeles' 
			when 20 then 'Madera' 
			when 21 then 'Marin' 
			when 22 then 'Mariposa' 
			when 23 then 'Mendocino' 
			when 24 then 'Merced' 
			when 25 then 'Modoc' 
			when 26 then 'Mono' 
			when 27 then 'Monterey' 
			when 28 then 'Napa' 
			when 29 then 'Nevada'
			when 30 then 'Orange'
			when 31 then 'Placer'
			when 32 then 'Plumas'
			when 33 then 'Riverside'
			when 34 then 'Sacramento'
			when 35 then 'San Benito'
			when 36 then 'San Bernardino'
			when 37 then 'San Diego' 
			when 38 then 'San Francisco' 
			when 39 then 'San Joaquin'
			when 40 then 'San Luis Obispo'
			when 41 then 'San Mateo'
			when 42 then 'Santa Barbara'
			when 43 then 'Santa Clara'
			when 44 then 'Santa Cruz'
			when 45 then 'Shasta'
			when 46 then 'Sierra'
			when 47 then 'Siskiyou'
			when 48 then 'Solano'
			when 49 then 'Sonoma'
			when 50 then 'Stanislaus'
			when 51 then 'Sutter'
			when 52 then 'Tehama'
			when 53 then 'Trinity'
			when 54 then 'Tulare'
			when 55 then 'Tuolumne'
			when 56 then 'Ventura'
			when 57 then 'Yolo'
			when 58 then 'Yuba'
			else self.to_s.squish.namerize
		end
	end
	
	#	what if state is only 1 char long?
	#	perhaps define array then convert code to_i
	#	then the value array[state_code.to_i] || state_code
	#	if is work of CA, to_i => 0 so array value is nil so returns CA
	#	time for some testing.
	#	same for county codes
	def decode_state_abbrev
	#	case state_code.to_s.slice(-2,2)
	#	what if '5' or '05' or '105' or 5 or 105 or 1234123405?
		case sprintf('%02d',self.to_i).to_s.slice(-2,2).to_i
	#		when 0 then the given state code was all text
			when 1 then 'AL'
			when 2 then 'AK'
			when 3 then 'AZ'
			when 4 then 'AR' 
			when 5 then 'CA' 
			when 6 then 'CO' 
			when 7 then 'CT' 
			when 8 then 'DE' 
			when 9 then 'DC'
			when 10 then 'FL'
			when 11 then 'GA' 
			when 12 then 'HI' 
			when 13 then 'ID' 
			when 14 then 'IL' 
			when 15 then 'IN' 
			when 16 then 'IA'
			when 17 then 'KS' 
			when 18 then 'KY' 
			when 19 then 'LA' 
			when 20 then 'ME' 
			when 21 then 'MD' 
			when 22 then 'MA' 
			when 23 then 'MI' 
			when 24 then 'MN' 
			when 25 then 'MS' 
			when 26 then 'MO' 
			when 27 then 'MT' 
			when 28 then 'NE' 
			when 29 then 'NV'
			when 30 then 'NH'
			when 31 then 'NJ'
			when 32 then 'NM'
			when 33 then 'NY'
			when 34 then 'NC'
			when 35 then 'ND'
			when 36 then 'OH'
			when 37 then 'OK' 
			when 38 then 'OR' 
			when 39 then 'PA'
			when 40 then 'RI'
			when 41 then 'SC'
			when 42 then 'SD'
			when 43 then 'TN'
			when 44 then 'TX'
			when 45 then 'UT'
			when 46 then 'VT'
			when 47 then 'VA'
			when 48 then 'WA'
			when 49 then 'WV'
			when 50 then 'WI'
			when 51 then 'WY'
			else self.to_s.squish.upcase
		end
	end

end
Object.send(:include, ObjectExtension)
