class CreateSubjectLanguages < ActiveRecord::Migration
	def self.up
		create_table :subject_languages do |t|
			t.integer :study_subject_id
			t.integer :language_code
			t.string  :other_language
			t.timestamps
		end
		add_index :subject_languages, :study_subject_id
	end

	def self.down
		drop_table :subject_languages
	end
end
