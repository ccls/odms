class ZipCode < ActiveRecord::Base

	belongs_to :county

	validations_from_yaml_file

#	acts_like_a_hash(:key => :zip_code)
#	Almost, but length validation would fail.
#	And what would the value field be?

	#	Treats the class a bit like a Hash and
	#	searches for a record with a matching code.
	def self.[](zip_code)
		where(:zip_code => zip_code.to_s).first
	end

	def to_s
		"#{city}, #{state} #{zip_code}"
	end

end
