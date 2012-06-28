class County < ActiveRecord::Base

	has_many :zip_codes

	validates_presence_of :name, :state_abbrev
	validates_length_of   :name,         :maximum => 250
	validates_length_of   :state_abbrev, :usc_code,
		:maximum => 2
	validates_length_of   :fips_code,    :maximum => 5, :allow_nil => true

	def to_s
		"#{name}, #{state_abbrev}"
	end

end
