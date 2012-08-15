class AddFatherRaceOtherToStudySubjects < ActiveRecord::Migration
  def change
    add_column :study_subjects, :father_race_other, :string
  end
end
