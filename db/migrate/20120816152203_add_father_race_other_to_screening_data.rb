class AddFatherRaceOtherToScreeningData < ActiveRecord::Migration
  def change
    add_column :screening_data, :father_race_other, :string
  end
end
