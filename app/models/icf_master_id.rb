class IcfMasterId < ActiveRecord::Base

#+------------------+------------+------+-----+---------+----------------+
#| Field            | Type       | Null | Key | Default | Extra          |
#+------------------+------------+------+-----+---------+----------------+
#| id               | int(11)    | NO   | PRI | NULL    | auto_increment |
#| icf_master_id    | varchar(9) | YES  | UNI | NULL    |                |
#| assigned_on      | date       | YES  |     | NULL    |                |
#| created_at       | datetime   | YES  |     | NULL    |                |
#| updated_at       | datetime   | YES  |     | NULL    |                |
#| study_subject_id | int(11)    | YES  | UNI | NULL    |                |
#+------------------+------------+------+-----+---------+----------------+

	belongs_to :study_subject
  attr_protected( :study_subject_id, :study_subject )

#	probably shouldn't add validations as this won't be created by users. yet.

	def to_s
		icf_master_id
	end

	scope :unused,      where('study_subject_id IS NULL')
	scope :next_unused, unused.limit(1)	#	NOTE still returns an array

end
