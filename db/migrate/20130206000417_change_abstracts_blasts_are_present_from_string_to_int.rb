class ChangeAbstractsBlastsArePresentFromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :blasts_are_present, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :blasts_are_present, :string
	end
end
