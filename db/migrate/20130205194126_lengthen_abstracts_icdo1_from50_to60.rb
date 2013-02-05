class LengthenAbstractsIcdo1From50To60 < ActiveRecord::Migration
	def up
		change_column :abstracts, :icdo1, :string, :limit => 60
	end

	def down
		change_column :abstracts, :icdo1, :string, :limit => 50
	end
end
