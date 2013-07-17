class ShortenAbstractsCbf7OldFrom255To155 < ActiveRecord::Migration
	def up
		change_column :abstracts, :cbf7_old, :string, :limit => 155
	end

	def down
		change_column :abstracts, :cbf7_old, :string
	end
end
