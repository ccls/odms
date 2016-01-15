class IcfMasterId < ActiveRecord::Base

	belongs_to :study_subject

#	probably shouldn't add validations as this won't be created by users. yet.

#	these are in the database, but were not in the app?
	validates_uniqueness_of :study_subject_id, :allow_nil => true
	validates_uniqueness_of :icf_master_id,    :allow_nil => true

	def to_s
		icf_master_id
	end

	scope :unused,      ->{ where( :study_subject_id => nil ) }

	#	NOTE still returns an array ( could add a .first but would break scope chainability or do I not really care about that here )
	scope :next_unused, ->{ unused.order('id asc').limit(1)	}

end
