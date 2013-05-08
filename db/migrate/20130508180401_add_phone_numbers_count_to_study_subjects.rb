class AddPhoneNumbersCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :phone_numbers_count, :integer, :default => 0
	end
end
