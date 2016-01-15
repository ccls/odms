class SubjectLanguage < ActiveRecord::Base

	belongs_to :study_subject
	belongs_to :language, :primary_key => "code", :foreign_key => "language_code"

#	be advised. the custom association keys cause the following
#	language_ids will return an array of the foreign key, CODES in this case
#	language_ids= will accept an array of the IDS, NOT CODES

	delegate :is_other?, :to => :language, :allow_nil => true, :prefix => true

	validates_presence_of :other_language, :if => :language_is_other?

	def to_s
		( language_is_other? ) ? other_language : language.to_s
	end

	after_save :reindex_study_subject!, :if => :changed?
	#	can be before as is just flagging it and not reindexing yet.
	before_destroy :reindex_study_subject!

protected

	def reindex_study_subject!
		logger.debug "Subject Language changed so reindexing study subject"
		study_subject.update_column(:needs_reindexed, true) if study_subject
	end

end
