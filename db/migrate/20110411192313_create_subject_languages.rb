class CreateSubjectLanguages < ActiveRecord::Migration
	def self.up
		create_table :subject_languages do |t|
			t.integer :study_subject_id
			t.integer :language_id
#			t.string  :other
			t.string  :other_language
			t.timestamps
		end
	end

	def self.down
		drop_table :subject_languages
	end
end
