#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectRaces
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

	has_many :subject_races
	has_many :races, :through => :subject_races
#		doesn't seem to do anything
#	has_many :races, :through => :subject_races,
#		:primary_key => "code", :foreign_key => "race_code"

#	be advised. the custom association keys cause the following
#	race_ids will return an array of the foreign key, CODES in this case
#	race_ids= will accept an array of the IDS, NOT CODES

	accepts_nested_attributes_for :subject_races, 
		:allow_destroy => true,
		:reject_if => proc{|attributes| attributes['race_code'].blank? }

	def race_names
		subject_races.collect(&:to_s).join(', ')
	end

end	#	class_eval
end	#	included
end	#	StudySubjectRaces
