class ChangeAbstractsBlastsArePresentFromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :blasts_are_present, :integer
	end

	def down
		change_column :abstracts, :blasts_are_present, :string
	end
end
