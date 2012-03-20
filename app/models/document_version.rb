class DocumentVersion < ActiveRecord::Base

	acts_as_list
	default_scope :order => 'position, title ASC'

	belongs_to :document_type
	belongs_to :language
	has_many :enrollments

	validates_presence_of :document_type_id
	validates_presence_of :document_type, :if => :document_type_id

	validates_length_of   :title, :description, :indicator,
		:maximum => 250, :allow_blank => true

	validates_complete_date_for :began_use_on, :allow_nil => true
	validates_complete_date_for :ended_use_on, :allow_nil => true

	#	Return title
	def to_s
		title
	end

#	scope :type1, :conditions => { :document_type_id => 1 }
	scope :type1, where(:document_type_id => 1)

end
