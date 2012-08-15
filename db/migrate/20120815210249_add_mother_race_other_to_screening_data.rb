class AddMotherRaceOtherToScreeningData < ActiveRecord::Migration
  def change
    add_column :screening_data, :mother_race_other, :string
  end
end
