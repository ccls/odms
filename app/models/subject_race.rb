class SubjectRace < ActiveRecord::Base

	belongs_to :study_subject
	attr_protected :study_subject_id, :study_subject
	belongs_to :race

	delegate :is_other?, :to => :race, :allow_nil => true, :prefix => true
	delegate :is_mixed?, :to => :race, :allow_nil => true, :prefix => true

	validates_presence_of :other_race, :if => :race_is_other?
	validates_presence_of :mixed_race, :if => :race_is_mixed?

	alias_attribute :mixed_race, :other_race

	def to_s
		( race_is_other? ) ? other_race : ( race_is_mixed? ? mixed_race : race.to_s )
	end

	after_save :reindex_study_subject!

protected

	def reindex_study_subject!
		study_subject.index if study_subject
	end

end
