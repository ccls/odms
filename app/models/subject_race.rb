class SubjectRace < ActiveRecord::Base

	belongs_to :study_subject
#	attr_protected :study_subject_id, :study_subject
	belongs_to :race, :primary_key => "code", :foreign_key => "race_code"

#	be advised. the custom association keys cause the following
#	race_ids will return an array of the foreign key, CODES in this case
#	race_ids= will accept an array of the IDS, NOT CODES

	delegate :is_other?, :to => :race, :allow_nil => true, :prefix => true
	delegate :is_mixed?, :to => :race, :allow_nil => true, :prefix => true

	validates_presence_of :other_race, :if => :race_is_other?
	validates_presence_of :mixed_race, :if => :race_is_mixed?

	alias_attribute :mixed_race, :other_race

	def to_s
		( race_is_other? ) ? other_race : ( race_is_mixed? ? mixed_race : race.to_s )
	end

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Subject Race changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
	end

end
