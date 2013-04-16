class AddSubjectidToBirthDatum < ActiveRecord::Migration
	def change
		add_column :birth_data, :subjectid, :string, :limit => 6
	end
end
