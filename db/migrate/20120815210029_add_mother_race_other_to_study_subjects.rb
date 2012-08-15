class AddMotherRaceOtherToStudySubjects < ActiveRecord::Migration
  def change
    add_column :study_subjects, :mother_race_other, :string
  end
end
