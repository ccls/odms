class ChangeAbstractsCytogenIsHyperdiploidyFromStringToInt < ActiveRecord::Migration
	def up
		change_column :abstracts, :cytogen_is_hyperdiploidy, :integer, :limit => 2
	end

	def down
		change_column :abstracts, :cytogen_is_hyperdiploidy, :string, :limit => 5
	end
end
