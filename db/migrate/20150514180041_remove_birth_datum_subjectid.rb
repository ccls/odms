class RemoveBirthDatumSubjectid < ActiveRecord::Migration
  def self.up
		remove_column :birth_data, :subjectid
  end
  def self.down
		add_column :birth_data, :subjectid, :string, :limit => 6
  end
end
