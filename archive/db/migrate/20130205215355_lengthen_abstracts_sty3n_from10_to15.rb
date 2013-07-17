class LengthenAbstractsSty3nFrom10To15 < ActiveRecord::Migration
	def up
		change_column :abstracts, :sty3n, :string, :limit => 15
	end

	def down
		change_column :abstracts, :sty3n, :string, :limit => 10
	end
end
