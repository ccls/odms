# Currently just US states + DC
class State < ActiveRecord::Base

	acts_as_list
	default_scope :order => :position

	validates_presence_of   :code, :name, :fips_state_code, :fips_country_code
	validates_uniqueness_of :code, :name, :fips_state_code
	validates_length_of     :code, :name, :fips_state_code, :fips_country_code, 
		:maximum => 250, :allow_blank => true

	# Returns an array of state abbreviations.
	def self.abbreviations
		@@abbreviations ||= all.collect(&:code)
	end

end
